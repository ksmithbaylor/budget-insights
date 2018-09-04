module Model exposing (Model, init, mapContext, setContext, setPage)

import Browser.Navigation as Navigation
import Data.Context as Context exposing (Context)
import Flags exposing (Flags)
import Page2 exposing (Page)


type alias Model =
    ( Context, Page )


init : Flags -> Navigation.Key -> Model
init flags key =
    ( Context.init flags key, Page2.Blank )



-- Helpers


mapContext : (Context -> Context) -> Model -> Model
mapContext f =
    Tuple.mapFirst f


setContext : Model -> Context -> Model
setContext ( _, page ) newContext =
    ( newContext, page )


setPage : Model -> Page -> Model
setPage ( context, _ ) page =
    ( context, page )
