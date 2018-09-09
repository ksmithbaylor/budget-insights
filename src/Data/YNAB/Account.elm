module Data.YNAB.Account exposing (Account, decoder)

import Data.Money as Money exposing (Money)
import Db exposing (Db)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias Account =
    { id : Id
    , name : String
    , kind : AccountType
    , onBudget : Bool
    , closed : Bool
    , deleted : Bool
    , note : Maybe String
    , balance : Money
    , clearedBalance : Money
    , unclearedBalance : Money
    }


decoder : Decoder Account
decoder =
    succeed Account
        |> required "id" Id.decoder
        |> required "name" string
        |> required "type" decodeAccountType
        |> required "on_budget" bool
        |> required "closed" bool
        |> required "deleted" bool
        |> required "note" (nullable string)
        |> required "balance" Money.decoder
        |> required "cleared_balance" Money.decoder
        |> required "uncleared_balance" Money.decoder



-- Helper types


type AccountType
    = Checking
    | Savings
    | Cash
    | CreditCard
    | LineOfCredit
    | OtherAsset
    | OtherLiability
    | PayPal
    | MerchantAccount
    | InvestmentAccount
    | Mortgage


decodeAccountType : Decoder AccountType
decodeAccountType =
    string |> andThen (stringToAccountType >> fromResult)


stringToAccountType : String -> Result String AccountType
stringToAccountType s =
    case s of
        "checking" ->
            Ok Checking

        "savings" ->
            Ok Savings

        "cash" ->
            Ok Cash

        "creditCard" ->
            Ok CreditCard

        "lineOfCredit" ->
            Ok LineOfCredit

        "otherAsset" ->
            Ok OtherAsset

        "otherLiability" ->
            Ok OtherLiability

        "payPal" ->
            Ok PayPal

        "merchantAccount" ->
            Ok MerchantAccount

        "investmentAccount" ->
            Ok InvestmentAccount

        "mortgage" ->
            Ok Mortgage

        _ ->
            Err "invalid type"
