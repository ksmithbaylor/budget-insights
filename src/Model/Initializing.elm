module Model.Initializing exposing (Model, init)

import API exposing (Token, fetchBudgetSummaries)
import Cmd.Extra exposing (withCmd)
import Data.Budget as Budget
import Flags exposing (Flags)


type alias Model =
    { token : Token
    , lastBudgetID : Maybe Budget.ID
    }


init : Flags -> Model
init flags =
    { token = flags.token
    , lastBudgetID = Just Budget.defaultBudgetID
    }



-- init : Token -> (Result Http.Error BudgetSummaries -> msg) -> ( Model, Cmd msg )
-- init token msg =
-- { token = token, lastBudgetID = Just Budget.defaultBudgetID }
-- |> withCmd (fetchBudgetSummaries token msg)
