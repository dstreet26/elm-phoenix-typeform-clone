module Views.Hello exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Tachyons exposing (classes, tachyons)


--import Tachyons.Classes exposing (f1, purple, pointer, b)

import Tachyons.Classes exposing (..)


hello : Int -> Html a
hello model =
    Html.h1
        [ classes [ Tachyons.Classes.blue ] ]
        [ text ("Hello, Elm" ++ ("!" |> String.repeat model)) ]
