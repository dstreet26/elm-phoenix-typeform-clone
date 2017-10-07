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


--import Model exposing (..)

import Regex
import Set exposing (Set)
import String
import View.Bootstrap exposing (..)
import Views.Hello exposing (hello)


main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }



--Placeholder flags
--Placeholder Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


emptyModel =
    { value = 0
    , form = Form.initial initialFields validate
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
    | FormMsg Form.Msg


update : Msg -> Model -> ( Model, Cmd Msg )



--update msg model =


update msg ({ form } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )

        FormMsg formMsg ->
            case ( formMsg, Form.getOutput form ) of
                ( Form.Submit, Just user ) ->
                    ( { model | userMaybe = Just user }, Cmd.none )

                _ ->
                    ( { model | form = Form.update validate formMsg form }, Cmd.none )



-- CSS STYLES


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ -- inline CSS (literal)
          div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ div [ class "jumbotron" ]
                    [ img [ src "static/img/elm.jpg", style styles.img ] []
                      -- inline CSS (via var)
                    , hello model.value
                      -- ext 'hello' component (takes 'model' as arg)
                    , p [] [ text ("Elm Webpack Starter") ]
                    , button [ class "btn btn-primary btn-lg", onClick Increment ]
                        [ -- click handler
                          span [ class "glyphicon glyphicon-star" ] []
                          -- glyphicon
                        , span [] [ text "FTW!" ]
                        ]
                    ]
                ]
            ]
        , div [ class "row" ]
            [ viewFormExample model
            ]
        ]


viewFormExample : Model -> Html Msg



--viewFormExample model =
--    div [] [ text "hey" ]


viewFormExample model =
    div
        []
        [ Html.map FormMsg (formView model.form)
        , case model.userMaybe of
            Just user ->
                p [ class "alert alert-success" ] [ text (toString user) ]

            Nothing ->
                text ""
        ]


formView : Form CustomError User -> Html Form.Msg
formView form =
    let
        roleOptions =
            ( "", "--" ) :: (List.map (\i -> ( i, String.toUpper i )) roles)

        superpowerOptions =
            List.map (\i -> ( i, String.toUpper i )) superpowers

        disableSubmit =
            Set.isEmpty <| Form.getChangedFields form

        submitBtnAttributes =
            [ onClick Form.Submit
            , classList
                [ ( "btn btn-primary", True )
                , ( "disabled", disableSubmit )
                ]
            ]
                ++ if disableSubmit then
                    [ attribute "disabled" "true" ]
                   else
                    []
    in
        div
            [ class "form-horizontal"
            , style [ ( "margin", "50px auto" ), ( "width", "600px" ) ]
            ]
            [ legend [] [ text "Elm Simple Form example" ]
            , textGroup (text "Name")
                (Form.getFieldAsString "name" form)
            , textGroup (text "Email address")
                (Form.getFieldAsString "email" form)
            , checkboxGroup (text "Administrator")
                (Form.getFieldAsBool "admin" form)
            , dateGroup (text "Date")
                (Form.getFieldAsString "date" form)
            , textGroup (text "Website")
                (Form.getFieldAsString "profile.website" form)
            , selectGroup roleOptions
                (text "Role")
                (Form.getFieldAsString "profile.role" form)
            , radioGroup superpowerOptions
                (text "Superpower")
                (Form.getFieldAsString "profile.superpower" form)
            , textGroup (text "Age")
                (Form.getFieldAsString "profile.age" form)
            , textAreaGroup (text "Bio")
                (Form.getFieldAsString "profile.bio" form)
            , todosView form
            , formActions
                [ button submitBtnAttributes
                    [ text "Submit" ]
                , text " "
                , button
                    [ onClick (Form.Reset initialFields)
                    , class "btn btn-default"
                    ]
                    [ text "Reset" ]
                ]
            ]


todosView : Form CustomError User -> Html Form.Msg
todosView form =
    let
        allTodos =
            List.concatMap (todoItemView form) (Form.getListIndexes "todos" form)
    in
        div
            [ class "row" ]
            [ colN 3
                [ label [ class "control-label" ] [ text "Todolist" ]
                , br [] []
                , button [ onClick (Form.Append "todos"), class "btn btn-xs btn-default" ] [ text "Add" ]
                ]
            , colN 9
                [ div [ class "todos" ] allTodos
                ]
            ]


todoItemView : Form CustomError User -> Int -> List (Html Form.Msg)
todoItemView form i =
    let
        labelField =
            Form.getFieldAsString ("todos." ++ (toString i) ++ ".label") form
    in
        [ div
            [ class ("input-group" ++ (errorClass labelField.liveError)) ]
            [ span
                [ class "input-group-addon" ]
                [ Input.checkboxInput
                    (Form.getFieldAsBool ("todos." ++ (toString i) ++ ".done") form)
                    []
                ]
            , Input.textInput
                labelField
                [ class "form-control" ]
            , span
                [ class "input-group-btn" ]
                [ button
                    [ onClick (Form.RemoveItem "todos" i), class "btn btn-danger" ]
                    [ text "Remove" ]
                ]
            ]
        , br [] []
        ]
