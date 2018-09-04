module Data.Context exposing
    ( Context
    , init
    , setBudgetSummaries
    )

import API exposing (Token)
import Browser.Navigation as Navigation
import Data.Budget exposing (Budget, BudgetSummary)
import Db exposing (Db)
import Flags exposing (Flags)


type alias Context =
    { key : Navigation.Key
    , token : Token
    , budgetSummaries : Db BudgetSummary
    , budgets : Db Budget
    }


init : Flags -> Navigation.Key -> Context
init flags key =
    { key = key
    , token = flags.token
    , budgetSummaries = Db.empty
    , budgets = Db.empty
    }


setBudgetSummaries : Db BudgetSummary -> Context -> Context
setBudgetSummaries budgetSummaries context =
    { context | budgetSummaries = budgetSummaries }
