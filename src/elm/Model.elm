module Model exposing (..)

import Date exposing (Date)


--import Form exposing (Form)
--import Form.Field as Field exposing (Field)
--import Form.Input as Input
--import Form.Validate as Validate exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


--import Model exposing (..)

import Regex
import Set exposing (Set)
import String


--import View.Bootstrap exposing (..)

import Views.Hello exposing (hello)


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



--type CustomError
--    = Ooops
--    | Nope
--    | AlreadyTaken
--    | InvalidSuperpower
--type alias User =
--    { name : String
--    , email : String
--    , admin : Bool
--    , date : Date
--    , profile : Profile
--    , todos : List Todo
--    }
--type alias Profile =
--    { website : Maybe String
--    , role : String
--    , superpower : Superpower
--    , age : Int
--    , bio : String
--    }
--type Superpower
--    = Flying
--    | Invisible
--type alias Todo =
--    { done : Bool
--    , label : String
--    }
