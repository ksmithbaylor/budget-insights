module Model exposing (DashboardState, Model(..), initialModel)

import API exposing (Token)
import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary)
import Flags exposing (Flags)
import Http
import Model.Initializing as Initializing


type Model
    = Initializing Initializing.Model
    | PickingBudget BudgetSummaries Token
    | Dashboard DashboardState
    | SomethingWentWrong Http.Error


initialModel : Flags -> Model
initialModel flags =
    Initializing (Initializing.initialModel flags)


type alias DashboardState =
    { budgets : BudgetSummaries
    , budget : BudgetSummary
    , token : Token
    }
