module Update exposing (Msg(..), init, update)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Navigation
import Url exposing (Url)
import Http
import Dict exposing (Dict)
import Model exposing (Model(..))
import API exposing (fetchToken, fetchBudgets)
import Data.Budget exposing (Budget, BudgetID)


-- UPDATE


type Msg
    = GotToken (Result Http.Error String)
    | GotBudgets (Result Http.Error (Dict BudgetID Budget))
    | SelectedBudget Budget
    | GoBack
    | ClickedLink UrlRequest
    | UrlChanged Url


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Initializing (Just "1b1f448f-8750-40a9-b744-f772f4898b91") Nothing
    , fetchToken GotToken
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -- While loading the page
        ( Initializing possibleBudgetID _, GotToken (Ok token) ) ->
            ( Initializing possibleBudgetID (Just token), fetchBudgets token GotBudgets )

        ( Initializing possibleBudgetID possibleToken, GotBudgets (Ok budgets) ) ->
            let
                token =
                    Maybe.withDefault "" possibleToken

                budgetID =
                    Maybe.withDefault "BOGUS" possibleBudgetID
            in
                case Dict.get budgetID budgets of
                    Nothing ->
                        ( PickingBudget budgets token, Cmd.none )

                    Just budget ->
                        ( Dashboard { budgets = budgets, activeBudget = budget, token = token }
                        , Cmd.none
                        )

        -- Budget picking screen
        ( PickingBudget budgets _, GotToken (Ok token) ) ->
            ( PickingBudget budgets token, Cmd.none )

        ( PickingBudget _ token, GotBudgets (Ok budgets) ) ->
            ( PickingBudget budgets token, Cmd.none )

        ( PickingBudget budgets token, SelectedBudget budget ) ->
            ( Dashboard { budgets = budgets, activeBudget = budget, token = token }
            , Cmd.none
            )

        -- On the dashboard
        ( Dashboard { budgets, token }, GoBack ) ->
            ( PickingBudget budgets token, Cmd.none )

        ( Dashboard state, GotToken (Ok token) ) ->
            ( Dashboard { state | token = token }, Cmd.none )

        ( Dashboard { activeBudget, token }, GotBudgets (Ok budgets) ) ->
            case Dict.get activeBudget.id budgets of
                Just budget ->
                    ( Dashboard { budgets = budgets, activeBudget = budget, token = token }
                    , Cmd.none
                    )

                Nothing ->
                    ( PickingBudget budgets token, Cmd.none )

        -- Error handling and unexpected messages
        ( _, GotBudgets (Err error) ) ->
            ( SomethingWentWrong error, Cmd.none )

        ( _, GotToken (Err error) ) ->
            ( SomethingWentWrong error, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )
