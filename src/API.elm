module API exposing (Token, fetchBudgetByID, fetchBudgetSummaries)

import Data.Budget as Budget exposing (Budget, BudgetSummaries, BudgetSummary, decodeBudgetResponse, decodeBudgetSummaries, decodeBudgetSummary)
import Data.Money
import Date exposing (Date)
import Dict.Any as AnyDict
import Http
import ISO8601 exposing (Time)
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


fetchBudgetSummaries : Token -> (Result Http.Error BudgetSummaries -> msg) -> Cmd msg
fetchBudgetSummaries token msg =
    ynabRequest token "/budgets" decodeBudgetSummaries
        |> Http.send msg


fetchBudgetByID : Token -> Budget.ID -> (Result Http.Error Budget -> msg) -> Cmd msg
fetchBudgetByID token id msg =
    ynabRequest token ("/budgets/" ++ Budget.idToString id) decodeBudgetResponse
        |> Http.send msg
