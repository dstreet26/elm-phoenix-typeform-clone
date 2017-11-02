module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Char exposing (isUpper, isLower, fromCode)
import Regex exposing (find, HowMany(..))
import Dom exposing (focus)
import Task exposing (perform)
import DynamicStyle exposing (hover_)
import Markdown exposing (toHtml)
import Ports.SmoothScroll exposing (scrollTo)
import Keyboard.Extra exposing (Key(..), toCode)
import List.Zipper as Zipper exposing (..)
import Colors exposing (ColorScheme)
import TestData.DemoData exposing (demoData, emptyQuestion)
import Widgets.Questionnaire exposing (..)
import Widgets.FilterableDropdown as FD
import TestData.ColorSchemes exposing (allColors)


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
    , currentHtmlFocus : String
    , colorSchemes : List ColorScheme
    , isSubmitted : Bool
    , numInvalid : Int
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
    , currentHtmlFocus = ""
    , colorSchemes = allColors
    , isSubmitted = False
    , numInvalid = 0
    }


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
    | SubmitQuestionnaire
    | KeyboardMsg Keyboard.Extra.Msg
    | TextQuestionInputChanged Question String
    | TextQuestionClicked Question
    | LetterClicked Int String
    | FDMsg FD.Msg
    | InputFocusResult (Result Dom.Error ())
    | ColorSchemeClicked ColorScheme
    | ResetQuestionnaire


type Direction
    = Up
    | Down


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ResetQuestionnaire ->
            ( emptyModel, Cmd.none )

        SubmitQuestionnaire ->
            submitQuestionnaire model

        ColorSchemeClicked colorScheme ->
            let
                newModel =
                    model |> setColorScheme colorScheme
            in
                ( newModel, Cmd.none )

        TextQuestionInputChanged question newContent ->
            let
                questionnaire =
                    model.questionnaire

                newModel =
                    model
                        |> focusModelOnId question.questionNumber
                        |> updateCurrentInternal newContent
                        |> setHtmlFocusCurrent
            in
                ( newModel, Cmd.none )

        TextQuestionClicked question ->
            let
                newModel =
                    model
                        |> focusModelOnId question.questionNumber
                        |> setHtmlFocusCurrent
            in
                ( newModel, scrollToCurrent newModel )

        LetterClicked id letter ->
            let
                newModel =
                    model |> focusModelOnId id
            in
                handleSelectLetter newModel letter

        KeyboardMsg keyMsg ->
            let
                pressedKeys =
                    Keyboard.Extra.update keyMsg model.pressedKeys

                ( newModel, newCmdMsg ) =
                    case model.isFormActivated of
                        True ->
                            if List.member Enter pressedKeys then
                                handleNavigationEnter model
                            else if (List.member Shift pressedKeys) && (List.member ArrowUp pressedKeys) then
                                scrollDirection model Up
                            else if (List.member Shift pressedKeys) && (List.member ArrowDown pressedKeys) then
                                scrollDirection model Down
                            else if List.any isChar pressedKeys then
                                handleSelectLetter model (keysToLetter pressedKeys)
                            else
                                ( model, Cmd.none )

                        False ->
                            if List.member Keyboard.Extra.Enter pressedKeys then
                                activateForm model
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
            activateForm model

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

                                ( newModel2, newCmdMsg ) =
                                    case subMsg of
                                        FD.SelectChoice choice ->
                                            answerQuestion newModel

                                        _ ->
                                            ( newModel, Cmd.none )
                            in
                                ( newModel2, newCmdMsg )

                        _ ->
                            ( model, Cmd.none )
            in
                ( newModel, newCmdMsg )


isChar : Key -> Bool
isChar key =
    let
        char =
            Char.fromCode (toCode key)
    in
        Char.isLower char || Char.isUpper char


keysToLetter : List Key -> String
keysToLetter keys =
    case List.head keys of
        Just head ->
            head
                |> toCode
                |> fromCode
                |> String.fromChar

        Nothing ->
            ""


