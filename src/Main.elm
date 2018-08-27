module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)


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
    { token : Maybe String
    , error : Maybe Http.Error
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( { token = Nothing, error = Nothing }, fetchToken )



-- TOKEN FETCH


fetchToken : Cmd Msg
fetchToken =
    Http.get "http://localhost:4000/token" decodeToken
        |> Http.send GotToken


decodeToken : Decoder String
decodeToken =
    Decode.field "token" Decode.string



-- UPDATE


type Msg
    = GotToken (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotToken (Ok token) ->
            ( { model | token = Just token }, Cmd.none )

        GotToken (Err error) ->
            ( { model | token = Nothing, error = Just error }, Cmd.none )



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
