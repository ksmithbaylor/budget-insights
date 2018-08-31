module Data.Budget exposing (BudgetSummaries, BudgetSummary, ID, decodeBudgetSummaries, decodeBudgetSummary, defaultBudgetID, idToString)

import Date exposing (Date)
import Dict.Any as AnyDict exposing (AnyDict)
import ISO8601 exposing (Time)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)



-- ID


type ID
    = ID String


decodeID : Decoder ID
decodeID =
    string |> andThen (ID >> succeed)


defaultBudgetID : ID
defaultBudgetID =
    ID "1b1f448f-8750-40a9-b744-f772f4898b91"


idToString : ID -> String
idToString (ID id) =
    id



-- Budget Summary


type alias BudgetSummary =
    { id : ID
    , name : String
    , lastModified : Time
    , firstMonth : Date
    , lastMonth : Date
    }


decodeBudgetSummary : Decoder BudgetSummary
decodeBudgetSummary =
    succeed BudgetSummary
        |> required "id" decodeID
        |> required "name" string
        |> required "last_modified_on" time
        |> required "first_month" date
        |> required "last_month" date


type alias BudgetSummaries =
    AnyDict String ID BudgetSummary


decodeBudgetSummaries : Decoder BudgetSummaries
decodeBudgetSummaries =
    succeed (dictKeyedBy .id idToString)
        |> requiredAt [ "data", "budgets" ] (list decodeBudgetSummary)



-- Helpers


date : Decoder Date
date =
    string |> andThen (Date.fromIsoString >> fromResult)


time : Decoder Time
time =
    string |> andThen (ISO8601.fromString >> fromResult)


dictKeyedBy : (a -> b) -> (b -> comparable) -> List a -> AnyDict comparable b a
dictKeyedBy key comparableKey =
    List.map (\value -> ( key value, value ))
        >> AnyDict.fromList comparableKey
