module API exposing (fetchToken, fetchBudgets)

import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Dict exposing (Dict)
import Date exposing (Date)
import ISO8601 exposing (Time)
import Data.Money
import Data.Budget exposing (..)


-- TOKEN FETCH


fetchToken : (Result Http.Error String -> msg) -> Cmd msg
fetchToken msg =
    Http.get "http://localhost:4000/token" decodeToken
        |> Http.send msg


decodeToken : Decoder String
decodeToken =
    Decode.field "token" Decode.string



-- YNAB API


ynabRequest : String -> String -> Decoder a -> Http.Request a
ynabRequest token path decoder =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = "https://api.youneedabudget.com/v1" ++ path
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


fetchBudgets : String -> (Result Http.Error (Dict BudgetID Budget) -> msg) -> Cmd msg
fetchBudgets token msg =
    ynabRequest token "/budgets" decodeBudgets
        |> Http.send msg


decodeBudgets : Decoder (Dict BudgetID Budget)
decodeBudgets =
    field "data"
        (field "budgets"
            (list decodeBudget
                |> andThen
                    (List.map (\budget -> ( budget.id, budget ))
                        >> Dict.fromList
                        >> succeed
                    )
            )
        )
