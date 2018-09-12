module Page exposing (Page(..))

import Page.BudgetSelector as BudgetSelector
import Page.Dashboard as Dashboard


type Page
    = BudgetSelector BudgetSelector.Model
    | Dashboard Dashboard.Model
    | SomethingWentWrong
    | Blank
