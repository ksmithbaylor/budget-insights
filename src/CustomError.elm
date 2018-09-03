module CustomError exposing (CustomError(..))

import Http


type CustomError
    = FetchError Http.Error
    | LogicError String
