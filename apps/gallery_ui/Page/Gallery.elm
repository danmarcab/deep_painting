module Page.Gallery exposing (..)

import Html exposing (Html, a, div, h2, h4, img, input, span, text)
import Html.Attributes exposing (class, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Page.Errored exposing (PageLoadError, pageLoadError)
import Route
import Task exposing (Task)
import Data.Painting as Painting exposing (Painting)


-- MODEL --


type alias Model =
    { paintings : List Painting
    , filter : String
    }


init : Task PageLoadError Model
init =
    Task.succeed
        { paintings =
            [ Painting.initialPainting "p1"
            , Painting.initialPainting "p2"
            , Painting.initialPainting "p3"
            , Painting.initialPainting "p4"
            , Painting.initialPainting "p5"
            , Painting.initialPainting "p6"
            , Painting.initialPainting "p7"
            ]
        , filter = ""
        }



--    Http.get "" decoder
--        |> Http.toTask
--        |> Task.mapError (\_ -> pageLoadError "Could not load Gallery")


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.succeed { paintings = [], filter = "" }



-- UPDATE --


type Msg
    = Search String
    | ClearSearch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search string ->
            ( { model | filter = string }, Cmd.none )

        ClearSearch ->
            ( { model | filter = "" }, Cmd.none )



-- VIEW --


view : Model -> Html Msg
view model =
    let
        filter p =
            if String.contains model.filter p.name then
                Just p
            else
                Nothing
    in
        div [ class "gallery" ] <|
            [ h2 [] [ text "Gallery" ]
            , searchView model.filter
            , div [ class "clearfix" ] []
            ]
                ++ (List.filterMap (filter >> Maybe.map paintingView) model.paintings)
                ++ [ div [ class "clearfix" ] [] ]


searchView : String -> Html Msg
searchView filter =
    div [ class "gallery-search" ]
        [ input [ value filter, onInput Search ] []
        , a [ onClick ClearSearch ] [ text "Clear" ]
        ]


paintingView : Painting -> Html Msg
paintingView painting =
    div
        [ class "painting_preview framed" ]
        [ h4 [] [ text painting.name ]
        , a [ Route.href (Route.Details painting.name) ]
            [ img [ src (Maybe.withDefault defaultImg painting.stylePath) ] [] ]
        ]


defaultImg : String
defaultImg =
    "not found"
