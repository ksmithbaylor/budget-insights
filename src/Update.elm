module Update exposing (initCmd, update)

import API
import Browser
import Browser.Navigation as Navigation
import Data.Context as Context
import Data.CustomError exposing (..)
import Http
import Json.Decode exposing (errorToString)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Page.SomethingWentWrong as SomethingWentWrong
import Platform exposing (Router)
import Return2 as R2
import Return3 as R3
import Router exposing (Route)
import Url exposing (Url)


initCmd : Model -> Cmd Msg
initCmd ( context, _ ) =
    API.fetchBudgetSummaries context.token GotBudgetSummaries


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
            model |> R2.withCmd (Navigation.load urlString)

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
                |> (case page of
                        Page.Dashboard subModel ->
                            -- If the budget matches the current dashboard,
                            -- re-initialize it so it has a chance to show a
                            -- loading spinner
                            if subModel.budgetId == budget.id then
                                handleRoute (Router.Dashboard budget.id)

                            else
                                R2.withNoCmd

                        _ ->
                            R2.withNoCmd
                   )

        GotBudget (Err error) ->
            handleHttpError error model

        GotBudgetSummaries (Ok budgetSummaries) ->
            model
                |> Model.mapContext (Context.setBudgetSummaries budgetSummaries)
                |> R2.withNoCmd

        GotBudgetSummaries (Err error) ->
            handleHttpError error model


handleBudgetSelectorReply : BudgetSelector.Model -> Maybe BudgetSelector.Reply -> Model -> ( Model, Cmd Msg )
handleBudgetSelectorReply subModel maybeReply (( context, page ) as model) =
    let
        newModel =
            Page.BudgetSelector subModel
                |> Model.setPage model
    in
    case maybeReply of
        Nothing ->
            newModel
                |> R2.withNoCmd

        Just (BudgetSelector.SelectedBudget id) ->
            newModel
                |> R2.withCmd (Router.goTo context (Router.Dashboard id))


handleDashboardReply : Dashboard.Model -> Maybe Dashboard.Reply -> Model -> ( Model, Cmd Msg )
handleDashboardReply subModel maybeReply (( context, page ) as model) =
    let
        newModel =
            Page.Dashboard subModel
                |> Model.setPage model
    in
    case maybeReply of
        Nothing ->
            newModel
                |> R2.withNoCmd

        Just (Dashboard.RequestedBudget budgetId) ->
            newModel
                |> R2.withCmd (API.fetchBudgetById context.token budgetId GotBudget)

        Just Dashboard.GoToBudgetSelector ->
            newModel
                |> R2.withCmd (Router.goTo context Router.BudgetSelector)


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
                |> R2.withCmd
                    (SomethingWentWrong.possiblyRedirect context
                        (Router.goTo context Router.BudgetSelector)
                    )


handleRoutingError : String -> Model -> ( Model, Cmd Msg )
handleRoutingError url (( context, _ ) as model) =
    model
        |> Model.mapContext (Context.setError (RoutingError url))
        |> R2.withCmd (Router.goTo context Router.Oops)


handleHttpError : Http.Error -> Model -> ( Model, Cmd Msg )
handleHttpError error (( context, _ ) as model) =
    model
        |> Model.mapContext (Context.setError (FetchingError error))
        |> R2.withCmd (Router.goTo context Router.Oops)
