module Data.YNAB.SubTransaction exposing (SubTransaction, decoder)

import Data.Money as Money exposing (Money)
import Date exposing (Date)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias SubTransaction =
    { id : Id
    , transactionId : Id
    , amount : Money
    , memo : Maybe String
    , payeeId : Maybe Id
    , categoryId : Maybe Id
    , transferAccountId : Maybe Id
    , deleted : Bool
    }


decoder : Decoder SubTransaction
decoder =
    succeed SubTransaction
        |> required "id" Id.decoder
        |> required "transaction_id" Id.decoder
        |> required "amount" Money.decoder
        |> required "memo" (nullable string)
        |> required "payee_id" (nullable Id.decoder)
        |> required "category_id" (nullable Id.decoder)
        |> required "transfer_account_id" (nullable Id.decoder)
        |> required "deleted" bool
