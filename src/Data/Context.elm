module Data.Context exposing
    ( Context
    , getBudget
    , getBudgetSummary
    , init
    , insertBudget
    , setBudgetSummaries
    , setError
    )

import API exposing (Token)
import Browser.Navigation as Navigation
import Data.Budget exposing (Budget, BudgetSummary)
import Data.CustomError exposing (CustomError)
import Db exposing (Db)
import Flags exposing (Flags)
import Id exposing (Id)


type alias Context =
    { key : Navigation.Key
    , token : Token
    , error : Maybe CustomError
    , budgetSummaries : Db BudgetSummary
    , budgets : Db Budget
    }


init : Flags -> Navigation.Key -> Context
init flags key =
    { key = key
    , token = flags.token
    , error = Nothing
    , budgetSummaries = Db.empty
    , budgets = Db.empty
    }


setBudgetSummaries : Db BudgetSummary -> Context -> Context
setBudgetSummaries budgetSummaries context =
    { context | budgetSummaries = budgetSummaries }


getBudget : Context -> Id -> Maybe Budget
getBudget context =
    Db.get context.budgets


getBudgetSummary : Context -> Id -> Maybe BudgetSummary
getBudgetSummary context =
    Db.get context.budgetSummaries


insertBudget : Budget -> Context -> Context
insertBudget budget context =
    { context | budgets = Db.insert budget.id budget context.budgets }


setError : CustomError -> Context -> Context
setError error context =
    { context | error = Just error }
