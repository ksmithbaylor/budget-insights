module Reports.DailyNetWorth exposing (report)

import Data.Money as Money exposing (Money)
import Data.YNAB.Budget as Budget exposing (Budget)
import Data.YNAB.Transaction as Transaction exposing (Transaction)
import Date exposing (Date)
import Db
import Dict
import Dict.Extra
import Helpers.Db exposing (dbToDict)


type alias Datum =
    { date : Date
    , amount : Money
    }


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


sumTransactions : List Transaction -> Money
sumTransactions =
    List.map .amount >> List.foldl Money.add (Money.create 0)


toDatum : ( Date, Money ) -> Datum
toDatum ( date, amount ) =
    Datum date amount
