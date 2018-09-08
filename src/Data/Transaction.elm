module Data.Transaction exposing (Transaction, decoder)

import Data.Money as Money exposing (Money)
import Date exposing (Date)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias Transaction =
    { id : Id
    , date : Date
    , amount : Money
    , memo : Maybe String
    , cleared : ClearedStatus
    , approved : Bool
    , flagColor : Maybe FlagColor
    , accountId : Id
    , payeeId : Maybe Id
    , categoryId : Maybe Id
    , transferAccountId : Maybe Id
    , importId : Maybe ImportId
    , deleted : Bool
    }


decoder : Decoder Transaction
decoder =
    succeed Transaction
        |> required "id" Id.decoder
        |> required "date" date
        |> required "amount" Money.decoder
        |> required "memo" (nullable string)
        |> required "cleared" decodeClearedStatus
        |> required "approved" bool
        |> required "flag_color" (nullable decodeFlagColor)
        |> required "account_id" Id.decoder
        |> required "payee_id" (nullable Id.decoder)
        |> required "category_id" (nullable Id.decoder)
        |> required "transfer_account_id" (nullable Id.decoder)
        |> required "import_id" (nullable (string |> andThen (ImportId >> succeed)))
        |> required "deleted" bool



-- Helper types


type ClearedStatus
    = Uncleared
    | Cleared
    | Reconciled


decodeClearedStatus : Decoder ClearedStatus
decodeClearedStatus =
    string
        |> andThen
            (\status ->
                case status of
                    "uncleared" ->
                        succeed Uncleared

                    "cleared" ->
                        succeed Cleared

                    "reconciled" ->
                        succeed Reconciled

                    other ->
                        fail ("Invalid 'cleared' field: " ++ other)
            )


type FlagColor
    = Red
    | Orange
    | Yellow
    | Green
    | Blue
    | Purple


decodeFlagColor : Decoder FlagColor
decodeFlagColor =
    string
        |> andThen
            (\color ->
                case color of
                    "red" ->
                        succeed Red

                    "orange" ->
                        succeed Orange

                    "yellow" ->
                        succeed Yellow

                    "green" ->
                        succeed Green

                    "blue" ->
                        succeed Blue

                    "purple" ->
                        succeed Purple

                    other ->
                        fail ("Invalid 'flag_color' field: " ++ other)
            )


type ImportId
    = ImportId String
