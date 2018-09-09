module Data.YNAB.MasterCategory exposing (MasterCategory, decoder)

import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias MasterCategory =
    { id : Id
    , name : String
    , hidden : Bool
    , deleted : Bool
    }


decoder : Decoder MasterCategory
decoder =
    succeed MasterCategory
        |> required "id" Id.decoder
        |> required "name" string
        |> required "hidden" bool
        |> required "deleted" bool