updateCurrentInternal : String -> Model -> Model
updateCurrentInternal newContent model =
    let
        newZipper =
            Zipper.mapCurrent (updateInternalWidgetAnswer newContent) model.questionnaire.questions
    in
        model |> setQuestionsDeep newZipper


setColorScheme : ColorScheme -> Model -> Model
setColorScheme colorScheme model =
    let
        currentQuestionniare =
            model.questionnaire

        newQuestionnaire =
            { currentQuestionniare | colorScheme = colorScheme }

        newModel =
            { model | questionnaire = newQuestionnaire }
    in
        newModel


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

                Email options ->
                    let
                        newOptions =
                            { options | internalValue = newContent }
                    in
                        { question | questionType = Email newOptions }

                Widgets.Questionnaire.Select options ->
                    let
                        newChoices =
                            List.map
                                (\choice ->
                                    let
                                        newChoice =
                                            if choice.letter == newContent then
                                                { choice | isSelected = True }
                                            else
                                                { choice | isSelected = False }
                                    in
                                        newChoice
                                )
                                options.choices

                        newOptions =
                            { options | choices = newChoices }
                    in
                        { question | questionType = Widgets.Questionnaire.Select newOptions }

                PhotoSelect options ->
                    let
                        newChoices =
                            List.map
                                (\choice ->
                                    let
                                        newChoice =
                                            if choice.letter == newContent then
                                                { choice | isSelected = True }
                                            else
                                                { choice | isSelected = False }
                                    in
                                        newChoice
                                )
                                options.choices

                        newOptions =
                            { options | choices = newChoices }
                    in
                        { question | questionType = PhotoSelect newOptions }

                _ ->
                    question
    in
        newQuestion


setQuestionIsFocused : Zipper Question -> Zipper Question
setQuestionIsFocused zipper =
    zipper
        |> Zipper.mapCurrent (\x -> { x | isFocused = True })
        |> Zipper.mapBefore (\list -> List.map (\x -> { x | isFocused = False }) list)
        |> Zipper.mapAfter (\list -> List.map (\x -> { x | isFocused = False }) list)


setQuestionIsFocused2 : Model -> Model
setQuestionIsFocused2 model =
    let
        newZipper =
            model.questionnaire.questions
                |> Zipper.mapCurrent (\x -> { x | isFocused = True })
                |> Zipper.mapBefore (\list -> List.map (\x -> { x | isFocused = False }) list)
                |> Zipper.mapAfter (\list -> List.map (\x -> { x | isFocused = False }) list)
    in
        model |> setQuestionsDeep newZipper


focusModelOnId : Int -> Model -> Model
focusModelOnId questionNumber model =
    let
        newZipper =
            model.questionnaire.questions
                |> Zipper.first
                |> Zipper.find (\x -> x.questionNumber == questionNumber)
                |> Zipper.withDefault emptyQuestion
                |> setQuestionIsFocused
    in
        model |> setQuestionsDeep newZipper


getIdToFocusOn : Model -> String
getIdToFocusOn model =
    let
        currentQuestion =
            Zipper.current model.questionnaire.questions
    in
        inputIdString currentQuestion.questionNumber


scrollDirection : Model -> Direction -> ( Model, Cmd Msg )
scrollDirection model direction =
    let
        currentId =
            (Zipper.current model.questionnaire.questions).questionNumber

        filteredQuestions =
            model.questionnaire.questions
                |> filterQuestions
                |> Zipper.withDefault emptyQuestion
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
                |> setQuestionIsFocused

        newModel =
            model
                |> setQuestionsDeep newZipper
                |> handleFooterButtons
                |> setHtmlFocusCurrent
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
                    Cmd.batch [ scrollTo idToScrollTo, Dom.focus model.currentHtmlFocus |> Task.attempt InputFocusResult ]

                Email options ->
                    Cmd.batch [ scrollTo idToScrollTo, Dom.focus model.currentHtmlFocus |> Task.attempt InputFocusResult ]

                Widgets.Questionnaire.Select options ->
                    Cmd.batch [ scrollTo idToScrollTo, Dom.blur model.currentHtmlFocus |> Task.attempt InputFocusResult ]

                Dropdown options ->
                    Cmd.batch [ scrollTo idToScrollTo, Dom.focus model.currentHtmlFocus |> Task.attempt InputFocusResult ]

                PhotoSelect options ->
                    Cmd.batch [ scrollTo idToScrollTo, Dom.blur model.currentHtmlFocus |> Task.attempt InputFocusResult ]

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


