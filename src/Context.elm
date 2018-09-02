module Context exposing (Model, Msg(..), init, update)

import API exposing (Token)
import Data.Account as Account exposing (Accounts)
import Data.Budget as Budget exposing (Budget, BudgetSummaries, Budgets)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Http
import Return2 as R2
import Task


type alias Model =
    { token : Token
    , budgets : Budgets
    , accounts : Accounts
    }


type Msg
    = GotBudget (Result Http.Error Budget)
    | FetchError Http.Error


init : Flags -> ( Model, Cmd Msg )
init flags =
    { token = flags.token
    , budgets = AnyDict.empty Budget.idToString
    , accounts = AnyDict.empty Account.idToString
    }
        |> R2.withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "context msg" msg
    in
    model |> R2.withNoCmd



-- | SelectedBudget BudgetSummary
-- | GoBack
-- | ClickedLink UrlRequest
-- | UrlChanged Url
