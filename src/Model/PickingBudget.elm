module Model.PickingBudget exposing (Model)

import API exposing (Token)
import Data.Budget exposing (BudgetSummaries)


type alias Model =
    { token : Token
    , budgetSummaries : BudgetSummaries
    }
