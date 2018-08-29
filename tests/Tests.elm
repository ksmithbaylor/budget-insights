module Tests exposing (..)

import Test exposing (..)
import Expect
import Data.Money as Money exposing (Money)


suite : Test
suite =
    describe "BudgetPlanner"
        [ describe "Data.Money"
            [ test "add, subtract, and rounding behavior" <|
                \_ ->
                    Money.create 2
                        |> Money.subtract (Money.create 1.1)
                        |> Expect.equal (Money.create 0.9)
            , test "map" <|
                \_ ->
                    Expect.equal (Money.create 42) (Money.map ((*) 2) (Money.create 21))
            , test "map2" <|
                \_ ->
                    Expect.equal (Money.create 23) (Money.map2 (+) (Money.create 11) (Money.create 12))
            , test "percent" <|
                \_ ->
                    Expect.equal (Money.create 23) (Money.create 100 |> Money.percent 23)
            , test "format with whole dollar" <|
                \_ ->
                    Expect.equal "$12,345.00" (Money.create 12345 |> Money.format)
            , test "format with cents" <|
                \_ ->
                    Expect.equal "$1.47" (Money.create 1.47 |> Money.format)
            ]
        ]
