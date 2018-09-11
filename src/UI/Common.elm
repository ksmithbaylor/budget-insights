module UI.Common exposing (header, htmlStyle, shadowBox, webComponent)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Html exposing (Html, node)
import Html.Attributes exposing (property)
import Json.Encode


webComponent : String -> List ( String, Json.Encode.Value ) -> List (Html msg) -> Element msg
webComponent name props children =
    html <|
        node name
            (props |> List.map (\( k, v ) -> property k v))
            children


htmlStyle : String -> String -> Attribute msg
htmlStyle property value =
    Html.Attributes.style property value |> htmlAttribute


header : String -> Element msg
header contents =
    el [ Font.size 32, Font.bold ]
        (text contents)


shadowBox : Bool -> List (Attribute msg) -> Element msg -> Element msg
shadowBox hoverable attrs child =
    let
        ownAttrs =
            [ paddingXY 16 12
            , Background.color (rgb 1.0 1.0 1.0)
            , Border.color (rgb 0.8 0.8 0.8)
            , Border.width 1
            , Border.shadow
                { offset = ( 1.0, 2.0 )
                , size = 1.0
                , blur = 4.0
                , color = rgba 0.0 0.0 0.0 0.1
                }
            , htmlStyle "transition" "box-shadow 200ms ease"
            , htmlStyle "user-select" "none"
            , htmlStyle "cursor" "default"
            ]

        hoverableAttrs =
            if hoverable then
                [ mouseOver
                    [ Border.shadow
                        { offset = ( 3.0, 6.0 )
                        , size = 2.0
                        , blur = 4.0
                        , color = rgba 0.0 0.0 0.0 0.12
                        }
                    ]
                ]

            else
                []
    in
    el
        (List.concat [ ownAttrs, hoverableAttrs, attrs ])
        child
