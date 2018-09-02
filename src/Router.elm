module Router exposing (Model)

import Flags exposing (Flags)
import Model.Dashboard as Dashboard
import Model.Initializing as Initializing
import Model.PickingBudget as PickingBudget
import Model.SomethingWentWrong as SomethingWentWrong


type alias Model =
    { route : Route
    , initializing : Initializing.Model
    , pickingBudget : PickingBudget.Model
    , dashboard : Dashboard.Model
    , somethingWentWrong : SomethingWentWrong.Model
    }


type Route
    = InitializingRoute
    | PickingBudgetRoute
    | DashboardRoute
    | SomethingWentWrongRoute


init : Flags -> Model
init flags =
    { route = InitializingRoute
    , initializing = Initializing.init flags
    , pickingBudget = PickingBudget.init flags
    , dashboard = Dashboard.init flags
    , somethingWentWrong = SomethingWentWrong.init flags
    }
