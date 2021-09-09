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
    , lighter = Element.rgb255 0xE2 0xE8 0xF0
    , light = Element.rgb255 0xCB 0xD5 0xE0
    , neutral = Element.rgb255 0xA0 0xAE 0xC0
    , dark = Element.rgb255 0x4A 0x55 0x68
    , darker = Element.rgb255 0x2D 0x37 0x48
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
    { backgroundColor = fromElmColor Color.white
    , foregroundColor = color.darkest
    , borders = color.dark
    , bodyClass = "light"
    }


darkColorScheme : ColorScheme
darkColorScheme =
    { backgroundColor = color.darker
    , foregroundColor = color.lightest
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
