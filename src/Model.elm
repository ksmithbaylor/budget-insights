module Model exposing (DashboardState, Model(..))

import API exposing (Token)
import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary)
import Dict.Any as AnyDict
import Http


type Model
    = Initializing (Maybe Budget.ID)
    | FetchingBudgetSummaries (Maybe Budget.ID) Token
    | PickingBudget BudgetSummaries Token
    | Dashboard DashboardState
    | SomethingWentWrong Http.Error


type alias DashboardState =
    { budgets : BudgetSummaries
    , budget : BudgetSummary
    , token : Token
    }
