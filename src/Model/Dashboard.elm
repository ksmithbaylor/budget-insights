module Model.Dashboard exposing (Model)

import API exposing (Token)
import Data.Budget exposing (BudgetSummaries, BudgetSummary)


type alias Model =
    { budgets : BudgetSummaries
    , budget : BudgetSummary
    , token : Token
    }
