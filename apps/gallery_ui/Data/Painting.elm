module Data.Painting exposing (Painting, Status(..), Settings, Iteration, initialPainting)


type alias Painting =
    { name : String
    , status : Status
    , contentPath : String
    , stylePath : String
    , settings : Settings
    , iterations : List Iteration
    }


type Status
    = New
    | InProgress
    | Done


type alias Settings =
    { iterations : Int }


type alias Iteration =
    { path : String
    , loss : Float
    }


initialPainting : String -> Painting
initialPainting name =
    { name = name
    , status = New
    , contentPath = "http://is2.mzstatic.com/image/thumb/Purple111/v4/c1/f1/a3/c1f1a320-189a-46a3-e4a0-47d895630d2d/source/175x175bb.jpg"
    , stylePath = "http://is2.mzstatic.com/image/thumb/Purple111/v4/c1/f1/a3/c1f1a320-189a-46a3-e4a0-47d895630d2d/source/175x175bb.jpg"
    , settings = { iterations = 5 }
    , iterations = [ { path = "http://is2.mzstatic.com/image/thumb/Purple111/v4/c1/f1/a3/c1f1a320-189a-46a3-e4a0-47d895630d2d/source/175x175bb.jpg", loss = 0.1 } ]
    }
