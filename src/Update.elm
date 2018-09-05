module Update exposing (update)

import API
import Browser
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
import Url exposing (Url)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (( context, page ) as model) =
    let
        noChange =
            model |> R2.withNoCmd
    in
    case msg of
        RouteChanged (Ok route) ->
            model |> handleRoute route

        RouteChanged (Err error) ->
            model |> handleRoutingError error

        UrlRequested (Browser.Internal url) ->
            case Router.fromUrl url of
                Ok route ->
                    model |> R2.withCmd (Router.goTo context route)

                Err error ->
                    model |> handleRoutingError error

        UrlRequested (Browser.External urlString) ->
            -- TODO: allow external links
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
            model
                |> Model.mapContext (Context.insertBudget budget)
                |> R2.withNoCmd

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
            result
                |> R2.addCmd (Router.goTo context (Router.Dashboard id))

        Just BudgetSelector.RequestedBudgetSummaries ->
            result
                |> R2.addCmd (API.fetchBudgetSummaries context.token GotBudgetSummaries)


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

        Just (Dashboard.RequestedBudget budgetId) ->
            result
                |> R2.addCmd (API.fetchBudgetById context.token budgetId GotBudget)

        Just Dashboard.GoToBudgetSelector ->
            result
                |> R2.addCmd (Router.goTo context Router.BudgetSelector)


handleRoute : Route -> Model -> ( Model, Cmd Msg )
handleRoute route (( context, page ) as model) =
    case route of
        Router.BudgetSelector ->
            ()
                |> BudgetSelector.init context
                |> R3.mapCmd BudgetSelectorMsg
                |> R3.incorp handleBudgetSelectorReply model

        Router.Dashboard budgetId ->
            { budgetId = budgetId }
                |> Dashboard.init context
                |> R3.mapCmd DashboardMsg
                |> R3.incorp handleDashboardReply model

        Router.Oops ->
            Page.Error
                |> Model.setPage model
                |> R2.withNoCmd


handleRoutingError : String -> Model -> ( Model, Cmd Msg )
handleRoutingError error (( context, _ ) as model) =
    -- TODO add error here to show message
    model |> R2.withCmd (Router.goTo context Router.Oops)
