module Model.PickingBudget exposing (Model, init)

import API exposing (Token)
import Data.Budget as Budget exposing (BudgetSummaries)
import Dict.Any as AnyDict
import Flags exposing (Flags)


type alias Model =
    { token : Token
    , budgetSummaries : BudgetSummaries
    }


init : Flags -> Model
init flags =
    { token = flags.token
    , budgetSummaries = AnyDict.empty Budget.idToString
    }
