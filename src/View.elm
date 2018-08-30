module View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (Model(..))
import Update exposing (Msg)
import View.PickingBudget
import View.Dashboard
import View.Error


view : Model -> Browser.Document Msg
view model =
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
            , viewPage model
            ]
        }


viewPage : Model -> Html Msg
viewPage model =
    case model of
        Initializing _ _ ->
            div [] []

        PickingBudget budgets _ ->
            View.PickingBudget.view budgets

        Dashboard state ->
            View.Dashboard.view state

        SomethingWentWrong error ->
            View.Error.view error


styleTag : Html msg
styleTag =
    node "link" [ rel "stylesheet", href "main.css" ] []
