module Widgets.Questionnaire exposing (..)

import Colors exposing (FormColors)
import Widgets.FilterableDropdown as FD


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
    , fdModel : FD.Model
    }


type alias Question =
    { questionType : QuestionType
    , questionNumber : Int
    , questionText : String
    , isAnswered : Bool
    , answer : String
    }


type alias Questionnaire =
    { topSection : TopSection
    , questions : List Question
    , name : String
    , colorScheme : Colors.ColorScheme
    }
