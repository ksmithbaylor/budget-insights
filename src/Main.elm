module Main exposing (main)

import Browser
import Model exposing (Model)
import View exposing (view)
import Update exposing (Msg(..), init, update)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = UrlChanged
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
