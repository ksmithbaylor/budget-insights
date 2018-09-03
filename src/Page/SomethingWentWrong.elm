module Page.SomethingWentWrong exposing
    ( Model
    , Msg
    , initCmd
    , initModel
    , update
    , view
    )

import Context
import Flags exposing (Flags)
import Html exposing (..)
import Return3 as R3 exposing (Return)


type alias Model =
    ()


initModel : Model
initModel =
    ()


initCmd : Flags -> Cmd Msg
initCmd flags =
    Cmd.none


type Msg
    = NoOp


update : Msg -> Model -> Return Model Msg Context.Msg
update msg model =
    case msg of
        NoOp ->
            model |> R3.withNothing


view : Context.Model -> Model -> Html Msg
view context model =
    div [] [ text "something went wrong." ]
