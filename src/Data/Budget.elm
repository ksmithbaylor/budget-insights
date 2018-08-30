module Data.Budget exposing (Budget, BudgetID, Budgets, decodeBudget, defaultBudgetID, idToString)

import Date exposing (Date)
import Dict.Any as AnyDict exposing (AnyDict)
import ISO8601 exposing (Time)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)


type alias Budget =
    { id : BudgetID
    , name : String
    , lastModified : Time
    , firstMonth : Date
    , lastMonth : Date
    }


type BudgetID
    = BudgetID String


type alias Budgets =
    AnyDict String BudgetID Budget


defaultBudgetID : BudgetID
defaultBudgetID =
    BudgetID "1b1f448f-8750-40a9-b744-f772f4898b91"


idToString : BudgetID -> String
idToString (BudgetID id) =
    id


decodeBudget : Decoder Budget
decodeBudget =
    map5 Budget
        (field "id" string |> andThen (BudgetID >> succeed))
        (field "name" string)
        (field "last_modified_on" (string |> andThen (fromResult << ISO8601.fromString)))
        (field "first_month" (string |> andThen (fromResult << Date.fromIsoString)))
        (field "last_month" (string |> andThen (fromResult << Date.fromIsoString)))
