module Page.Dashboard exposing
    ( Model
    , Msg
    , Reply(..)
    , init
    , isLoading
    , update
    , view
    )

import API
import Data.Context as Context exposing (Context)
import Data.Money as Money
import Data.YNAB.Budget as Budget exposing (Budget)
import Database exposing (..)
import Db exposing (Db)
import Dict.Any as AnyDict
import Element exposing (..)
import Element.Events exposing (..)
import Element.Font as Font
import Flags exposing (Flags)
import Html
import Html.Attributes
import Id exposing (Id)
import Json.Encode as Encode
import Process
import Return2 as R2
import Return3 as R3 exposing (Return)
import Task
import UI.Common exposing (..)


type alias Model =
    { budgetId : Id
    , budget : Maybe Budget
    }


type Msg
    = AddBudgetAsync
    | BackButtonClicked


type Reply
    = RequestedBudget Id
    | GoToBudgetSelector


type alias Props =
    { budgetId : Id
    }


init : Context -> Props -> Return Model Msg Reply
init context props =
    let
        model =
            { budgetId = props.budgetId, budget = Nothing }
    in
    case Context.getBudget context model.budgetId of
        Nothing ->
            model
                |> R2.withNoCmd
                |> R3.withReply (RequestedBudget props.budgetId)

        Just _ ->
            model
                |> R2.withCmd (putBudgetInModelAsync context props.budgetId)
                |> R3.withNoReply


isLoading : Context -> Model -> Bool
isLoading context model =
    (Context.getBudget context model.budgetId == Nothing) || (model.budget == Nothing)


putBudgetInModelAsync : Context -> Id -> Cmd Msg
putBudgetInModelAsync context budgetId =
    case Context.getBudget context budgetId of
        Nothing ->
            Cmd.none

        Just budget ->
            Process.sleep 0.0
                |> Task.andThen (always <| Task.succeed AddBudgetAsync)
                |> Task.perform identity


update : Context -> Msg -> Model -> Return Model Msg Reply
update context msg model =
    case msg of
        AddBudgetAsync ->
            { model | budget = Context.getBudget context model.budgetId }
                |> R3.withNothing

        BackButtonClicked ->
            model |> R2.withNoCmd |> R3.withReply GoToBudgetSelector


view : Context -> Model -> Element Msg
view context model =
    column [ spacing 24, width fill, height fill ]
        [ viewTopBar context model
        , viewMain context model
        ]


viewTopBar : Context -> Model -> Element Msg
viewTopBar context model =
    let
        budgetName =
            Context.getBudgetSummary context model.budgetId
                |> Maybe.map .name
                |> Maybe.withDefault ""
    in
    row [ width fill, spacing 16 ]
        [ viewBackButton
        , el [ Font.size 20, Font.bold ] (text budgetName)
        ]


viewBackButton : Element Msg
viewBackButton =
    shadowBox True [ paddingXY 8 4, onClick BackButtonClicked ] <|
        el [ Font.size 24 ] (text "⬅")


viewMain : Context -> Model -> Element Msg
viewMain context model =
    shadowBox False [ width fill, height fill ] <|
        column [ spacing 16, width fill, height fill ] <|
            case model.budget of
                Nothing ->
                    [ text "Loading..." ]

                Just budget ->
                    [ webComponent "x-hello"
                        [ ( "numbers", Encode.list Encode.int [ 1, 3, 2, 7, 4, 5, 9, 6, 0, 8 ] )
                        ]
                    ]
