module View exposing (view)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html, div)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Page.SomethingWentWrong as SomethingWentWrong
import UI.Loader


view : Model -> Browser.Document Msg
view model =
    { title = "Budget Insights"
    , body = viewPage model
    }


viewPage : Model -> List (Html Msg)
viewPage ( context, page ) =
    let
        ( loading, mainContent ) =
            case page of
                Page.BudgetSelector subModel ->
                    subModel
                        |> BudgetSelector.view context
                        |> Element.map BudgetSelectorMsg
                        |> Tuple.pair (BudgetSelector.isLoading context subModel)

                Page.Dashboard subModel ->
                    subModel
                        |> Dashboard.view context
                        |> Element.map DashboardMsg
                        |> Tuple.pair (Dashboard.isLoading context subModel)

                Page.Error ->
                    SomethingWentWrong.view context
                        |> Tuple.pair False

                Page.Blank ->
                    Element.none
                        |> Tuple.pair False
    in
    -- Eventually, add stuff like header/footer here
    [ UI.Loader.view loading
    , Element.layout
        [ width fill
        , height fill
        , padding 24
        , Background.color (rgb 0.9 0.9 0.9)
        , Font.size 16
        , Font.family
            [ Font.typeface "Avenir"
            , Font.typeface "Helvetica"
            , Font.sansSerif
            ]
        ]
        mainContent
    ]
