module TestData.ColorSchemes exposing (..)

import Colors exposing (ColorScheme)


allColors : List ColorScheme
allColors =
    [ lightBlue
    , pinky
    , insight
    , gusher
    ]


lightBlue : ColorScheme
lightBlue =
    { mainText = "#5fb4bf"
    , background = "#E5F3F5"
    , buttonText = "#275b62"
    , buttonBackground = "#73BEC8"
    , buttonHover = "#98cfd6"
    , secondaryText = "#696969"
    , selectBackground = "#DFEDEE"
    , selectHover = "#CCD7D9"
    , selectLetterBackground = "#C7D2D4"
    , footerBackground = "#E1EEF0"
    }


pinky : ColorScheme
pinky =
    { mainText = "#FFFFFF"
    , background = "#C384C5"
    , buttonText = "#6B6B6B"
    , buttonBackground = "#EBEBEB"
    , buttonHover = "#D2D2D2"
    , secondaryText = "#F6FFB5"
    , selectBackground = "#C68AC4"
    , selectHover = "#CD9DC2"
    , selectLetterBackground = "#CFA2C1"
    , footerBackground = "#BB7FBD"
    }


insight : ColorScheme
insight =
    { mainText = "#C9A538"
    , background = "#FAF2DB"
    , buttonText = "#634E0E"
    , buttonBackground = "#E4BB3F"
    , buttonHover = "#EACB6C"
    , secondaryText = "#7A7A7A"
    , selectBackground = "#F4EDD7"
    , selectHover = "#E0DAC7"
    , selectLetterBackground = "#DBD6C4"
    , footerBackground = "#F5EDD7"
    }


gusher : ColorScheme
gusher =
    { mainText = "#FFFFFF"
    , background = "#C85976"
    , buttonText = "#808080"
    , buttonBackground = "#FFFFFF"
    , buttonHover = "#E6E6E6"
    , secondaryText = "#F6FFB5"
    , selectBackground = "#CA6178"
    , selectHover = "#CE7A82"
    , selectLetterBackground = "#CF8084"
    , footerBackground = "#BF5570"
    }
