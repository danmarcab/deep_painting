module Page.Gallery exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, a, div, h2, h4, img, input, span, text)
import Html.Attributes exposing (class, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Page.Errored exposing (PageLoadError, pageLoadError)
import Route
import Task exposing (Task)
import Data.Painting as Painting exposing (Painting)
import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel exposing (Channel)


-- MODEL --


type Model
    = Loading
    | Loaded LoadedModel


type alias LoadedModel =
    { paintings : Dict String Painting
    , filter : String
    , newName : String
    }


init : Task PageLoadError Model
init =
    Task.succeed Loading



-- UPDATE --


type Msg
    = Search String
    | ClearSearch
    | UpdateNewName String
    | InitGallery Json.Decode.Value
    | UpdatePainting Json.Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Loading ->
            case msg of
                InitGallery json ->
                    case Json.Decode.decodeValue (Json.Decode.dict Painting.decoder) json of
                        Ok paintings ->
                            ( Loaded { paintings = paintings, filter = "", newName = "" }, Cmd.none )

                        Err err ->
                            let
                                _ =
                                    Debug.log "InitGallery: " err
                            in
                                ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Loaded model ->
            case msg of
                Search string ->
                    ( Loaded { model | filter = string }, Cmd.none )

                UpdateNewName string ->
                    ( Loaded { model | newName = string }, Cmd.none )

                ClearSearch ->
                    ( Loaded { model | filter = "" }, Cmd.none )

                UpdatePainting json ->
                    case Json.Decode.decodeValue Painting.decoder json of
                        Ok painting ->
                            ( Loaded { model | paintings = Dict.insert painting.name painting model.paintings }, Cmd.none )

                        Err err ->
                            let
                                _ =
                                    Debug.log "UpdatePainting: " err
                            in
                                ( Loaded model, Cmd.none )

                _ ->
                    ( Loaded model, Cmd.none )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.connect socket [ channel ]


socketUrl : String
socketUrl =
    "ws://localhost:4000/socket/websocket"


socket : Socket Msg
socket =
    Socket.init socketUrl


channel : Channel Msg
channel =
    Channel.init ("gallery")
        |> Channel.onJoin InitGallery
        |> Channel.on "update" UpdatePainting



-- VIEW --


view : Model -> Html Msg
view model =
    let
        filter filt p =
            if String.contains filt p.name then
                Just p
            else
                Nothing

        content =
            case model of
                Loading ->
                    [ text "loading..." ]

                Loaded loaded ->
                    [ searchView loaded.filter
                    , createView loaded
                    , div [ class "clearfix" ] []
                    ]
                        ++ (List.filterMap (filter loaded.filter >> Maybe.map paintingView) <| Dict.values loaded.paintings)
                        ++ [ div [ class "clearfix" ] [] ]
    in
        div [ class "gallery" ] <|
            [ h2 [] [ text "Gallery" ]
            ]
                ++ content


searchView : String -> Html Msg
searchView filter =
    div [ class "gallery-search" ]
        [ input [ value filter, onInput Search ] []
        , a [ onClick ClearSearch ] [ text "Clear" ]
        ]


paintingView : Painting -> Html Msg
paintingView painting =
    let
        lastImg =
            painting.iterations
                |> List.reverse
                |> List.head
                |> Maybe.map .path
                |> Maybe.withDefault defaultImg
    in
        div
            [ class "painting_preview framed" ]
            [ h4 [] [ text painting.name ]
            , a [ Route.href (Route.Details painting.name) ]
                [ img [ src lastImg ] [] ]
            ]


defaultImg : String
defaultImg =
    "not found"


createView : LoadedModel -> Html Msg
createView loaded =
    let
        alreadyThere =
            Dict.member loaded.newName loaded.paintings

        valid =
            not (String.isEmpty loaded.newName)

        content =
            case ( alreadyThere, valid ) of
                ( True, _ ) ->
                    text "Name already taken"

                ( False, False ) ->
                    text "Enter a name to create a new painting"

                ( False, True ) ->
                    a [ Route.href (Route.Details loaded.newName) ] [ text "Create" ]
    in
        div []
            [ input [ onInput UpdateNewName, value loaded.newName ] []
            , content
            ]
