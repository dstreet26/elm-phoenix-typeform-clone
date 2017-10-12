module View.Demo exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import View.ViewHelpers exposing (liElement)


demoData : DemoData
demoData =
    { topSection = demoTopSection
    , firstQuestion = demoFirstQuestion
    , name = "hey"
    , colors = demoColors
    }


demoColors : DemoColors
demoColors =
    { colorMain = "color-1"
    , colorText = "color-3"
    , colorButton = "color-3"
    , colorButtonBackground = "bg-typeform-blue2"
    , colorButtonHover = "typeform-button-hover"
    , colorGray = "color-5"
    }


demo : DemoData -> Html msg
demo data =
    div []
        [ viewTopSection data.topSection data.colors
        , viewFirstQuestion data.firstQuestion data.colors
        , viewSecondQuestion data.topSection
        ]


demoTopSection : TopSection
demoTopSection =
    { imageLink = "static/img/typeform-example-face.png"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


demoFirstQuestion : FirstQuestion
demoFirstQuestion =
    { questionNumber = "1"
    , headerText = ". What's your name?*"
    , headerTextBold = "Hello"
    , pressText = "press ENTER"
    , buttonText = "OK"
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
        , p [ classes [], class colors.colorText ] [ text options.headerText ]
        , div []
            [ button
                [ classes
                    [ Tachyons.Classes.button_reset
                    , Tachyons.Classes.b
                    , Tachyons.Classes.br2
                    , Tachyons.Classes.pv2
                    , Tachyons.Classes.ph4
                    , Tachyons.Classes.bn
                    , Tachyons.Classes.pointer
                    , Tachyons.Classes.shadow_5
                    ]
                , classes
                    [ colors.colorButton
                    , colors.colorButtonBackground
                    , colors.colorButtonHover
                    ]
                ]
                [ span [] [ text options.buttonText ] ]
            , span [ classes [ Tachyons.Classes.f6 ], class colors.colorGray ] [ text options.pressText ]
            ]
        ]


viewFirstQuestion : FirstQuestion -> DemoColors -> Html msg
viewFirstQuestion options colors =
    div
        [ classes
            [ Tachyons.Classes.mt6
            , Tachyons.Classes.mh7
            , Tachyons.Classes.f3
            , Tachyons.Classes.vh_100
            ]
        ]
        [ span [ classes [ Tachyons.Classes.pr2 ], class colors.colorGray ]
            [ span [ classes [ Tachyons.Classes.pr1 ] ]
                [ text options.questionNumber ]
            , span [ class "fa fa-arrow-right" ]
                []
            ]
        , span []
            [ Html.b []
                [ text options.headerTextBold ]
            , text options.headerText
            ]
        , div [ classes [ Tachyons.Classes.ml3 ], class "input--hoshi" ]
            [ input [ class "input__field--hoshi", id "input-4", type_ "text" ]
                []
            , label [ class "input__label--hoshi hoshi-color-4", for "input-4" ]
                []
            ]
        , div
            [ classes
                [ Tachyons.Classes.pt2
                , Tachyons.Classes.ml3
                ]
            ]
            [ button
                typeformButton
                [ span []
                    [ text options.buttonText ]
                , span [ class "fa fa-check" ]
                    []
                ]
            , span [ classes [ Tachyons.Classes.f6 ], class "color-5" ]
                [ text options.pressText ]
            ]
        , Html.br []
            []
        ]


typeformButton =
    [ classes
        [ Tachyons.Classes.button_reset
        , Tachyons.Classes.b
        , Tachyons.Classes.br2
        , Tachyons.Classes.pv2
        , Tachyons.Classes.ph3
        , Tachyons.Classes.bn
        , Tachyons.Classes.pointer
        , Tachyons.Classes.shadow_5
        ]
    , class "bg-typeform-blue2 color-3 typeform-button-hover"
    ]


viewSecondQuestion model =
    div []
        [ div
            [ classes
                [ Tachyons.Classes.mt6
                , Tachyons.Classes.mh7
                , Tachyons.Classes.f3
                , Tachyons.Classes.vh_100
                ]
            ]
            [ span [ classes [ Tachyons.Classes.pr2 ] ]
                [ span [ classes [ Tachyons.Classes.pr1 ], class "color-5" ]
                    [ text "2" ]
                , span [ class " color-5 fa fa-arrow-right" ]
                    []
                ]
            , span []
                [ text "Hi, asdf. What's your "
                , Html.b []
                    [ text "gender" ]
                , text "?"
                ]
            , ul
                [ classes
                    [ Tachyons.Classes.list
                    , Tachyons.Classes.mw5
                    ]
                , class "color-5"
                ]
                [ liElement "A" "hey"
                , liElement "B" "hey"
                , liElement "X" "hardcoded!"
                ]
            ]
        ]
