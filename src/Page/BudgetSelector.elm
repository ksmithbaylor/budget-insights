module Page.BudgetSelector exposing (Model, Msg, Reply(..), init, update, view)

import CustomError
import Data.Budget as Budget exposing (BudgetSummary)
import Data.Context exposing (Context)
import Db exposing (Db)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import ISO8601
import Id exposing (Id)
import Return2 as R2
import Return3 as R3 exposing (Return, reply)


type alias Model =
    ()


type Msg
    = BudgetClicked Id


type Reply
    = SelectedBudget Id
    | RequestedBudgetSummaries


type alias Props =
    ()


init : Props -> Context -> Return Model Msg Reply
init props context =
    ()
        |> R2.withNoCmd
        |> R3.withReply RequestedBudgetSummaries


update : Context -> Msg -> Model -> Return Model Msg Reply
update context msg model =
    case msg of
        BudgetClicked id ->
            model
                |> R2.withNoCmd
                |> R3.withReply (SelectedBudget id)


view : Context -> Model -> Html Msg
view context model =
    let
        contents =
            div [ class "flow" ]
                (context.budgetSummaries
                    |> Db.toList
                    |> List.map Tuple.second
                    |> List.sortBy (.lastModified >> ISO8601.toString)
                    |> List.reverse
                    |> List.map viewBudget
                )
    in
    div [ class "budget-list" ]
        [ h1 [] [ text "Available Budgets" ]
        , contents
        ]


viewBudget : BudgetSummary -> Html Msg
viewBudget budget =
    -- a [ class "budget shadow-box", href ("/budgets/" ++ Id.toString budget.id) ]
    div [ class "budget shadow-box", onClick (BudgetClicked budget.id) ]
        [ div [ class "budget-name" ] [ text budget.name ]
        , div []
            [ span [] [ text "Last Modified: " ]
            , span [ class "light" ]
                [ text <|
                    (ISO8601.toString budget.lastModified
                        |> String.split "T"
                        |> List.head
                        |> Maybe.withDefault ""
                    )
                ]
            ]
        ]
