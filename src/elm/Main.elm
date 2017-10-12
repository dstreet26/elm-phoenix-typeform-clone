module Main exposing (..)

import Date exposing (Date)


--import Form exposing (Form)
--import Form.Field as Field exposing (Field)
--import Form.Input as Input
--import Form.Validate as Validate exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import Views.Hello exposing (hello)
import View.ViewHelpers exposing (mybold)
import View.Demo as Demo exposing (..)


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


topSectionOptions : Model.TopSection
topSectionOptions =
    { imageLink = "static/img/typeform-example-face.png"
    , colorText = "color-1"
    , colorButton = "color-3"
    , colorButtonBackground = "bg-typeform-blue2"
    , colorButtonHover = "typeform-button-hover"
    , colorGray = "color-5"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


view : Model -> Html Msg
view model =
    div [ classes [ fl, w_100 ], class "bg-typeform-blue montserrat color-1" ]
        [ Demo.viewTopSection topSectionOptions
        , Demo.viewFirstQuestion model
        , Demo.viewSecondQuestion model
        ]


viewTachyonsTest : Model -> Html Msg
viewTachyonsTest model =
    div [ classes [ f1, purple, pointer, Tachyons.Classes.b ] ]
        [ text "I'm Purple and big!"
        ]
