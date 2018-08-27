module API exposing (fetchToken)

import Http
import Json.Decode as Decode exposing (Decoder)


-- TOKEN FETCH


fetchToken : (Result Http.Error String -> msg) -> Cmd msg
fetchToken msg =
    Http.get "http://localhost:4000/token" decodeToken
        |> Http.send msg


decodeToken : Decoder String
decodeToken =
    Decode.field "token" Decode.string
