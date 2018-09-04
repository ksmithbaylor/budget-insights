module Msg exposing (Msg(..))

import Browser exposing (UrlRequest)
import Data.Budget exposing (Budget, BudgetSummary)
import Db exposing (Db)
import Http
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Router exposing (Route)


type Msg
    = RouteChanged (Result String Route)
    | UrlRequested UrlRequest
    | BudgetSelectorMsg BudgetSelector.Msg
    | DashboardMsg Dashboard.Msg
    | GotBudget (Result Http.Error Budget)
    | GotBudgetSummaries (Result Http.Error (Db BudgetSummary))
