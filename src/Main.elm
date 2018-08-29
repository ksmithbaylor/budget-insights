module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Dict exposing (Dict)
import API exposing (fetchToken, fetchBudgets)
import Debug
import ISO8601
import Data.Budget exposing (..)


-- MAIN


main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Token =
    String


type alias DashboardState =
    { budgets : Dict BudgetID Budget
    , activeBudget : Budget
    , apiToken : Token
    }


type alias PickingBudgetState =
    { budgets : Dict BudgetID Budget, apiToken : Token }


type Model
    = Initializing (Maybe BudgetID) (Maybe Token)
    | PickingBudget PickingBudgetState
    | Initialized DashboardState
    | SomethingWentWrong Http.Error


init : () -> ( Model, Cmd Msg )
init flags =
    ( Initializing (Just "1b1f448f-8750-40a9-b744-f772f4898b91") Nothing
    , fetchToken GotToken
    )



-- UPDATE


type Msg
    = GotToken (Result Http.Error String)
    | GotBudgets (Result Http.Error (Dict BudgetID Budget))
    | SelectedBudget Budget
    | GoBack


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GoBack ->
            case model of
                Initialized { budgets, apiToken } ->
                    ( PickingBudget { budgets = budgets, apiToken = apiToken }, Cmd.none )

                other ->
                    ( other, Cmd.none )

        GotToken (Ok token) ->
            case model of
                Initializing budgetID _ ->
                    ( Initializing budgetID (Just token), fetchBudgets token GotBudgets )

                PickingBudget state ->
                    ( PickingBudget { state | apiToken = token }, Cmd.none )

                Initialized state ->
                    ( Initialized { state | apiToken = token }, Cmd.none )

                other ->
                    ( other, Cmd.none )

        GotToken (Err error) ->
            ( SomethingWentWrong error, Cmd.none )

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
                                ( PickingBudget
                                    { budgets = budgets
                                    , apiToken = token
                                    }
                                , Cmd.none
                                )

                            Just budget ->
                                ( Initialized
                                    { budgets = budgets
                                    , activeBudget = budget
                                    , apiToken = token
                                    }
                                , Cmd.none
                                )

                PickingBudget { apiToken } ->
                    ( PickingBudget { budgets = budgets, apiToken = apiToken }, Cmd.none )

                Initialized { activeBudget, apiToken } ->
                    case Dict.get activeBudget.id budgets of
                        Just budget ->
                            ( Initialized
                                { budgets = budgets
                                , activeBudget = budget
                                , apiToken = apiToken
                                }
                            , Cmd.none
                            )

                        Nothing ->
                            ( PickingBudget
                                { budgets = budgets
                                , apiToken = apiToken
                                }
                            , Cmd.none
                            )

                other ->
                    ( other, Cmd.none )

        GotBudgets (Err error) ->
            ( SomethingWentWrong error, Cmd.none )

        SelectedBudget budget ->
            case model of
                PickingBudget { budgets, apiToken } ->
                    ( Initialized
                        { budgets = budgets
                        , activeBudget = budget
                        , apiToken = apiToken
                        }
                    , Cmd.none
                    )

                other ->
                    ( other, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    let
        title =
            case model of
                Initialized { activeBudget } ->
                    "Budget Insights | " ++ activeBudget.name

                _ ->
                    "Budget Insights"
    in
        { title = title
        , body =
            [ styleTag
            , view model
            ]
        }


styleTag : Html msg
styleTag =
    Html.node "link" [ Html.Attributes.rel "stylesheet", Html.Attributes.href "main.css" ] []


view : Model -> Html Msg
view model =
    case model of
        Initializing _ _ ->
            div [] []

        PickingBudget { budgets } ->
            viewBudgets budgets

        Initialized state ->
            viewDashboard state

        SomethingWentWrong error ->
            viewError error


viewBudgets : Dict BudgetID Budget -> Html Msg
viewBudgets budgets =
    div [ class "budget-list" ]
        [ h1 [] [ text "Available Budgets" ]
        , div [ class "flow" ]
            (budgets
                |> Dict.toList
                |> List.map Tuple.second
                |> List.sortBy (.lastModified >> ISO8601.toString)
                |> List.reverse
                |> List.map viewBudget
            )
        ]


viewBudget : Budget -> Html Msg
viewBudget budget =
    div [ class "budget shadow-box", onClick (SelectedBudget budget) ]
        [ div [ class "budget-name" ] [ text budget.name ]
        , div []
            [ span [] [ text "Last Modified: " ]
            , span [ class "light" ]
                [ text <|
                    (ISO8601.toString budget.lastModified
                        |> String.split "T"
                        |> List.head
                        |> Maybe.withDefault ""
                    )
                ]
            ]
        ]


viewDashboard : DashboardState -> Html Msg
viewDashboard state =
    div [ class "dashboard" ]
        [ viewTopBar state.activeBudget
        , viewMain state
        ]


viewTopBar : Budget -> Html Msg
viewTopBar budget =
    div [ class "top-bar" ]
        [ button [ class "back shadow-box", onClick GoBack ] [ text "⬅" ]
        , span [ class "budget-name" ] [ text budget.name ]
        ]


viewMain : DashboardState -> Html Msg
viewMain state =
    div [ class "main shadow-box no-hover" ] []


viewError : Http.Error -> Html msg
viewError err =
    div [ class "error" ]
        [ text <|
            case err of
                Http.Timeout ->
                    "Request timed out"

                Http.NetworkError ->
                    "Something went wrong with a request"

                Http.BadUrl str ->
                    "Badly-formed URL: " ++ str

                Http.BadStatus _ ->
                    "Non-200 status code"

                Http.BadPayload mess _ ->
                    "Error decoding response: " ++ mess
        ]
