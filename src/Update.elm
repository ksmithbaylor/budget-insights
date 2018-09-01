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
                    PickingBudget budgets token
                        |> withNoCmd

                Just budget ->
                    Dashboard { budgets = budgets, budget = budget, token = token }
                        |> withCmd (fetchBudgetByID token budget.id GotBudget)

        -- Budget picking screen
        ( PickingBudget _ token, GotBudgetSummaries (Ok budgets) ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( PickingBudget budgets token, SelectedBudget budget ) ->
            Dashboard { budgets = budgets, budget = budget, token = token }
                |> withCmd (fetchBudgetByID token budget.id GotBudget)

        -- On the dashboard
        ( Dashboard { budgets, token }, GoBack ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( Dashboard state, GotBudgetSummaries (Ok budgets) ) ->
            case AnyDict.get state.budget.id budgets of
                Just budget ->
                    Dashboard { budgets = budgets, budget = budget, token = state.token }
                        |> withNoCmd

                Nothing ->
                    PickingBudget budgets state.token
                        |> withNoCmd

        ( Dashboard state, GotBudget (Ok budget) ) ->
            -- let
            -- logBudget =
            -- Debug.log "budget" budget
            -- in
            Dashboard state |> withNoCmd

        -- Error handling
        ( _, GotBudgetSummaries (Err error) ) ->
            SomethingWentWrong error
                |> withNoCmd

        ( _, GotBudget (Err error) ) ->
            SomethingWentWrong error
                |> withNoCmd

        -- Ignore any unexpected messages sent to the wrong page
        ( _, _ ) ->
            model |> withNoCmd
