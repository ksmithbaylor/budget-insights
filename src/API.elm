module API exposing (Token, fetchBudgetById, fetchBudgetSummaries)

import Data.Money
import Data.YNAB.Budget as Budget exposing (Budget, BudgetSummary, decodeBudgetResponse, decodeBudgetSummaries, decodeBudgetSummary)
import Date exposing (Date)
import Db exposing (Db)
import Dict.Any as AnyDict
import Http
import ISO8601 exposing (Time)
import Id exposing (Id)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type alias Token =
    String



-- YNAB API


ynabRequest : Token -> String -> Decoder a -> Http.Request a
ynabRequest token path decoder =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = "http://localhost:4000/ynab" ++ path
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


fetchBudgetSummaries : Token -> (Result Http.Error (Db BudgetSummary) -> msg) -> Cmd msg
fetchBudgetSummaries token msg =
    ynabRequest token "/budgets" decodeBudgetSummaries
        |> Http.send msg


fetchBudgetById : Token -> Id -> (Result Http.Error Budget -> msg) -> Cmd msg
fetchBudgetById token id msg =
    ynabRequest token ("/budgets/" ++ Id.toString id) decodeBudgetResponse
        |> Http.send msg
