module Page.BudgetSelector exposing
    ( Model
    , Msg
    , initCmd
    , initModel
    , update
    , view
    )

import API exposing (fetchBudgetSummaries)
import Context
import CustomError
import Data.Budget as Budget exposing (BudgetSummary)
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
import Return3 as R3 exposing (Return)
import Router


type alias Model =
    { budgetSummaries : Db BudgetSummary
    }


type Msg
    = GotBudgetSummaries (Result Http.Error (Db BudgetSummary))
    | SelectedBudget Id


initModel : Model
initModel =
    { budgetSummaries = Db.empty }


initCmd : Flags -> Cmd Msg
initCmd flags =
    fetchBudgetSummaries flags.token GotBudgetSummaries


update : Msg -> Model -> Context.Model -> Return Model Msg Context.Msg
update msg model context =
    case msg of
        GotBudgetSummaries (Ok budgetSummaries) ->
            { model | budgetSummaries = budgetSummaries }
                |> R2.withNoCmd
                |> R3.withNoReply

        GotBudgetSummaries (Err error) ->
            model
                |> R2.withNoCmd
                |> R3.withReply (Context.ErrorHappened <| CustomError.FetchError error)

        SelectedBudget id ->
            model
                |> R3.withNothing


view : Context.Model -> Model -> Html Msg
view context model =
    let
        contents =
            div [ class "flow" ]
                (model.budgetSummaries
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
    a [ class "budget shadow-box", href ("/budgets/" ++ Id.toString budget.id) ]
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
