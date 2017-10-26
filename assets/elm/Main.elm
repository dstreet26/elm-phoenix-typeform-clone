module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import DynamicStyle exposing (..)
import Markdown exposing (toHtml)
import Ports.SmoothScroll exposing (scrollTo)
import List.Zipper as Zipper exposing (..)
import Dom exposing (..)
import Task exposing (..)
import Debug exposing (log)
import Keyboard.Extra exposing (Key(..))
import Json.Decode as JD
import Widgets.FilterableDropdown as FD
import Colors exposing (ColorScheme)
import Widgets.Questionnaire exposing (..)
import TestData.DemoData exposing (demoData, emptyQuestion)
import Regex exposing (..)


main : Program (Maybe Flags) Model Msg
main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Flags =
    { user : String
    , token : String
    }


type alias Model =
    { questionnaire : Questionnaire
    , isFormActivated : Bool
    , numQuestionsAnswered : Int
    , totalQuestions : Int
    , footerButtonUpEnabled : Bool
    , footerButtonDownEnabled : Bool
    , pressedKeys : List Key
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map KeyboardMsg Keyboard.Extra.subscriptions


emptyModel : Model
emptyModel =
    { questionnaire = demoData
    , isFormActivated = False
    , numQuestionsAnswered = 0
    , totalQuestions = 0
    , footerButtonUpEnabled = False
    , footerButtonDownEnabled = False
    , pressedKeys = []
    }


emptyQuestionError1 : Question
emptyQuestionError1 =
    { questionNumber = 1
    , questionType = Submit { buttonText = "N/A" }
    , answer = ""
    , isAnswered = False
    , questionText = "Problem with question dependencies"
    , dependsOn = []
    , isFocused = False
    }



--Placeholder flags


init : Maybe Flags -> ( Model, Cmd Msg )
init flags =
    emptyModel ! []


type Msg
    = NoOp
    | AnswerQuestionWithId Int
    | AnswerQuestion
    | FooterNext
    | FooterPrevious
    | ActivateForm
    | KeyboardMsg Keyboard.Extra.Msg
    | TextQuestionInputChanged Question String
    | TextQuestionClicked Question
    | FDMsg FD.Msg
    | InputFocusResult (Result Dom.Error ())


type Direction
    = Up
    | Down


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TextQuestionInputChanged question newContent ->
            let
                questionnaire =
                    model.questionnaire

                --If we're not focused on the question that was just changed, we need to change focus
                newModel =
                    model
                        |> focusModelOnId question.questionNumber
                        |> updateCurrent newContent
            in
                ( newModel, scrollToCurrent newModel )

        TextQuestionClicked question ->
            let
                questionnaire =
                    model.questionnaire

                --If we're not focused on the question that was just changed, we need to change focus
                newModel =
                    model
                        |> focusModelOnId question.questionNumber
            in
                ( newModel, scrollToCurrent newModel )

        KeyboardMsg keyMsg ->
            let
                pressedKeys =
                    Keyboard.Extra.update keyMsg model.pressedKeys

                ( newModel, newCmdMsg ) =
                    case model.isFormActivated of
                        True ->
                            if List.member Keyboard.Extra.Enter pressedKeys then
                                handleNavigationEnter model
                            else if (List.member Shift pressedKeys) && (List.member ArrowUp pressedKeys) then
                                scrollDirection model Up
                            else if (List.member Shift pressedKeys) && (List.member ArrowDown pressedKeys) then
                                scrollDirection model Down
                            else
                                ( model, Cmd.none )

                        False ->
                            if List.member Keyboard.Extra.Enter pressedKeys then
                                ( activateForm model, Dom.focus (getIdToFocusOn model) |> Task.attempt InputFocusResult )
                            else
                                ( model, Cmd.none )

                newModel2 =
                    { newModel | pressedKeys = pressedKeys }
            in
                ( newModel2, newCmdMsg )

        AnswerQuestionWithId id ->
            answerQuestion (model |> focusModelOnId id)

        AnswerQuestion ->
            answerQuestion model

        FooterNext ->
            scrollDirection model Down

        FooterPrevious ->
            scrollDirection model Up

        ActivateForm ->
            let
                newModel =
                    activateForm model

                idToFocusOn =
                    getIdToFocusOn model
            in
                ( newModel, Dom.focus idToFocusOn |> Task.attempt InputFocusResult )

        InputFocusResult result ->
            case result of
                Ok value ->
                    ( model, Cmd.none )

                Err error ->
                    case error of
                        Dom.NotFound s ->
                            ( model, Cmd.none )

        FDMsg subMsg ->
            let
                ( newModel, newCmdMsg ) =
                    case (Zipper.current model.questionnaire.questions).questionType of
                        Dropdown options ->
                            let
                                newOptions =
                                    FD.update subMsg options

                                newQuestions =
                                    Zipper.mapCurrent (\x -> { x | questionType = Dropdown newOptions }) model.questionnaire.questions

                                newModel =
                                    model |> setQuestionsDeep newQuestions
                            in
                                ( newModel, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
                ( newModel, newCmdMsg )


updateCurrent : String -> Model -> Model
updateCurrent newContent model =
    let
        newZipper =
            Zipper.mapCurrent (updateInternalWidgetAnswer newContent) model.questionnaire.questions
    in
        model |> setQuestionsDeep newZipper


updateInternalWidgetAnswer : String -> Question -> Question
updateInternalWidgetAnswer newContent question =
    let
        newQuestion =
            case question.questionType of
                Text options ->
                    let
                        newOptions =
                            { options | internalValue = newContent }
                    in
                        { question | questionType = Text newOptions }

                _ ->
                    question
    in
        newQuestion


focusModelOnId : Int -> Model -> Model
focusModelOnId questionNumber model =
    let
        newZipper =
            model.questionnaire.questions
                |> Zipper.first
                |> Zipper.find (\x -> x.questionNumber == questionNumber)
                |> Zipper.withDefault emptyQuestion
    in
        model |> setQuestionsDeep newZipper


getIdToFocusOn : Model -> String
getIdToFocusOn model =
    let
        currentQuestion =
            Zipper.current model.questionnaire.questions
    in
        "input " ++ (toString currentQuestion.questionNumber)


scrollDirection : Model -> Direction -> ( Model, Cmd Msg )
scrollDirection model direction =
    let
        currentId =
            (Zipper.current model.questionnaire.questions).questionNumber

        filteredQuestions =
            model.questionnaire.questions
                |> filterQuestions
                |> Zipper.withDefault emptyQuestionError1
                |> Zipper.find (\x -> x.questionNumber == currentId)
                |> Zipper.withDefault (Zipper.current model.questionnaire.questions)

        nextOrPrevious =
            case direction of
                Up ->
                    filteredQuestions
                        |> Zipper.previous
                        |> Zipper.withDefault (Zipper.current model.questionnaire.questions)

                Down ->
                    filteredQuestions
                        |> Zipper.next
                        |> Zipper.withDefault (Zipper.current model.questionnaire.questions)

        nextFilteredNumber =
            (Zipper.current nextOrPrevious).questionNumber

        newZipper =
            model.questionnaire.questions
                |> Zipper.first
                |> Zipper.find (\x -> x.questionNumber == nextFilteredNumber)
                |> Zipper.withDefault emptyQuestion

        newModel =
            model
                |> setQuestionsDeep newZipper
                |> handleFooterButtons
    in
        ( newModel, scrollToCurrent newModel )


scrollToCurrent : Model -> Cmd Msg
scrollToCurrent model =
    let
        question =
            Zipper.current model.questionnaire.questions

        idToScrollTo =
            questionIdString question.questionNumber

        newCmd =
            case question.questionType of
                Text options ->
                    Cmd.batch [ scrollTo idToScrollTo, Dom.focus (getIdToFocusOn model) |> Task.attempt InputFocusResult ]

                _ ->
                    scrollTo idToScrollTo
    in
        newCmd


setQuestions : Zipper Question -> Questionnaire -> Questionnaire
setQuestions newQuestions questionnaire =
    { questionnaire | questions = newQuestions }


setQuestionsDeep : Zipper Question -> Model -> Model
setQuestionsDeep newQuestions model =
    { model | questionnaire = model.questionnaire |> setQuestions newQuestions }


setCurrentAnswer : String -> Model -> Model
setCurrentAnswer answer model =
    let
        newQuestions =
            Zipper.mapCurrent (\q -> { q | answer = answer }) model.questionnaire.questions
    in
        model |> setQuestionsDeep newQuestions


setCurrentIsAnswered : Bool -> Model -> Model
setCurrentIsAnswered bool model =
    let
        newQuestions =
            Zipper.mapCurrent (\q -> { q | isAnswered = bool }) model.questionnaire.questions
    in
        model |> setQuestionsDeep newQuestions


answerQuestion : Model -> ( Model, Cmd Msg )
answerQuestion model =
    let
        answer =
            toAnswer (Zipper.current model.questionnaire.questions)

        newModel =
            model
                |> setCurrentAnswer answer
                |> setCurrentIsAnswered True
                |> setNumQuestionsAnswered

        ( newModel2, newCmdMsg ) =
            scrollDirection newModel Down
    in
        ( newModel2, newCmdMsg )


toAnswer : Question -> String
toAnswer question =
    case question.questionType of
        Text options ->
            options.internalValue

        Widgets.Questionnaire.Select options ->
            ""

        Dropdown options ->
            options.inputValue

        PhotoSelect options ->
            ""

        Submit options ->
            ""


setNumQuestionsAnswered : Model -> Model
setNumQuestionsAnswered model =
    { model | numQuestionsAnswered = getNumQuestionsAnswered model }


getNumQuestionsAnswered : Model -> Int
getNumQuestionsAnswered model =
    let
        questionsAnswered =
            List.filter
                (\x ->
                    x.isAnswered == True
                )
                (Zipper.toList model.questionnaire.questions)
    in
        List.length questionsAnswered


setActivated : Model -> Model
setActivated model =
    { model | isFormActivated = True }


setTotalQuestions : Model -> Model
setTotalQuestions model =
    --minus 1 for the submit button
    { model | totalQuestions = (List.length (Zipper.toList model.questionnaire.questions) - 1) }


handleNavigationEnter : Model -> ( Model, Cmd Msg )
handleNavigationEnter model =
    answerQuestion model


activateForm : Model -> Model
activateForm model =
    model
        |> setActivated
        |> setTotalQuestions
        |> handleFooterButtons


handleFooterButtons : Model -> Model
handleFooterButtons model =
    let
        zipper =
            model.questionnaire.questions

        newModel =
            if Zipper.previous zipper == Nothing then
                { model | footerButtonUpEnabled = False, footerButtonDownEnabled = True }
            else if Zipper.next zipper == Nothing then
                { model | footerButtonUpEnabled = True, footerButtonDownEnabled = False }
            else
                { model | footerButtonUpEnabled = True, footerButtonDownEnabled = True }
    in
        newModel


filterQuestions : Zipper Question -> Maybe (Zipper Question)
filterQuestions questions =
    let
        filteredQuestions =
            List.filter
                (\q ->
                    not (anyDependsOn questions q)
                )
                (Zipper.toList questions)
    in
        Zipper.fromList filteredQuestions


anyDependsOn : Zipper Question -> Question -> Bool
anyDependsOn questions q =
    List.any
        (\x ->
            not x
        )
        (List.map
            (\questionNumber ->
                let
                    questionById =
                        getQuestionById questions questionNumber

                    isAnswered =
                        case questionById of
                            Just x ->
                                x.isAnswered

                            Nothing ->
                                True
                in
                    isAnswered
            )
            q.dependsOn
        )


getQuestionById : Zipper Question -> Int -> Maybe Question
getQuestionById questions id =
    let
        filtered =
            List.filter
                (\q ->
                    if q.questionNumber == id then
                        True
                    else
                        False
                )
                (Zipper.toList questions)
    in
        List.head filtered


calculateProgressbar : Int -> Int -> String
calculateProgressbar completed total =
    toString (100 * (toFloat completed / toFloat total)) ++ "%"


questionIdString : Int -> String
questionIdString id =
    "question" ++ toString id


parseQuestionText : Model -> String -> String
parseQuestionText model string =
    let
        myregex =
            Regex.regex "{{.*?}}"

        replace1 =
            Regex.replace All myregex (\{ match } -> replacer match model.questionnaire.questions) string
    in
        replace1


replacer : String -> Zipper Question -> String
replacer match questions =
    let
        myregex2 =
            Regex.regex "question(\\d+)answer"

        strippedString =
            match |> String.dropLeft 2 |> String.dropRight 2

        match4 =
            Regex.find (AtMost 1) myregex2 strippedString

        outValue =
            case List.head match4 of
                Just x ->
                    case List.head x.submatches of
                        Just firstSubMatch ->
                            case firstSubMatch of
                                Just submatch ->
                                    case String.toInt submatch of
                                        Ok id ->
                                            --getAnswerById answers id
                                            case getQuestionById questions id of
                                                Just question ->
                                                    question.answer

                                                Nothing ->
                                                    ""

                                        Err err ->
                                            err

                                Nothing ->
                                    ""

                        Nothing ->
                            ""

                Nothing ->
                    ""
    in
        outValue


view : Model -> Html Msg
view model =
    div [ class "fl w-100 montserrat" ]
        [ div [] [ text (toString model.pressedKeys) ]
        , demo model
        ]


demo : Model -> Html Msg
demo model =
    div
        [ style
            [ ( "color", model.questionnaire.colorScheme.colorMain )
            , ( "backgroundColor", model.questionnaire.colorScheme.colorBackground )
            ]
        ]
        [ if model.isFormActivated then
            div [ class "mh7-l mh2" ]
                [ div [ class "" ] (viewQuestions model (filterQuestions model.questionnaire.questions |> Zipper.withDefault emptyQuestion) model.questionnaire.colorScheme)
                , viewFooter model
                ]
          else
            viewTopSection model.questionnaire.topSection model.questionnaire.colorScheme
        ]


viewTopSection : TopSection -> ColorScheme -> Html Msg
viewTopSection options colors =
    div
        [ class "pt6 f3 mw7 center tc vh-100"
        , id "topsection"
        ]
        [ img
            [ src options.imageLink
            ]
            []
        , p [] [ text options.headerText ]
        , div []
            [ topSectionButton colors options.buttonText
            , buttonAsideText options.pressText colors.colorGray
            ]
        ]


topSectionButton : ColorScheme -> String -> Html Msg
topSectionButton colors buttonText =
    button
        ([ onClick ActivateForm ]
            ++ buttonTopTachyons
            ++ hoverStyles colors
        )
        [ span [] [ text buttonText ] ]


viewQuestions : Model -> Zipper Question -> ColorScheme -> List (Html Msg)
viewQuestions model questions colors =
    List.map
        (\question ->
            viewQuestion model question colors
        )
        (Zipper.toList questions)


viewQuestion : Model -> Question -> ColorScheme -> Html Msg
viewQuestion model question colors =
    case question.questionType of
        Text options ->
            viewTextQuestion question options colors

        Widgets.Questionnaire.Select options ->
            viewSelectQuestion model question options colors

        Dropdown options ->
            --Html.map (FDMsg question) (viewDropdownQuestion model question options colors)
            Html.map FDMsg (viewDropdownQuestion model question options colors)

        PhotoSelect options ->
            viewPhotoQuestion model question options colors

        Submit options ->
            viewSubmit model question options colors


viewTextQuestion : Question -> TextOptions -> ColorScheme -> Html Msg
viewTextQuestion question options colors =
    div
        [ class "pt6  f3 vh-100"
        , id (questionIdString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ class "ml3", class "input--hoshi" ]
            [ input
                [ class "input__field--hoshi"
                , onClick (TextQuestionClicked question)
                , onInput (TextQuestionInputChanged question)
                , id ("input " ++ toString question.questionNumber)
                , type_ "text"
                ]
                []
            , label [ class "input__label--hoshi hoshi-color-4", for "input-4" ]
                []
            ]
        , div
            [ class "pt2 ml3" ]
            [ typeFormButton colors options.buttonText question.questionNumber
            , buttonAsideText options.pressText colors.colorGray
            ]
        , Html.br []
            []
        ]


viewSelectQuestion : Model -> Question -> SelectOptions -> ColorScheme -> Html Msg
viewSelectQuestion model question options colors =
    div []
        [ div
            [ class "  f3 vh-100"
            , id (questionIdString question.questionNumber)
            ]
            [ questionText demoData.colorScheme question.questionNumber (parseQuestionText model question.questionText)
            , ul
                [ class "list mw6"
                , style [ ( "color", colors.colorGray ) ]
                ]
                (listChoices options.choices colors)
            ]
        ]


listChoices : List Choice -> ColorScheme -> List (Html msg)
listChoices choices colors =
    List.map
        (\choice ->
            liElement choice.letter choice.body colors.colorSelectBackground colors.colorSelectHover colors.colorSelectLetterBackground
        )
        choices


liElement : String -> String -> CSSValue -> CSSValue -> String -> Html msg
liElement letter body colorBackground colorHover colorLetterBackground =
    li
        (liElementTachyons ++ hover [ ( "backgroundColor", colorBackground, colorHover ) ])
        [ span
            [ class "ba ph2 pv1 mr2"
            , style [ ( "backgroundColor", colorLetterBackground ) ]
            ]
            [ text letter ]
        , span []
            [ text body ]
        ]


liElementTachyons : List (Attribute msg)
liElementTachyons =
    [ class "ba pa3 br2 b--black-40 mv3 pointer"
    ]


viewDropdownQuestion : Model -> Question -> DropdownOptions -> ColorScheme -> Html FD.Msg
viewDropdownQuestion model question options colors =
    div []
        [ div
            [ class "  f3 vh-100"
            , id (questionIdString question.questionNumber)
            ]
            [ questionText demoData.colorScheme question.questionNumber (parseQuestionText model question.questionText)
            , div
                [ class "mw7 pl3"
                , style [ ( "color", colors.colorGray ) ]
                ]
                [ FD.view options colors
                ]
            ]
        ]


viewPhotoQuestion : Model -> Question -> PhotoOptions -> ColorScheme -> Html Msg
viewPhotoQuestion model question options colors =
    div
        [ class " f3  vh-100"
        , id (questionIdString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ class "" ]
            [ div [ class "cf" ]
                (List.map
                    (\photo ->
                        viewSinglePhotoSelect photo
                    )
                    options.choices
                )
            ]
        ]


viewSinglePhotoSelect : Photo -> Html Msg
viewSinglePhotoSelect photo =
    div [ class "fl mw5 ba br2 b--black-40 pa2 ma2 " ]
        [ img [ alt "", class "", src photo.url ]
            []
        , div [ class "tc pv3 f5" ]
            [ span [ class "ba ph2 pv1 mr2 colorSelectLetterBackground br2" ]
                [ text photo.letter ]
            , span []
                [ text photo.name ]
            ]
        ]


viewSinglePhotoSelected : Photo -> Html Msg
viewSinglePhotoSelected photo =
    div [ class "fl ba br2 b--black-40 pa2 ma2 " ]
        [ img [ alt "", class "", src photo.url ]
            []
        , div [ class "tc pv3 f5" ]
            [ span [ class "ba ph2 pv1 mr2 colorSelectLetterBackground br2" ]
                [ text photo.letter ]
            , span []
                [ text photo.name ]
            ]
        ]


typeFormButton : ColorScheme -> String -> Int -> Html Msg
typeFormButton colors buttonText questionNumber =
    button
        ([ onClick (AnswerQuestionWithId questionNumber) ]
            ++ buttonTypeformTachyons
            ++ hoverStyles colors
        )
        [ span []
            [ text buttonText ]
        , span [ class "fa fa-check" ]
            []
        ]


buttonAsideText : String -> String -> Html msg
buttonAsideText asideText asideColor =
    span
        [ class "f6 pl3"
        , style [ ( "color", asideColor ) ]
        ]
        [ text asideText ]


submitButton : ColorScheme -> String -> Html Msg
submitButton colors buttonText =
    button
        ([ onClick NoOp ]
            ++ buttonTopTachyons
            ++ hoverStyles colors
        )
        [ span [] [ text buttonText ] ]


chevronUpOrDown : Bool -> String
chevronUpOrDown isUp =
    if isUp == True then
        "fa fa-chevron-up"
    else
        "fa fa-chevron-down"


buttonTopTachyons : List (Attribute msg)
buttonTopTachyons =
    [ class ("ph4 " ++ buttonBase)
    ]


buttonTypeformTachyons : List (Attribute msg)
buttonTypeformTachyons =
    [ class ("ph3 " ++ buttonBase)
    ]


buttonBase : String
buttonBase =
    "button_reset b br2 pv2 ph3 bn pointer shadow_5"


hoverStyles : ColorScheme -> List (Attribute msg)
hoverStyles colorScheme =
    hover_
        [ ( "color", colorScheme.colorButton )
        ]
        [ ( "backgroundColor", colorScheme.colorButtonBackground, colorScheme.colorButtonHover ) ]


questionText : ColorScheme -> Int -> String -> Html msg
questionText colors questionNumber body =
    div [ class "" ]
        [ span [ class "pr2 fl" ]
            [ span [ style [ ( "color", colors.colorGray ) ] ]
                [ span [ class "pr1" ]
                    [ text (toString questionNumber) ]
                , span [ class "fa fa-arrow-right" ]
                    []
                ]
            ]
        , span [] <|
            toHtml Nothing body
        ]


viewSubmit : Model -> Question -> SubmitOptions -> ColorScheme -> Html Msg
viewSubmit model question options colors =
    div [ class "f3 mt3 pt3 center tc vh-50", id (questionIdString question.questionNumber) ]
        [ submitButton model.questionnaire.colorScheme options.buttonText
        , buttonAsideText "press ENTER" model.questionnaire.colorScheme.colorGray
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    div
        [ class "fixed left-0 right-0 bottom-0 ph6-l ph2 pv3 fl w-100 bt  "
        , style
            [ ( "backgroundColor", model.questionnaire.colorScheme.colorBackground )
            , ( "color", model.questionnaire.colorScheme.colorFooter )
            ]
        ]
        [ div [ class "fl w-50" ]
            (viewFooterProgressBar model.numQuestionsAnswered model.totalQuestions)
        , div [ class "fl w-50 pt3" ]
            [ typeFormFooterButton model.questionnaire.colorScheme True model.footerButtonUpEnabled FooterPrevious
            , typeFormFooterButton model.questionnaire.colorScheme False model.footerButtonDownEnabled FooterNext
            ]
        ]


typeFormFooterButton : ColorScheme -> Bool -> Bool -> msg -> Html msg
typeFormFooterButton colorScheme isUp isEnabled action =
    if isEnabled then
        button
            ([ onClick action, class "fr mh1" ]
                ++ buttonTypeformTachyons
                ++ hoverStyles colorScheme
                ++ [ disabled False ]
            )
            [ span [ class (chevronUpOrDown isUp) ]
                []
            ]
    else
        button
            ([ class "fr mh1" ]
                ++ buttonTypeformTachyons
                ++ [ style
                        [ ( "color", colorScheme.colorButton )
                        , ( "backgroundColor", colorScheme.colorButtonHover )
                        ]
                   , disabled True
                   ]
            )
            [ span [ class (chevronUpOrDown isUp) ]
                []
            ]


viewFooterProgressBar : Int -> Int -> List (Html Msg)
viewFooterProgressBar completed total =
    [ p [] [ text (toString completed ++ " out of " ++ toString total ++ " questions completed") ]
    , div [ class "bg-moon-gray br-pill h1 overflow-y-hidden" ]
        [ div
            [ class "bg-blue br-pill h1 shadow-1"
            , style [ ( "width", calculateProgressbar completed total ) ]
            ]
            []
        ]
    ]
