module Page.BudgetSelector exposing
    ( Model
    , Msg
    , Reply(..)
    , init
    , isLoading
    , update
    , view
    )

import Data.Budget as Budget exposing (BudgetSummary)
import Data.Context exposing (Context)
import Db exposing (Db)
import Dict.Any as AnyDict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Flags exposing (Flags)
import Http
import ISO8601
import Id exposing (Id)
import Return2 as R2
import Return3 as R3 exposing (Return, reply)
import UI.Common exposing (..)


type alias Model =
    ()


type Msg
    = BudgetClicked Id


type Reply
    = SelectedBudget Id


type alias Props =
    ()


init : Context -> Props -> Return Model Msg Reply
init context props =
    let
        model =
            props
    in
    model
        |> R3.withNothing


isLoading : Context -> Model -> Bool
isLoading context model =
    (context.budgetSummaries |> Db.toList |> List.length) == 0


update : Context -> Msg -> Model -> Return Model Msg Reply
update context msg model =
    case msg of
        BudgetClicked id ->
            model
                |> R2.withNoCmd
                |> R3.withReply (SelectedBudget id)


view : Context -> Model -> Element Msg
view context model =
    column [ spacing 24 ]
        [ header "Available Budgets"
        , column [ spacing 16 ]
            (context.budgetSummaries
                |> Db.toList
                |> List.map Tuple.second
                |> List.sortBy (.lastModified >> ISO8601.toString)
                |> List.reverse
                |> List.map viewBudget
            )
        ]


viewBudget : BudgetSummary -> Element Msg
viewBudget budget =
    shadowBox True [ onClick (BudgetClicked budget.id) ] <|
        column [ spacing 8 ]
            [ el [ Font.bold, Font.size 20 ] (text budget.name)
            , text
                (ISO8601.toString budget.lastModified
                    |> String.split "T"
                    |> List.head
                    |> Maybe.withDefault ""
                    |> (++) "Last Modified: "
                )
            ]
