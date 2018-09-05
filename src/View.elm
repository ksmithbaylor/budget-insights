module View exposing (view)

import Browser
import Html exposing (Html, div)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Page.SomethingWentWrong as SomethingWentWrong


view : Model -> Browser.Document Msg
view model =
    { title = "Budget Insights"
    , body = viewPage model
    }


viewPage : Model -> List (Html Msg)
viewPage ( context, page ) =
    let
        mainContent =
            case page of
                Page.BudgetSelector subModel ->
                    subModel
                        |> BudgetSelector.view context
                        |> Html.map BudgetSelectorMsg

                Page.Dashboard subModel ->
                    subModel
                        |> Dashboard.view context
                        |> Html.map DashboardMsg

                Page.Error ->
                    SomethingWentWrong.view

                Page.Blank ->
                    div [] []
    in
    -- Eventually, add stuff like header/footer here
    [ mainContent ]
