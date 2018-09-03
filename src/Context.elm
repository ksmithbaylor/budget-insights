module Context exposing
    ( Model
    , Msg(..)
    , init
    , update
    )

import API exposing (Token)
import CustomError exposing (CustomError(..))
import Data.Account as Account exposing (Accounts)
import Data.Budget as Budget exposing (Budget, BudgetSummaries, Budgets)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Http
import Return2 as R2
import Task


type alias Model =
    { error : Maybe CustomError
    , token : Token
    , budgets : Budgets
    , accounts : Accounts
    }


type Msg
    = ErrorHappened CustomError
    | RequestBudget Budget.ID
    | GotBudget (Result Http.Error Budget)


init : Flags -> ( Model, Cmd Msg )
init flags =
    { error = Nothing
    , token = flags.token
    , budgets = AnyDict.empty Budget.idToString
    , accounts = AnyDict.empty Account.idToString
    }
        |> R2.withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ErrorHappened error ->
            { model | error = Just error }
                |> R2.withNoCmd

        RequestBudget id ->
            model
                |> R2.withCmd (API.fetchBudgetByID model.token id GotBudget)

        GotBudget (Ok budget) ->
            { model | budgets = AnyDict.insert budget.id budget model.budgets }
                |> R2.withNoCmd

        _ ->
            model |> R2.withNoCmd



-- | SelectedBudget BudgetSummary
-- | GoBack
-- | ClickedLink UrlRequest
-- | UrlChanged Url
