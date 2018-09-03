module Model.Initializing exposing (Model, init)

import API exposing (Token, fetchBudgetSummaries)
import Cmd.Extra exposing (withCmd)
import Data.Budget as Budget
import Flags exposing (Flags)
import Id exposing (Id)


type alias Model =
    { token : Token
    , lastBudgetId : Maybe Id
    }


init : Flags -> Model
init flags =
    { token = flags.token
    , lastBudgetId = Just Budget.defaultBudgetId
    }



-- init : Token -> (Result Http.Error BudgetSummaries -> msg) -> ( Model, Cmd msg )
-- init token msg =
-- { token = token, lastBudgetId = Just Budget.defaultBudgetId }
-- |> withCmd (fetchBudgetSummaries token msg)
