module Data.CustomError exposing (CustomError(..))

import Http


type CustomError
    = FetchingError Http.Error
    | LogicalError String
    | RoutingError String
