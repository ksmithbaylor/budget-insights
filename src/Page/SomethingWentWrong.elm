module Page.SomethingWentWrong exposing
    ( Model
    , Msg
    , initCmd
    , initModel
    , update
    , view
    )

import Context
import CustomError exposing (CustomError(..))
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
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
    case context.error of
        Nothing ->
            div []
                [ div [] [ text "Nothing appears to be wrong!" ]
                , a [ href "/" ] [ text "Go home" ]
                ]

        Just error ->
            let
                errorMessage =
                    case error of
                        FetchError httpError ->
                            "network error"

                        LogicError message ->
                            message
            in
            div [] [ text errorMessage ]
