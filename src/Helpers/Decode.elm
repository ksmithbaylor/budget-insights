module Helpers.Decode exposing (date, dbById, listToDb, time)

import Date exposing (Date)
import Db exposing (Db)
import Dict.Any as AnyDict exposing (AnyDict)
import ISO8601 exposing (Time)
import Id exposing (Id)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)


date : Decoder Date
date =
    string |> andThen (Date.fromIsoString >> fromResult)


time : Decoder Time
time =
    string |> andThen (ISO8601.fromString >> fromResult)


listToDb : Decoder { a | id : Id } -> Decoder (Db { a | id : Id })
listToDb itemDecoder =
    list itemDecoder
        |> andThen (dbById >> succeed)


dbById : List { a | id : Id } -> Db { a | id : Id }
dbById items =
    items
        |> List.map (\item -> ( item.id, item ))
        |> Db.fromList
