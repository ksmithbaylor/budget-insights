module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Flags exposing (Flags)
import Model exposing (Model)
import Msg exposing (Msg)
import Return2 as R2
import Router
import Update
import Url exposing (Url)
import View


main : Program Flags Model Msg
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
    let
        model =
            Model.init flags key

        ( updatedModel, routeCmd ) =
            Update.update (onUrlChange url) model
    in
    updatedModel
        |> R2.withCmd (Update.initCmd model)
        |> R2.addCmd routeCmd


onUrlChange : Url -> Msg
onUrlChange =
    Router.fromUrl >> Msg.RouteChanged


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
