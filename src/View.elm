module View exposing (viewDocument)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Dict exposing (Dict)
import ISO8601
import Update exposing (Model(..), Msg(..), DashboardState)
import Data.Budget exposing (Budget, BudgetID)


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    let
        title =
            case model of
                Dashboard { activeBudget } ->
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

        PickingBudget budgets _ ->
            viewBudgets budgets

        Dashboard state ->
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
