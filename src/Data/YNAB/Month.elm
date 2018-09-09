module Data.YNAB.Month exposing (Month, decoder)

import Data.Money as Money exposing (Money)
import Data.YNAB.Category as Category exposing (Category)
import Date exposing (Date)
import Db exposing (Db)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type alias Month =
    { id : Id
    , month : Date
    , note : Maybe String
    , income : Money
    , budgeted : Money
    , activity : Money
    , toBeBudgeted : Money
    , ageOfMoney : Maybe Int
    , categories : Db Category
    }


decoder : Decoder Month
decoder =
    succeed Month
        |> required "month" Id.decoder
        |> required "month" date
        |> required "note" (nullable string)
        |> required "income" Money.decoder
        |> required "budgeted" Money.decoder
        |> required "activity" Money.decoder
        |> required "to_be_budgeted" Money.decoder
        |> required "age_of_money" (nullable int)
        |> required "categories" (listToDb Category.decoder)
