module Data.Painting
    exposing
        ( Painting
        , Status(..)
        , Settings
        , InitialType(..)
        , Iteration
        , initialPainting
        , setIterations
        , setContentWeight
        , setStyleWeight
        , setVariationWeight
        , setOutputWidth
        , setContentPath
        , setStylePath
        , setInitialType
        , readyToStart
        , decoder
        , encode
        )

import Json.Decode exposing (Decoder)
import Json.Encode


type alias Painting =
    { name : String
    , status : Status
    , contentPath : Maybe String
    , stylePath : Maybe String
    , settings : Settings
    , iterations : List Iteration
    }


type Status
    = NotReady
    | Ready
    | InProgress
    | Complete


type alias Settings =
    { iterations : Int
    , contentWeight : Float
    , styleWeight : Float
    , variationWeight : Float
    , outputWidth : Int
    , initialType : InitialType
    }


type alias Iteration =
    { path : String
    , loss : Float
    }


initialPainting : String -> Painting
initialPainting name =
    { name = name
    , status = NotReady
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
    , outputWidth = 50
    , initialType = Content
    }


type InitialType
    = Content
    | Style
    | Random


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


setInitialType : InitialType -> Painting -> Painting
setInitialType initialType ({ settings } as painting) =
    let
        newSettings =
            { settings | initialType = initialType }
    in
        { painting | settings = newSettings }


readyToStart : Painting -> Bool
readyToStart painting =
    painting.contentPath /= Nothing && painting.stylePath /= Nothing


decoder : Decoder Painting
decoder =
    Json.Decode.map6 Painting
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "status" statusDecoder)
        (Json.Decode.field "content" maybeStringDecoder)
        (Json.Decode.field "style" maybeStringDecoder)
        (Json.Decode.field "settings" settingsDecoder)
        (Json.Decode.field "iterations" <| Json.Decode.list iterationDecoder)


maybeStringDecoder : Decoder (Maybe String)
maybeStringDecoder =
    let
        filterEmpty maybeStr =
            case maybeStr of
                Nothing ->
                    Nothing

                Just str ->
                    if String.isEmpty str then
                        Nothing
                    else
                        Just str
    in
        Json.Decode.map filterEmpty <| Json.Decode.nullable Json.Decode.string


statusDecoder : Decoder Status
statusDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case str of
                    "not_ready" ->
                        Json.Decode.succeed NotReady

                    "ready" ->
                        Json.Decode.succeed Ready

                    "in_progress" ->
                        Json.Decode.succeed InProgress

                    "complete" ->
                        Json.Decode.succeed Complete

                    status ->
                        Json.Decode.fail ("Unexpected status: " ++ status)
            )


settingsDecoder : Decoder Settings
settingsDecoder =
    Json.Decode.map6 Settings
        (Json.Decode.field "iterations" Json.Decode.int)
        (Json.Decode.field "content_weight" Json.Decode.float)
        (Json.Decode.field "style_weight" Json.Decode.float)
        (Json.Decode.field "variation_weight" Json.Decode.float)
        (Json.Decode.field "output_width" Json.Decode.int)
        (Json.Decode.field "initial_type" initialTypeDecoder)


initialTypeDecoder : Decoder InitialType
initialTypeDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case str of
                    "content" ->
                        Json.Decode.succeed Content

                    "style" ->
                        Json.Decode.succeed Style

                    "random" ->
                        Json.Decode.succeed Random

                    status ->
                        Json.Decode.fail ("Unexpected initial type: " ++ status)
            )


iterationDecoder : Decoder Iteration
iterationDecoder =
    Json.Decode.map2 Iteration
        (Json.Decode.field "file_name" Json.Decode.string)
        (Json.Decode.field "loss" Json.Decode.float)


encode : Painting -> Json.Encode.Value
encode painting =
    Json.Encode.object
        [ ( "name", Json.Encode.string painting.name )
        , ( "status", encodeStatus painting.status )
        , ( "content", Maybe.map Json.Encode.string painting.contentPath |> Maybe.withDefault Json.Encode.null )
        , ( "style", Maybe.map Json.Encode.string painting.stylePath |> Maybe.withDefault Json.Encode.null )
        , ( "settings", encodeSettings painting.settings )
        , ( "iterations", Json.Encode.list <| List.map encodeIteration painting.iterations )
        ]


encodeStatus : Status -> Json.Encode.Value
encodeStatus status =
    case status of
        NotReady ->
            Json.Encode.string "new"

        Ready ->
            Json.Encode.string "ready"

        InProgress ->
            Json.Encode.string "in_progress"

        Complete ->
            Json.Encode.string "complete"


encodeSettings : Settings -> Json.Encode.Value
encodeSettings settings =
    Json.Encode.object
        [ ( "iterations", Json.Encode.int settings.iterations )
        , ( "content_weight", Json.Encode.float settings.contentWeight )
        , ( "style_weight", Json.Encode.float settings.styleWeight )
        , ( "variation_weight", Json.Encode.float settings.variationWeight )
        , ( "output_width", Json.Encode.int settings.outputWidth )
        , ( "initial_type", encodeInitialType settings.initialType )
        ]


encodeInitialType : InitialType -> Json.Encode.Value
encodeInitialType initial_type =
    case initial_type of
        Content ->
            Json.Encode.string "content"

        Style ->
            Json.Encode.string "style"

        Random ->
            Json.Encode.string "random"


encodeIteration : Iteration -> Json.Encode.Value
encodeIteration iteration =
    Json.Encode.object
        [ ( "file_name", Json.Encode.string iteration.path )
        , ( "loss", Json.Encode.float iteration.loss )
        ]
