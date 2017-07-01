module Page.Details exposing (..)

import Html as H exposing (Html, a, div, fieldset, h4, img, li, text, ul)
import Data.Painting as Painting exposing (Painting, Status(..))
import Html.Attributes as HA exposing (class, src)
import Html.Events as HE
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
    = UpdateIterations Int
    | UpdateContentWeight Float
    | UpdateStyleWeight Float
    | UpdateVariationWeight Float
    | UpdateOutputWidth Int
    | UpdateContentPath String
    | UpdateStylePath String
    | StartPainting


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        UpdateIterations num ->
            ( Model { model | painting = Painting.setIterations num model.painting }, Cmd.none )

        UpdateContentWeight weight ->
            ( Model { model | painting = Painting.setContentWeight weight model.painting }, Cmd.none )

        UpdateStyleWeight weight ->
            ( Model { model | painting = Painting.setStyleWeight weight model.painting }, Cmd.none )

        UpdateVariationWeight weight ->
            ( Model { model | painting = Painting.setVariationWeight weight model.painting }, Cmd.none )

        UpdateOutputWidth width ->
            ( Model { model | painting = Painting.setOutputWidth width model.painting }, Cmd.none )

        UpdateContentPath path ->
            ( Model { model | painting = Painting.setContentPath path model.painting }, Cmd.none )

        UpdateStylePath path ->
            ( Model { model | painting = Painting.setStylePath path model.painting }, Cmd.none )

        StartPainting ->
            --        submit data to server
            ( Model model, Cmd.none )



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
        disabled =
            case painting.status of
                New ->
                    False

                InProgress ->
                    True

                Done ->
                    True
    in
        div [ class "details-settings framed" ]
            [ h4 [] [ text "settings" ]
            , settingsViewHelp painting.settings disabled
            ]


settingsViewHelp : Painting.Settings -> Bool -> Html Msg
settingsViewHelp settings disabled =
    let
        log10 =
            logBase 10

        exp10 exp =
            10 ^ exp

        expRangeInput range msg label val =
            rangeInput range msg label val log10 exp10

        linRangeInput range msg label val =
            rangeInput range msg label val identity identity

        rangeInput ( from, to, step ) msg label val toSlider toVal =
            let
                parsedToVal str =
                    case String.toFloat str of
                        Ok num ->
                            toVal num

                        Err err ->
                            val
            in
                div []
                    [ H.div [] [ text <| label ++ toString val ]
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
    in
        div []
            [ linRangeInput ( 3, 50, 1 ) (UpdateIterations << round) "Interations: " (toFloat settings.iterations)
            , expRangeInput ( -10, 10, 1 ) UpdateContentWeight "Content weight: " settings.contentWeight
            , expRangeInput ( -10, 10, 1 ) UpdateStyleWeight "Style weight: " settings.styleWeight
            , expRangeInput ( -10, 10, 1 ) UpdateVariationWeight "Variation weight: " settings.variationWeight
            , linRangeInput ( 100, 600, 50 ) (UpdateOutputWidth << round) "Output width (px): " (toFloat settings.outputWidth)
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
        , div [ class "source_preview" ] <| maybeSourceImg painting.contentPath
        , h4 [] [ text "style" ]
        , div [ class "source_preview" ] <| maybeSourceImg painting.stylePath
        ]


editableSourcesView : Painting -> Html Msg
editableSourcesView painting =
    div []
        [ h4 [] [ text "content" ]
        , H.select [ HE.onInput UpdateContentPath ] <| optionsFromList contentList
        , div [ class "source_preview" ] <| maybeSourceImg painting.contentPath
        , h4 [] [ text "style" ]
        , H.select [ HE.onInput UpdateStylePath ] <| optionsFromList styleList
        , div [ class "source_preview" ] <| maybeSourceImg painting.stylePath
        ]


maybeSourceImg : Maybe String -> List (Html Msg)
maybeSourceImg maybePath =
    case maybePath of
        Just path ->
            [ img [ src path ] [] ]

        Nothing ->
            []


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

        content =
            case painting.status of
                New ->
                    if Painting.readyToStart painting then
                        H.button [ HE.onClick StartPainting ] [ text "Start Painting!" ]
                    else
                        H.p [] [ text "Enter setting, and select content and style to start painting" ]

                _ ->
                    case maybeIteration index of
                        Just iteration ->
                            img [ src iteration.path ] []

                        Nothing ->
                            H.p [] [ text "Nothing to show yet." ]
    in
        div [ class "details-result framed" ]
            [ h4 [] [ text "result" ]
            , content
            ]


optionsFromList : List ( String, String ) -> List (Html Msg)
optionsFromList list =
    List.map
        (\( label, val ) -> H.option [ HA.value val ] [ text label ])
        (( "Please select", "" ) :: list)


styleList : List ( String, String )
styleList =
    [ ( "Starry night", "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg" )
    , ( "The Scream", "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/The_Scream.jpg/1200px-The_Scream.jpg" )
    , ( "Picasso self portrait", "https://uploads2.wikiart.org/images/pablo-picasso/self-portrait-1907.jpg" )
    ]


contentList : List ( String, String )
contentList =
    [ ( "Cadiz", "http://www.cadizturismo.com/media/fotos/image_61020.jpeg" )
    , ( "London", "http://www.hdfondos.eu/pictures/2013/0803/1/bridge-england-united-kingdom-big-ben-thames-night-london-street-lights-cities-river-reflection-clock-watch-time-images-198692.jpg" )
    , ( "Dani", "https://www.mymedsandme.com/uploads/img/our-team/_large/daniel-cabillas.jpg" )
    ]
