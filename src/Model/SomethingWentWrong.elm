module Model.SomethingWentWrong exposing (Error(..), Model)

import Http


type alias Model =
    { error : Error
    }


type Error
    = FetchError Http.Error
    | LogicError String
