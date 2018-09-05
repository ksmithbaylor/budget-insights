module Router exposing (Route(..), fromUrl, goTo)

import Browser.Navigation as Navigation
import Data.Budget as Budget
import Data.Context exposing (Context)
import Id exposing (Id)
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser, s, top)


type Route
    = BudgetSelector
    | Dashboard Id
    | Oops


parser : Parser (Route -> a) a
parser =
    Url.oneOf
        [ Url.map BudgetSelector top
        , Url.map Dashboard (s "budgets" </> id "BUDGET")
        , Url.map Oops (s "oops")
        ]


id : String -> Parser (Id -> a) a
id marker =
    Url.custom (marker ++ "_ID") (Just << Id.fromString)


fromUrl : Url -> Result String Route
fromUrl url =
    Url.parse parser url
        |> Result.fromMaybe url.path


toUrlString : Route -> String
toUrlString route =
    "/" ++ String.join "/" (toPieces route)


toPieces : Route -> List String
toPieces route =
    case route of
        BudgetSelector ->
            []

        Dashboard budgetId ->
            [ "budgets", Id.toString budgetId ]

        Oops ->
            [ "oops" ]


goTo : Context -> Route -> Cmd msg
goTo { key } route =
    Navigation.pushUrl key (toUrlString route)
