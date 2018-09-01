module Update exposing (Msg(..), init, update)

import API exposing (Token, fetchBudgetByID, fetchBudgetSummaries)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Navigation
import Cmd.Extra exposing (..)
import Data.Budget as Budget exposing (Budget, BudgetSummaries, BudgetSummary)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Http
import Json.Decode
import Model exposing (Model(..), initialModel)
import Model.SomethingWentWrong
import Url exposing (Url)



-- UPDATE


type Msg
    = GotBudgetSummaries (Result Http.Error BudgetSummaries)
    | GotBudget (Result Http.Error Budget)
    | SelectedBudget BudgetSummary
    | GoBack
    | ClickedLink UrlRequest
    | UrlChanged Url


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
        ( Initializing { token, lastBudgetID }, GotBudgetSummaries (Ok budgets) ) ->
            case lastBudgetID |> Maybe.andThen (\id -> AnyDict.get id budgets) of
                Nothing ->
                    PickingBudget { budgetSummaries = budgets, token = token }
                        |> withNoCmd

                Just budget ->
                    Dashboard { budgets = budgets, budget = budget, token = token }
                        |> withCmd (fetchBudgetByID token budget.id GotBudget)

        -- Budget picking screen
        ( PickingBudget { token }, GotBudgetSummaries (Ok budgets) ) ->
            PickingBudget { budgetSummaries = budgets, token = token }
                |> withNoCmd

        ( PickingBudget { budgetSummaries, token }, SelectedBudget budget ) ->
            Dashboard { budgets = budgetSummaries, budget = budget, token = token }
                |> withCmd (fetchBudgetByID token budget.id GotBudget)

        -- On the dashboard
        ( Dashboard { budgets, token }, GoBack ) ->
            PickingBudget { budgetSummaries = budgets, token = token }
                |> withNoCmd

        ( Dashboard { budget, token }, GotBudgetSummaries (Ok budgets) ) ->
            case AnyDict.get budget.id budgets of
                Just foundBudget ->
                    Dashboard { budgets = budgets, budget = foundBudget, token = token }
                        |> withNoCmd

                Nothing ->
                    PickingBudget { budgetSummaries = budgets, token = token }
                        |> withNoCmd

        ( Dashboard dashboardModel, GotBudget (Ok budget) ) ->
            Dashboard dashboardModel |> withNoCmd

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
