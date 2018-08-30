module Update exposing (Msg(..), init, update)

import API exposing (Token, fetchBudgets, fetchToken, usableToken)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Navigation
import Cmd.Extra exposing (..)
import Data.Budget as Budget exposing (Budget, Budgets)
import Dict.Any as AnyDict
import Http
import Model exposing (Model(..))
import Url exposing (Url)



-- UPDATE


type Msg
    = GotToken (Result Http.Error Token)
    | GotBudgets (Result Http.Error Budgets)
    | SelectedBudget Budget
    | GoBack
    | ClickedLink UrlRequest
    | UrlChanged Url


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Initializing (Just Budget.defaultBudgetID)
    , fetchToken GotToken
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- Initial page load
        ( Initializing possibleBudgetID, GotToken (Ok token) ) ->
            FetchingBudgets possibleBudgetID token
                |> withCmd (fetchBudgets token GotBudgets)

        -- Have a token, now fetching the list of budgets
        ( FetchingBudgets possibleBudgetID token, GotBudgets (Ok budgets) ) ->
            let
                possibleBudget =
                    possibleBudgetID |> Maybe.andThen (\id -> AnyDict.get id budgets)
            in
            case possibleBudget of
                Nothing ->
                    PickingBudget budgets token
                        |> withNoCmd

                Just budget ->
                    Dashboard { budgets = budgets, budget = budget, token = token }
                        |> withNoCmd

        -- Budget picking screen
        ( PickingBudget budgets _, GotToken (Ok token) ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( PickingBudget _ token, GotBudgets (Ok budgets) ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( PickingBudget budgets token, SelectedBudget budget ) ->
            Dashboard { budgets = budgets, budget = budget, token = token }
                |> withNoCmd

        -- On the dashboard
        ( Dashboard { budgets, token }, GoBack ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( Dashboard state, GotToken (Ok token) ) ->
            Dashboard { state | token = token }
                |> withNoCmd

        ( Dashboard state, GotBudgets (Ok budgets) ) ->
            case AnyDict.get state.budget.id budgets of
                Just budget ->
                    Dashboard { budgets = budgets, budget = budget, token = state.token }
                        |> withNoCmd

                Nothing ->
                    PickingBudget budgets state.token
                        |> withNoCmd

        -- Error handling
        ( _, GotBudgets (Err error) ) ->
            SomethingWentWrong error
                |> withNoCmd

        ( _, GotToken (Err error) ) ->
            SomethingWentWrong error
                |> withNoCmd

        -- Ignore any unexpected messages sent to the wrong page
        ( _, _ ) ->
            model |> withNoCmd
