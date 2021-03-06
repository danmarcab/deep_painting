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
import Time
import Views.Range as Range


-- MODEL --


type Model
    = Loading String
    | Loaded LoadedModel


type alias LoadedModel =
    { painting : Painting
    , resultFrame : ResultFrame
    , lossOpened : Bool
    , loss : Loss.Model
    }


type ResultFrame
    = Stopped Int
    | Playing Int
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
    | SetInitialType Painting.InitialType
    | StartPainting
    | LossMsg Loss.Msg
    | AdvanceResultIter
    | ShowAlwaysLastIter
    | PlayResultIter
    | StopResultIter
    | UpdateResultPos Int
    | ToogleLoss


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
                        ( Loaded { painting = painting, resultFrame = Last, lossOpened = False, loss = Loss.initialModel }, Cmd.none )

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

                SetInitialType initialType ->
                    ( Loaded { loadedModel | painting = Painting.setInitialType initialType loadedModel.painting }, Cmd.none )

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

                UpdateResultPos pos ->
                    ( Loaded { loadedModel | resultFrame = Stopped pos }, Cmd.none )

                PlayResultIter ->
                    ( Loaded { loadedModel | resultFrame = Playing 1 }, Cmd.none )

                StopResultIter ->
                    let
                        i =
                            case loadedModel.resultFrame of
                                Last ->
                                    (List.length loadedModel.painting.iterations) - 1

                                Playing m ->
                                    m

                                Stopped m ->
                                    m
                    in
                        ( Loaded { loadedModel | resultFrame = Stopped i }, Cmd.none )

                ShowAlwaysLastIter ->
                    ( Loaded { loadedModel | resultFrame = Last }, Cmd.none )

                AdvanceResultIter ->
                    let
                        adjust n =
                            (n + 1) % (List.length loadedModel.painting.iterations)

                        i =
                            case loadedModel.resultFrame of
                                Last ->
                                    0

                                Playing m ->
                                    adjust m

                                Stopped m ->
                                    adjust m
                    in
                        ( Loaded { loadedModel | resultFrame = Playing i }, Cmd.none )

                ToogleLoss ->
                    ( Loaded { loadedModel | lossOpened = not loadedModel.lossOpened }, Cmd.none )

                _ ->
                    ( Loaded loadedModel, Cmd.none )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Loading name ->
            Phoenix.connect socket [ channel name ]

        Loaded loeadedModel ->
            case loeadedModel.resultFrame of
                Playing _ ->
                    Sub.batch
                        [ Time.every (500 * Time.millisecond) (always AdvanceResultIter)
                        , Phoenix.connect socket [ channel loeadedModel.painting.name ]
                        ]

                _ ->
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
                    [ H.h2 []
                        [ text loadedModel.painting.name
                        , text <| " (" ++ Painting.statusText loadedModel.painting ++ ")"
                        ]
                    , settingsView loadedModel
                    , sourcesView loadedModel
                    , resultView loadedModel
                    , div [ class "clearfix" ] []
                    , if loadedModel.lossOpened then
                        div [ class "framed loss" ]
                            [ H.map LossMsg <| Loss.view loadedModel.loss loadedModel.painting
                            , H.button [ class "close-loss", HE.onClick ToogleLoss ] [ text "Close" ]
                            ]
                      else
                        text ""
                    ]
    in
        div [ class "details" ] content


settingsView : LoadedModel -> Html Msg
settingsView ({ painting } as loadedModel) =
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
    div []
        [ Range.linear ( 5, 100, 5 ) (UpdateIterations << round) "Interations: " (toFloat settings.iterations) disabled
        , Range.exponential ( -4, 4, 0.25 ) UpdateContentWeight "Content weight: " settings.contentWeight disabled
        , Range.exponential ( -4, 4, 0.25 ) UpdateStyleWeight "Style weight: " settings.styleWeight disabled
        , Range.exponential ( -4, 4, 0.25 ) UpdateVariationWeight "Variation weight: " settings.variationWeight disabled
        , Range.linear ( 100, 800, 50 ) (UpdateOutputWidth << round) "Output width (px): " (toFloat settings.outputWidth) disabled
        , initialTypeView settings.initialType disabled
        ]


