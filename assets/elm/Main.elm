module Main exposing (..)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import DynamicStyle exposing (..)
import Markdown exposing (toHtml)
import SmoothScroll exposing (scrollTo)


main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }



--Model


type alias Flags =
    { user : String
    , token : String
    }


type alias Model =
    { value : Int
    , demoData : DemoData
    }


type Question
    = QuestionTypeText TextQuestion
    | QuestionTypeSelect SelectQuestion


type alias DemoData =
    { topSection : TopSection
    , questions : List Question
    , name : String
    , colors : DemoColors
    }


type alias DemoColors =
    { colorMain : String
    , colorBackground : String
    , colorText : String
    , colorButton : String
    , colorButtonBackground : String
    , colorButtonHover : String
    , colorGray : String
    , colorSelectBackground : String
    , colorSelectHover : String
    , colorSelectLetterBackground : String
    , colorFooterBackground : String
    , colorFooter : String
    }


type alias TopSection =
    { imageLink : String
    , headerText : String
    , buttonText : String
    , pressText : String
    }


type alias TextQuestion =
    { questionNumber : String
    , questionText : String
    , buttonText : String
    , pressText : String
    }


type alias Choice =
    { letter : String
    , body : String
    }


type alias SelectQuestion =
    { questionNumber : String
    , questionText : String
    , choices : List Choice
    }



--Placeholder Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


emptyModel =
    { value = 0
    , demoData = demoData
    }



--Placeholder flags


init : Maybe Flags -> ( Model, Cmd Msg )
init flags =
    emptyModel ! []


type Msg
    = NoOp
    | Increment
    | ScrollTo2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )

        ScrollTo2 ->
            ( model, scrollTo "question2" )


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }


view : Model -> Html Msg
view model =
    div [ classes [ fl, w_100 ], class "montserrat" ]
        [ div [] [ button [ Html.Events.onClick ScrollTo2 ] [ text "scrollto2" ] ]
        , demo model.demoData
        ]


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


demoData : DemoData
demoData =
    { topSection = demoTopSection
    , questions = [ QuestionTypeText demoFirstQuestion, QuestionTypeSelect demoSecondQuestion ]
    , name = "hey"
    , colors = demoColors
    }


demoColors : DemoColors
demoColors =
    { colorMain = "#5fb4bf"
    , colorBackground = "#E5F3F5"
    , colorText = "#275b62"
    , colorButton = "#275b62"
    , colorButtonBackground = "#73BEC8"
    , colorButtonHover = "#98cfd6"
    , colorGray = "#696969"
    , colorSelectBackground = "#DFEDEE"
    , colorSelectHover = "#CCD7D9"
    , colorSelectLetterBackground = "#C7D2D4"
    , colorFooterBackground = "#E1EEF0"
    , colorFooter = "#7C697F"
    }


demo : DemoData -> Html msg
demo data =
    div [ Html.Attributes.style [ ( "color", data.colors.colorMain ), ( "backgroundColor", data.colors.colorBackground ) ] ]
        [ viewTopSection data.topSection data.colors
        , div [] (mapQuestions data.questions data.colors)
        , viewFooter data.colors.colorFooter data.colors.colorFooterBackground data.colors.colorButton data.colors.colorButtonBackground data.colors.colorButtonHover
        ]


viewFooter colorFooter colorBackground colorButton colorButtonBackground colorButtonHover =
    div [ class "fixed left-0 right-0 bottom-0 ph6 pv3 fl w-100 bt  ", style [ ( "backgroundColor", colorBackground ), ( "color", colorFooter ) ] ]
        [ div [ class "fl w-50" ]
            [ p [] [ text "0% completed" ]
            , div [ class "bg-moon-gray br-pill h1 overflow-y-hidden" ] [ div [ class "bg-blue br-pill h1 shadow-1 w-third" ] [] ]
            ]
        , div [ class "fl w-50" ]
            [ typeFormFooterButton colorButton colorButtonBackground colorButtonHover True
            , typeFormFooterButton colorButton colorButtonBackground colorButtonHover False
            ]
        ]



--div [ class "footer ph6 pv3 fl w-100 bt tc  ", style [ ( "backgroundColor", colorBackground ), ( "color", color ) ] ] [ text "footer" ]


