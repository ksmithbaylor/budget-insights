module Data.YNAB.Category exposing (Category, decoder)

import Data.Money as Money exposing (Money)
import Data.YNAB.Goal as Goal exposing (Goal)
import Date exposing (Date)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias Category =
    { id : Id
    , masterCategoryId : Id
    , name : String
    , hidden : Bool
    , originalCategoryGroupId : Maybe Id
    , note : Maybe String
    , budgeted : Money
    , activity : Money
    , balance : Money
    , deleted : Bool
    , goal : Maybe Goal
    }


decoder : Decoder Category
decoder =
    succeed Category
        |> required "id" Id.decoder
        |> required "category_group_id" Id.decoder
        |> required "name" string
        |> required "hidden" bool
        |> required "original_category_group_id" (nullable Id.decoder)
        |> required "note" (nullable string)
        |> required "budgeted" Money.decoder
        |> required "activity" Money.decoder
        |> required "balance" Money.decoder
        |> required "deleted" bool
        |> custom Goal.decoder
