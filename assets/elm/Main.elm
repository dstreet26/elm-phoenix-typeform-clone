module Main exposing (..)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import DynamicStyle exposing (..)
import Markdown exposing (toHtml)
import Ports.SmoothScroll exposing (scrollTo)
import Keyboard
import Json.Decode as JD
import List.Zipper as Zipper exposing (..)
import Widgets.FilterableDropdown as FD
import Colors exposing (ColorScheme)
import Widgets.Questionnaire exposing (..)
import TestData.DemoData exposing (demoData)


main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }


type ValidationType
    = NotNull
    | Email
    | AtLeastOne


type alias Flags =
    { user : String
    , token : String
    }


type alias Model =
    { value : Int
    , demoData : Questionnaire
    , currentActiveQuestionNumber : Int
    , isFormActivated : Bool
    , numQuestionsAnswered : Int
    , totalQuestions : Int
    , footerButtonUpEnabled : Bool
    , footerButtonDownEnabled : Bool
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Keyboard.downs KeyMsg ]


emptyModel : Model
emptyModel =
    { value = 0
    , demoData = demoData
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
    | AnswerQuestion Int
    | PreviousQuestion
    | ActivateForm
    | KeyMsg Keyboard.KeyCode
    | TextQuestionInputChanged Int String
    | FDMsg FD.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        --Change (newContent, questionNumber) ->
        TextQuestionInputChanged questionNumber newContent ->
            let
                demoData =
                    model.demoData

                questions =
                    demoData.questions

                newDemoData =
                    { demoData | questions = setQuestionAnswer questions newContent questionNumber }

                newModel =
                    { model | demoData = newDemoData }
            in
                ( newModel, Cmd.none )

        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )

        KeyMsg keyCode ->
            if keyCode == 13 then
                if model.isFormActivated then
                    --TODO: Jump to the next question
                    let
                        newModel =
                            answerQuestion2 model model.currentActiveQuestionNumber
                    in
                        ( newModel, scrollToId newModel newModel.currentActiveQuestionNumber )
                else
                    ( activateForm model, Cmd.none )
            else
                ( model, Cmd.none )

        AnswerQuestion questionNumber ->
            let
                newModel3 =
                    answerQuestion2 model questionNumber
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

        FDMsg subMsg ->
            ( model, Cmd.none )



--let
--    updatedFDModel =
--        FD.update subMsg model.fdModel
--in
--    ( { model | fdModel = updatedFDModel }, Cmd.none )


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


answerQuestion2 : Model -> Int -> Model
answerQuestion2 model questionNumber =
    let
        demoData =
            model.demoData

        questions =
            demoData.questions

        newDemoData =
            { demoData | questions = (answerQuestion questions questionNumber) }

        newModel =
            { model | demoData = newDemoData }

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
        scrollTo ("question" ++ (toString id))


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
    { model | numQuestionsAnswered = (getNumQuestionsAnswered model) }


getNumQuestionsAnswered : Model -> Int
getNumQuestionsAnswered model =
    let
        questionsAnswered =
            List.filter
                (\x ->
                    x.isAnswered == True
                )
                model.demoData.questions
    in
        List.length questionsAnswered


answerQuestion : List Question -> Int -> List Question
answerQuestion questions questionNumber =
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
    { model | totalQuestions = List.length model.demoData.questions }


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }


view : Model -> Html Msg
view model =
    div [ classes [ fl, w_100 ], class "montserrat" ]
        [ demo model model.demoData
        ]


liElement : String -> String -> CSSValue -> CSSValue -> String -> Html msg
liElement letter body colorBackground colorHover colorLetterBackground =
    li
        ((liElementTachyons) ++ (hover [ ( "backgroundColor", colorBackground, colorHover ) ]))
        [ span
            [ classes
                [ Tachyons.Classes.ba
                , Tachyons.Classes.ph2
                , Tachyons.Classes.pv1
                , Tachyons.Classes.mr2
                ]
            , style [ ( "backgroundColor", colorLetterBackground ) ]
            ]
            [ text letter ]
        , span []
            [ text body ]
        ]


liElementTachyons : List (Attribute msg)
liElementTachyons =
    [ classes
        [ Tachyons.Classes.ba
        , Tachyons.Classes.pa3
        , Tachyons.Classes.br2
        , Tachyons.Classes.b__black_40
        , Tachyons.Classes.mv3
        , Tachyons.Classes.pointer
        ]
    ]


submitButton : ColorScheme -> String -> Html Msg
submitButton colors buttonText =
    button ([ (Html.Events.onClick NoOp) ] ++ (buttonTopTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover)) [ span [] [ Html.text buttonText ] ]


topSectionButton : ColorScheme -> String -> Html Msg
topSectionButton colors buttonText =
    button ([ (Html.Events.onClick ActivateForm) ] ++ (buttonTopTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover)) [ span [] [ Html.text buttonText ] ]


