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
    = GotBudget (Result Http.Error Budget)
    | ErrorHappened CustomError


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

        _ ->
            model |> R2.withNoCmd



-- | SelectedBudget BudgetSummary
-- | GoBack
-- | ClickedLink UrlRequest
-- | UrlChanged Url
