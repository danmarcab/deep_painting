module Page.NotFound exposing (view)

import Html exposing (Html, h1, div, text)


-- VIEW --


view : Html msg
view =
    div [] [ h1 [] [ text "Not Found" ] ]
