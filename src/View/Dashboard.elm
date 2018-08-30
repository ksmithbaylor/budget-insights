module View.Dashboard exposing (view)

import Data.Budget as Budget exposing (Budget)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model exposing (DashboardState, Model(..))
import Update exposing (Msg(..))


view : DashboardState -> Html Msg
view state =
    div [ class "dashboard" ]
        [ viewTopBar state.budget
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
