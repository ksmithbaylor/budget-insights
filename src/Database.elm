module Database exposing (select)

import Data.YNAB.Budget exposing (Budget)
import Db exposing (Db)
import Dict exposing (Dict)
import Id exposing (Id)


dbToDict : Db a -> Dict String a
dbToDict db =
    db
        |> Db.toList
        |> List.map (Tuple.mapFirst Id.toString)
        |> Dict.fromList


select : (Budget -> Db a) -> (a -> Bool) -> Budget -> List a
select accessor predicate budget =
    accessor budget
        |> dbToDict
        |> Dict.filter (\k v -> predicate v)
        |> Dict.toList
        |> List.map Tuple.second