setHtmlFocus : String -> Model -> Model
setHtmlFocus string model =
    { model | currentHtmlFocus = string }


setHtmlFocusCurrent : Model -> Model
setHtmlFocusCurrent model =
    let
        currentQuestion =
            Zipper.current model.questionnaire.questions

        newModel =
            case currentQuestion.questionType of
                Text options ->
                    model |> setHtmlFocus (inputIdString currentQuestion.questionNumber)

                Email options ->
                    model |> setHtmlFocus (inputIdString currentQuestion.questionNumber)

                Dropdown options ->
                    model |> setHtmlFocus (inputIdString currentQuestion.questionNumber)

                Widgets.Questionnaire.Select options ->
                    model

                PhotoSelect options ->
                    model

                _ ->
                    model
    in
        newModel


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


submitQuestionnaire : Model -> ( Model, Cmd Msg )
submitQuestionnaire model =
    let
        validatedModel =
            validateAllQuestions model

        filteredQuestions =
            List.filter
                (\x ->
                    if x.validationResult == Nothing then
                        False
                    else
                        True
                )
                (Zipper.toList validatedModel.questionnaire.questions)

        filteredQuestionsLength =
            (List.length filteredQuestions) - 1

        newModel =
            if filteredQuestionsLength > 0 then
                { validatedModel | numInvalid = filteredQuestionsLength }
            else
                { validatedModel | isSubmitted = True, numInvalid = 0 }
    in
        ( newModel, Cmd.none )


answerQuestion : Model -> ( Model, Cmd Msg )
answerQuestion model =
    let
        currentQuestion =
            Zipper.current model.questionnaire.questions

        answer =
            toAnswer currentQuestion

        validatedModel =
            validateCurrentQuestion model

        validationResult =
            (Zipper.current validatedModel.questionnaire.questions).validationResult

        ( newModel, newCmdMsg ) =
            case validationResult of
                Just x ->
                    ( validatedModel, Cmd.none )

                Nothing ->
                    let
                        newModel =
                            validatedModel
                                |> setCurrentAnswer answer
                                |> setCurrentIsAnswered True
                                |> setNumQuestionsAnswered
                    in
                        scrollDirection newModel Down
    in
        ( newModel, newCmdMsg )


validateAllQuestions : Model -> Model
validateAllQuestions model =
    let
        newQuestions =
            model.questionnaire.questions
                |> Zipper.map validateQuestion
                |> Zipper.map validateRequired
    in
        model |> setQuestionsDeep newQuestions


validateCurrentQuestion : Model -> Model
validateCurrentQuestion model =
    let
        newQuestions =
            model.questionnaire.questions
                |> Zipper.mapCurrent validateQuestion
                |> Zipper.mapCurrent validateRequired
    in
        model |> setQuestionsDeep newQuestions


validateRequired : Question -> Question
validateRequired question =
    case question.validationResult of
        Nothing ->
            if question.isRequired then
                if (toAnswer question) == "" then
                    { question | validationResult = Just "Required" }
                else
                    { question | validationResult = Nothing }
            else
                { question | validationResult = Nothing }

        Just "Required" ->
            if (toAnswer question) == "" then
                { question | validationResult = Just "Required" }
            else
                { question | validationResult = Nothing }

        Just "Can't be blank" ->
            if (toAnswer question) == "" then
                { question | validationResult = Just "Required" }
            else
                { question | validationResult = Nothing }

        Just x ->
            question


validateQuestion : Question -> Question
validateQuestion question =
    case question.questionType of
        Text textOptions ->
            if String.length textOptions.internalValue > 0 then
                { question | validationResult = Nothing }
            else
                { question | validationResult = Just "Can't be blank" }

        Email textOptions ->
            if Regex.contains (Regex.caseInsensitive (Regex.regex "^\\S+@\\S+\\.\\S+$")) (toAnswer question) then
                { question | validationResult = Nothing }
            else
                { question | validationResult = Just "Mmm.. That email does not look valid" }

        _ ->
            question


