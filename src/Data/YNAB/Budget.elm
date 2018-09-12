module Data.YNAB.Budget exposing
    ( Budget
    , BudgetSummary
    , decodeResponse
    , decodeSummariesResponse
    , decodeSummary
    )

import Data.YNAB.Account as Account exposing (Account)
import Data.YNAB.Category as Category exposing (Category)
import Data.YNAB.CurrencyFormat as CurrencyFormat exposing (CurrencyFormat)
import Data.YNAB.MasterCategory as MasterCategory exposing (MasterCategory)
import Data.YNAB.Month as Month exposing (Month)
import Data.YNAB.Payee as Payee exposing (Payee)
import Data.YNAB.PayeeLocation as PayeeLocation exposing (PayeeLocation)
import Data.YNAB.ScheduledSubTransaction as ScheduledSubTransaction exposing (ScheduledSubTransaction)
import Data.YNAB.ScheduledTransaction as ScheduledTransaction exposing (ScheduledTransaction)
import Data.YNAB.SubTransaction as SubTransaction exposing (SubTransaction)
import Data.YNAB.Transaction as Transaction exposing (Transaction)
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


decodeResponse : Decoder Budget
decodeResponse =
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


decodeSummary : Decoder BudgetSummary
decodeSummary =
    succeed BudgetSummary
        |> required "id" Id.decoder
        |> required "name" string
        |> required "last_modified_on" time
        |> required "first_month" date
        |> required "last_month" date


decodeSummariesResponse : Decoder (Db BudgetSummary)
decodeSummariesResponse =
    succeed dbById
        |> requiredAt [ "data", "budgets" ] (list decodeSummary)
