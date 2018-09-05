module Page.SomethingWentWrong exposing (view)

import Data.Context exposing (Context)
import Data.CustomError exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http


view : Context -> Html msg
view context =
    div [ class "error" ]
        [ text <|
            case context.error of
                Nothing ->
                    "Nothing seems to be wrong. Reload?"

                Just (LogicalError message) ->
                    message

                Just (RoutingError url) ->
                    "Route not found: " ++ url

                Just (FetchingError httpError) ->
                    case httpError of
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