toAnswer : Question -> String
toAnswer question =
    case question.questionType of
        Text options ->
            options.internalValue

        Email options ->
            options.internalValue

        Widgets.Questionnaire.Select options ->
            let
                filteredQuestions =
                    List.filter (\x -> x.isSelected) options.choices

                first =
                    case List.head filteredQuestions of
                        Just x ->
                            x.body

                        Nothing ->
                            ""
            in
                first

        Dropdown options ->
            options.inputValue

        PhotoSelect options ->
            let
                filteredQuestions =
                    List.filter (\x -> x.isSelected) options.choices

                first =
                    case List.head filteredQuestions of
                        Just x ->
                            x.name

                        Nothing ->
                            ""
            in
                first

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
                    case x.questionType of
                        Submit options ->
                            False

                        _ ->
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


getCurrentQuestion : Model -> Question
getCurrentQuestion model =
    Zipper.current model.questionnaire.questions


handleSelectLetter : Model -> String -> ( Model, Cmd Msg )
handleSelectLetter model letter =
    let
        currentQuestion =
            getCurrentQuestion model

        ( newModel, newCmdMsg ) =
            case currentQuestion.questionType of
                Widgets.Questionnaire.Select options ->
                    let
                        newModel =
                            model |> updateCurrentInternal letter
                    in
                        answerQuestion newModel

                PhotoSelect options ->
                    let
                        newModel =
                            model |> updateCurrentInternal letter
                    in
                        answerQuestion newModel

                _ ->
                    ( model, Cmd.none )
    in
        ( newModel, newCmdMsg )


handleNavigationEnter : Model -> ( Model, Cmd Msg )
handleNavigationEnter model =
    case (Zipper.current model.questionnaire.questions).questionType of
        Submit options ->
            submitQuestionnaire model

        _ ->
            answerQuestion model


activateForm : Model -> ( Model, Cmd Msg )
activateForm model =
    let
        newModel =
            model
                |> setActivated
                |> setTotalQuestions
                |> handleFooterButtons
                |> setHtmlFocusCurrent
                |> setQuestionIsFocused2

        newCmdMsg =
            Dom.focus newModel.currentHtmlFocus |> Task.attempt InputFocusResult
    in
        ( newModel, newCmdMsg )


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


inputIdString : Int -> String
inputIdString id =
    "input" ++ toString id


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
        [ viewControlPanel model
        , if model.isSubmitted then
            viewResult model model.questionnaire.colorScheme
          else
            demo model
        ]


viewResult : Model -> ColorScheme -> Html Msg
viewResult model colors =
    div [ class "pa6-l pa2 f2-l f3", style [ ( "color", colors.mainText ), ( "backgroundColor", colors.background ) ] ]
        [ div [] [ text "Thanks for making it through the demo! Here are your answers:" ]
        , div []
            (List.filterMap
                (\question ->
                    case question.questionType of
                        Submit options ->
                            Nothing

                        _ ->
                            Just (div [] [ text ("Question " ++ toString question.questionNumber ++ ": " ++ (toAnswer question)) ])
                )
                (Zipper.toList model.questionnaire.questions)
            )
        , button
            ([ onClick ResetQuestionnaire ]
                ++ buttonTopClasses
                ++ hoverStyles colors
            )
            [ span [] [ text "Reset" ] ]
        ]


viewControlPanel : Model -> Html Msg
viewControlPanel model =
    div [ class "cf bg-white pa6-l pa2 bb bw2" ]
        [ div [ class "fl w-50" ]
            [ h2 []
                [ text "Elm Typeform Clone"
                ]
            , p [] [ text "Use Shift+Up/Down for keyboard navigation." ]
            ]
        , div [ class "fl w-50" ]
            [ p [] [ text "Color Schemes (click to change)" ]
            , viewColorSchemeButtons model
            ]
        ]


