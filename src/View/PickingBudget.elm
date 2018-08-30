module View.PickingBudget exposing (view)

import Data.Budget exposing (Budget, BudgetID)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ISO8601
import Model exposing (DashboardState, Model(..))
import Update exposing (Msg(..))


view : AnyDict String BudgetID Budget -> Html Msg
view budgets =
    div [ class "budget-list" ]
        [ h1 [] [ text "Available Budgets" ]
        , div [ class "flow" ]
            (budgets
                |> AnyDict.values
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
