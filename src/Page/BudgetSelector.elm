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
import Data.Budget exposing (BudgetSummaries)
import Flags exposing (Flags)
import Html exposing (..)
import Http
import Return2 as R2
import Return3 as R3 exposing (Return)


type alias Model =
    { budgetSummaries : Maybe BudgetSummaries
    }


type Msg
    = GotBudgetSummaries (Result Http.Error BudgetSummaries)


initModel : Model
initModel =
    { budgetSummaries = Nothing }


initCmd : Flags -> Cmd Msg
initCmd flags =
    fetchBudgetSummaries flags.token GotBudgetSummaries


update : Msg -> Model -> Return Model Msg Context.Msg
update msg model =
    case msg of
        GotBudgetSummaries (Ok budgetSummaries) ->
            { model | budgetSummaries = Just budgetSummaries }
                |> R2.withNoCmd
                |> R3.withNoReply

        GotBudgetSummaries (Err error) ->
            model
                |> R2.withNoCmd
                |> R3.withReply (Context.FetchError error)


view : Context.Model -> Model -> Html Msg
view context model =
    div [] [ text "budget selector" ]
