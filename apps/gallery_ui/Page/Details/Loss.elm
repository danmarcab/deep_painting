module Page.Details.Loss exposing (Model, initialModel, Msg, update, view)

import Color exposing (Color)
import Color.Convert exposing (colorToCssRgb)
import Date
import Numeral
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Visualization.Axis as Axis exposing (defaultOptions)
import Visualization.List as List
import Visualization.Scale as Scale exposing (ContinuousScale, OrdinalScale)
import Visualization.Shape as Shape
import Data.Painting as Painting
import Svg.Events exposing (onClick, onMouseOut, onMouseOver)


type alias Model =
    { yScaleType : ScaleType
    , lineType : LineType
    , pointInfo : Maybe Int
    }


type ScaleType
    = Linear
    | Log10


type LineType
    = Straight
    | Curved


initialModel =
    { yScaleType = Log10
    , lineType = Straight
    , pointInfo = Nothing
    }


type Msg
    = LinearScale
    | Log10Scale
    | StraightLine
    | CurvedLine
    | PointInfo (Maybe Int)


update msg model =
    case msg of
        LinearScale ->
            { model | yScaleType = Linear }

        Log10Scale ->
            { model | yScaleType = Log10 }

        StraightLine ->
            { model | lineType = Straight }

        CurvedLine ->
            { model | lineType = Curved }

        PointInfo maybeInt ->
            { model | pointInfo = maybeInt }


view model painting =
    Svg.svg
        [ viewBox <| "0 0 " ++ toString w ++ " " ++ toString h ]
        [ graphView model painting.iterations ]


graphView : Model -> List Painting.Iteration -> Svg Msg
graphView model iterations =
    let
        scales =
            { x = xScale iterations
            , y = yScale model iterations
            }
    in
        svg [ width (toString w ++ "px"), height (toString h ++ "px") ]
            [ xAxis scales.x iterations
            , yAxis scales.y iterations
            , curve model scales.x scales.y iterations
            , curveLabel scales.y iterations
            , points model scales.x scales.y iterations
              --            , graphTitle
            , graphControls model
            ]


xScale : List Painting.Iteration -> ContinuousScale
xScale iterations =
    Scale.linear ( 0, toFloat <| (List.length iterations) - 1 ) ( 0, w - 2 * padding )


yScale : Model -> List Painting.Iteration -> ContinuousScale
yScale model iterations =
    let
        min =
            iterations
                |> List.map (values >> List.minimum >> Maybe.withDefault 0)
                |> List.minimum
                |> Maybe.withDefault 0

        max =
            iterations
                |> List.map (values >> List.maximum >> Maybe.withDefault 0)
                |> List.maximum
                |> Maybe.withDefault 0
    in
        case model.yScaleType of
            Linear ->
                Scale.linear ( min, max ) ( h - 2 * padding, 0 )

            Log10 ->
                Scale.log 10 ( min, max ) ( h - 2 * padding, 0 )


xAxis : ContinuousScale -> List Painting.Iteration -> Svg msg
xAxis scale iterations =
    let
        axis =
            Axis.axis { defaultOptions | orientation = Axis.Bottom, tickCount = List.length iterations } scale
    in
        g [ transform ("translate(" ++ toString (padding - 1) ++ ", " ++ toString (h - padding) ++ ")") ]
            [ axis ]


yAxis : ContinuousScale -> List Painting.Iteration -> Svg msg
yAxis scale iterations =
    let
        min =
            iterations
                |> List.map (values >> List.minimum >> Maybe.withDefault 0)
                |> List.minimum
                |> Maybe.withDefault 0

        max =
            iterations
                |> List.map (values >> List.maximum >> Maybe.withDefault 0)
                |> List.maximum
                |> Maybe.withDefault 0

        axis =
            Axis.axis
                { defaultOptions
                    | orientation = Axis.Left
                    , ticks = Just [ min, max ]
                    , tickFormat = Just formatLoss
                }
                scale
    in
        g [ transform ("translate(" ++ toString (padding - 1) ++ ", " ++ toString padding ++ ")") ]
            [ axis, text_ [ fontFamily "sans-serif", fontSize "10", x "5", y "5" ] [ text "Loss" ] ]