initialTypeView : Painting.InitialType -> Bool -> Html Msg
initialTypeView initialType disabled =
    div []
        [ H.label []
            [ text "Initial image" ]
        , div
            []
            [ H.input [ HA.type_ "radio", HA.name "initial_type", HA.checked (initialType == Painting.Content), HE.onClick <| SetInitialType Painting.Content ] []
            , text "Content"
            , H.input [ HA.type_ "radio", HA.name "initial_type", HA.checked (initialType == Painting.Style), HE.onClick <| SetInitialType Painting.Style ] []
            , text "Style"
            , H.input [ HA.type_ "radio", HA.name "initial_type", HA.checked (initialType == Painting.Blank), HE.onClick <| SetInitialType Painting.Blank ] []
            , text "Blank"
            ]
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
            List.drop idx painting.iterations
                |> List.head

        ( index, buttons ) =
            case resultFrame of
                Last ->
                    ( (List.length painting.iterations) - 1
                    , [ H.button [ HE.onClick StopResultIter ] [ text "[]" ]
                      , H.button [ HE.onClick PlayResultIter ] [ text "|>" ]
                      ]
                    )

                Stopped pos ->
                    ( pos
                    , [ H.button [ HE.onClick PlayResultIter ] [ text "|>" ]
                      , H.button [ HE.onClick ShowAlwaysLastIter ] [ text ">>" ]
                      ]
                    )

                Playing pos ->
                    ( pos
                    , [ H.button [ HE.onClick StopResultIter ] [ text "[]" ]
                      , H.button [ HE.onClick ShowAlwaysLastIter ] [ text ">>" ]
                      ]
                    )

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
                            div []
                                ([ img [ src iteration.path ] []
                                 , Range.linear ( 0, toFloat <| (List.length painting.iterations) - 1, 1 ) (UpdateResultPos << round) "Interation: " (toFloat index) False
                                 , H.button [ HE.onClick ToogleLoss ] [ text "Show loss graph" ]
                                 ]
                                    ++ buttons
                                )

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
    [ ( "Starry night", "https://raw.githubusercontent.com/titu1994/Neural_Style_Transfer/master/images/inputs/style/starry_night.jpg" )
    , ( "The Scream", "http://localhost:4000/images/sources/style/1200px-The_Scream.jpg" )
    , ( "Red Canna", "http://www.georgiaokeeffe.net/images/paintings/red-canna.jpg" )
    , ( "Picasso seated nude", "https://www.pablopicasso.org/images/paintings/seated-nude.jpg" )
    , ( "Picasso self portrait", "http://localhost:4000/images/sources/style/self-portrait-1907.jpg" )
    , ( "Misty mood", "http://img02.deviantart.net/ebd6/i/2015/236/c/d/misty_mood_by_leonid_afremov_by_leonidafremov-d2k3jaw.jpg" )
    , ( "Ink City", "http://s-media-cache-ak0.pinimg.com/originals/48/c8/e3/48c8e3d14e5d0224ee8287013be7ad7d.jpg" )
    ]


contentList : List ( String, String )
contentList =
    [ ( "Cadiz", "http://localhost:4000/images/sources/content/image_61020.jpeg" )
    , ( "Cadiz 2", "http://sleepincadiz.com/wp-content/uploads/2015/06/catedral-de-cadiz.jpg" )
    , ( "London", "http://www.telegraph.co.uk/content/dam/business/2016/12/06/JS115443655_wwwalamycom_London-Piccadilly-Circus-illuminated-xlarge_trans_NvBQzQNjv4Bq5yQLQqeH37t50SCyM4-zeGtT0gK_6EfZT336f62EI5U.jpg" )
    , ( "London Park", "https://media.timeout.com/images/102880972/image.jpg" )
    , ( "Santa ana", "http://www.fondobook.com/wp-content/uploads/2012/01/fondo_hd_43_ermita_andaluza.jpg" )
    , ( "Blue lake", "http://natbg.com/wp-content/uploads/2016/09/winter-evening-nigh-night-blue-lake-cold-mountains-trees-beautiful-reflection-snow-winter-moon-wallpaper-hd.jpg" )
    ]
