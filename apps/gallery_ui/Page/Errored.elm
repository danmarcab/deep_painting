module Page.Errored exposing (..)

import Html exposing (Html, h1, div, text, p)
import Html.Attributes exposing (class, tabindex, id, alt)


-- MODEL --


type PageLoadError
    = PageLoadError String


pageLoadError : String -> PageLoadError
pageLoadError errorMessage =
    PageLoadError errorMessage


type Msg
    = None



-- VIEW --


view : PageLoadError -> Html msg
view (PageLoadError errorMessage) =
    div []
        [ h1 [] [ text "Error Loading Page" ]
        , div []
            [ p [] [ text errorMessage ] ]
        ]
