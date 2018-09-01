module View exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (Model(..))
import Msg exposing (Msg)
import View.Dashboard as Dashboard
import View.Initializing as Initializing
import View.PickingBudget as PickingBudget
import View.SomethingWentWrong as SomethingWentWrong


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
        Initializing subModel ->
            Initializing.view subModel

        PickingBudget subModel ->
            PickingBudget.view subModel

        Dashboard state ->
            Dashboard.view state

        SomethingWentWrong error ->
            SomethingWentWrong.view error
