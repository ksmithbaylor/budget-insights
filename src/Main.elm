module Main exposing (main)

import API exposing (Token, fetchBudgetSummaries)
import Browser
import Browser.Navigation as Navigation
import Context
import Data.Account as Account exposing (Accounts)
import Data.Budget as Budget exposing (BudgetSummaries, Budgets)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Html exposing (Html)
import Page
import Return2 as R2
import Return3 as R3
import Task.Extra exposing (message)
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = Page.NavigateTo >> PageMsg
        , onUrlChange = Page.UrlChanged >> PageMsg
        }


type alias Model =
    ( Context.Model, Page.Model )


type Msg
    = ContextMsg Context.Msg
    | PageMsg Page.Msg


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( contextModel, contextCmd ) =
            Context.init flags

        ( pageModel, pageCmd ) =
            Page.init flags url key
    in
    ( ( contextModel
      , pageModel
      )
    , combineCmds contextCmd pageCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( contextModel, pageModel ) =
            model
    in
    case msg of
        ContextMsg contextMsg ->
            let
                ( newContextModel, contextCmd ) =
                    Context.update contextMsg contextModel

                ( newPageModel, pageCmd, maybeContextMsg ) =
                    Page.update (Page.ContextMsg contextMsg) pageModel

                newModel =
                    ( newContextModel, newPageModel )
            in
            handlePageReply newPageModel maybeContextMsg newModel
                |> R2.addCmd (combineCmds contextCmd pageCmd)

        -- |> R3.incorp handlePageReply model
        -- |> R3.mapCmd (combineCmds contextCmd)
        PageMsg pageMsg ->
            Page.update pageMsg pageModel
                |> R3.mapCmd PageMsg
                |> R3.incorp handlePageReply model


handlePageReply : Page.Model -> Maybe Context.Msg -> Model -> ( Model, Cmd Msg )
handlePageReply pageModel maybeReply model =
    let
        newModel =
            model
                |> Tuple.mapSecond (always pageModel)
    in
    case maybeReply of
        Nothing ->
            newModel
                |> R2.withNoCmd

        Just contextMsg ->
            newModel
                |> R2.withCmd (message contextMsg)
                |> R2.mapCmd ContextMsg


combineCmds : Cmd Context.Msg -> Cmd Page.Msg -> Cmd Msg
combineCmds contextCmd pageCmd =
    Cmd.batch
        [ Cmd.map ContextMsg contextCmd
        , Cmd.map PageMsg pageCmd
        ]


view : Model -> Browser.Document Msg
view ( context, page ) =
    { title = "Budget Insights"
    , body =
        [ Page.view context page
            |> Html.map PageMsg
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
