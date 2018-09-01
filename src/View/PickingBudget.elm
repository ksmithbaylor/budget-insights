module View.PickingBudget exposing (view)

import Data.Budget as Budget exposing (BudgetSummaries, BudgetSummary)
import Dict.Any as AnyDict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ISO8601
import Model.PickingBudget exposing (Model)
import Msg exposing (Msg(..))


view : Model -> Html Msg
view { budgetSummaries } =
    div [ class "budget-list" ]
        [ h1 [] [ text "Available Budgets" ]
        , div [ class "flow" ]
            (budgetSummaries
                |> AnyDict.values
                |> List.sortBy (.lastModified >> ISO8601.toString)
                |> List.reverse
                |> List.map viewBudget
            )
        ]


viewBudget : BudgetSummary -> Html Msg
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
