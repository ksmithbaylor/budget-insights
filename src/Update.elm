module Update exposing (update)

import API
import Data.Context as Context
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Page2 as Page
import Platform exposing (Router)
import Return2 as R2
import Return3 as R3
import Router exposing (Route)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (( context, page ) as model) =
    let
        noChange =
            model |> R2.withNoCmd
    in
    case msg of
        RouteChanged (Ok route) ->
            model |> handleRoute route

        RouteChanged (Err url) ->
            noChange

        UrlRequested urlRequest ->
            noChange

        BudgetSelectorMsg subMsg ->
            case page of
                Page.BudgetSelector subModel ->
                    subModel
                        |> BudgetSelector.update context subMsg
                        |> R3.mapCmd BudgetSelectorMsg
                        |> R3.incorp handleBudgetSelectorReply model

                _ ->
                    noChange

        DashboardMsg subMsg ->
            case page of
                Page.Dashboard subModel ->
                    subModel
                        |> Dashboard.update context subMsg
                        |> R3.mapCmd DashboardMsg
                        |> R3.incorp handleDashboardReply model

                _ ->
                    noChange

        GotBudget (Ok budget) ->
            -- TODO
            noChange

        GotBudget (Err error) ->
            -- TODO
            noChange

        GotBudgetSummaries (Ok budgetSummaries) ->
            model
                |> Model.mapContext (Context.setBudgetSummaries budgetSummaries)
                |> R2.withNoCmd

        GotBudgetSummaries (Err error) ->
            -- TODO
            noChange


handleBudgetSelectorReply : BudgetSelector.Model -> Maybe BudgetSelector.Reply -> Model -> ( Model, Cmd Msg )
handleBudgetSelectorReply subModel maybeReply (( context, page ) as model) =
    let
        result =
            Page.BudgetSelector subModel
                |> Model.setPage model
                |> R2.withNoCmd
    in
    case maybeReply of
        Nothing ->
            result

        Just (BudgetSelector.SelectedBudget id) ->
            Page.Dashboard { budgetId = id }
                |> Model.setPage model
                |> R2.withNoCmd


handleDashboardReply : Dashboard.Model -> Maybe Dashboard.Reply -> Model -> ( Model, Cmd Msg )
handleDashboardReply subModel maybeReply (( context, page ) as model) =
    let
        result =
            Page.Dashboard subModel
                |> Model.setPage model
                |> R2.withNoCmd
    in
    case maybeReply of
        Nothing ->
            result

        Just () ->
            result


handleRoute : Route -> Model -> ( Model, Cmd Msg )
handleRoute route (( context, page ) as model) =
    case route of
        Router.BudgetSelector ->
            Page.BudgetSelector (BudgetSelector.init ())
                |> Model.setPage model
                |> R2.withCmd (API.fetchBudgetSummaries context.token GotBudgetSummaries)

        Router.Dashboard budgetId ->
            Page.Dashboard (Dashboard.init { budgetId = budgetId })
                |> Model.setPage model
                |> R2.withCmd (API.fetchBudgetById context.token budgetId GotBudget)

        Router.Oops ->
            Page.Error
                |> Model.setPage model
                |> R2.withNoCmd
