module Data.Budget exposing (Budget, BudgetID, decodeBudget)

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Date exposing (Date)
import ISO8601 exposing (Time)


type alias BudgetID =
    String


type alias Budget =
    { id : BudgetID
    , name : String
    , lastModified : Time
    , firstMonth : Date
    , lastMonth : Date
    }


decodeBudget : Decoder Budget
decodeBudget =
    map5 Budget
        (field "id" string)
        (field "name" string)
        (field "last_modified_on" (string |> andThen (fromResult << ISO8601.fromString)))
        (field "first_month" (string |> andThen (fromResult << Date.fromIsoString)))
        (field "last_month" (string |> andThen (fromResult << Date.fromIsoString)))
