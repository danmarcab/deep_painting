module Views.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route


frame : Bool -> List (Html msg) -> Html msg -> Html msg
frame isLoading headerButtons content =
    div [ classList [ ( "page-loading", isLoading ) ] ]
        [ viewHeader headerButtons
        , viewContent content
        , viewFooter
        ]


viewHeader : List (Html msg) -> Html msg
viewHeader buttons =
    header []
        [ h1 [] [ text "Deep Painting" ]
        , div [ class "header-buttons" ] buttons
        ]


viewContent : Html msg -> Html msg
viewContent content =
    main_ []
        [ content ]


viewFooter : Html msg
viewFooter =
    footer [] [ text "Daniel Marin Cabillas - 2017" ]
