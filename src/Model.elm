module Model exposing (Model(..), initialModel)

import API exposing (Token)
import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary)
import Flags exposing (Flags)
import Http
import Model.Dashboard as Dashboard
import Model.Initializing as Initializing
import Model.PickingBudget as PickingBudget


type Model
    = Initializing Initializing.Model
    | PickingBudget PickingBudget.Model
    | Dashboard Dashboard.Model
    | SomethingWentWrong Http.Error


initialModel : Flags -> Model
initialModel flags =
    Initializing (Initializing.initialModel flags)
