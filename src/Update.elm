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
    case ( msg, model ) of
        ( GoBack, Dashboard { budgets, token } ) ->
            ( PickingBudget budgets token, Cmd.none )

        ( GotToken (Ok token), Initializing budgetID _ ) ->
            ( Initializing budgetID (Just token), fetchBudgets token GotBudgets )

        ( GotToken (Ok token), PickingBudget budgets _ ) ->
            ( PickingBudget budgets token, Cmd.none )

        ( GotToken (Ok token), Dashboard state ) ->
            ( Dashboard { state | token = token }, Cmd.none )

        ( GotBudgets (Ok budgets), Initializing possibleBudgetID possibleToken ) ->
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
                        ( Dashboard
                            { budgets = budgets
                            , activeBudget = budget
                            , token = token
                            }
                        , Cmd.none
                        )

        ( GotBudgets (Ok budgets), PickingBudget _ token ) ->
            ( PickingBudget budgets token, Cmd.none )

        ( GotBudgets (Ok budgets), Dashboard { activeBudget, token } ) ->
            case Dict.get activeBudget.id budgets of
                Just budget ->
                    ( Dashboard
                        { budgets = budgets
                        , activeBudget = budget
                        , token = token
                        }
                    , Cmd.none
                    )

                Nothing ->
                    ( PickingBudget budgets token, Cmd.none )

        ( SelectedBudget budget, PickingBudget budgets token ) ->
            ( Dashboard
                { budgets = budgets
                , activeBudget = budget
                , token = token
                }
            , Cmd.none
            )

        ( GotBudgets (Err error), _ ) ->
            ( SomethingWentWrong error, Cmd.none )

        ( GotToken (Err error), _ ) ->
            ( SomethingWentWrong error, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )
