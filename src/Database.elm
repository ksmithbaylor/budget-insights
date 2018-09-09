module Database exposing (all, from, join, limit, orderBy, where_)

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


type alias Query fromType compareType =
    { fromAccessor : Budget -> Db fromType
    , wherePredicate : fromType -> Bool
    , orderBy_ : Maybe (fromType -> compareType)
    , limit_ : Maybe Int
    }


from : (Budget -> Db fromType) -> Query fromType comparable
from accessor =
    { fromAccessor = accessor
    , wherePredicate = always True
    , orderBy_ = Nothing
    , limit_ = Nothing
    }


where_ : (fromType -> Bool) -> Query fromType comparable -> Query fromType comparable
where_ predicate query =
    { query | wherePredicate = predicate }


orderBy : (fromType -> comparable) -> Query fromType comparable -> Query fromType comparable
orderBy ordering query =
    { query | orderBy_ = Just ordering }


limit : Int -> Query fromType comparable -> Query fromType comparable
limit lim query =
    { query | limit_ = Just lim }


all : Budget -> Query fromType comparable -> List fromType
all budget { fromAccessor, wherePredicate, orderBy_, limit_ } =
    fromAccessor budget
        |> dbToDict
        |> Dict.filter (\k v -> wherePredicate v)
        |> Dict.toList
        |> List.map Tuple.second
        |> (case orderBy_ of
                Nothing ->
                    List.map identity

                Just sorter ->
                    List.sortBy sorter
           )
        |> (case limit_ of
                Nothing ->
                    identity

                Just lim ->
                    List.take lim
           )


join : (Budget -> Db b) -> Budget -> (a -> b -> Bool) -> List a -> List ( a, List b )
join otherAccessor budget predicate source =
    source
        |> List.map
            (\a ->
                from otherAccessor
                    |> where_ (\b -> predicate a b)
                    |> all budget
                    |> Tuple.pair a
            )
