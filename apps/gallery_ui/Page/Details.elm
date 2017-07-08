module Page.Details exposing (..)

import Html as H exposing (Html, a, div, fieldset, h4, img, li, text, ul)
import Data.Painting as Painting exposing (Painting, Status(..))
import Html.Attributes as HA exposing (class, src)
import Html.Events as HE
import Http
import Json.Decode
import Page.Errored exposing (PageLoadError, pageLoadError)
import Task exposing (Task)
import Phoenix
import Phoenix.Push as Push
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel exposing (Channel)
import Page.Details.Loss as Loss


-- MODEL --


type Model
    = Loading String
    | Loaded LoadedModel


type alias LoadedModel =
    { painting : Painting
    , resultFrame : ResultFrame
    , loss : Loss.Model
    }


type ResultFrame
    = Exactly Int
    | Last


init : String -> Task PageLoadError Model
init name =
    Task.succeed <| Loading name



-- UPDATE --


type Msg
    = InitPainting Json.Decode.Value
    | UpdatePainting Json.Decode.Value
    | UpdateIterations Int
    | UpdateContentWeight Float
    | UpdateStyleWeight Float
    | UpdateVariationWeight Float
    | UpdateOutputWidth Int
    | UpdateContentPath String
    | UpdateStylePath String
    | StartPainting
    | LossMsg Loss.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Loading name ->
            case msg of
                InitPainting json ->
                    let
                        painting =
                            case Json.Decode.decodeValue Painting.decoder json of
                                Ok paint ->
                                    paint

                                Err err ->
                                    let
                                        _ =
                                            Debug.log "InitPainting: " err
                                    in
                                        Painting.initialPainting name
                    in
                        ( Loaded { painting = painting, resultFrame = Last, loss = Loss.initialModel }, Cmd.none )

                _ ->
                    ( Loading name, Cmd.none )

        Loaded loadedModel ->
            case msg of
                UpdatePainting json ->
                    let
                        painting =
                            case Json.Decode.decodeValue Painting.decoder json of
                                Ok paint ->
                                    paint

                                Err err ->
                                    loadedModel.painting
                    in
                        ( Loaded { loadedModel | painting = painting }, Cmd.none )

                UpdateIterations num ->
                    ( Loaded { loadedModel | painting = Painting.setIterations num loadedModel.painting }, Cmd.none )

                UpdateContentWeight weight ->
                    ( Loaded { loadedModel | painting = Painting.setContentWeight weight loadedModel.painting }, Cmd.none )

                UpdateStyleWeight weight ->
                    ( Loaded { loadedModel | painting = Painting.setStyleWeight weight loadedModel.painting }, Cmd.none )

                UpdateVariationWeight weight ->
                    ( Loaded { loadedModel | painting = Painting.setVariationWeight weight loadedModel.painting }, Cmd.none )

                UpdateOutputWidth width ->
                    ( Loaded { loadedModel | painting = Painting.setOutputWidth width loadedModel.painting }, Cmd.none )

                UpdateContentPath path ->
                    ( Loaded { loadedModel | painting = Painting.setContentPath path loadedModel.painting }, Cmd.none )

                UpdateStylePath path ->
                    ( Loaded { loadedModel | painting = Painting.setStylePath path loadedModel.painting }, Cmd.none )

                StartPainting ->
                    let
                        painting =
                            loadedModel.painting

                        message =
                            Push.init ("painting:" ++ painting.name) "start"
                                |> Push.withPayload (Painting.encode painting)
                    in
                        ( Loaded loadedModel, Phoenix.push socketUrl message )

                LossMsg submsg ->
                    ( Loaded { loadedModel | loss = Loss.update submsg loadedModel.loss }, Cmd.none )

                _ ->
                    ( Loaded loadedModel, Cmd.none )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Loading name ->
            Phoenix.connect socket [ channel name ]

        Loaded loeadedModel ->
            Phoenix.connect socket [ channel loeadedModel.painting.name ]


socketUrl : String
socketUrl =
    "ws://localhost:4000/socket/websocket"


socket : Socket Msg
socket =
    Socket.init socketUrl


channel : String -> Channel Msg
channel name =
    Channel.init ("painting:" ++ name)
        |> Channel.onJoin InitPainting
        |> Channel.on "update" UpdatePainting



-- VIEW --


view : Model -> Html Msg
view model =
    let
        content =
            case model of
                Loading name ->
                    [ H.p [] [ text "loading......" ] ]

                Loaded loadedModel ->
                    [ H.h2 [] [ text loadedModel.painting.name ]
                    , settingsView loadedModel
                    , sourcesView loadedModel
                    , resultView loadedModel
                    , div [ class "clearfix" ] []
                    , H.map LossMsg <| Loss.view loadedModel.loss loadedModel.painting
                    ]
    in
        div [ class "details" ] content


settingsView : LoadedModel -> Html Msg
settingsView { painting } =
    let
        disabled =
            case painting.status of
                NotReady ->
                    False

                Ready ->
                    True

                InProgress ->
                    True

                Complete ->
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


sourcesView : LoadedModel -> Html Msg
sourcesView { painting } =
    let
        view =
            case painting.status of
                NotReady ->
                    editableSourcesView painting

                Ready ->
                    readOnlySourcesView painting

                InProgress ->
                    readOnlySourcesView painting

                Complete ->
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


resultView : LoadedModel -> Html Msg
resultView { painting, resultFrame } =
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
                NotReady ->
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
    [ ( "Starry night", "http://localhost:4000/images/sources/style/1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg" )
    , ( "The Scream", "http://localhost:4000/images/sources/style/1200px-The_Scream.jpg" )
    , ( "Picasso self portrait", "http://localhost:4000/images/sources/style/self-portrait-1907.jpg" )
    ]


contentList : List ( String, String )
contentList =
    [ ( "Cadiz", "http://localhost:4000/images/sources/content/image_61020.jpeg" )
    , ( "London", "http://localhost:4000/images/sources/content/bridge-england-united-kingdom-big-ben-thames-night-london-street-lights-cities-river-reflection-clock-watch-time-images-198692.jpg" )
    , ( "Dani", "http://localhost:4000/images/sources/content/daniel-cabillas.jpg" )
    ]
