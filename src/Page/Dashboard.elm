module Page.Dashboard exposing
    ( Model
    , Msg(..)
    , initCmd
    , initModel
    , update
    , view
    )

import API
import Context
import Data.Budget as Budget exposing (Budget)
import Db exposing (Db)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Html exposing (..)
import Id exposing (Id)
import Return2 as R2
import Return3 as R3 exposing (Return)


type alias Model =
    { budgetId : Maybe Id
    , loading : Bool
    }


initModel : Model
initModel =
    { budgetId = Nothing
    , loading = False
    }


initCmd : Flags -> Cmd Msg
initCmd flags =
    Cmd.none


type Msg
    = Init Id


update : Msg -> Model -> Context.Model -> Return Model Msg Context.Msg
update msg model context =
    let
        loading =
            case getBudget model.budgetId context.budgets of
                Nothing ->
                    True

                Just _ ->
                    False
    in
    case msg of
        Init budgetId ->
            if loading then
                { model | budgetId = Just budgetId, loading = False }
                    |> R3.withNothing

            else
                { model | budgetId = Just budgetId, loading = True }
                    |> R2.withNoCmd
                    |> R3.withReply (Context.RequestBudget budgetId)


getBudget : Maybe Id -> Db Budget -> Maybe Budget
getBudget id budgets =
    id |> Maybe.andThen (Db.get budgets)


view : Context.Model -> Model -> Html Msg
view context model =
    let
        maybeBudget =
            getBudget model.budgetId context.budgets
    in
    case ( model.loading, maybeBudget ) of
        ( True, Nothing ) ->
            div [] [ text "Loading budget..." ]

        ( True, Just budget ) ->
            div [] [ text "Refreshing budget..." ]

        ( False, Nothing ) ->
            div [] [ text "Nothing to see here." ]

        ( False, Just budget ) ->
            div [] [ text "I have a budget!" ]
