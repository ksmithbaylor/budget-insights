module View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (Model(..))
import Update exposing (Msg)
import View.Dashboard
import View.Error
import View.PickingBudget


view : Model -> Browser.Document Msg
view model =
    let
        title =
            case model of
                Dashboard { budget } ->
                    "Budget Insights | " ++ budget.name

                _ ->
                    "Budget Insights"
    in
    { title = title
    , body =
        [ viewPage model
        ]
    }


viewPage : Model -> Html Msg
viewPage model =
    case model of
        Initializing _ ->
            div [] []

        PickingBudget budgets _ ->
            View.PickingBudget.view budgets

        Dashboard state ->
            View.Dashboard.view state

        SomethingWentWrong error ->
            View.Error.view error
