module Model exposing (..)

import Date exposing (Date)
import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Form.Input as Input
import Form.Validate as Validate exposing (..)
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
    , userMaybe : Maybe User
    }


type CustomError
    = Ooops
    | Nope
    | AlreadyTaken
    | InvalidSuperpower


type alias User =
    { name : String
    , email : String
    , admin : Bool
    , date : Date
    , profile : Profile
    , todos : List Todo
    }


type alias Profile =
    { website : Maybe String
    , role : String
    , superpower : Superpower
    , age : Int
    , bio : String
    }


type Superpower
    = Flying
    | Invisible


type alias Todo =
    { done : Bool
    , label : String
    }


initialFields : List ( String, Field )
initialFields =
    [ ( "name", Field.string "hey" )
    , ( "profile"
      , Field.group
            [ ( "age", Field.string "33" ) ]
      )
    , ( "todos"
      , Field.list
            [ Field.group
                [ ( "done", Field.bool True )
                , ( "label", Field.string "Remember the milk" )
                ]
            ]
      )
    ]


roles : List String
roles =
    [ "role1", "role2" ]


superpowers : List String
superpowers =
    [ "flying", "invisible" ]


validate : Validation CustomError User
validate =
    map6
        User
        (field "name" (string |> andThen nonEmpty))
        (field "email" (email |> andThen (asyncCheck True)))
        (field "admin" (bool |> Validate.defaultValue False))
        (field "date" date)
        (field "profile" validateProfile)
        (field "todos" (Validate.list validateTodo))


validateProfile : Validation CustomError Profile
validateProfile =
    succeed Profile
        |> andMap
            (field "website"
                (oneOf
                    [ emptyString |> Validate.map (\_ -> Nothing)
                    , validateUrl |> Validate.map Just
                    ]
                )
            )
        |> andMap (field "role" (string |> andThen (includedIn roles)))
        |> andMap (field "superpower" validateSuperpower)
        |> andMap (field "age" naturalInt)
        |> andMap (field "bio" (string |> Validate.defaultValue ""))


validateSuperpower : Validation CustomError Superpower
validateSuperpower =
    customValidation
        string
        (\s ->
            case s of
                "flying" ->
                    Ok Flying

                "invisible" ->
                    Ok Invisible

                _ ->
                    Err (customError InvalidSuperpower)
        )


validateTodo : Validation CustomError Todo
validateTodo =
    map2 Todo
        (field "done" bool)
        (field "label" string)


{-| Check if the string is a valid URL.
-}
validateUrl : Validation e String
validateUrl =
    string
        |> andThen (format (Regex.regex "^(https?://)"))



-- eq. to: int `andThen` (minInt 0)


naturalInt : Validation CustomError Int
naturalInt =
    customValidation
        int
        (\i ->
            if i > 0 then
                Ok i
            else
                Err (customError Nope)
        )


asyncCheck : Bool -> String -> Validation CustomError String
asyncCheck serverIsOk s =
    if serverIsOk then
        succeed s
    else
        fail (customError AlreadyTaken)
