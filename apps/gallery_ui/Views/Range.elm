module Views.Range exposing (linear, exponential)

import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Route


type alias Range =
    ( Float, Float, Float )


exponential : Range -> (Float -> msg) -> String -> Float -> Bool -> Html msg
exponential range msg label val disabled =
    rangeInput range msg label val log10 exp10 disabled


linear : Range -> (Float -> msg) -> String -> Float -> Bool -> Html msg
linear range msg label val disabled =
    rangeInput range msg label val identity identity disabled


rangeInput : Range -> (Float -> msg) -> String -> Float -> (Float -> Float) -> (Float -> Float) -> Bool -> Html msg
rangeInput ( from, to, step ) msg label val toSlider toVal disabled =
    let
        parsedToVal str =
            case String.toFloat str of
                Ok num ->
                    toVal num

                Err err ->
                    val
    in
        H.div []
            [ H.div [] [ H.text <| label ++ toString val ]
            , H.input
                [ HA.type_ "range"
                , HA.min (toString from)
                , HA.max (toString to)
                , HA.value <| toString <| toSlider val
                , HA.step (toString step)
                , HE.onInput (parsedToVal >> msg)
                , HA.disabled disabled
                ]
                []
            ]


log10 =
    logBase 10


exp10 exp =
    10 ^ exp