mapQuestions questions colors =
    List.map
        (\question ->
            viewQuestion question colors
        )
        questions


viewQuestion question colors =
    case question of
        QuestionTypeText options ->
            viewTextQuestion options colors

        QuestionTypeSelect options ->
            viewSelectQuestion options colors


demoTopSection : TopSection
demoTopSection =
    { imageLink = "images/typeform-example-face.png"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


demoFirstQuestion : TextQuestion
demoFirstQuestion =
    { questionNumber = "1"
    , questionText = "**Hello**. What's your name?*"
    , pressText = "press ENTER"
    , buttonText = "OK"
    }


demoSecondQuestion : SelectQuestion
demoSecondQuestion =
    { questionNumber = "2"
    , questionText = "Hi, asdf. What's your **gender**?"
    , choices =
        [ { letter = "A", body = "hey" }
        , { letter = "B", body = "still hardcoded" }
        , { letter = "C", body = "but safer" }
        ]
    }


viewTopSection : TopSection -> DemoColors -> Html msg
viewTopSection options colors =
    div
        [ classes
            [ Tachyons.Classes.pt6
            , Tachyons.Classes.f3
            , Tachyons.Classes.mw7
            , Tachyons.Classes.center
            , Tachyons.Classes.tc
            , Tachyons.Classes.vh_100
            ]
        , Html.Attributes.id "topsection"
        ]
        [ img
            [ classes []
            , Html.Attributes.src options.imageLink
            ]
            []
        , p [ classes [] ] [ Html.text options.headerText ]
        , div []
            [ topSectionButton colors options.buttonText
            , buttonAsideText options.pressText colors.colorGray
            ]
        ]


viewTextQuestion : TextQuestion -> DemoColors -> Html msg
viewTextQuestion options colors =
    div
        [ classes
            [ Tachyons.Classes.mt6
            , Tachyons.Classes.mh7
            , Tachyons.Classes.f3
            , Tachyons.Classes.vh_100
            ]
        , Html.Attributes.id ("question" ++ options.questionNumber)
        ]
        [ questionText colors options.questionNumber options.questionText
        , div [ classes [ Tachyons.Classes.ml3 ], Html.Attributes.class "input--hoshi" ]
            [ input [ Html.Attributes.class "input__field--hoshi", Html.Attributes.id "input-4", type_ "text" ]
                []
            , label [ Html.Attributes.class "input__label--hoshi hoshi-color-4", for "input-4" ]
                []
            ]
        , div
            [ classes
                [ Tachyons.Classes.pt2
                , Tachyons.Classes.ml3
                ]
            ]
            [ typeFormButton colors options.buttonText
            , buttonAsideText options.pressText colors.colorGray
            ]
        , Html.br []
            []
        ]


viewSelectQuestion : SelectQuestion -> DemoColors -> Html msg
viewSelectQuestion options colors =
    div []
        [ div
            [ classes
                [ Tachyons.Classes.mt6
                , Tachyons.Classes.mh7
                , Tachyons.Classes.f3
                , Tachyons.Classes.vh_100
                ]
            , Html.Attributes.id ("question" ++ options.questionNumber)
            ]
            [ questionText colors options.questionNumber options.questionText
            , ul
                [ classes
                    [ Tachyons.Classes.list
                    , Tachyons.Classes.mw6
                    ]
                , Html.Attributes.style [ ( "color", colors.colorGray ) ]
                ]
                (listChoices options.choices colors)
            ]
        ]


listChoices choices colors =
    List.map
        (\choice ->
            liElement choice.letter choice.body colors.colorSelectBackground colors.colorSelectHover colors.colorSelectLetterBackground
        )
        choices


questionText colors questionNumber body =
    div [ Html.Attributes.class "" ]
        [ span [ classes [ Tachyons.Classes.pr2, Tachyons.Classes.fl ] ]
            [ span [ Html.Attributes.style [ ( "color", colors.colorGray ) ] ]
                [ span [ classes [ Tachyons.Classes.pr1 ] ]
                    [ Html.text questionNumber ]
                , span [ Html.Attributes.class "fa fa-arrow-right" ]
                    []
                ]
            ]
        , span [] <|
            toHtml Nothing body
        ]