viewColorSchemeButtons : Model -> Html Msg
viewColorSchemeButtons model =
    div [ class "flex flex-wrap mw6" ]
        (List.map
            (\colorScheme ->
                div
                    (([ class "pa3 flex-auto ba bw2 grow"
                      , onClick (ColorSchemeClicked colorScheme)
                      ]
                     )
                        ++ (hover_ [ ( "backgroundColor", colorScheme.background ) ] [])
                    )
                    []
            )
            model.colorSchemes
        )


demo : Model -> Html Msg
demo model =
    div
        [ style
            [ ( "color", model.questionnaire.colorScheme.mainText )
            , ( "backgroundColor", model.questionnaire.colorScheme.background )
            ]
        ]
        [ if model.isFormActivated then
            div [ class "mh7-l mh2" ]
                [ div [ class "" ] (viewQuestions model (filterQuestions model.questionnaire.questions |> Zipper.withDefault emptyQuestion) model.questionnaire.colorScheme)
                , viewFooter model model.questionnaire.colorScheme
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
            , buttonAsideText options.pressText colors.secondaryText
            ]
        ]


viewQuestions : Model -> Zipper Question -> ColorScheme -> List (Html Msg)
viewQuestions model questions colors =
    List.map
        (\question ->
            case question.validationResult of
                Nothing ->
                    div [] [ viewQuestion model question colors ]

                Just validationError ->
                    div []
                        [ viewQuestion model question colors
                        , viewValidation model question colors
                        ]
        )
        (Zipper.toList questions)


viewValidation : Model -> Question -> ColorScheme -> Html Msg
viewValidation model question colors =
    div [ class "bg-dark-red white di pv2 ph2 ml3" ] [ text (question.validationResult |> Maybe.withDefault "N/A") ]


viewQuestion : Model -> Question -> ColorScheme -> Html Msg
viewQuestion model question colors =
    case question.questionType of
        Text options ->
            viewTextQuestion question options colors

        Email options ->
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


questionContainerClasses : Question -> Html.Attribute msg
questionContainerClasses question =
    if question.isFocused then
        class "pt6 f3"
    else
        class "pt6 f3 o-30"


viewTextQuestion : Question -> TextOptions -> ColorScheme -> Html Msg
viewTextQuestion question options colors =
    div
        [ questionContainerClasses question
        , id (questionIdString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ class "ml3", class "input--hoshi" ]
            [ input
                [ class "input__field--hoshi"
                , style [ ( "color", colors.secondaryText ) ]
                , onClick (TextQuestionClicked question)
                , onInput (TextQuestionInputChanged question)
                , id (inputIdString question.questionNumber)
                , type_ "text"
                ]
                []
            , label [ class "input__label--hoshi hoshi-color-4", for "input-4" ]
                []
            ]
        , div
            [ class "pt2 ml3" ]
            [ if String.length options.internalValue > 0 then
                div []
                    [ viewTextButton colors options.buttonText question.questionNumber
                    , buttonAsideText options.pressText colors.secondaryText
                    ]
              else
                div [] []
            ]
        , Html.br []
            []
        ]


viewSelectQuestion : Model -> Question -> SelectOptions -> ColorScheme -> Html Msg
viewSelectQuestion model question options colors =
    div []
        [ div
            [ questionContainerClasses question
            , id (questionIdString question.questionNumber)
            ]
            [ questionText colors question.questionNumber (parseQuestionText model question.questionText)
            , ul
                [ class "list mw6 nl4 ml0-ns"
                , style [ ( "color", colors.secondaryText ) ]
                , id (inputIdString question.questionNumber)
                ]
                (viewSelectChoices options.choices colors question.questionNumber)
            ]
        ]


viewSelectChoices : List Choice -> ColorScheme -> Int -> List (Html Msg)
viewSelectChoices choices colors id =
    List.map
        (\choice ->
            viewSelectChoice choice id colors
        )
        choices


