module Data.Money exposing (Money, create, map, map2, add, subtract, percent, format)

import FormatNumber
import FormatNumber.Locales exposing (usLocale)


type Money
    = Money Int


create : Float -> Money
create value =
    value |> (*) 100 |> round |> Money


map : (Int -> Int) -> Money -> Money
map f (Money value) =
    Money (f value)


map2 : (Int -> Int -> Int) -> Money -> Money -> Money
map2 f (Money a) (Money b) =
    Money (f a b)


add : Money -> Money -> Money
add =
    map2 (+)


subtract : Money -> Money -> Money
subtract a b =
    map2 (-) b a


percent : Float -> Money -> Money
percent p (Money value) =
    (toFloat value) * p / 100 |> round |> Money


format : Money -> String
format (Money value) =
    (toFloat value / 100) |> FormatNumber.format usLocale |> (++) "$"
