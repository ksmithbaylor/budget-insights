module Data.YNAB.ScheduledTransaction exposing (ScheduledTransaction, decoder)

import Data.Money as Money exposing (Money)
import Data.YNAB.Account
import Data.YNAB.Transaction exposing (FlagColor, decodeFlagColor)
import Date exposing (Date)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias ScheduledTransaction =
    { id : Id
    , firstDate : Date
    , nextDate : Date
    , frequency : Frequency
    , amount : Money
    , memo : Maybe String
    , flagColor : Maybe FlagColor
    , accountId : Id
    , payeeId : Maybe Id
    , categoryId : Maybe Id
    , transferAccountId : Maybe Id
    , deleted : Bool
    }


decoder : Decoder ScheduledTransaction
decoder =
    succeed ScheduledTransaction
        |> required "id" Id.decoder
        |> required "date_first" date
        |> required "date_next" date
        |> required "frequency" decodeFrequency
        |> required "amount" Money.decoder
        |> required "memo" (nullable string)
        |> required "flag_color" (nullable decodeFlagColor)
        |> required "account_id" Id.decoder
        |> required "payee_id" (nullable Id.decoder)
        |> required "category_id" (nullable Id.decoder)
        |> required "transfer_account_id" (nullable Id.decoder)
        |> required "deleted" bool



-- Helper types


type Frequency
    = NotEver
    | Daily
    | Weekly
    | EveryOtherWeek
    | TwiceAMonth
    | EveryFourWeeks
    | Monthly
    | EveryOtherMonth
    | EveryThreeMonths
    | EveryFourMonths
    | TwiceAYear
    | Yearly
    | EveryOtherYear


decodeFrequency : Decoder Frequency
decodeFrequency =
    string
        |> andThen
            (\frequency ->
                case frequency of
                    "never" ->
                        succeed NotEver

                    "daily" ->
                        succeed Daily

                    "weekly" ->
                        succeed Weekly

                    "everyOtherWeek" ->
                        succeed EveryOtherWeek

                    "twiceAMonth" ->
                        succeed TwiceAMonth

                    "every4Weeks" ->
                        succeed EveryFourWeeks

                    "monthly" ->
                        succeed Monthly

                    "everyOtherMonth" ->
                        succeed EveryOtherMonth

                    "every3Months" ->
                        succeed EveryThreeMonths

                    "every4Months" ->
                        succeed EveryFourMonths

                    "twiceAYear" ->
                        succeed TwiceAYear

                    "yearly" ->
                        succeed Yearly

                    "everyOtherYear" ->
                        succeed EveryOtherYear

                    other ->
                        fail ("Invalid 'frequency' field: " ++ other)
            )
