module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import DynamicStyle exposing (..)
import Markdown exposing (toHtml)
import Ports.SmoothScroll exposing (scrollTo)
import Keyboard
import Json.Decode as JD
import Widgets.FilterableDropdown as FD
import Colors exposing (ColorScheme)
import Widgets.Questionnaire exposing (..)
import TestData.DemoData exposing (demoData)
import Regex exposing (..)


main : Program (Maybe Flags) Model Msg
main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Flags =
    { user : String
    , token : String
    }


type alias Model =
    { value : Int
    , questionnaire : Questionnaire
    , currentActiveQuestionNumber : Int
    , isFormActivated : Bool
    , numQuestionsAnswered : Int
    , totalQuestions : Int
    , footerButtonUpEnabled : Bool
    , footerButtonDownEnabled : Bool
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    --Sub.batch [ Keyboard.downs KeyMsg ]
    Sub.none


emptyModel : Model
emptyModel =
    { value = 0
    , questionnaire = demoData
    , currentActiveQuestionNumber = 0
    , isFormActivated = False
    , numQuestionsAnswered = 0
    , totalQuestions = 0
    , footerButtonUpEnabled = False
    , footerButtonDownEnabled = False
    }



--Placeholder flags


init : Maybe Flags -> ( Model, Cmd Msg )
init flags =
    emptyModel ! []


type Msg
    = NoOp
    | Increment
    | NextQuestion
    | TextQuestionClicked Question
    | AnswerQuestion Int
    | PreviousQuestion
    | ActivateForm
    | KeyDown Keyboard.KeyCode
    | TextQuestionInputChanged Int String
    | FDMsg Question FD.Msg


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (JD.map tagger keyCode)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        --Change (newContent, questionNumber) ->
        TextQuestionInputChanged questionNumber newContent ->
            let
                questionnaire =
                    model.questionnaire

                questions =
                    questionnaire.questions

                newQuestionnaire =
                    { questionnaire | questions = setQuestionAnswer questions newContent questionNumber }

                newModel =
                    { model | questionnaire = newQuestionnaire }
            in
                ( newModel, Cmd.none )

        TextQuestionClicked question ->
            ( { model | currentActiveQuestionNumber = question.questionNumber }, Cmd.none )

        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )

        KeyDown keyCode ->
            if keyCode == 13 then
                if model.isFormActivated then
                    let
                        newModel =
                            answerQuestion model model.currentActiveQuestionNumber
                    in
                        ( newModel, scrollToId newModel newModel.currentActiveQuestionNumber )
                else
                    ( activateForm model, Cmd.none )
            else
                ( model, Cmd.none )

        AnswerQuestion questionNumber ->
            let
                newModel3 =
                    answerQuestion model questionNumber
            in
                ( newModel3, scrollToId newModel3 newModel3.currentActiveQuestionNumber )

        NextQuestion ->
            let
                nextActiveQuestionNumber =
                    model.currentActiveQuestionNumber + 1

                newModel =
                    { model | currentActiveQuestionNumber = nextActiveQuestionNumber }

                newmodel2 =
                    handleFooterButtons newModel
            in
                ( newmodel2, scrollToId newmodel2 nextActiveQuestionNumber )

        PreviousQuestion ->
            let
                nextActiveQuestionNumber =
                    model.currentActiveQuestionNumber - 1

                newModel =
                    { model | currentActiveQuestionNumber = nextActiveQuestionNumber }

                newmodel2 =
                    handleFooterButtons newModel
            in
                ( newmodel2, scrollToId newmodel2 nextActiveQuestionNumber )

        ActivateForm ->
            let
                newModel =
                    activateForm model
            in
                ( newModel, Cmd.none )

        --FDMsg id subMsg ->
        FDMsg question subMsg ->
            let
                ( newModel, newcmdmsg ) =
                    case question.questionType of
                        Dropdown options ->
                            let
                                newOptions =
                                    FD.update subMsg options

                                newQuestions =
                                    updateQuestionsWithId model question newOptions

                                oldDemoData =
                                    model.questionnaire

                                newQuestionnaire =
                                    { oldDemoData | questions = newQuestions }

                                newModel2 =
                                    { model | questionnaire = newQuestionnaire }
                            in
                                ( newModel2, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
                ( newModel, newcmdmsg )


updateQuestionsWithId : Model -> Question -> DropdownOptions -> List Question
updateQuestionsWithId model question newOptions =
    List.map
        (\x ->
            if x.questionNumber == question.questionNumber then
                { x | questionType = Dropdown newOptions }
            else
                x
        )
        model.questionnaire.questions


activateForm : Model -> Model
activateForm model =
    model |> setActivated |> setTotalQuestions |> setCurrentQuestionToFirst |> handleFooterButtons


handleFooterButtons : Model -> Model
handleFooterButtons model =
    --current active id should be 0 initially
    --if we're at the bottom, then set the down one to disabled
    --if we're at the top, then set the top one to disabled
    if model.currentActiveQuestionNumber > model.totalQuestions then
        --we're at the bottom
        { model | footerButtonUpEnabled = True, footerButtonDownEnabled = False }
    else if model.currentActiveQuestionNumber == 1 then
        --we're at the top
        { model | footerButtonUpEnabled = False, footerButtonDownEnabled = True }
    else
        --we're in the middle
        { model | footerButtonUpEnabled = True, footerButtonDownEnabled = True }


setQuestionAnswered : List Question -> Int -> List Question
setQuestionAnswered questions questionNumber =
    List.map
        (\question ->
            if question.questionNumber == questionNumber then
                let
                    question2 =
                        testSetIsAnswered question
                in
                    testSetIsAnswered question2
            else
                question
        )
        questions


answerQuestion : Model -> Int -> Model
answerQuestion model questionNumber =
    let
        questionnaire =
            model.questionnaire

        questions =
            questionnaire.questions

        newQuestionnaire =
            { questionnaire | questions = setQuestionAnswered questions questionNumber }

        newModel =
            { model | questionnaire = newQuestionnaire }

        newModel2 =
            setNumQuestionsAnswered newModel

        newModel3 =
            incrementCurrentlyActiveQuestion newModel2

        newModel4 =
            handleFooterButtons newModel3
    in
        newModel4


incrementCurrentlyActiveQuestion : Model -> Model
incrementCurrentlyActiveQuestion model =
    { model | currentActiveQuestionNumber = model.currentActiveQuestionNumber + 1 }


scrollToId : Model -> Int -> Cmd Msg
scrollToId model id =
    if id > model.totalQuestions then
        scrollTo "submit"
    else
        scrollTo ("question" ++ toString id)


setQuestionAnswer : List Question -> String -> Int -> List Question
setQuestionAnswer questions newContent questionNumber =
    List.map
        (\question ->
            if question.questionNumber == questionNumber then
                { question | answer = newContent }
            else
                question
        )
        questions


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
                model.questionnaire.questions
    in
        List.length questionsAnswered


testSetIsAnswered : Question -> Question
testSetIsAnswered question =
    { question | isAnswered = True }


testSetAnswer : Question -> String -> Question
testSetAnswer question answer =
    { question | answer = answer }


setCurrentQuestionToFirst : Model -> Model
setCurrentQuestionToFirst model =
    { model | currentActiveQuestionNumber = 1 }


setActivated : Model -> Model
setActivated model =
    { model | isFormActivated = True }


setTotalQuestions : Model -> Model
setTotalQuestions model =
    { model | totalQuestions = List.length model.questionnaire.questions }


view : Model -> Html Msg
view model =
    div [ class "fl w-100 montserrat" ]
        [ demo model
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
            div []
                [ div [] (viewQuestions model (filterQuestions model.questionnaire.questions) model.questionnaire.colorScheme)
                , viewSubmit model
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


buttonAsideText : String -> String -> Html msg
buttonAsideText asideText asideColor =
    span
        [ class "f6 pl3"
        , style [ ( "color", asideColor ) ]
        ]
        [ text asideText ]


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


submitButton : ColorScheme -> String -> Html Msg
submitButton colors buttonText =
    button
        ([ onClick NoOp ]
            ++ buttonTopTachyons
            ++ hoverStyles colors
        )
        [ span [] [ text buttonText ] ]


typeFormFooterButton : ColorScheme -> Bool -> Bool -> msg -> Html msg
typeFormFooterButton colorScheme isUp isEnabled action =
    if isEnabled then
        button
            ([ onClick action ]
                ++ buttonTypeformTachyons
                ++ hoverStyles colorScheme
                ++ [ disabled False ]
            )
            [ span [ class (chevronUpOrDown isUp) ]
                []
            ]
    else
        button
            (buttonTypeformTachyons
                ++ [ style [ ( "color", colorScheme.colorButton ), ( "backgroundColor", colorScheme.colorButtonHover ) ], disabled True ]
            )
            [ span [ class (chevronUpOrDown isUp) ]
                []
            ]


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


filterQuestions : List Question -> List Question
filterQuestions questions =
    List.filter
        (\q ->
            not (anyDependsOn questions q)
        )
        questions


anyDependsOn : List Question -> Question -> Bool
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


getQuestionById : List Question -> Int -> Maybe Question
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
                questions
    in
        List.head filtered


viewSubmit : Model -> Html Msg
viewSubmit model =
    div [ class "f3 mw7 center tc vh-50", id "submit" ]
        [ submitButton model.questionnaire.colorScheme "Submit"
        , buttonAsideText "press ENTER" model.questionnaire.colorScheme.colorGray
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    div
        [ class "fixed left-0 right-0 bottom-0 ph6 pv3 fl w-100 bt  "
        , style
            [ ( "backgroundColor", model.questionnaire.colorScheme.colorBackground )
            , ( "color", model.questionnaire.colorScheme.colorFooter )
            ]
        ]
        [ div [ class "fl w-50" ]
            (viewFooterProgressBar model.numQuestionsAnswered model.totalQuestions)
        , div [ class "fl w-50" ]
            [ typeFormFooterButton model.questionnaire.colorScheme True model.footerButtonUpEnabled PreviousQuestion
            , typeFormFooterButton model.questionnaire.colorScheme False model.footerButtonDownEnabled NextQuestion
            ]
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


calculateProgressbar : Int -> Int -> String
calculateProgressbar completed total =
    toString (100 * (toFloat completed / toFloat total)) ++ "%"


viewQuestions : Model -> List Question -> ColorScheme -> List (Html Msg)
viewQuestions model questions colors =
    List.map
        (\question ->
            viewQuestion model question colors
        )
        questions


viewQuestion : Model -> Question -> ColorScheme -> Html Msg
viewQuestion model question colors =
    case question.questionType of
        Text options ->
            viewTextQuestion question options colors

        Select options ->
            viewSelectQuestion model question options colors

        Dropdown options ->
            Html.map (FDMsg question) (viewDropdownQuestion model question options colors)


viewTextQuestion : Question -> TextOptions -> ColorScheme -> Html Msg
viewTextQuestion question options colors =
    div
        [ class "pt6 mh7 f3 vh-100"
        , id ("question" ++ toString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ class "ml3", class "input--hoshi" ]
            [ input
                [ onKeyDown KeyDown
                , onClick (TextQuestionClicked question)
                , onInput (TextQuestionInputChanged question.questionNumber)
                , class "input__field--hoshi"
                , id "input-4"
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


typeFormButton : ColorScheme -> String -> Int -> Html Msg
typeFormButton colors buttonText questionNumber =
    button
        ([ onClick (AnswerQuestion questionNumber) ]
            ++ buttonTypeformTachyons
            ++ hoverStyles colors
        )
        [ span []
            [ text buttonText ]
        , span [ class "fa fa-check" ]
            []
        ]


viewSelectQuestion : Model -> Question -> SelectOptions -> ColorScheme -> Html Msg
viewSelectQuestion model question options colors =
    div []
        [ div
            [ class "mt6 mh7 f3 vh_100"
            , id ("question" ++ toString question.questionNumber)
            ]
            [ questionText demoData.colorScheme question.questionNumber (parseQuestionText model question.questionText)
            , ul
                [ class "list mw6"
                , style [ ( "color", colors.colorGray ) ]
                ]
                (listChoices options.choices colors)
            ]
        ]


viewDropdownQuestion : Model -> Question -> DropdownOptions -> ColorScheme -> Html FD.Msg
viewDropdownQuestion model question options colors =
    div []
        [ div
            [ class "mt6 mh7 f3 vh-100"
            , id ("question" ++ toString question.questionNumber)
            ]
            [ questionText demoData.colorScheme question.questionNumber (parseQuestionText model question.questionText)
            , div
                [ class "mw7 pl3"
                , style [ ( "color", colors.colorGray ) ]
                ]
                [ FD.view options
                ]
            ]
        ]


parseQuestionText : Model -> String -> String
parseQuestionText model string =
    let
        myregex =
            Regex.regex "{{.*?}}"

        replace1 =
            Regex.replace All myregex (\{ match } -> replacer match model.questionnaire.questions) string
    in
        replace1


replacer : String -> List Question -> String
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


listChoices : List Choice -> ColorScheme -> List (Html msg)
listChoices choices colors =
    List.map
        (\choice ->
            liElement choice.letter choice.body colors.colorSelectBackground colors.colorSelectHover colors.colorSelectLetterBackground
        )
        choices


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
