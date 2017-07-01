module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, a, button, div, img, text)
import Html.Attributes exposing (src, type_)
import Html.Events exposing (onClick)
import Data.Painting as Painting exposing (Painting)
import Page.Gallery
import Page.Details
import Page.Errored exposing (PageLoadError)
import Navigation exposing (Location)
import Page.NotFound
import Route exposing (Route)
import Task
import Views.Page


-- MODEL --


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Gallery Page.Gallery.Model
    | Details Page.Details.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState
    }


init : Location -> ( Model, Cmd Msg )
init location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        }


initialPage =
    Blank



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | GalleryLoaded Page.Gallery.Model
    | DetailsLoaded Page.Details.Model
    | PageFailedToLoad PageLoadError
    | GalleryMsg Page.Gallery.Msg
    | DetailsMsg Page.Details.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute route ->
            setRoute route model

        GalleryLoaded subModel ->
            ( { model | pageState = Loaded (Gallery subModel) }, Cmd.none )

        DetailsLoaded subModel ->
            ( { model | pageState = Loaded (Details subModel) }, Cmd.none )

        PageFailedToLoad error ->
            ( { model | pageState = Loaded (Errored error) }, Cmd.none )

        _ ->
            updatePage msg (getPage model.pageState) model


updatePage : Msg -> Page -> Model -> ( Model, Cmd Msg )
updatePage msg page model =
    case ( msg, page ) of
        ( GalleryMsg subMsg, Gallery subModel ) ->
            let
                ( newPageModel, pageCmd ) =
                    Page.Gallery.update subMsg subModel
            in
                ( { model | pageState = Loaded <| Gallery newPageModel }, Cmd.map GalleryMsg pageCmd )

        ( DetailsMsg subMsg, Details subModel ) ->
            let
                ( newPageModel, pageCmd ) =
                    Page.Details.update subMsg subModel
            in
                ( { model | pageState = Loaded <| Details newPageModel }, Cmd.map DetailsMsg pageCmd )

        ( _, _ ) ->
            ( model, Cmd.none )


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        toMsg onOk result =
            case result of
                Ok data ->
                    onOk data

                Err error ->
                    PageFailedToLoad error

        transition onOk task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }
            , Task.attempt (toMsg onOk) task
            )
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            Just (Route.Gallery) ->
                transition GalleryLoaded (Page.Gallery.init)

            Just (Route.Details name) ->
                transition DetailsLoaded (Page.Details.init name)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage False page

        TransitioningFrom page ->
            viewPage True page


viewPage : Bool -> Page -> Html Msg
viewPage isLoading page =
    let
        frame =
            Views.Page.frame isLoading
    in
        case page of
            Blank ->
                Html.text ""
                    |> frame []

            NotFound ->
                Page.NotFound.view
                    |> frame []

            Errored subModel ->
                Page.Errored.view subModel
                    |> frame []

            Gallery gallery ->
                Page.Gallery.view gallery
                    |> frame []
                    |> Html.map GalleryMsg

            Details details ->
                Page.Details.view details
                    |> frame [ a [ Route.href (Route.Gallery) ] [ text "Back to Gallery" ] ]
                    |> Html.map DetailsMsg



-- MAIN --


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> SetRoute)
        { init = init, update = update, view = view, subscriptions = subscriptions }
