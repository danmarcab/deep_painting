module Page.Details exposing (..)

import Html exposing (Html, a, div, h4, img, li, text, ul)
import Data.Painting as Painting exposing (Painting, Status(..))
import Html.Attributes exposing (class, src)
import Http
import Json.Decode
import Page.Errored exposing (PageLoadError, pageLoadError)
import Task exposing (Task)


-- MODEL --


type Model
    = Model
        { painting : Painting
        , resultFrame : ResultFrame
        }


type ResultFrame
    = Exactly Int
    | Last


init : String -> Task PageLoadError Model
init name =
    Task.succeed <| Model { painting = Painting.initialPainting name, resultFrame = Last }



--    Http.get "" decoder
--        |> Http.toTask
--        |> Task.mapError (\_ -> pageLoadError "Could not load Details")


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.succeed <| Model { painting = Painting.initialPainting "name", resultFrame = Last }



-- UPDATE --


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )



-- VIEW --


view : Model -> Html Msg
view model =
    div []
        [ settingsView model
        , sourcesView model
        , resultView model
        , div [ class "clearfix" ] []
        ]


settingsView : Model -> Html Msg
settingsView (Model { painting }) =
    let
        view =
            case painting.status of
                New ->
                    editableSettingsView painting.settings

                InProgress ->
                    readOnlySettingsView painting.settings

                Done ->
                    readOnlySettingsView painting.settings
    in
        div [ class "details-settings framed" ]
            [ h4 [] [ text "settings" ]
            , view
            ]


editableSettingsView : Painting.Settings -> Html Msg
editableSettingsView settings =
    ul []
        [ li [] [ text <| "iterations: " ++ toString (settings.iterations) ]
        ]


readOnlySettingsView : Painting.Settings -> Html Msg
readOnlySettingsView settings =
    ul []
        [ li [] [ text <| "iterations: " ++ toString (settings.iterations) ]
        ]


sourcesView : Model -> Html Msg
sourcesView (Model { painting }) =
    let
        view =
            case painting.status of
                New ->
                    editableSourcesView painting

                InProgress ->
                    readOnlySourcesView painting

                Done ->
                    readOnlySourcesView painting
    in
        div [ class "details-source framed" ] [ view ]


readOnlySourcesView : Painting -> Html Msg
readOnlySourcesView painting =
    div []
        [ h4 [] [ text "content" ]
        , img [ src painting.contentPath ] []
        , h4 [] [ text "style" ]
        , img [ src painting.stylePath ] []
        ]


editableSourcesView : Painting -> Html Msg
editableSourcesView painting =
    div []
        [ h4 [] [ text "content" ]
        , img [ src painting.contentPath ] []
        , h4 [] [ text "style" ]
        , img [ src painting.stylePath ] []
        ]


resultView : Model -> Html Msg
resultView (Model { painting, resultFrame }) =
    let
        maybeIteration idx =
            List.drop (idx - 1) painting.iterations
                |> List.head

        index =
            case resultFrame of
                Last ->
                    List.length painting.iterations

                Exactly pos ->
                    pos
    in
        case maybeIteration index of
            Just iteration ->
                div [ class "details-result framed" ]
                    [ h4 [] [ text "result" ]
                    , img [ src iteration.path ] []
                    ]

            Nothing ->
                text "Nothing to show yet."
