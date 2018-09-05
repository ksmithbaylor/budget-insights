module View.SomethingWentWrong exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model.SomethingWentWrong exposing (Error(..), Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
