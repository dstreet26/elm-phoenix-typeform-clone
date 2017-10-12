--Bootstrap Utilities
--TODO: remove if not using


module View.Demo exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import View.ViewHelpers exposing (liElement)


viewTopSection topSectionOptions =
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
            , Html.Attributes.src topSectionOptions.imageLink
            ]
            []
        , p [ classes [], class topSectionOptions.colorText ] [ text topSectionOptions.headerText ]
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
                    [ topSectionOptions.colorButton
                    , topSectionOptions.colorButtonBackground
                    , topSectionOptions.colorButtonHover
                    ]
                ]
                [ span [] [ text topSectionOptions.buttonText ] ]
            , span [ classes [ Tachyons.Classes.f6 ], class topSectionOptions.colorGray ] [ text topSectionOptions.pressText ]
            ]
        ]


viewFirstQuestion model =
    div
        [ classes
            [ Tachyons.Classes.mt6
            , Tachyons.Classes.mh7
            , Tachyons.Classes.f3
            , Tachyons.Classes.vh_100
            ]
        ]
        [ span [ classes [ Tachyons.Classes.pr2 ] ]
            [ span [ classes [ Tachyons.Classes.pr1 ], class "color-5" ]
                [ text "1" ]
            , span [ class "color-5 fa fa-arrow-right" ]
                []
            ]
        , span []
            [ Html.b []
                [ text "Hello" ]
            , text ". What's your name?*"
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
                [ span []
                    [ text "OK" ]
                , span [ class "fa fa-check" ]
                    []
                ]
            , span [ classes [ Tachyons.Classes.f6 ], class "color-5" ]
                [ text "press ENTER" ]
            ]
        , Html.br []
            []
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
