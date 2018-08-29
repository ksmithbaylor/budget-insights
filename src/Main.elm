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


type Model
    = Initializing (Maybe BudgetID) (Maybe Token)
    | PickingBudgets { budgets : Dict BudgetID Budget, apiToken : Token }
    | Initialized
        { budgets : Dict BudgetID Budget
        , activeBudget : Budget
        , apiToken : Token
        }
    | SomethingWentWrong Http.Error


init : () -> ( Model, Cmd Msg )
init flags =
    -- ( Initializing (Just "1b1f448f-8750-40a9-b744-f772f4898b91") Nothing
    ( Initializing Nothing Nothing
    , fetchToken GotToken
    )



-- UPDATE


type Msg
    = GotToken (Result Http.Error String)
    | GotBudgets (Result Http.Error (Dict BudgetID Budget))
    | SelectBudget Budget


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotToken (Ok token) ->
            case model of
                Initializing budgetID _ ->
                    ( Initializing budgetID (Just token), fetchBudgets token GotBudgets )

                PickingBudgets state ->
                    ( PickingBudgets { state | apiToken = token }, Cmd.none )

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
                                ( PickingBudgets
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

                PickingBudgets { apiToken } ->
                    ( PickingBudgets { budgets = budgets, apiToken = apiToken }, Cmd.none )

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
                            ( PickingBudgets
                                { budgets = budgets
                                , apiToken = apiToken
                                }
                            , Cmd.none
                            )

                other ->
                    ( other, Cmd.none )

        GotBudgets (Err error) ->
            ( SomethingWentWrong error, Cmd.none )

        SelectBudget budget ->
            case model of
                PickingBudgets { budgets, apiToken } ->
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
    { title = "Hello"
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
    let
        loading =
            text "Loading..."
    in
        case model of
            Initializing _ _ ->
                loading

            PickingBudgets { budgets } ->
                viewBudgets budgets

            Initialized _ ->
                loading

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
    div [ class "budget shadow-box" ]
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
