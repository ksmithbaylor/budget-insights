module UI.Loader exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Bool -> Html msg
view loading =
    div
        [ class
            (if loading then
                "loader"

             else
                "loader hidden"
            )
        ]
        [ div [] [] ]