typeFormFooterButton colorButton colorButtonBackground colorButtonHover isUp isEnabled action =
    if isEnabled then
        button
            (([ Html.Events.onClick action ]) ++ (buttonTypeformTachyons) ++ (hoverStyles colorButton colorButtonBackground colorButtonHover) ++ [ Html.Attributes.disabled False ])
            [ span [ Html.Attributes.class (chevronUpOrDown isUp) ]
                []
            ]
    else
        button
            ((buttonTypeformTachyons) ++ ([ style [ ( "color", colorButton ), (( "backgroundColor", colorButtonHover )) ] ]) ++ [ Html.Attributes.disabled True ])
            [ span [ Html.Attributes.class (chevronUpOrDown isUp) ]
                []
            ]


chevronUpOrDown isUp =
    if isUp == True then
        "fa fa-chevron-up"
    else
        "fa fa-chevron-down"


buttonTopTachyons =
    [ classes
        ([ Tachyons.Classes.ph4 ] ++ buttonBaseTachyons)
    ]


buttonTypeformTachyons =
    [ classes
        ([ Tachyons.Classes.ph3 ] ++ buttonBaseTachyons)
    ]


buttonBaseTachyons =
    [ Tachyons.Classes.button_reset
    , Tachyons.Classes.b
    , Tachyons.Classes.br2
    , Tachyons.Classes.pv2
    , Tachyons.Classes.ph3
    , Tachyons.Classes.bn
    , Tachyons.Classes.pointer
    , Tachyons.Classes.shadow_5
    ]


hoverStyles colorButton colorButtonBackground colorButtonHover =
    hover_
        [ ( "color", colorButton )
        ]
        [ ( "backgroundColor", colorButtonBackground, colorButtonHover ) ]


buttonAsideText asideText asideColor =
    span
        [ classes [ Tachyons.Classes.f6, Tachyons.Classes.pl3 ]
        , Html.Attributes.style [ ( "color", asideColor ) ]
        ]
        [ Html.text asideText ]


demo : Model -> Questionnaire -> Html Msg
demo model data =
    div [ Html.Attributes.style [ ( "color", data.colorScheme.colorMain ), ( "backgroundColor", data.colorScheme.colorBackground ) ] ]
        [ if model.isFormActivated then
            div []
                [ div [ Html.Attributes.style [ ( "asdf", "asdf" ) ] ] (mapQuestions data.questions data.colorScheme)
                , viewSubmit model data
                , viewFooter
                    data.colorScheme.colorFooter
                    data.colorScheme.colorFooterBackground
                    data.colorScheme.colorButton
                    data.colorScheme.colorButtonBackground
                    data.colorScheme.colorButtonHover
                    model.numQuestionsAnswered
                    model.totalQuestions
                    model.footerButtonUpEnabled
                    model.footerButtonDownEnabled
                ]
          else
            viewTopSection data.topSection data.colorScheme
        ]


viewSubmit : Model -> Questionnaire -> Html Msg
viewSubmit model data =
    div [ class "f3 mw7 center tc vh-50", id "submit" ]
        [ submitButton model.demoData.colorScheme "Submit"
        , buttonAsideText "press ENTER" data.colorScheme.colorGray
        ]


viewFooter colorFooter colorBackground colorButton colorButtonBackground colorButtonHover completed total footerButtonUpEnabled footerButtonDownEnabled =
    div [ class "fixed left-0 right-0 bottom-0 ph6 pv3 fl w-100 bt  ", style [ ( "backgroundColor", colorBackground ), ( "color", colorFooter ) ] ]
        [ div [ class "fl w-50" ]
            (viewFooterProgressBar completed total)
        , div [ class "fl w-50" ]
            [ typeFormFooterButton colorButton colorButtonBackground colorButtonHover True footerButtonUpEnabled PreviousQuestion
            , typeFormFooterButton colorButton colorButtonBackground colorButtonHover False footerButtonDownEnabled NextQuestion
            ]
        ]


viewFooterProgressBar : Int -> Int -> List (Html Msg)
viewFooterProgressBar completed total =
    [ p [] [ text (toString completed ++ " out of " ++ toString total ++ " questions completed") ]
    , div [ class "bg-moon-gray br-pill h1 overflow-y-hidden" ] [ div [ class "bg-blue br-pill h1 shadow-1", style [ ( "width", calculateProgressbar completed total ) ] ] [] ]
      --, div [ class "bg-moon-gray br-pill h1 overflow-y-hidden" ] [ div [ class "bg-blue br-pill h1 shadow-1", style [ ( "width", "10%" ) ] ] [] ]
    ]


