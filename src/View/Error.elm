module View.Error exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Update exposing (Msg)


view : Http.Error -> Html Msg
view error =
    div [ class "error" ]
        [ text <|
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
