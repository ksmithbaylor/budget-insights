module Router exposing (Route(..), fromUrl)

import Data.Budget as Budget
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser, s, top)


type Route
    = BudgetSelector
    | Dashboard Budget.ID
    | Oops


fromUrl : Url -> Result String Route
fromUrl url =
    Url.parse routeParser url
        |> Result.fromMaybe url.path


routeParser : Parser (Route -> a) a
routeParser =
    Url.oneOf
        [ Url.map BudgetSelector top
        , Url.map Dashboard (s "budgets" </> budgetID)
        , Url.map Oops (s "oops")
        ]


budgetID : Parser (Budget.ID -> a) a
budgetID =
    Url.custom "BUDGET_ID" (Just << Budget.idFromString)
