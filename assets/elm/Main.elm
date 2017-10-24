module Main exposing (..)

import Date exposing (Date)
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
                demoData =
                    model.questionnaire

                questions =
                    demoData.questions

                newDemoData =
                    { demoData | questions = setQuestionAnswer questions newContent questionNumber }

                newModel =
                    { model | questionnaire = newDemoData }
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
                                --( newOptions, newcmdmsg ) =
                                newOptions =
                                    FD.update subMsg options

                                newQuestions =
                                    updateQuestionsWithId model question newOptions

                                oldDemoData =
                                    model.questionnaire

                                newDemoData =
                                    { oldDemoData | questions = newQuestions }

                                newModel =
                                    { model | questionnaire = newDemoData }
                            in
                                ( newModel, Cmd.none )

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
        demoData =
            model.questionnaire

        questions =
            demoData.questions

        newDemoData =
            { demoData | questions = setQuestionAnswered questions questionNumber }

        newModel =
            { model | questionnaire = newDemoData }

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
                [ div [] (viewQuestions (filterQuestions model.questionnaire.questions) model.questionnaire.colorScheme)
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



--typeFormFooterButton : ColorScheme -> Bool -> Bool -> msg -> Html Msg


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
                ++ [ style [ ( "color", colorScheme.colorButton ), ( "backgroundColor", colorScheme.colorButtonHover ) ] ]
                ++ [ disabled True ]
            )
            [ span [ class (chevronUpOrDown isUp) ]
                []
            ]


chevronUpOrDown isUp =
    if isUp == True then
        "fa fa-chevron-up"
    else
        "fa fa-chevron-down"


buttonTopTachyons =
    [ class ("ph4 " ++ buttonBase)
    ]


buttonTypeformTachyons =
    [ class ("ph3 " ++ buttonBase)
    ]


buttonBase =
    "button_reset b br2 pv2 ph3 bn pointer shadow_5"


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


type alias DependsOnConditions =
    { conditions : List Bool
    }


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


viewQuestions : List Question -> ColorScheme -> List (Html Msg)
viewQuestions questions colors =
    List.map
        (\question ->
            viewQuestion question colors
        )
        questions


viewQuestion : Question -> ColorScheme -> Html Msg
viewQuestion question colors =
    case question.questionType of
        Text options ->
            viewTextQuestion question options colors

        Select options ->
            viewSelectQuestion question options colors

        Dropdown options ->
            Html.map (FDMsg question) (viewDropdownQuestion question options colors)


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


viewSelectQuestion : Question -> SelectOptions -> ColorScheme -> Html Msg
viewSelectQuestion question options colors =
    div []
        [ div
            [ class "mt6 mh7 f3 vh_100"
            , id ("question" ++ toString question.questionNumber)
            ]
            [ questionText colors question.questionNumber question.questionText
            , ul
                [ class "list mw6"
                , style [ ( "color", colors.colorGray ) ]
                ]
                (listChoices options.choices colors)
            ]
        ]


viewDropdownQuestion : Question -> DropdownOptions -> ColorScheme -> Html FD.Msg
viewDropdownQuestion question options colors =
    div []
        [ div
            [ class "mt6 mh7 f3 vh-100"
            , id ("question" ++ toString question.questionNumber)
            ]
            [ questionText demoData.colorScheme question.questionNumber question.questionText
            , div
                [ class "mw7 pl3"
                , style [ ( "color", colors.colorGray ) ]
                ]
                [ FD.view options
                ]
            ]
        ]


listChoices : List Choice -> ColorScheme -> List (Html msg)
listChoices choices colors =
    List.map
        (\choice ->
            liElement choice.letter choice.body colors.colorSelectBackground colors.colorSelectHover colors.colorSelectLetterBackground
        )
        choices


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
