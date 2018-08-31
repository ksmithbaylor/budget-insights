module Helpers.Decode exposing (date, dictByID, time)

import Date exposing (Date)
import Dict.Any as AnyDict exposing (AnyDict)
import ISO8601 exposing (Time)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)


date : Decoder Date
date =
    string |> andThen (Date.fromIsoString >> fromResult)


time : Decoder Time
time =
    string |> andThen (ISO8601.fromString >> fromResult)


dictByID : (id -> comparable) -> List { a | id : id } -> AnyDict comparable id { a | id : id }
dictByID comparableKey =
    List.map (\value -> ( value.id, value ))
        >> AnyDict.fromList comparableKey
