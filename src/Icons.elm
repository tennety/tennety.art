module Icons exposing
    ( chevronLeft
    , chevronRight
    , close
    , instagram
    , menu
    , moon
    , pencil
    , shoppingBag
    , skipBack
    , skipForward
    , sun
    )

import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (..)


svgFeatherIcon : String -> List (Svg msg) -> Html msg
svgFeatherIcon className =
    svg
        [ class <| "feather feather-" ++ className
        , fill "none"
        , height "24"
        , stroke "currentColor"
        , strokeLinecap "round"
        , strokeLinejoin "round"
        , strokeWidth "2"
        , viewBox "0 0 24 24"
        , width "24"
        ]


close : Html msg
close =
    svg [ fill "none", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M6 18L18 6M6 6l12 12" ] [] ]


instagram : Html msg
instagram =
    svgFeatherIcon "instagram"
        [ Svg.rect [ Svg.Attributes.x "2", y "2", width "20", height "20", rx "5", ry "5" ] []
        , Svg.path [ d "M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" ] []
        , Svg.line [ x1 "17.5", y1 "6.5", x2 "17.51", y2 "6.5" ] []
        ]


menu : Html msg
menu =
    svg [ fill "none", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M4 8h16M4 16h16" ] [] ]


pencil : Html msg
pencil =
    svgFeatherIcon "edit-2"
        [ Svg.path [ d "M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" ] []
        ]


shoppingBag : Html msg
shoppingBag =
    svgFeatherIcon "shopping-bag"
        [ Svg.path [ d "M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" ] []
        , Svg.line [ x1 "3", y1 "6", x2 "21", y2 "6" ] []
        , Svg.path [ d "M16 10a4 4 0 0 1-8 0" ] []
        ]


moon : Html msg
moon =
    svg [ fill "none", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" ] [] ]


sun : Html msg
sun =
    svg [ fill "none", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" ] [] ]


chevronLeft : Html msg
chevronLeft =
    svgFeatherIcon "chevron-left"
        [ Svg.polyline [ points "15 18 9 12 15 6" ] []
        ]


chevronRight : Html msg
chevronRight =
    svgFeatherIcon "chevron-right"
        [ Svg.polyline [ points "9 18 15 12 9 6" ] []
        ]


skipBack : Html msg
skipBack =
    svgFeatherIcon "skip-back"
        [ Svg.polygon [ points "19 20 9 12 19 4 19 20" ] []
        , Svg.line [ x1 "5", y1 "19", x2 "5", y2 "5" ] []
        ]


skipForward : Html msg
skipForward =
    svgFeatherIcon "skip-forward"
        [ Svg.polygon [ points "5 4 15 12 5 20 5 4" ] []
        , Svg.line [ x1 "19", y1 "5", x2 "19", y2 "19" ] []
        ]