calculateProgressbar : Int -> Int -> String
calculateProgressbar completed total =
    toString (100 * (toFloat completed / toFloat total)) ++ "%"


mapQuestions : List Question -> ColorScheme -> List (Html Msg)
mapQuestions questions colors =
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
            viewDropdownQuestion question options colors


viewTopSection : TopSection -> ColorScheme -> Html Msg
viewTopSection options colors =
    div
        [ classes
            [ Tachyons.Classes.pt6
            , Tachyons.Classes.f3
            , Tachyons.Classes.mw7
            , Tachyons.Classes.center
            , Tachyons.Classes.tc
            , Tachyons.Classes.vh_100
            ]
        , Html.Attributes.id "topsection"
        ]
        [ img
            [ classes []
            , Html.Attributes.src options.imageLink
            ]
            []
        , p [ classes [] ] [ Html.text options.headerText ]
        , div []
            [ topSectionButton colors options.buttonText
            , buttonAsideText options.pressText colors.colorGray
            ]
        ]


viewTextQuestion : Question -> TextOptions -> ColorScheme -> Html Msg
viewTextQuestion question options colors =
    div
        [ classes
            [ Tachyons.Classes.pt6
            , Tachyons.Classes.mh7
            , Tachyons.Classes.f3
            , Tachyons.Classes.vh_100
            ]
        , Html.Attributes.id ("question" ++ toString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ classes [ Tachyons.Classes.ml3 ], Html.Attributes.class "input--hoshi" ]
            [ input [ Html.Events.onInput (TextQuestionInputChanged question.questionNumber), Html.Attributes.class "input__field--hoshi", Html.Attributes.id "input-4", type_ "text" ]
                []
            , label [ Html.Attributes.class "input__label--hoshi hoshi-color-4", for "input-4" ]
                []
            ]
        , div
            [ classes
                [ Tachyons.Classes.pt2
                , Tachyons.Classes.ml3
                ]
            ]
            [ typeFormButton colors options.buttonText question.questionNumber
            , buttonAsideText options.pressText colors.colorGray
            ]
        , Html.br []
            []
        ]


typeFormButton : ColorScheme -> String -> Int -> Html Msg
typeFormButton colors buttonText questionNumber =
    button
        ([ onClick (AnswerQuestion questionNumber) ] ++ (buttonTypeformTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover))
        [ span []
            [ Html.text buttonText ]
        , span [ Html.Attributes.class "fa fa-check" ]
            []
        ]


viewSelectQuestion : Question -> SelectOptions -> ColorScheme -> Html Msg
viewSelectQuestion question options colors =
    div []
        [ div
            [ classes
                [ Tachyons.Classes.mt6
                , Tachyons.Classes.mh7
                , Tachyons.Classes.f3
                , Tachyons.Classes.vh_100
                ]
            , Html.Attributes.id ("question" ++ toString question.questionNumber)
            ]
            [ questionText colors question.questionNumber question.questionText
            , ul
                [ classes
                    [ Tachyons.Classes.list
                    , Tachyons.Classes.mw6
                    ]
                , Html.Attributes.style [ ( "color", colors.colorGray ) ]
                ]
                (listChoices options.choices colors)
            ]
        ]


viewDropdownQuestion : Question -> DropdownOptions -> ColorScheme -> Html Msg
viewDropdownQuestion question options colors =
    div []
        [ div
            [ classes
                [ Tachyons.Classes.mt6
                , Tachyons.Classes.mh7
                , Tachyons.Classes.f3
                , Tachyons.Classes.vh_100
                ]
            , Html.Attributes.id ("question" ++ toString question.questionNumber)
            ]
            [ questionText demoData.colorScheme question.questionNumber question.questionText
            , div
                [ classes
                    [ Tachyons.Classes.mw7
                    , Tachyons.Classes.pl3
                    ]
                , Html.Attributes.style [ ( "color", colors.colorGray ) ]
                ]
                [ Html.map FDMsg (FD.view options.fdModel)
                ]
            ]
        ]


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (JD.map tagger keyCode)


listChoices : List Choice -> ColorScheme -> List (Html msg)
listChoices choices colors =
    List.map
        (\choice ->
            liElement choice.letter choice.body colors.colorSelectBackground colors.colorSelectHover colors.colorSelectLetterBackground
        )
        choices


questionText colors questionNumber body =
    div [ Html.Attributes.class "" ]
        [ span [ classes [ Tachyons.Classes.pr2, Tachyons.Classes.fl ] ]
            [ span [ Html.Attributes.style [ ( "color", colors.colorGray ) ] ]
                [ span [ classes [ Tachyons.Classes.pr1 ] ]
                    [ Html.text (toString questionNumber) ]
                , span [ Html.Attributes.class "fa fa-arrow-right" ]
                    []
                ]
            ]
        , span [] <|
            toHtml Nothing body
        ]
