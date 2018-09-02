module Model.Dashboard exposing (Model, init)

import API exposing (Token)
import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary)
import Dict.Any as AnyDict
import Flags exposing (Flags)


type alias Model =
    { budgetSummaries : BudgetSummaries
    , budgetSummary : Maybe BudgetSummary
    , loading : Bool
    , token : Token
    }


init : Flags -> Model
init flags =
    { budgetSummaries = AnyDict.empty Budget.idToString
    , budgetSummary = Nothing
    }
