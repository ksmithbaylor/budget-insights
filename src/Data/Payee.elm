module Data.Payee exposing (Payee, decoder)

import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias Payee =
    { id : Id }


decoder : Decoder Payee
decoder =
    succeed Payee
        |> required "id" Id.decoder
