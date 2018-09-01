module Msg exposing (Msg(..))

import Browser exposing (UrlRequest(..))
import Data.Budget as Budget exposing (Budget, BudgetSummaries, BudgetSummary)
import Http
import Url exposing (Url)


type Msg
    = GotBudgetSummaries (Result Http.Error BudgetSummaries)
    | GotBudget (Result Http.Error Budget)
    | SelectedBudget BudgetSummary
    | GoBack
    | ClickedLink UrlRequest
    | UrlChanged Url
