module Update exposing (Msg(..), init, update)

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


init : () -> ( Model, Cmd Msg )
init flags =
    ( Initializing (Just "1b1f448f-8750-40a9-b744-f772f4898b91") Nothing
    , fetchToken GotToken
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GoBack ->
            case model of
                Dashboard { budgets, token } ->
                    ( PickingBudget budgets token, Cmd.none )

                other ->
                    ( other, Cmd.none )

        GotToken (Ok token) ->
            case model of
                Initializing budgetID _ ->
                    ( Initializing budgetID (Just token), fetchBudgets token GotBudgets )

                PickingBudget budgets _ ->
                    ( PickingBudget budgets token, Cmd.none )

                Dashboard state ->
                    ( Dashboard { state | token = token }, Cmd.none )

                other ->
                    ( other, Cmd.none )

        GotBudgets (Ok budgets) ->
            case model of
                Initializing possibleBudgetID possibleToken ->
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

                PickingBudget _ token ->
                    ( PickingBudget budgets token, Cmd.none )

                Dashboard { activeBudget, token } ->
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

                other ->
                    ( other, Cmd.none )

        SelectedBudget budget ->
            case model of
                PickingBudget budgets token ->
                    ( Dashboard
                        { budgets = budgets
                        , activeBudget = budget
                        , token = token
                        }
                    , Cmd.none
                    )

                other ->
                    ( other, Cmd.none )

        GotBudgets (Err error) ->
            ( SomethingWentWrong error, Cmd.none )

        GotToken (Err error) ->
            ( SomethingWentWrong error, Cmd.none )
