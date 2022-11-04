module Palette exposing (ColorPreference(..), blogHeading, colorScheme, heading, scaled)

import Color
import Element exposing (Element)
import Element.Font as Font
import Element.Region


type ColorPreference
    = Light
    | Dark


type alias ColorScheme =
    { backgroundColor : Element.Color
    , foregroundColor : Element.Color
    , borders : Element.Color
    , bodyClass : String
    }


color =
    { lightest = Element.rgb255 0xF7 0xFA 0xFC
    , lighter = Element.rgb255 0xDC 0xDF 0xE2
    , light = Element.rgb255 0xC0 0xC4 0xC8
    , neutral = Element.rgb255 0x89 0x8D 0x94
    , dark = Element.rgb255 0x52 0x57 0x60
    , darker = Element.rgb255 0x36 0x3C 0x46
    , darkest = Element.rgb255 0x1A 0x20 0x2C
    }


fromElmColor : Color.Color -> Element.Color
fromElmColor =
    Color.toRgba >> Element.fromRgb


scaled =
    Element.modular 20 1.25 >> round


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


lightColorScheme : ColorScheme
lightColorScheme =
    { backgroundColor = color.lightest
    , foregroundColor = color.darker
    , borders = color.dark
    , bodyClass = "light"
    }


darkColorScheme : ColorScheme
darkColorScheme =
    { backgroundColor = color.darkest
    , foregroundColor = color.lighter
    , borders = color.neutral
    , bodyClass = "dark"
    }


colorScheme : ColorPreference -> ColorScheme
colorScheme pref =
    case pref of
        Light ->
            lightColorScheme

        Dark ->
            darkColorScheme
