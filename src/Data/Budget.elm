module Data.Budget exposing
    ( Budget
    , BudgetSummaries
    , BudgetSummary
    , Budgets
    , ID
    , decodeBudgetResponse
    , decodeBudgetSummaries
    , decodeBudgetSummary
    , defaultBudgetID
    , idFromString
    , idToString
    )

import Data.Account as Account exposing (Accounts, decodeAccounts)
import Date exposing (Date)
import Dict.Any exposing (AnyDict)
import Helpers.Decode exposing (..)
import ISO8601 exposing (Time)
import Json.Decode as Decode exposing (..)
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


idFromString : String -> ID
idFromString s =
    ID s



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
    succeed (dictByID idToString)
        |> requiredAt [ "data", "budgets" ] (list decodeBudgetSummary)



-- Budget


type alias Budget =
    { id : ID
    , name : String
    , lastModified : Time
    , accounts : Accounts

    -- , payees : Payees
    -- , masterCategories : MasterCategories
    -- , categories : Categories
    -- , months : Months
    -- , transactions : Transactions
    -- , subTransactions : SubTransactions
    -- , scheduledTransactions : ScheduledTransactions
    -- , scheduledSubTransactions : ScheduledSubTransactions
    }


type alias Budgets =
    AnyDict String ID Budget


decodeBudget : Decoder Budget
decodeBudget =
    succeed Budget
        |> required "id" decodeID
        |> required "name" string
        |> required "last_modified_on" time
        |> required "accounts" decodeAccounts


decodeBudgetResponse : Decoder Budget
decodeBudgetResponse =
    succeed identity
        |> requiredAt [ "data", "budget" ] decodeBudget
