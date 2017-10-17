module View.ViewHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import DynamicStyle exposing (..)


mybold sometext =
    div [ classes [ Tachyons.Classes.b ] ] [ text sometext ]


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


topSectionButton colors buttonText =
    button ((buttonTopTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover)) [ span [] [ Html.text buttonText ] ]


typeFormButton colors buttonText =
    button
        ((buttonTypeformTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover))
        [ span []
            [ Html.text buttonText ]
        , span [ Html.Attributes.class "fa fa-check" ]
            []
        ]


typeFormFooterButton colorButton colorButtonBackground colorButtonHover isUp =
    button
        ((buttonTypeformTachyons) ++ (hoverStyles colorButton colorButtonBackground colorButtonHover))
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
