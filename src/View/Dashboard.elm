module View.Dashboard exposing (view)

import Data.Budget as Budget exposing (BudgetSummary)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model.Dashboard exposing (Model)
import Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ viewTopBar model.budget
        , viewMain model
        ]


viewTopBar : BudgetSummary -> Html Msg
viewTopBar budget =
    div [ class "top-bar" ]
        [ button [ class "back shadow-box", onClick GoBack ] [ text "⬅" ]
        , span [ class "budget-name" ] [ text budget.name ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    div [ class "main shadow-box no-hover" ] []