viewSelectChoice : Choice -> Int -> ColorScheme -> Html Msg
viewSelectChoice choice id colors =
    if choice.isSelected then
        li
            ([ class "ba pa3 br2 mv3 pointer", onClick (LetterClicked id choice.letter) ]
                ++ hover_
                    []
                    [ ( "backgroundColor", colors.selectBackground, colors.selectHover ) ]
            )
            [ span
                [ class "ba ph2 pv1 mr2"
                , style [ ( "backgroundColor", colors.secondaryText ), ( "color", colors.background ) ]
                ]
                [ text choice.letter ]
            , span []
                [ text choice.body ]
            , span [ class "fr fa fa-check" ]
                []
            ]
    else
        li
            ([ class "ba pa3 br2 mv3 pointer", onClick (LetterClicked id choice.letter) ]
                ++ hover_ [] [ ( "backgroundColor", colors.selectBackground, colors.selectHover ) ]
            )
            [ span
                [ class "ba ph2 pv1 mr2"
                , style [ ( "backgroundColor", colors.selectLetterBackground ) ]
                ]
                [ text choice.letter ]
            , span []
                [ text choice.body ]
            ]


viewDropdownQuestion : Model -> Question -> DropdownOptions -> ColorScheme -> Html FD.Msg
viewDropdownQuestion model question options colors =
    div []
        [ div
            [ questionContainerClasses question
            , id (questionIdString question.questionNumber)
            ]
            [ questionText colors question.questionNumber (parseQuestionText model question.questionText)
            , div
                [ class "mw7 pl3"
                , style [ ( "color", colors.secondaryText ) ]
                ]
                [ FD.view options colors question.questionNumber
                ]
            ]
        ]


viewPhotoQuestion : Model -> Question -> PhotoOptions -> ColorScheme -> Html Msg
viewPhotoQuestion model question options colors =
    div
        [ questionContainerClasses question
        , id (questionIdString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ class "" ]
            [ div [ class "cf", style [ ( "color", colors.secondaryText ) ] ]
                (List.map
                    (\photo ->
                        viewSinglePhotoSelect photo question.questionNumber colors
                    )
                    options.choices
                )
            ]
        ]


viewSinglePhotoSelect : Photo -> Int -> ColorScheme -> Html Msg
viewSinglePhotoSelect photo id colors =
    if photo.isSelected then
        div
            ([ class "fl mw5 ba br2 pa2 ma2 ", onClick (LetterClicked id photo.letter) ]
                ++ hover_ [] [ ( "backgroundColor", colors.selectBackground, colors.selectHover ) ]
            )
            [ img [ alt "", class "", src photo.url ]
                []
            , div [ class "tc pv3 f5" ]
                [ span
                    [ class "ba ph2 pv1 mr2 br2"
                    , style [ ( "backgroundColor", colors.secondaryText ), ( "color", colors.background ) ]
                    ]
                    [ text photo.letter ]
                , span []
                    [ text photo.name ]
                ]
            ]
    else
        div
            ([ class "fl mw5 ba br2 pa2 ma2 ", onClick (LetterClicked id photo.letter) ]
                ++ hover_ [] [ ( "backgroundColor", colors.selectBackground, colors.selectHover ) ]
            )
            [ img [ alt "", class "", src photo.url ]
                []
            , div [ class "tc pv3 f5" ]
                [ span
                    [ class "ba ph2 pv1 mr2 br2"
                    , style [ ( "backgroundColor", colors.selectLetterBackground ) ]
                    ]
                    [ text photo.letter ]
                , span []
                    [ text photo.name ]
                ]
            ]


buttonAsideText : String -> String -> Html msg
buttonAsideText asideText asideColor =
    span
        [ class "f6 pl3"
        , style [ ( "color", asideColor ) ]
        ]
        [ text asideText ]


topSectionButton : ColorScheme -> String -> Html Msg
topSectionButton colors buttonText =
    button
        ([ onClick ActivateForm ]
            ++ buttonTopClasses
            ++ hoverStyles colors
        )
        [ span [] [ text buttonText ] ]


viewTextButton : ColorScheme -> String -> Int -> Html Msg
viewTextButton colors buttonText questionNumber =
    button
        ([ onClick (AnswerQuestionWithId questionNumber) ]
            ++ buttonClasses
            ++ hoverStyles colors
        )
        [ span []
            [ text buttonText ]
        , span [ class "fa fa-check" ]
            []
        ]


