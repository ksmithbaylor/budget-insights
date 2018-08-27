module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import API exposing (Budget, fetchToken, fetchBudgets)
import Debug


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
    , budgets : Maybe (List Budget)
    , error : Maybe Http.Error
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( { token = Nothing
      , budgets = Nothing
      , error = Nothing
      }
    , fetchToken GotToken
    )



-- UPDATE


type Msg
    = GotToken (Result Http.Error String)
    | GotBudgets (Result Http.Error (List Budget))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotToken (Ok token) ->
            ( { model | token = Just token }, fetchBudgets token GotBudgets )

        GotToken (Err error) ->
            ( { model | token = Nothing, error = Just error }, Cmd.none )

        GotBudgets (Ok budgets) ->
            ( { model | budgets = Just budgets }, Cmd.none )

        GotBudgets (Err error) ->
            ( { model | budgets = Nothing, error = Just error }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ styleTag
        , viewWithErrorHandling model
        ]
    }


styleTag : Html msg
styleTag =
    Html.node "link" [ Html.Attributes.rel "stylesheet", Html.Attributes.href "main.css" ] []


viewWithErrorHandling : Model -> Html Msg
viewWithErrorHandling model =
    case model.error of
        Nothing ->
            viewApp model

        Just err ->
            viewError err


viewError : Http.Error -> Html msg
viewError err =
    div [ class "error" ]
        [ text <|
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
        ]


viewApp : Model -> Html Msg
viewApp model =
    div [] [ text <| Debug.toString model.budgets ]
