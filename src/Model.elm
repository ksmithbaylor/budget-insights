module Model exposing (Model(..), initialModel)

import API exposing (Token)
import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary)
import Flags exposing (Flags)
import Http
import Model.Dashboard as Dashboard
import Model.Initializing as Initializing
import Model.PickingBudget as PickingBudget
import Model.SomethingWentWrong as SomethingWentWrong
import Router


type Model
    = Initializing Initializing.Model
    | PickingBudget PickingBudget.Model
    | Dashboard Dashboard.Model
    | SomethingWentWrong SomethingWentWrong.Model


initialModel : Flags -> Model
initialModel flags =
    Initializing (Initializing.init flags)
