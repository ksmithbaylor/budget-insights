module Update exposing (Msg(..), init, update)

import API exposing (Token, fetchBudgets, fetchToken, usableToken)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Navigation
import Cmd.Extra exposing (..)
import Data.Budget exposing (Budget, BudgetID)
import Dict exposing (Dict)
import Http
import Model exposing (Model(..))
import Url exposing (Url)



-- UPDATE


type Msg
    = GotToken (Result Http.Error Token)
    | GotBudgets (Result Http.Error (Dict BudgetID Budget))
    | SelectedBudget Budget
    | GoBack
    | ClickedLink UrlRequest
    | UrlChanged Url


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Initializing (Just "1b1f448f-8750-40a9-b744-f772f4898b91")
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
            case possibleBudgetID |> Maybe.andThen (\id -> Dict.get id budgets) of
                Nothing ->
                    PickingBudget budgets token
                        |> withNoCmd

                Just budget ->
                    Dashboard { budgets = budgets, activeBudget = budget, token = token }
                        |> withNoCmd

        -- Budget picking screen
        ( PickingBudget budgets _, GotToken (Ok token) ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( PickingBudget _ token, GotBudgets (Ok budgets) ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( PickingBudget budgets token, SelectedBudget budget ) ->
            Dashboard { budgets = budgets, activeBudget = budget, token = token }
                |> withNoCmd

        -- On the dashboard
        ( Dashboard { budgets, token }, GoBack ) ->
            PickingBudget budgets token
                |> withNoCmd

        ( Dashboard state, GotToken (Ok token) ) ->
            Dashboard { state | token = token }
                |> withNoCmd

        ( Dashboard { activeBudget, token }, GotBudgets (Ok budgets) ) ->
            case Dict.get activeBudget.id budgets of
                Just budget ->
                    Dashboard { budgets = budgets, activeBudget = budget, token = token }
                        |> withNoCmd

                Nothing ->
                    PickingBudget budgets token
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
