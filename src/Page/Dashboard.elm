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
import Data.Budget as Budget exposing (Budget, Budgets)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Html exposing (..)
import Return2 as R2
import Return3 as R3 exposing (Return)


type alias Model =
    { budgetID : Maybe Budget.ID
    , loading : Bool
    }


initModel : Model
initModel =
    { budgetID = Nothing
    , loading = False
    }


initCmd : Flags -> Cmd Msg
initCmd flags =
    Cmd.none


type Msg
    = Init Budget.ID


update : Msg -> Model -> Context.Model -> Return Model Msg Context.Msg
update msg model context =
    let
        loading =
            case getBudget model.budgetID context.budgets of
                Nothing ->
                    True

                Just _ ->
                    False
    in
    case msg of
        Init budgetID ->
            if loading then
                { model | budgetID = Just budgetID, loading = False }
                    |> R3.withNothing

            else
                { model | budgetID = Just budgetID, loading = True }
                    |> R2.withNoCmd
                    |> R3.withReply (Context.RequestBudget budgetID)


getBudget : Maybe Budget.ID -> Budgets -> Maybe Budget
getBudget maybeID budgets =
    maybeID
        |> Maybe.andThen (\id -> AnyDict.get id budgets)


view : Context.Model -> Model -> Html Msg
view context model =
    let
        maybeBudget =
            getBudget model.budgetID context.budgets
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
