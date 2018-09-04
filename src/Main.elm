module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Flags exposing (Flags)
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Update
import Url exposing (Url)
import View


main =
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        , onUrlRequest = Msg.UrlRequested
        , onUrlChange = onUrlChange
        }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    Model.init flags key
        |> Update.update (onUrlChange url)


onUrlChange : Url -> Msg
onUrlChange =
    Router.fromUrl >> Msg.RouteChanged


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
