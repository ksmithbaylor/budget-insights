module Page.SomethingWentWrong exposing (possiblyRedirect, view)

import Data.Context exposing (Context)
import Data.CustomError exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Http
import UI.Common exposing (..)


possiblyRedirect : Context -> Cmd msg -> Cmd msg
possiblyRedirect { error } redirectCmd =
    case error of
        Just _ ->
            -- If there is actually an error, do nothing
            Cmd.none

        Nothing ->
            -- If there is no error, redirect using the passed-in Cmd
            redirectCmd


view : Context -> Element.Element msg
view context =
    let
        errorMessage =
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
    in
    column [ spacing 24 ]
        [ header "Oops!"
        , shadowBox False
            [ Border.color (rgb 0.7 0.2 0.2)
            , Border.width 1
            , centerX
            , width fill
            ]
            (paragraph [] [ text errorMessage ])
        ]
