module Page exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Navigation
import Context
import Flags exposing (Flags)
import Html exposing (Html, div)
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Page.SomethingWentWrong as SomethingWentWrong
import Return2 as R2
import Return3 as R3 exposing (Return)
import Url exposing (Url)


type alias Model =
    { currentPage : Page
    , key : Navigation.Key
    , budgetSelector : BudgetSelector.Model
    , dashboard : Dashboard.Model
    , somethingWentWrong : SomethingWentWrong.Model
    }


type Page
    = BudgetSelector
    | Dashboard
    | SomethingWentWrong


type Msg
    = NavigateTo Browser.UrlRequest
    | UrlChanged Url
    | ContextMsg Context.Msg
    | BudgetSelectorMsg BudgetSelector.Msg
    | DashboardMsg Dashboard.Msg
    | SomethingWentWrongMsg SomethingWentWrong.Msg


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    { currentPage = BudgetSelector
    , key = key
    , budgetSelector = BudgetSelector.initModel
    , dashboard = Dashboard.initModel
    , somethingWentWrong = SomethingWentWrong.initModel
    }
        |> R2.withCmds
            [ BudgetSelector.initCmd flags |> Cmd.map BudgetSelectorMsg
            , Dashboard.initCmd flags |> Cmd.map DashboardMsg
            , SomethingWentWrong.initCmd flags |> Cmd.map SomethingWentWrongMsg
            ]


update : Msg -> Model -> Return Model Msg Context.Msg
update msg model =
    case msg of
        BudgetSelectorMsg subMsg ->
            BudgetSelector.update subMsg model.budgetSelector
                |> R3.mapModel (\subModel -> { model | budgetSelector = subModel })
                |> R3.mapCmd BudgetSelectorMsg

        ContextMsg (Context.FetchError error) ->
            { model | currentPage = SomethingWentWrong }
                |> R3.withNothing

        _ ->
            model |> R3.withNothing


view : Context.Model -> Model -> Html Msg
view context model =
    case model.currentPage of
        BudgetSelector ->
            BudgetSelector.view context model.budgetSelector
                |> Html.map BudgetSelectorMsg

        Dashboard ->
            Dashboard.view context model.dashboard
                |> Html.map DashboardMsg

        SomethingWentWrong ->
            SomethingWentWrong.view context model.somethingWentWrong
                |> Html.map SomethingWentWrongMsg
