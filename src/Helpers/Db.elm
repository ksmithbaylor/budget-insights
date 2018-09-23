module Helpers.Db exposing (dbToDict)

import Db exposing (Db)
import Dict exposing (Dict)
import Id exposing (Id)


dbToDict : Db a -> Dict String a
dbToDict db =
    db
        |> Db.toList
        |> List.map (Tuple.mapFirst Id.toString)
        |> Dict.fromList
