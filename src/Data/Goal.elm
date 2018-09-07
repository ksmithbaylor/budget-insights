module Data.Goal exposing (Goal, decoder)

import Data.Money as Money exposing (Money)
import Date exposing (Date)
import Helpers.Decode exposing (..)
import Id exposing (Id)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline exposing (..)


type Goal
    = TargetBalanceGoal Money ( Date, Maybe Date ) Int
    | MonthlyFundingGoal Money Date Int


decoder : Decoder (Maybe Goal)
decoder =
    succeed fromFields
        |> required "goal_type" (nullable string)
        |> required "goal_target" (nullable Money.decoder)
        |> required "goal_creation_month" (nullable date)
        |> required "goal_target_month" (nullable date)
        |> required "goal_percentage_complete" (nullable int)


fromFields :
    Maybe String
    -> Maybe Money
    -> Maybe Date
    -> Maybe Date
    -> Maybe Int
    -> Maybe Goal
fromFields maybeKind maybeTarget maybeStart maybeEnd maybePercentage =
    case maybeKind of
        Nothing ->
            Nothing

        Just kind ->
            case kind of
                "TB" ->
                    case ( maybeTarget, maybeStart, maybePercentage ) of
                        ( Just target, Just start, Just percentage ) ->
                            Just <| TargetBalanceGoal target ( start, Nothing ) percentage

                        _ ->
                            Nothing

                "TBD" ->
                    case ( maybeTarget, maybeStart, maybePercentage ) of
                        ( Just target, Just start, Just percentage ) ->
                            Just <| TargetBalanceGoal target ( start, maybeEnd ) percentage

                        _ ->
                            Nothing

                "MF" ->
                    case ( maybeTarget, maybeStart, maybePercentage ) of
                        ( Just target, Just start, Just percentage ) ->
                            Just <| MonthlyFundingGoal target start percentage

                        _ ->
                            Nothing

                _ ->
                    Nothing
