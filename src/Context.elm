module Context exposing
    ( Model
    , Msg(..)
    , init
    , update
    )

import API exposing (Token)
import CustomError exposing (CustomError(..))
import Data.Account as Account exposing (Account)
import Data.Budget as Budget exposing (Budget)
import Db exposing (Db)
import Dict.Any as AnyDict
import Flags exposing (Flags)
import Http
import Id exposing (Id)
import Return2 as R2
import Task


type alias Model =
    { error : Maybe CustomError
    , token : Token
    , budgets : Db Budget
    , accounts : Db Account
    }


type Msg
    = ErrorHappened CustomError
    | RequestBudget Id
    | GotBudget (Result Http.Error Budget)


init : Flags -> ( Model, Cmd Msg )
init flags =
    { error = Nothing
    , token = flags.token
    , budgets = Db.empty
    , accounts = Db.empty
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
                |> R2.withCmd (API.fetchBudgetById model.token id GotBudget)

        GotBudget (Ok budget) ->
            { model | budgets = Db.insert budget.id budget model.budgets }
                |> R2.withNoCmd

        _ ->
            model |> R2.withNoCmd



-- | SelectedBudget BudgetSummary
-- | GoBack
-- | ClickedLink UrlRequest
-- | UrlChanged Url
