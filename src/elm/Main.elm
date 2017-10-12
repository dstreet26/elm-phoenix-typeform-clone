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
    div [ classes [ fl, w_100 ], class "bg-typeform-blue montserrat color-1" ]
        [ viewTopSection model
        , viewFirstQuestion model
        , viewSecondQuestion model
        ]


viewTachyonsTest : Model -> Html Msg
viewTachyonsTest model =
    div [ classes [ f1, purple, pointer, Tachyons.Classes.b ] ]
        [ text "I'm Purple and big!"
        ]


viewTopSection model =
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
            , Html.Attributes.src "static/img/typeform-example-face.png"
            ]
            []
        , p [ classes [], class "color-1" ] [ text "Hey stranger, I'm dying to get to know you better!" ]
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
                , class "color-3 bg-typeform-blue2 typeform-button-hover"
                ]
                [ span [] [ text "Talk to me" ] ]
            , span [ classes [ Tachyons.Classes.f6 ], class "color-5 arial" ] [ text "press ENTER" ]
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
            , span [ classes [ Tachyons.Classes.f_6 ], class "color-5" ]
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
