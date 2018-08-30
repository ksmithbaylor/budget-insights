module View.Dashboard exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model exposing (Model(..), DashboardState)
import Update exposing (Msg(..))
import Data.Budget exposing (Budget, BudgetID)


view : DashboardState -> Html Msg
view state =
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
