module Data.Painting
    exposing
        ( Painting
        , Status(..)
        , Settings
        , Iteration
        , initialPainting
        , setIterations
        , setContentWeight
        , setStyleWeight
        , setVariationWeight
        , setOutputWidth
        , setContentPath
        , setStylePath
        , readyToStart
        )


type alias Painting =
    { name : String
    , status : Status
    , contentPath : Maybe String
    , stylePath : Maybe String
    , settings : Settings
    , iterations : List Iteration
    }


type Status
    = New
    | InProgress
    | Done


type alias Settings =
    { iterations : Int
    , contentWeight : Float
    , styleWeight : Float
    , variationWeight : Float
    , outputWidth : Int
    }


type alias Iteration =
    { path : String
    , loss : Float
    }


initialPainting : String -> Painting
initialPainting name =
    { name = name
    , status = New
    , contentPath = Nothing
    , stylePath = Nothing
    , settings = initialSettings
    , iterations = []
    }


initialSettings : Settings
initialSettings =
    { iterations = 10
    , contentWeight = 0.1
    , styleWeight = 100.0
    , variationWeight = 1.0
    , outputWidth = 400
    }


setContentWeight : Float -> Painting -> Painting
setContentWeight weight ({ settings } as painting) =
    let
        newSettings =
            { settings | contentWeight = weight }
    in
        { painting | settings = newSettings }


setStyleWeight : Float -> Painting -> Painting
setStyleWeight weight ({ settings } as painting) =
    let
        newSettings =
            { settings | styleWeight = weight }
    in
        { painting | settings = newSettings }


setVariationWeight : Float -> Painting -> Painting
setVariationWeight weight ({ settings } as painting) =
    let
        newSettings =
            { settings | variationWeight = weight }
    in
        { painting | settings = newSettings }


setOutputWidth : Int -> Painting -> Painting
setOutputWidth width ({ settings } as painting) =
    let
        newSettings =
            { settings | outputWidth = width }
    in
        { painting | settings = newSettings }


setIterations : Int -> Painting -> Painting
setIterations num ({ settings } as painting) =
    let
        newSettings =
            { settings | iterations = num }
    in
        { painting | settings = newSettings }


setContentPath : String -> Painting -> Painting
setContentPath path painting =
    if String.isEmpty path then
        { painting | contentPath = Nothing }
    else
        { painting | contentPath = Just path }


setStylePath : String -> Painting -> Painting
setStylePath path painting =
    if String.isEmpty path then
        { painting | stylePath = Nothing }
    else
        { painting | stylePath = Just path }


readyToStart : Painting -> Bool
readyToStart painting =
    painting.contentPath /= Nothing && painting.stylePath /= Nothing
