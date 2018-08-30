module Model exposing (DashboardState, Model(..), Token)

import Data.Budget exposing (Budget, BudgetID)
import Dict exposing (Dict)
import Http


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
