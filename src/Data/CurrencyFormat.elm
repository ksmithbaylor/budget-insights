module Data.CurrencyFormat exposing (CurrencyFormat, decoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type alias CurrencyFormat =
    { isoCode : String
    , exampleFormat : String
    , decimalDigits : Int
    , decimalSeparator : String
    , symbolFirst : Bool
    , groupSeparator : String
    , currencySymbol : String
    , displaySymbol : Bool
    }


decoder : Decoder CurrencyFormat
decoder =
    succeed CurrencyFormat
        |> required "iso_code" string
        |> required "example_format" string
        |> required "decimal_digits" int
        |> required "decimal_separator" string
        |> required "symbol_first" bool
        |> required "group_separator" string
        |> required "currency_symbol" string
        |> required "display_symbol" bool
