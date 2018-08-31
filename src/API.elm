module API exposing (Token, fetchBudgetSummaries, fetchToken, usableToken)

import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary, decodeBudgetSummary)
import Data.Money
import Date exposing (Date)
import Dict.Any as AnyDict
import Http
import ISO8601 exposing (Time)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)



-- TOKEN


type Token
    = Token String


usableToken : Maybe Token -> Token
usableToken possibleToken =
    case possibleToken of
        Nothing ->
            Token ""

        Just token ->
            token


fetchToken : (Result Http.Error Token -> msg) -> Cmd msg
fetchToken msg =
    Http.send msg <|
        Http.get "http://localhost:4000/token" <|
            (field "token" string
                |> andThen (Token >> succeed)
            )



-- YNAB API


ynabRequest : Token -> String -> Decoder a -> Http.Request a
ynabRequest (Token token) path decoder =
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
    Http.send msg <|
        ynabRequest token "/budgets" <|
            field "data"
                (field "budgets"
                    (list decodeBudgetSummary
                        |> andThen
                            (List.map (\budget -> ( budget.id, budget ))
                                >> AnyDict.fromList Budget.idToString
                                >> succeed
                            )
                    )
                )
