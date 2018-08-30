module API exposing (Token, fetchBudgets, fetchToken, usableToken)

import Data.Budget as Budget exposing (Budget, BudgetID, decodeBudget)
import Data.Money
import Date exposing (Date)
import Dict.Any as AnyDict exposing (AnyDict)
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


fetchBudgets : Token -> (Result Http.Error (AnyDict String BudgetID Budget) -> msg) -> Cmd msg
fetchBudgets token msg =
    Http.send msg <|
        ynabRequest token "/budgets" <|
            field "data"
                (field "budgets"
                    (list decodeBudget
                        |> andThen
                            (List.map (\budget -> ( budget.id, budget ))
                                >> AnyDict.fromList Budget.idToString
                                >> succeed
                            )
                    )
                )
