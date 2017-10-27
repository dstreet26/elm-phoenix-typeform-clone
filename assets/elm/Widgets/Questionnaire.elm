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
    | Submit SubmitOptions


type alias Choice =
    { letter : String
    , body : String
    , isSelected : Bool
    }


type alias TextOptions =
    { buttonText : String
    , pressText : String
    , internalValue : String
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
    , isSelected : Bool
    }


type alias PhotoOptions =
    { choices : List Photo
    }


type alias SubmitOptions =
    { buttonText : String
    }


type alias Question =
    { questionType : QuestionType
    , questionNumber : Int
    , questionText : String
    , isAnswered : Bool
    , answer : String
    , dependsOn : List Int
    , isFocused : Bool
    }


type alias Questionnaire =
    { topSection : TopSection
    , questions : Zipper Question
    , name : String
    , colorScheme : Colors.ColorScheme
    }
