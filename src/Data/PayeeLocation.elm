module Data.PayeeLocation exposing (PayeeLocation, decoder)

import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias PayeeLocation =
    { id : Id
    , payeeId : Id
    , latitude : Maybe String
    , longitude : Maybe String
    , deleted : Bool
    }


decoder : Decoder PayeeLocation
decoder =
    succeed PayeeLocation
        |> required "id" Id.decoder
        |> required "payee_id" Id.decoder
        |> required "latitude" (nullable string)
        |> required "longitude" (nullable string)
        |> required "deleted" bool
