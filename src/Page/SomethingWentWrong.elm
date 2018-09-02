module Page.SomethingWentWrong exposing
    ( Model
    , Msg
    , initModel
    , view
    )

import Context
import Html exposing (..)


type alias Model =
    ()


initModel : Model
initModel =
    ()


type Msg
    = NoOp


view : Context.Model -> Model -> Html Msg
view context model =
    div [] [ text "something went wrong." ]
