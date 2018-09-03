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
import CustomError
import Flags exposing (Flags)
import Html exposing (Html, div)
import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard
import Page.SomethingWentWrong as SomethingWentWrong
import Return2 as R2
import Return3 as R3 exposing (Return)
import Router
import Url exposing (Url)


type alias Model =
    { route : Router.Route
    , key : Navigation.Key
    , budgetSelector : BudgetSelector.Model
    , dashboard : Dashboard.Model
    , somethingWentWrong : SomethingWentWrong.Model
    }


type Msg
    = NavigateTo Browser.UrlRequest
    | UrlChanged Url
    | ContextMsg Context.Msg
    | BudgetSelectorMsg BudgetSelector.Msg
    | DashboardMsg Dashboard.Msg
    | SomethingWentWrongMsg SomethingWentWrong.Msg


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( initialRoute, routingCmd ) =
            case Router.fromUrl url of
                Ok route ->
                    ( route, Cmd.none )

                Err _ ->
                    ( Router.BudgetSelector, Navigation.replaceUrl key "/" )
    in
    { route = initialRoute
    , key = key
    , budgetSelector = BudgetSelector.initModel
    , dashboard = Dashboard.initModel
    , somethingWentWrong = SomethingWentWrong.initModel
    }
        |> R2.withCmds
            [ routingCmd
            , BudgetSelector.initCmd flags |> Cmd.map BudgetSelectorMsg
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

        DashboardMsg subMsg ->
            Dashboard.update subMsg model.dashboard
                |> R3.mapModel (\subModel -> { model | dashboard = subModel })
                |> R3.mapCmd DashboardMsg

        SomethingWentWrongMsg subMsg ->
            SomethingWentWrong.update subMsg model.somethingWentWrong
                |> R3.mapModel (\subModel -> { model | somethingWentWrong = subModel })
                |> R3.mapCmd SomethingWentWrongMsg

        NavigateTo urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    model
                        |> R2.withCmd (Navigation.pushUrl model.key (Url.toString url))
                        |> R3.withNoReply

                Browser.External url ->
                    model
                        |> R2.withCmd (Navigation.load url)
                        |> R3.withNoReply

        UrlChanged url ->
            case Router.fromUrl url of
                Ok route ->
                    { model | route = route }
                        |> R3.withNothing

                Err message ->
                    { model | route = Router.Oops }
                        |> R2.withNoCmd
                        |> R3.withReply (Context.ErrorHappened <| CustomError.LogicError <| "Routing error: " ++ message)

        ContextMsg contextMsg ->
            handleContextMsg contextMsg model


handleContextMsg : Context.Msg -> Model -> Return Model Msg Context.Msg
handleContextMsg contextMsg model =
    case contextMsg of
        Context.ErrorHappened error ->
            model
                |> R2.withCmd (Navigation.pushUrl model.key "/oops")
                |> R3.withNoReply

        _ ->
            model |> R3.withNothing


view : Context.Model -> Model -> Html Msg
view context model =
    case model.route of
        Router.BudgetSelector ->
            BudgetSelector.view context model.budgetSelector
                |> Html.map BudgetSelectorMsg

        Router.Dashboard budgetID ->
            Dashboard.view context model.dashboard
                |> Html.map DashboardMsg

        Router.Oops ->
            SomethingWentWrong.view context model.somethingWentWrong
                |> Html.map SomethingWentWrongMsg
