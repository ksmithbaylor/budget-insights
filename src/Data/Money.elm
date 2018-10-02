module Data.Money exposing
    ( Money
    , add
    , create
    , decoder
    , encoder
    , format
    , fromYNAB
    , map
    , map2
    , percent
    , subtract
    )

import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Json.Decode exposing (Decoder, andThen, int, succeed)
import Json.Encode as Encode


type Money
    = Money Int


decoder : Decoder Money
decoder =
    int |> andThen (fromYNAB >> succeed)


encoder : Money -> Encode.Value
encoder (Money value) =
    Encode.float <| toFloat value / 100


fromYNAB : Int -> Money
fromYNAB value =
    Money (value // 10)


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
    toFloat value * p / 100 |> round |> Money


format : Money -> String
format (Money value) =
    if value < 0 then
        "($"
            ++ ((toFloat (-1 * value) / 100) |> FormatNumber.format usLocale)
            ++ ")"

    else
        (toFloat value / 100) |> FormatNumber.format usLocale |> (++) "$"
