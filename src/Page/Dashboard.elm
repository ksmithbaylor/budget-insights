module Page.Dashboard exposing (Model, Msg, Reply(..), init, update, view)

import API
import Data.Budget as Budget exposing (Budget)
import Data.Context as Context exposing (Context)
import Db exposing (Db)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Id exposing (Id)
import Return2 as R2
import Return3 as R3 exposing (Return)


type alias Model =
    { budgetId : Id
    }


type Msg
    = BackButtonClicked


type Reply
    = RequestedBudget Id
    | GoToBudgetSelector


type alias Props =
    { budgetId : Id
    }


init : Context -> Props -> Return Model Msg Reply
init context props =
    props
        |> R2.withNoCmd
        |> R3.withReply (RequestedBudget props.budgetId)


update : Context -> Msg -> Model -> Return Model Msg Reply
update context msg model =
    case msg of
        BackButtonClicked ->
            model |> R2.withNoCmd |> R3.withReply GoToBudgetSelector


view : Context -> Model -> Html Msg
view context model =
    div [ class "dashboard" ]
        [ viewTopBar context model
        , viewMain context model
        ]


viewTopBar : Context -> Model -> Html Msg
viewTopBar context model =
    let
        budgetName =
            Context.getBudgetSummary context model.budgetId
                |> Maybe.map .name
                |> Maybe.withDefault ""
    in
    div [ class "top-bar" ]
        [ button [ class "back shadow-box", onClick BackButtonClicked ] [ text "⬅" ]
        , span [ class "budget-name" ] [ text budgetName ]
        ]


viewMain : Context -> Model -> Html Msg
viewMain context model =
    let
        maybeBudget =
            Context.getBudget context model.budgetId
    in
    div [ class "main shadow-box no-hover" ] <|
        case maybeBudget of
            Nothing ->
                [ text "Loading..." ]

            Just budget ->
                [ text "Budget loaded!" ]
