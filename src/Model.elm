module Model exposing (DashboardState, Model(..))

import API exposing (Token)
import Data.Budget exposing (Budget, BudgetID)
import Dict.Any as AnyDict exposing (AnyDict)
import Http


type Model
    = Initializing (Maybe BudgetID)
    | FetchingBudgets (Maybe BudgetID) Token
    | PickingBudget (AnyDict String BudgetID Budget) Token
    | Dashboard DashboardState
    | SomethingWentWrong Http.Error


type alias DashboardState =
    { budgets : AnyDict String BudgetID Budget
    , budget : Budget
    , token : Token
    }
