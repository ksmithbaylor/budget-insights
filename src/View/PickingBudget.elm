module View.PickingBudget exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dict exposing (Dict)
import ISO8601
import Model exposing (Model(..), DashboardState)
import Update exposing (Msg(..))
import Data.Budget exposing (Budget, BudgetID)


view : Dict BudgetID Budget -> Html Msg
view budgets =
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
