module Colors exposing (..)

import Color exposing (..)
import Color.Accessibility exposing (..)
import Color.Blending exposing (..)
import Color.Convert exposing (..)
import Color.Gradient exposing (..)
import Color.Interpolate exposing (..)
import Color.Manipulate exposing (..)


type alias FormColors =
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


type alias ColorScheme =
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
