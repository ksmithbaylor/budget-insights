module Model exposing (..)

import Http
import Dict exposing (Dict)
import Data.Budget exposing (Budget, BudgetID)


type Model
    = Initializing (Maybe BudgetID) (Maybe Token)
    | PickingBudget (Dict BudgetID Budget) Token
    | Dashboard DashboardState
    | SomethingWentWrong Http.Error


type alias DashboardState =
    { budgets : Dict BudgetID Budget
    , activeBudget : Budget
    , token : Token
    }


type alias Token =
    String
