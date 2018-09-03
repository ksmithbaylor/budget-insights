module Update exposing (init, update)

import API exposing (Token, fetchBudgetById, fetchBudgetSummaries)
import Browser.Navigation as Navigation
import Cmd.Extra exposing (..)
import Data.Budget as Budget exposing (Budget, BudgetSummaries, BudgetSummary)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Http
import Json.Decode
import Model exposing (Model(..), initialModel)
import Model.SomethingWentWrong
import Msg exposing (Msg(..))
import Url exposing (Url)


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel flags, initialCmd flags )


initialCmd : Flags -> Cmd Msg
initialCmd flags =
    fetchBudgetSummaries flags.token GotBudgetSummaries


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- Have a token, now fetching the list of budgets
        ( Initializing { token, lastBudgetId }, GotBudgetSummaries (Ok budgetSummaries) ) ->
            case lastBudgetId |> Maybe.andThen (\id -> AnyDict.get id budgetSummaries) of
                Nothing ->
                    PickingBudget { budgetSummaries = budgetSummaries, token = token }
                        |> withNoCmd

                Just budget ->
                    Dashboard { budgetSummaries = budgetSummaries, budgetSummary = budget, token = token, loading = True }
                        |> withCmd (fetchBudgetById token budget.id GotBudget)

        -- Budget picking screen
        ( PickingBudget { token }, GotBudgetSummaries (Ok budgetSummaries) ) ->
            PickingBudget { budgetSummaries = budgetSummaries, token = token }
                |> withNoCmd

        ( PickingBudget { budgetSummaries, token }, SelectedBudget budget ) ->
            Dashboard { budgetSummaries = budgetSummaries, budgetSummary = budget, token = token, loading = True }
                |> withCmd (fetchBudgetById token budget.id GotBudget)

        -- On the dashboard
        ( Dashboard { budgetSummaries, token }, GoBack ) ->
            PickingBudget { budgetSummaries = budgetSummaries, token = token }
                |> withNoCmd

        ( Dashboard { budgetSummary, token }, GotBudgetSummaries (Ok budgetSummaries) ) ->
            case AnyDict.get budgetSummary.id budgetSummaries of
                Just foundBudget ->
                    Dashboard { budgetSummaries = budgetSummaries, budgetSummary = foundBudget, token = token, loading = False }
                        |> withNoCmd

                Nothing ->
                    PickingBudget { budgetSummaries = budgetSummaries, token = token }
                        |> withNoCmd

        ( Dashboard dashboardModel, GotBudget (Ok budget) ) ->
            Dashboard { dashboardModel | loading = False } |> withNoCmd

        -- Error handling
        ( _, GotBudgetSummaries (Err error) ) ->
            SomethingWentWrong { error = Model.SomethingWentWrong.FetchError error }
                |> withNoCmd

        ( _, GotBudget (Err error) ) ->
            SomethingWentWrong { error = Model.SomethingWentWrong.FetchError error }
                |> withNoCmd

        -- Ignore any unexpected messages sent to the wrong page
        ( _, _ ) ->
            model |> withNoCmd
