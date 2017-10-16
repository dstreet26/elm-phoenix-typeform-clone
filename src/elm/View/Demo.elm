module View.Demo exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import View.ViewHelpers exposing (liElement, topSectionButton, typeFormButton, buttonAsideText)
import Markdown exposing (toHtml)


demoData : DemoData
demoData =
    { topSection = demoTopSection
    , questions = [ QuestionTypeText demoFirstQuestion, QuestionTypeSelect demoSecondQuestion ]
    , name = "hey"
    , colors = demoColors
    }


demoColors : DemoColors
demoColors =
    { colorMain = "#5fb4bf"
    , colorBackground = "#E5F3F5"
    , colorText = "#275b62"
    , colorButton = "#275b62"
    , colorButtonBackground = "#73BEC8"
    , colorButtonHover = "#98cfd6"
    , colorGray = "#696969"
    , colorSelectBackground = "#DFEDEE"
    , colorSelectHover = "#CCD7D9"
    , colorSelectLetterBackground = "#C7D2D4"
    }


demo : DemoData -> Html msg
demo data =
    div [ Html.Attributes.style [ ( "color", data.colors.colorMain ), ( "backgroundColor", data.colors.colorBackground ) ] ]
        [ viewTopSection data.topSection data.colors
        , div [] (mapQuestions data.questions data.colors)
        ]


mapQuestions questions colors =
    List.map
        (\question ->
            viewQuestion question colors
        )
        questions


viewQuestion question colors =
    case question of
        QuestionTypeText options ->
            viewTextQuestion options colors

        QuestionTypeSelect options ->
            viewSelectQuestion options colors


demoTopSection : TopSection
demoTopSection =
    { imageLink = "static/img/typeform-example-face.png"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


demoFirstQuestion : TextQuestion
demoFirstQuestion =
    { questionNumber = "1"
    , questionText = "**Hello**. What's your name?*"
    , pressText = "press ENTER"
    , buttonText = "OK"
    }


demoSecondQuestion : SelectQuestion
demoSecondQuestion =
    { questionNumber = "2"
    , questionText = "Hi, asdf. What's your **gender**?"
    , choices =
        [ { letter = "A", body = "hey" }
        , { letter = "B", body = "still hardcoded" }
        , { letter = "C", body = "but safer" }
        ]
    }


viewTopSection : TopSection -> DemoColors -> Html msg
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


viewTextQuestion : TextQuestion -> DemoColors -> Html msg
viewTextQuestion options colors =
    div
        [ classes
            [ Tachyons.Classes.mt6
            , Tachyons.Classes.mh7
            , Tachyons.Classes.f3
            , Tachyons.Classes.vh_100
            ]
        ]
        [ questionText colors options.questionNumber options.questionText
        , div [ classes [ Tachyons.Classes.ml3 ], Html.Attributes.class "input--hoshi" ]
            [ input [ Html.Attributes.class "input__field--hoshi", Html.Attributes.id "input-4", type_ "text" ]
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
            [ typeFormButton colors options.buttonText
            , buttonAsideText options.pressText colors.colorGray
            ]
        , Html.br []
            []
        ]


viewSelectQuestion : SelectQuestion -> DemoColors -> Html msg
viewSelectQuestion options colors =
    div []
        [ div
            [ classes
                [ Tachyons.Classes.mt6
                , Tachyons.Classes.mh7
                , Tachyons.Classes.f3
                , Tachyons.Classes.vh_100
                ]
            ]
            [ questionText colors options.questionNumber options.questionText
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
                    [ Html.text questionNumber ]
                , span [ Html.Attributes.class "fa fa-arrow-right" ]
                    []
                ]
            ]
        , span [] <|
            toHtml Nothing body
        ]
