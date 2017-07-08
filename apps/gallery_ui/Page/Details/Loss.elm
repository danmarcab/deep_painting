module Page.Details.Loss exposing (Model, initialModel, Msg, update, view)

import Data.Painting exposing (Painting)
import Html exposing (Html, span)
import Html.Attributes
import Plot exposing (DataPoint, Point)
import Svg exposing (Svg)
import Svg.Attributes


type alias Model =
    { hovering : Maybe Point }


initialModel : Model
initialModel =
    { hovering = Nothing }


type Msg
    = Hover (Maybe Point)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover maybePoint ->
            { model | hovering = maybePoint }


view : Model -> Painting -> Html Msg
view { hovering } painting =
    let
        dataPoints =
            painting.iterations
                |> List.indexedMap
                    (\n iter ->
                        { x = toFloat (n + 1), y = iter.loss }
                    )

        customizations =
            Plot.defaultSeriesPlotCustomizations
    in
        Plot.viewSeriesCustom
            { customizations | height = 100, margin = { top = 20, bottom = 30, left = 100, right = 40 }, onHover = Just Hover }
            [ Plot.line <| List.map (myDot hovering) ]
            dataPoints


myDot : Maybe { x : Float, y : Float } -> { x : Float, y : Float } -> Plot.DataPoint msg
myDot hovering point =
    hintDot hovering point.x point.y


hintDot : Maybe Point -> Float -> Float -> DataPoint msg
hintDot hovering x y =
    let
        view =
            (Plot.viewCircle 3 "#ff9edf")

        hoverView y =
            Svg.g []
                [ (Plot.viewCircle 3 "#ff9edf")
                , Svg.text_ [] [ Svg.text (toString y) ]
                ]
    in
        { view = onHovering (hoverView y) hovering x |> Maybe.withDefault view |> Just
        , xLine = Nothing
        , yLine = Nothing
        , xTick = Nothing
        , yTick = Nothing
        , hint = onHovering (hint y) hovering x
        , x = x
        , y = y
        }


onHovering : a -> Maybe Point -> Float -> Maybe a
onHovering stuff hovering x =
    Maybe.andThen
        (\p ->
            if p.x == x then
                Just stuff
            else
                Nothing
        )
        hovering


hint : Float -> Html msg
hint y =
    Html.span
        [ Html.Attributes.style [ ( "padding", "5px" ) ] ]
        [ Html.text ("Loss: " ++ toString y) ]
