module Data.Budget exposing
    ( Budget
    , BudgetSummary
    , decodeBudgetResponse
    , decodeBudgetSummaries
    , decodeBudgetSummary
    )

import Data.Account as Account exposing (Account)
import Data.Category as Category exposing (Category)
import Data.CurrencyFormat as CurrencyFormat exposing (CurrencyFormat)
import Data.MasterCategory as MasterCategory exposing (MasterCategory)
import Data.Month as Month exposing (Month)
import Data.Payee as Payee exposing (Payee)
import Data.PayeeLocation as PayeeLocation exposing (PayeeLocation)
import Data.ScheduledSubTransaction as ScheduledSubTransaction exposing (ScheduledSubTransaction)
import Data.ScheduledTransaction as ScheduledTransaction exposing (ScheduledTransaction)
import Data.SubTransaction as SubTransaction exposing (SubTransaction)
import Data.Transaction as Transaction exposing (Transaction)
import Date exposing (Date)
import Db exposing (Db)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers.Decode exposing (..)
import ISO8601 exposing (Time)
import Id exposing (Id)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type alias Budget =
    { id : Id
    , name : String
    , lastModified : Time
    , dateFormat : String
    , currencyFormat : CurrencyFormat
    , accounts : Db Account
    , payees : Db Payee
    , payeeLocations : Db PayeeLocation
    , masterCategories : Db MasterCategory
    , categories : Db Category
    , months : Db Month
    , transactions : Db Transaction
    , subTransactions : Db SubTransaction
    , scheduledTransactions : Db ScheduledTransaction
    , scheduledSubTransactions : Db ScheduledSubTransaction
    }


decodeBudget : Decoder Budget
decodeBudget =
    succeed Budget
        |> required "id" Id.decoder
        |> required "name" string
        |> required "last_modified_on" time
        |> requiredAt [ "date_format", "format" ] string
        |> required "currency_format" CurrencyFormat.decoder
        |> required "accounts" (listToDb Account.decoder)
        |> required "payees" (listToDb Payee.decoder)
        |> required "payee_locations" (listToDb PayeeLocation.decoder)
        |> required "category_groups" (listToDb MasterCategory.decoder)
        |> required "categories" (listToDb Category.decoder)
        |> required "months" (listToDb Month.decoder)
        |> required "transactions" (listToDb Transaction.decoder)
        |> required "subtransactions" (listToDb SubTransaction.decoder)
        |> required "scheduled_transactions" (listToDb ScheduledTransaction.decoder)
        |> required "scheduled_subtransactions" (listToDb ScheduledSubTransaction.decoder)


decodeBudgetResponse : Decoder Budget
decodeBudgetResponse =
    succeed identity
        |> requiredAt [ "data", "budget" ] decodeBudget



-- BudgetSummary


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
