module Data.Account exposing (Account, decoder)

import Data.Money as Money exposing (Money)
import Db exposing (Db)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)



-- Account


type alias Account =
    { id : Id
    , name : String
    , kind : Type
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
        |> required "type" decodeType
        |> required "on_budget" bool
        |> required "closed" bool
        |> required "deleted" bool
        |> required "note" (nullable string)
        |> required "balance" Money.decoder
        |> required "cleared_balance" Money.decoder
        |> required "uncleared_balance" Money.decoder


type Type
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


decodeType : Decoder Type
decodeType =
    string |> andThen (stringToType >> fromResult)


stringToType : String -> Result String Type
stringToType s =
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