curve : Model -> ContinuousScale -> ContinuousScale -> List Painting.Iteration -> Svg Msg
curve model xScale yScale iterations =
    let
        lineGenerator : ( Int, Int ) -> Maybe ( Float, Float )
        lineGenerator ( x, y ) =
            Just ( Scale.convert xScale (toFloat x), Scale.convert yScale (toFloat y) )

        lineType =
            case model.lineType of
                Straight ->
                    Shape.linearCurve

                Curved ->
                    Shape.monotoneInXCurve

        line : (Painting.Iteration -> Int) -> String
        line accessor =
            List.indexedMap (\idx iter -> ( idx, accessor iter )) iterations
                |> List.map lineGenerator
                |> Shape.line lineType
    in
        g [ transform ("translate(" ++ toString padding ++ ", " ++ toString padding ++ ")"), class "series" ]
            (List.map (\{ accessor, label } -> Svg.path [ d (line <| round << accessor), stroke (colorString label), strokeWidth "3px", fill "none" ] []) series)


points : Model -> ContinuousScale -> ContinuousScale -> List Painting.Iteration -> Svg Msg
points model xScale yScale iterations =
    let
        pointView n iter =
            let
                point =
                    ( Scale.convert xScale (toFloat n), Scale.convert yScale iter.loss )

                ( c, el ) =
                    if Just (round <| Tuple.first point) == model.pointInfo then
                        ( circle 8
                        , [ Svg.text_
                                [ transform ("translate(10,-10)") ]
                                [ text <| formatLoss iter.loss ]
                          ]
                        )
                    else
                        ( circle 4, [] )
            in
                Svg.g [ transform ("translate" ++ toString point) ]
                    ((Svg.path
                        [ d c
                        , fill "white"
                        , stroke "black"
                        , onMouseOver (PointInfo (Just <| round <| Tuple.first point))
                        , onMouseOut (PointInfo Nothing)
                        ]
                        []
                     )
                        :: el
                    )
    in
        g [ transform ("translate(" ++ toString padding ++ ", " ++ toString padding ++ ")") ]
            (List.indexedMap pointView iterations)


circle : Float -> String
circle radius =
    Shape.arc
        { innerRadius = 0
        , outerRadius = radius
        , cornerRadius = 0
        , startAngle = 0
        , endAngle = 2 * pi
        , padAngle = 0
        , padRadius = 0
        }


curveLabel : ContinuousScale -> List Painting.Iteration -> Svg Msg
curveLabel scale iterations =
    let
        last =
            List.reverse iterations
                |> List.head
                |> Maybe.withDefault (Painting.Iteration "" 0)
    in
        g [ fontFamily "sans-serif", fontSize "10" ]
            (List.map
                (\{ accessor, label } ->
                    g [ transform ("translate(" ++ toString (w - padding + 10) ++ ", " ++ toString (padding + Scale.convert scale ((accessor last))) ++ ")") ]
                        [ text_ [ fill (colorString label) ] [ text label ] ]
                )
                series
            )


graphTitle : Svg Msg
graphTitle =
    g [ transform ("translate(" ++ toString (w - padding) ++ ", " ++ toString (padding + 20) ++ ")") ]
        [ text_ [ fontFamily "sans-serif", fontSize "20", textAnchor "end" ] [ text "Loss on each iteration" ]
        ]


graphControls : Model -> Svg Msg
graphControls model =
    let
        control pos msg label =
            g [ transform ("translate(" ++ toString (w - padding) ++ ", " ++ toString (padding + pos) ++ ")") ]
                [ text_ [ fontFamily "sans-serif", fontSize "15", textAnchor "end", onClick msg ] [ text label ]
                ]
    in
        g []
            [ case model.yScaleType of
                Linear ->
                    control 20 Log10Scale "Scale: Linear. Click for Log10"

                Log10 ->
                    control 20 LinearScale "Scale: Log10. Click for Linear"
            , case model.lineType of
                Straight ->
                    control 40 CurvedLine "Line: Straight. Click for Curved"

                Curved ->
                    control 40 StraightLine "Scale: Curved. Click for Straight"
            ]


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    60


series =
    [ { label = "Loss"
      , accessor = .loss
      }
    ]


accessors : List (Painting.Iteration -> Float)
accessors =
    List.map .accessor series


values : Painting.Iteration -> List Float
values i =
    List.map (\a -> a i) accessors


colorScale : OrdinalScale String Color
colorScale =
    Scale.ordinal (List.map .label series) Scale.category10


colorString : String -> String
colorString =
    Scale.convert colorScale >> Maybe.withDefault Color.black >> colorToCssRgb


formatLoss : Float -> String
formatLoss loss =
    let
        exp =
            (round (logBase 10 loss)) - 1

        n =
            Numeral.format "0,0.00" <| loss / toFloat (10 ^ exp)
    in
        n ++ "e" ++ toString exp
