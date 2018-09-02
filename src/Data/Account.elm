module Data.Account exposing
    ( Account
    , Accounts
    , decodeAccount
    , decodeAccounts
    , idToString
    )

import Data.Money exposing (Money, decodeMoney)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers.Decode exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)



-- ID


type ID
    = ID String


decodeID : Decoder ID
decodeID =
    string |> andThen (ID >> succeed)


idToString : ID -> String
idToString (ID id) =
    id



-- Account


type alias Account =
    { id : ID
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


decodeAccount : Decoder Account
decodeAccount =
    succeed Account
        |> required "id" decodeID
        |> required "name" string
        |> required "type" decodeType
        |> required "on_budget" bool
        |> required "closed" bool
        |> required "deleted" bool
        |> required "note" (nullable string)
        |> required "balance" decodeMoney
        |> required "cleared_balance" decodeMoney
        |> required "uncleared_balance" decodeMoney


type alias Accounts =
    AnyDict String ID Account


decodeAccounts : Decoder Accounts
decodeAccounts =
    list decodeAccount
        |> andThen (dictByID idToString >> succeed)


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
