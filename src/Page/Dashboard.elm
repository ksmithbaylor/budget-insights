module Page.Dashboard exposing (Model, Msg, Reply, init, update, view)

import API
import Data.Budget as Budget exposing (Budget)
import Data.Context exposing (Context)
import Db exposing (Db)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Html exposing (..)
import Id exposing (Id)
import Return2 as R2
import Return3 as R3 exposing (Return)


type alias Model =
    { budgetId : Id
    }


type Msg
    = NoOp


type alias Reply =
    ()


type alias Props =
    { budgetId : Id
    }


init : Props -> Model
init props =
    { budgetId = props.budgetId
    }


update : Context -> Msg -> Model -> Return Model Msg Reply
update context msg model =
    case msg of
        NoOp ->
            model |> R3.withNothing


view : Context -> Model -> Html Msg
view context model =
    div []
        [ text <| "Budget with id " ++ Id.toString model.budgetId
        ]
