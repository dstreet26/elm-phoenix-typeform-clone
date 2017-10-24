module TestData.DemoData exposing (..)

import Widgets.Questionnaire exposing (..)
import TestData.Countries exposing (countries)
import TestData.ColorSchemes exposing (lightBlue, hornet)
import List.Zipper as Zipper exposing (..)


demoData : Questionnaire
demoData =
    { topSection = demoTopSection
    , questions =
        [ demoFirstQuestion
        , demoAnotherFirstQuestion
        , demoSecondQuestion
        , demoDropDownQuestion
        ]
    , name = "hey"
    , colorScheme = lightBlue
    }


demoTopSection : TopSection
demoTopSection =
    { imageLink = "svg/square_face.svg"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


demoFirstQuestion : Question
demoFirstQuestion =
    { questionNumber = 1
    , questionType = Text { buttonText = "OK", pressText = "press ENTER" }
    , answer = ""
    , isAnswered = False
    , questionText = "**Hello**. What's your name?*"
    , dependsOn = []
    }


demoAnotherFirstQuestion : Question
demoAnotherFirstQuestion =
    { questionNumber = 2
    , questionType = Text { buttonText = "OK", pressText = "press ENTER" }
    , answer = ""
    , isAnswered = False
    , questionText = "Enter anything, this is a placeholder"
    , dependsOn = []
    }


demoSecondQuestion : Question
demoSecondQuestion =
    { questionNumber = 3
    , questionType =
        Select
            { choices =
                [ { letter = "A", body = "Male" }
                , { letter = "B", body = "Female" }
                , { letter = "C", body = "Other" }
                ]
            }
    , answer = ""
    , isAnswered = False
    , questionText = "Hi, {{question1answer}}. What's your **gender**?"
    , dependsOn = [ 1 ]
    }


demoDropDownQuestion : Question
demoDropDownQuestion =
    { questionNumber = 4
    , questionType =
        Dropdown
            { choices = countries
            , filteredChoicesZipped = generateZipper countries
            , inputValue = ""
            , showList = False
            }
    , answer = ""
    , isAnswered = False
    , questionText = "{{question1answer}} + {{question2answer}}. Pick a country."
    , dependsOn = [ 1, 2 ]
    }


generateZipper : List String -> Zipper String
generateZipper choices =
    Zipper.fromList choices |> Zipper.withDefault "Not Found :("
