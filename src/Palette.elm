module Palette exposing (blogHeading, color, heading, scaled)

import Element exposing (Element)
import Element.Font as Font
import Element.Region


color =
    { primary = Element.rgb255 5 117 230
    , secondary = Element.rgb255 0 242 96
    }

scaled = (Element.modular 20 1.25) >> round

heading : Int -> List (Element msg) -> Element msg
heading level content =
    Element.paragraph
        ([ Font.regular
         , Font.family [ Font.typeface "IM Fell English" ]
         , Element.Region.heading level
         ]
            ++ (case level of
                    1 ->
                        [ Font.size (scaled 4) ]

                    2 ->
                        [ Font.size (scaled 3) ]

                    3 ->
                        [ Font.size (scaled 2) ]

                    _ ->
                        [ Font.size (scaled 1) ]
               )
        )
        content


blogHeading : String -> Element msg
blogHeading title =
    Element.paragraph
        [ Font.regular
        , Font.family [ Font.typeface "IM Fell English" ]
        , Element.Region.heading 1
        , Font.size (scaled 4)
        , Font.center
        ]
        [ Element.text title ]