viewFooterButton : ColorScheme -> Bool -> Bool -> msg -> Html msg
viewFooterButton colors isUp isEnabled action =
    if isEnabled then
        button
            ([ onClick action, class "fr mh1" ]
                ++ buttonClasses
                ++ hoverStyles colors
                ++ [ disabled False ]
            )
            [ span [ class (chevronUpOrDown isUp) ]
                []
            ]
    else
        button
            ([ class "fr mh1" ]
                ++ buttonClasses
                ++ [ style
                        [ ( "color", colors.buttonText )
                        , ( "backgroundColor", colors.buttonHover )
                        ]
                   , disabled True
                   ]
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


buttonTopClasses : List (Attribute msg)
buttonTopClasses =
    [ class ("ph4 " ++ buttonBase)
    ]


buttonClasses : List (Attribute msg)
buttonClasses =
    [ class ("ph3 " ++ buttonBase)
    ]


buttonBase : String
buttonBase =
    "button-reset b br2 pv2 ph3 bn pointer shadow-5"


hoverStyles : ColorScheme -> List (Attribute msg)
hoverStyles colorScheme =
    hover_
        [ ( "color", colorScheme.buttonText )
        ]
        [ ( "backgroundColor", colorScheme.buttonBackground, colorScheme.buttonHover ) ]


questionText : ColorScheme -> Int -> String -> Html msg
questionText colors questionNumber body =
    div [ class "" ]
        [ span [ class "pr2-l fl f2-l f3" ]
            [ span [ style [ ( "color", colors.secondaryText ) ] ]
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
    div [ class "f3  pt6 center tc vh-50", id (questionIdString question.questionNumber) ]
        [ if model.numInvalid > 0 then
            div []
                [ div [ class "mb3", style [ ( "color", "#FFFFFF" ), ( "backgroundColor", "#990000" ) ] ] [ text (toString model.numInvalid ++ " questions are invalid") ]
                , button
                    ([ onClick SubmitQuestionnaire ]
                        ++ buttonTopClasses
                        ++ hover_ [ ( "color", "#FF8080" ) ] [ ( "backgroundColor", "#990000", "#CC0000" ) ]
                    )
                    [ span [] [ text "Review" ] ]
                ]
          else
            button
                ([ onClick SubmitQuestionnaire ]
                    ++ buttonTopClasses
                    ++ hoverStyles colors
                )
                [ span [] [ text options.buttonText ] ]
        , buttonAsideText "press ENTER" model.questionnaire.colorScheme.secondaryText
        ]


viewFooter : Model -> ColorScheme -> Html Msg
viewFooter model colors =
    div
        [ class "fixed left-0 right-0 bottom-0 ph6-l ph2 pv3 fl w-100 bt  "
        , style
            [ ( "backgroundColor", model.questionnaire.colorScheme.background )
            , ( "color", model.questionnaire.colorScheme.secondaryText )
            ]
        ]
        [ div [ class "fl w-50" ]
            (viewFooterProgressBar model colors)
        , div [ class "fl w-50 pt3" ]
            [ viewFooterButton model.questionnaire.colorScheme False model.footerButtonDownEnabled FooterNext
            , viewFooterButton model.questionnaire.colorScheme True model.footerButtonUpEnabled FooterPrevious
            ]
        ]


viewFooterProgressBar : Model -> ColorScheme -> List (Html Msg)
viewFooterProgressBar model colors =
    [ p [] [ text (toString model.numQuestionsAnswered ++ " out of " ++ toString model.totalQuestions ++ " questions completed") ]
    , div [ class "br-pill h1 overflow-y-hidden", style [ ( "backgroundColor", colors.selectLetterBackground ) ] ]
        [ div
            [ class "br-pill h1"
            , style
                [ ( "width", calculateProgressbar model.numQuestionsAnswered model.totalQuestions )
                , ( "backgroundColor", model.questionnaire.colorScheme.secondaryText )
                , ( "color", model.questionnaire.colorScheme.secondaryText )
                ]
            ]
            []
        ]
    ]
