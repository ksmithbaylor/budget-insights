module Page.SomethingWentWrong exposing
    ( Model
    , Msg
    , initCmd
    , initModel
    , view
    )

import Context
import Flags exposing (Flags)
import Html exposing (..)


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


view : Context.Model -> Model -> Html Msg
view context model =
    div [] [ text "something went wrong." ]
