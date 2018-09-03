module Router exposing (Route(..), fromUrl)

import Data.Budget as Budget
import Id exposing (Id)
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser, s, top)


type Route
    = BudgetSelector
    | Dashboard Id
    | Oops


fromUrl : Url -> Result String Route
fromUrl url =
    Url.parse parser url
        |> Result.fromMaybe url.path


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
