module Model.Dashboard exposing (Model)

import API exposing (Token)
import Data.Budget exposing (BudgetSummaries, BudgetSummary)


type alias Model =
    { budgetSummaries : BudgetSummaries
    , budgetSummary : BudgetSummary
    , loading : Bool
    , token : Token
    }
