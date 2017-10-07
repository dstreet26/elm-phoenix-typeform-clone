module Views.Hello exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import String


hello : Int -> Html a
hello model =
    div
        [ class "h1" ]
        [ text ("Hello, Elm" ++ ("!" |> String.repeat model)) ]
