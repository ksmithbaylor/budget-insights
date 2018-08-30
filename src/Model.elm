module Model exposing (DashboardState, Model(..))

import API exposing (Token)
import Data.Budget exposing (Budget, BudgetID)
import Dict exposing (Dict)
import Http


type Model
    = Initializing (Maybe BudgetID)
    | FetchingBudgets (Maybe BudgetID) Token
    | PickingBudget (Dict BudgetID Budget) Token
    | Dashboard DashboardState
    | SomethingWentWrong Http.Error


type alias DashboardState =
    { budgets : Dict BudgetID Budget
    , activeBudget : Budget
    , token : Token
    }
