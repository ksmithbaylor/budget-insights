module API exposing (Budget, fetchToken, fetchBudgets)

import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import ISO8601 exposing (Time)
import Date exposing (Date)


-- TOKEN FETCH


fetchToken : (Result Http.Error String -> msg) -> Cmd msg
fetchToken msg =
    Http.get "http://localhost:4000/token" decodeToken
        |> Http.send msg


decodeToken : Decoder String
decodeToken =
    Decode.field "token" Decode.string



-- API TYPES AND DECODERS


type alias BudgetID =
    String


type alias Budget =
    { id : BudgetID
    , name : String
    , lastModified : Time
    , firstMonth : Date
    , lastMonth : Date
    }


decodeBudget : Decoder Budget
decodeBudget =
    map5 Budget
        (field "id" string)
        (field "name" string)
        (field "last_modified_on" (string |> andThen (fromResult << ISO8601.fromString)))
        (field "first_month" (string |> andThen (fromResult << Date.fromIsoString)))
        (field "last_month" (string |> andThen (fromResult << Date.fromIsoString)))


decodeBudgets : Decoder (List Budget)
decodeBudgets =
    field "data" (field "budgets" (list decodeBudget))



-- YNAB API


fetchBudgets : String -> (Result Http.Error (List Budget) -> msg) -> Cmd msg
fetchBudgets token msg =
    { method = "GET"
    , headers = [ authHeader token ]
    , url = ynabURL "/budgets"
    , body = Http.emptyBody
    , expect = Http.expectJson decodeBudgets
    , timeout = Nothing
    , withCredentials = False
    }
        |> Http.request
        |> Http.send msg


authHeader : String -> Http.Header
authHeader token =
    Http.header "Authorization" ("Bearer " ++ token)


ynabURL : String -> String
ynabURL path =
    "https://api.youneedabudget.com/v1" ++ path
