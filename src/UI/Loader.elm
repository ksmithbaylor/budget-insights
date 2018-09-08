module UI.Loader exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (class)


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
