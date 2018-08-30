module Model exposing (DashboardState, Model(..))

import API exposing (Token)
import Data.Budget exposing (Budget, BudgetID, Budgets)
import Dict.Any as AnyDict
import Http


type Model
    = Initializing (Maybe BudgetID)
    | FetchingBudgets (Maybe BudgetID) Token
    | PickingBudget Budgets Token
    | Dashboard DashboardState
    | SomethingWentWrong Http.Error


type alias DashboardState =
    { budgets : Budgets
    , budget : Budget
    , token : Token
    }
