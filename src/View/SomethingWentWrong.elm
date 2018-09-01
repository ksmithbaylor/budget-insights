module View.SomethingWentWrong exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model.SomethingWentWrong exposing (Error(..), Model)
import Update exposing (Msg)


view : Model -> Html Msg
view model =
    div [ class "error" ]
        [ text <|
            case model.error of
                LogicError message ->
                    message

                FetchError error ->
                    case error of
                        Http.Timeout ->
                            "Request timed out"

                        Http.NetworkError ->
                            "Something went wrong with a request"

                        Http.BadUrl str ->
                            "Badly-formed URL: " ++ str

                        Http.BadStatus _ ->
                            "Non-200 status code"

                        Http.BadPayload message _ ->
                            "Error decoding response: " ++ message
        ]
