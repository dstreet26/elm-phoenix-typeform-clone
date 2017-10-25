module Widgets.Questionnaire exposing (..)

import Colors exposing (ColorScheme)
import List.Zipper as Zipper exposing (Zipper)


type alias TopSection =
    { imageLink : String
    , headerText : String
    , buttonText : String
    , pressText : String
    }


type QuestionType
    = Text TextOptions
    | Select SelectOptions
    | Dropdown DropdownOptions
    | PhotoSelect PhotoOptions


type alias Choice =
    { letter : String
    , body : String
    }


type alias TextOptions =
    { buttonText : String
    , pressText : String
    }


type alias SelectOptions =
    { choices : List Choice
    }


type alias DropdownOptions =
    { choices : List String
    , filteredChoicesZipped : Zipper String
    , inputValue : String
    , showList : Bool
    }


type alias Photo =
    { name : String
    , url : String
    , letter : String
    }


type alias PhotoOptions =
    { choices : List Photo
    }


type alias Question =
    { questionType : QuestionType
    , questionNumber : Int
    , questionText : String
    , isAnswered : Bool
    , answer : String
    , dependsOn : List Int
    }


type alias Questionnaire =
    { topSection : TopSection
    , questions : List Question
    , name : String
    , colorScheme : Colors.ColorScheme
    }
