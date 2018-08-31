module Data.Budget exposing (BudgetSummaries, BudgetSummary, ID, decodeBudgetSummary, defaultBudgetID, idToString)

import Date exposing (Date)
import Dict.Any as AnyDict exposing (AnyDict)
import ISO8601 exposing (Time)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)


type alias BudgetSummary =
    { id : ID
    , name : String
    , lastModified : Time
    , firstMonth : Date
    , lastMonth : Date
    }


type ID
    = ID String


type alias BudgetSummaries =
    AnyDict String ID BudgetSummary


defaultBudgetID : ID
defaultBudgetID =
    ID "1b1f448f-8750-40a9-b744-f772f4898b91"


idToString : ID -> String
idToString (ID id) =
    id


decodeBudgetSummary : Decoder BudgetSummary
decodeBudgetSummary =
    map5 BudgetSummary
        (field "id" string |> andThen (ID >> succeed))
        (field "name" string)
        (field "last_modified_on" (string |> andThen (fromResult << ISO8601.fromString)))
        (field "first_month" (string |> andThen (fromResult << Date.fromIsoString)))
        (field "last_month" (string |> andThen (fromResult << Date.fromIsoString)))
