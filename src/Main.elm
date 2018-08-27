module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode


-- MAIN


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { message : String }



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( { message = "hello world" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ styleTag
        , handleError model
        ]
    }


styleTag : Html msg
styleTag =
    Html.node "link" [ Html.Attributes.rel "stylesheet", Html.Attributes.href "main.css" ] []


handleError : Model -> Html Msg
handleError model =
    case model.error of
        Nothing ->
            viewApp model

        Just err ->
            let
                message =
                    case err of
                        Http.Timeout ->
                            "Request timed out"

                        Http.NetworkError ->
                            "Generic network error"

                        Http.BadUrl str ->
                            "Badly-formed URL: " ++ str

                        Http.BadStatus _ ->
                            "Non-200 status code"

                        Http.BadPayload mess _ ->
                            "Error decoding response: " ++ mess
            in
                div [ class "error" ] [ text message ]


viewApp : Model -> Html Msg
viewApp model =
    div [] [ text <| Maybe.withDefault "NO TOKEN" model.token ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
