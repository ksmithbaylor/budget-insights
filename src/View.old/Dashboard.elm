module View.Dashboard exposing (view)

import Data.Budget as Budget exposing (BudgetSummary)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model.Dashboard exposing (Model)
import Msg exposing (Msg(..))


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ viewTopBar model.budgetSummary
        , viewMain model
        ]


viewTopBar : BudgetSummary -> Html Msg
viewTopBar budgetSummary =
    div [ class "top-bar" ]
        [ button [ class "back shadow-box", onClick GoBack ] [ text "⬅" ]
        , span [ class "budget-name" ] [ text budgetSummary.name ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    div [ class "main shadow-box no-hover" ] <|
        if model.loading then
            [ text "Loading..." ]

        else
            [ text <| Debug.toString model ]
