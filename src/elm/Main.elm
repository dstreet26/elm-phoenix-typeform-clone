module Main exposing (..)

import Date exposing (Date)
import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Form.Input as Input
import Form.Validate as Validate exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import Views.Hello exposing (hello)
import View.ViewHelpers exposing (mybold)


main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }



--Placeholder Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


emptyModel =
    { value = 0
    , userMaybe = Nothing
    }



--Placeholder flags


init : Maybe Flags -> ( Model, Cmd Msg )
init flags =
    --Maybe.withDefault emptyModel flags ! []
    emptyModel ! []


type Msg
    = NoOp
    | Increment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }


view : Model -> Html Msg
view model =
    section [ classes [ w_100, fl, bg_green ] ]
        [ hello model.value
        , button [ class "btn btn-primary btn-lg", onClick Increment ]
            [ span [ class "glyphicon glyphicon-star" ] []
            , span [] [ text "FTW!" ]
            ]
        , div [ class "row" ]
            [ viewTachyonsTest model
            , mybold "hey"
            ]
        ]


viewTachyonsTest : Model -> Html Msg
viewTachyonsTest model =
    div [ classes [ f1, purple, pointer, Tachyons.Classes.b ] ]
        [ text "I'm Purple and big!"
        ]
