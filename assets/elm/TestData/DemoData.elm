module TestData.DemoData exposing (..)

import Widgets.Questionnaire exposing (..)
import TestData.Countries exposing (countries)
import TestData.ColorSchemes exposing (..)
import List.Zipper as Zipper exposing (..)


demoData : Questionnaire
demoData =
    { topSection = demoTopSection
    , questions = (Zipper.fromList questions |> Zipper.withDefault emptyQuestion)
    , name = "hey"
    , colorScheme = lightBlue
    }


emptyQuestion : Question
emptyQuestion =
    { questionNumber = 0
    , questionType = Submit { buttonText = "N/A" }
    , answer = ""
    , isAnswered = False
    , questionText = "EMPTY QUESTION"
    , dependsOn = []
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
    }


questions : List Question
questions =
    [ demoTextQuestion
    , demoAnotherTextQuestion
    , demoSelectQuestion
    , demoDropDownQuestion
    , demoPhotoQuestion
    , submitQuestion
    ]


demoTopSection : TopSection
demoTopSection =
    { imageLink = "svg/square_face.svg"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


demoTextQuestion : Question
demoTextQuestion =
    { questionNumber = 1
    , questionType =
        Text
            { buttonText = "OK"
            , pressText = "press ENTER"
            , internalValue = ""
            }
    , answer = ""
    , isAnswered = False
    , questionText = "**Hello**. What's your name?*"
    , dependsOn = []
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
    }


demoAnotherTextQuestion : Question
demoAnotherTextQuestion =
    { questionNumber = 2
    , questionType =
        Email
            { buttonText = "OK"
            , pressText = "press ENTER"
            , internalValue = ""
            }
    , answer = ""
    , isAnswered = False
    , questionText = "Enter anything, this is a placeholder"
    , dependsOn = []
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
    }


demoSelectQuestion : Question
demoSelectQuestion =
    { questionNumber = 3
    , questionType =
        Select
            { choices =
                [ { letter = "A"
                  , body = "Male"
                  , isSelected = False
                  }
                , { letter = "B"
                  , body = "Female"
                  , isSelected = False
                  }
                , { letter = "C"
                  , body = "Other"
                  , isSelected = False
                  }
                ]
            }
    , answer = ""
    , isAnswered = False
    , questionText = "Hi, {{question1answer}}. What's your **gender**?"
    , dependsOn = [ 1 ]
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
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
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
    }


demoPhotos : List Photo
demoPhotos =
    [ { name = "City"
      , url = "images/city.jpg"
      , letter = "A"
      , isSelected = False
      }
    , { name = "Countryside"
      , url = "images/countryside.jpg"
      , letter = "B"
      , isSelected = False
      }
    , { name = "Mountain"
      , url = "images/mountain.jpg"
      , letter = "C"
      , isSelected = False
      }
    , { name = "Beach"
      , url = "images/beach.jpg"
      , letter = "D"
      , isSelected = False
      }
    ]


demoPhotoQuestion : Question
demoPhotoQuestion =
    { questionNumber = 5
    , questionType =
        PhotoSelect { choices = demoPhotos }
    , answer = ""
    , isAnswered = False
    , questionText = "Which of these scenes makes you feel happiest?"
    , dependsOn = []
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
    }


submitQuestion : Question
submitQuestion =
    { questionNumber = 6
    , questionType =
        Submit { buttonText = "Submit" }
    , answer = ""
    , isAnswered = False
    , questionText = ""
    , dependsOn = []
    , isFocused = False
    , isRequired = True
    , validationResult = Nothing
    }


generateZipper : List String -> Zipper String
generateZipper choices =
    Zipper.fromList choices |> Zipper.withDefault "Not Found :("
