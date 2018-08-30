module Main exposing (main)

import Browser
import Model exposing (Model)
import View exposing (view)
import Update exposing (Msg, init, update)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
