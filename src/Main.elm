module Main exposing (main)

import Browser
import Flags exposing (Flags)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Update exposing (init, update)
import View exposing (view)


main : Program Flags Model Msg
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
