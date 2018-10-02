module Reports.DailyNetWorth exposing (encodeDatum, report)

import Data.Money as Money exposing (Money)
import Data.YNAB.Budget as Budget exposing (Budget)
import Data.YNAB.Transaction as Transaction exposing (Transaction)
import Date exposing (Date, toIsoString)
import Db
import Dict
import Dict.Extra
import Helpers.Db exposing (dbToDict)
import Json.Encode as Encode
import List.Extra exposing (scanl1)


type alias Datum =
    { date : Date
    , amount : Money
    }


encodeDatum : Datum -> Encode.Value
encodeDatum datum =
    Encode.object
        [ ( "x", Encode.string <| toIsoString datum.date )
        , ( "y", Money.encoder datum.amount )
        ]


report : Budget -> List Datum
report budget =
    budget.transactions
        |> (Db.toList >> List.map Tuple.second)
        |> Dict.Extra.groupBy (.date >> Date.toRataDie)
        |> Dict.toList
        |> List.map
            (Tuple.mapFirst Date.fromRataDie
                >> Tuple.mapSecond sumTransactions
                >> toDatum
            )
        |> scanl1 accum


sumTransactions : List Transaction -> Money
sumTransactions =
    List.map .amount >> List.foldl Money.add (Money.create 0)


toDatum : ( Date, Money ) -> Datum
toDatum ( date, amount ) =
    Datum date amount


accum : Datum -> Datum -> Datum
accum a b =
    { date = a.date, amount = Money.add a.amount b.amount }
