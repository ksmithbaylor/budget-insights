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
        , view = viewDocument
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Model
    = Initial
    | HaveToken String
    | HaveBudgets (List Budget)
    | SelectedBudget Budget
    | SomethingWentWrong Http.Error



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( Initial
    , fetchToken GotToken
    )



-- UPDATE


type Msg
    = GotToken (Result Http.Error String)
    | GotBudgets (Result Http.Error (List Budget))
    | SelectBudget Budget


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotToken (Ok token) ->
            ( HaveToken token, fetchBudgets token GotBudgets )

        GotToken (Err error) ->
            ( SomethingWentWrong error, Cmd.none )

        GotBudgets (Ok budgets) ->
            ( HaveBudgets budgets, Cmd.none )

        GotBudgets (Err error) ->
            ( SomethingWentWrong error, Cmd.none )

        SelectBudget budget ->
            ( SelectedBudget budget, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "Hello"
    , body =
        [ styleTag
        , view model
        ]
    }


styleTag : Html msg
styleTag =
    Html.node "link" [ Html.Attributes.rel "stylesheet", Html.Attributes.href "main.css" ] []


view : Model -> Html Msg
view model =
    let
        loading =
            text "Loading..."
    in
        case model of
            Initial ->
                loading

            HaveToken _ ->
                loading

            HaveBudgets budgets ->
                viewBudgets budgets

            SelectedBudget budgets ->
                loading

            SomethingWentWrong error ->
                viewError error


viewBudgets : List Budget -> Html Msg
viewBudgets budgets =
    div [ class "budget-list" ] <|
        List.map viewBudget budgets


viewBudget : Budget -> Html Msg
viewBudget budget =
    div [ class "budget" ] [ text budget.name ]


viewError : Http.Error -> Html msg
viewError err =
    div [ class "error" ]
        [ text <|
            case err of
                Http.Timeout ->
                    "Request timed out"

                Http.NetworkError ->
                    "Something went wrong with a request"

                Http.BadUrl str ->
                    "Badly-formed URL: " ++ str

                Http.BadStatus _ ->
                    "Non-200 status code"

                Http.BadPayload mess _ ->
                    "Error decoding response: " ++ mess
        ]
