module Data.Budget exposing
    ( Budget
    , BudgetSummary
    , decodeBudgetResponse
    , decodeBudgetSummaries
    , decodeBudgetSummary
    , defaultBudgetId
    )

import Data.Account as Account exposing (Account)
import Data.MasterCategory as MasterCategory exposing (MasterCategory)
import Data.Payee as Payee exposing (Payee)
import Data.PayeeLocation as PayeeLocation exposing (PayeeLocation)
import Date exposing (Date)
import Db exposing (Db)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers.Decode exposing (..)
import ISO8601 exposing (Time)
import Id exposing (Id)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


defaultBudgetId : Id
defaultBudgetId =
    Id.fromString "1b1f448f-8750-40a9-b744-f772f4898b91"


type alias BudgetSummary =
    { id : Id
    , name : String
    , lastModified : Time
    , firstMonth : Date
    , lastMonth : Date
    }


decodeBudgetSummary : Decoder BudgetSummary
decodeBudgetSummary =
    succeed BudgetSummary
        |> required "id" Id.decoder
        |> required "name" string
        |> required "last_modified_on" time
        |> required "first_month" date
        |> required "last_month" date


decodeBudgetSummaries : Decoder (Db BudgetSummary)
decodeBudgetSummaries =
    succeed dbById
        |> requiredAt [ "data", "budgets" ] (list decodeBudgetSummary)



-- Budget


type alias Budget =
    { id : Id
    , name : String
    , lastModified : Time
    , accounts : Db Account
    , payees : Db Payee
    , payeeLocations : Db PayeeLocation
    , masterCategories : Db MasterCategory

    -- , categories : Categories
    -- , months : Months
    -- , transactions : Transactions
    -- , subTransactions : SubTransactions
    -- , scheduledTransactions : ScheduledTransactions
    -- , scheduledSubTransactions : ScheduledSubTransactions
    }


decodeBudget : Decoder Budget
decodeBudget =
    succeed Budget
        |> required "id" Id.decoder
        |> required "name" string
        |> required "last_modified_on" time
        |> required "accounts" (listToDb Account.decoder)
        |> required "payees" (listToDb Payee.decoder)
        |> required "payee_locations" (listToDb PayeeLocation.decoder)
        |> required "category_groups" (listToDb MasterCategory.decoder)


decodeBudgetResponse : Decoder Budget
decodeBudgetResponse =
    succeed identity
        |> requiredAt [ "data", "budget" ] decodeBudget
