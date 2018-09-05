module Data.Context exposing
    ( Context
    , getBudget
    , init
    , insertBudget
    , setBudgetSummaries
    )

import API exposing (Token)
import Browser.Navigation as Navigation
import Data.Budget exposing (Budget, BudgetSummary)
import Db exposing (Db)
import Flags exposing (Flags)
import Id exposing (Id)


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


getBudget : Id -> Context -> Maybe Budget
getBudget id context =
    Db.get context.budgets id


insertBudget : Budget -> Context -> Context
insertBudget budget context =
    { context | budgets = Db.insert budget.id budget context.budgets }
