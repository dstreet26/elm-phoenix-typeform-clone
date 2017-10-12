module View.ViewHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)


mybold sometext =
    div [ classes [ Tachyons.Classes.b ] ] [ text sometext ]


liElement letter body =
    li
        [ classes
            [ Tachyons.Classes.ba
            , Tachyons.Classes.pa3
            , Tachyons.Classes.br2
            , Tachyons.Classes.b__black_40
            , Tachyons.Classes.mv3
            , Tachyons.Classes.pointer
            ]
        , class "bg-color-7 typeform-select-hover"
        ]
        [ span
            [ classes
                [ Tachyons.Classes.ba
                , Tachyons.Classes.ph2
                , Tachyons.Classes.pv1
                , Tachyons.Classes.mr2
                ]
            , class "bg-color-8"
            ]
            [ text letter ]
        , span []
            [ text body ]
        ]
