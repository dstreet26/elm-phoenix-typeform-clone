module Widgets.FilterableDropdown exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import TestData.Countries exposing (countries)
import Keyboard
import List.Zipper as Zipper exposing (..)
import Json.Decode as JD


type Msg
    = InputClicked
    | InputChanged String
    | SelectChoice String
    | ArrowClicked
    | KeyDown Int


type Direction
    = Up
    | Down


type alias Model =
    { choices : List String
    , filteredChoicesZipped : Zipper String
    , inputValue : String
    , showList : Bool
    }


model : Model
model =
    { choices = countries
    , filteredChoicesZipped = generateZipper countries
    , inputValue = ""
    , showList = False
    }


generateZipper : List String -> Zipper String
generateZipper choices =
    Zipper.fromList choices |> Zipper.withDefault "Not Found :("


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (JD.map tagger keyCode)



--update : Msg -> Model -> ( Model, Cmd Msg )


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputClicked ->
            (model |> setListVisibility True)

        InputChanged newValue ->
            (model |> setListVisibility True |> setFilterValue newValue |> filterChoices newValue)

        SelectChoice choice ->
            (model |> setInputValue choice |> filterChoices choice |> setListVisibility False)

        KeyDown keyCode ->
            case keyCode of
                13 ->
                    --ENTER
                    (model |> handleEnter |> setListVisibility False)

                38 ->
                    --UP
                    (model |> handleUpOrDown Up)

                40 ->
                    --DOWN
                    (model |> handleUpOrDown Down)

                27 ->
                    --ESC
                    (model |> setListVisibility False)

                _ ->
                    --Everything Else
                    model

        ArrowClicked ->
            (model |> flipVisibility)


flipVisibility : Model -> Model
flipVisibility model =
    if model.showList then
        { model | showList = False }
    else
        { model | showList = True }


handleEnter : Model -> Model
handleEnter model =
    if model.showList then
        { model | inputValue = (Zipper.current model.filteredChoicesZipped) }
    else
        model


handleUpOrDown : Direction -> Model -> Model
handleUpOrDown direction model =
    if model.showList then
        let
            nextZipper =
                case direction of
                    Up ->
                        Zipper.previous model.filteredChoicesZipped

                    Down ->
                        Zipper.next model.filteredChoicesZipped
        in
            { model | filteredChoicesZipped = nextZipper |> Zipper.withDefault "Not Found :(" }
    else
        model


setInputValue : String -> Model -> Model
setInputValue value model =
    { model | inputValue = value }


setFilterValue : String -> Model -> Model
setFilterValue filterValue model =
    { model | inputValue = filterValue }


filterChoices : String -> Model -> Model
filterChoices filterValue model =
    let
        contains query item =
            String.contains (String.toLower query) (String.toLower item)

        filteredItems =
            List.filter
                (\choice ->
                    contains filterValue choice
                )
                model.choices

        filteredZipper =
            generateZipper filteredItems
    in
        { model | filteredChoicesZipped = filteredZipper }


setListVisibility : Bool -> Model -> Model
setListVisibility bool model =
    { model | showList = bool }


view : Model -> Html.Html Msg
view model =
    div []
        [ div [ class "" ]
            [ div [ class "" ]
                [ div [ class " bb" ]
                    [ input
                        [ onKeyDown KeyDown
                        , onClick InputClicked
                        , onInput InputChanged
                        , class "input reset bn  w-90 pv3 f3 bg-transparent on"
                        , placeholder "Type or select an option"
                        , type_ "text"
                        , value model.inputValue
                        ]
                        []
                    , renderArrow model
                    ]
                , if model.showList then
                    theList model
                  else
                    div [] []
                ]
            ]
        ]


renderArrow { showList } =
    if showList then
        div [ onClick ArrowClicked, class "fa fa-chevron-up pointer f1 " ]
            []
    else
        div [ onClick ArrowClicked, class "fa fa-chevron-down pointer f1 " ]
            []


theList { filteredChoicesZipped } =
    div [ class "absolute nano  w-30" ]
        [ ul [ class "list pl0 f3 z-2 overflow-auto   vh-50 " ]
            ((List.map (\choice -> viewLiNormal choice) (Zipper.before filteredChoicesZipped))
                ++ [ viewLiHighlighted (Zipper.current filteredChoicesZipped) ]
                ++ (List.map (\choice -> viewLiNormal choice) (Zipper.after filteredChoicesZipped))
            )
        ]


viewLiNormal choice =
    li [ onClick (SelectChoice choice), class "ba bw1 b--black-20 br2 mv2 ph2 pv2 pointer bg-white-50 hover-bg-silver" ]
        [ text choice ]


viewLiHighlighted choice =
    li [ onClick (SelectChoice choice), class "ba bw1 b--black-20 br2 mv2 ph2 pv2 pointer bg-silver hover-bg-silver" ]
        [ text choice ]
