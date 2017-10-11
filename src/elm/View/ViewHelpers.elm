--Bootstrap Utilities
--TODO: remove if not using


module View.ViewHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)


mybold sometext =
    div [ classes [ Tachyons.Classes.b ] ] [ text sometext ]
