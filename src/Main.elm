module Main exposing (main)

import Browser
import Update exposing (Model, Msg, init, update)
import View exposing (viewDocument)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = viewDocument
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
