module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import Color
import DataSource
import DataSource.Glob as Glob
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Input as Input
import Element.Region
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Json.Decode as Decode exposing (Decoder)
import Pages.Flags exposing (Flags(..))
import Pages.PageUrl exposing (PageUrl)
import Palette exposing (ColorScheme(..))
import Path exposing (Path)
import Route exposing (Route)
import Set
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | MenuToggled
    | ColorSchemeToggled


type SharedMsg
    = NoOp


type alias Data =
    Set.Set String


type MenuState
    = Open
    | Closed


type alias Model =
    { menuState : MenuState
    , colorScheme : ColorScheme
    }


type alias Page =
    { path : Path
    , route : Maybe Route
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    let
        decodeResult =
            case flags of
                BrowserFlags val ->
                    Decode.decodeValue colorSchemeDecoder val

                PreRenderFlags ->
                    Ok Dark

        colorScheme =
            case decodeResult of
                Ok pref ->
                    pref

                Err _ ->
                    Dark
    in
    ( { menuState = Closed, colorScheme = colorScheme }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | menuState = Closed }, Cmd.none )

        MenuToggled ->
            ( { model | menuState = toggleMenu model.menuState }, Cmd.none )

        ColorSchemeToggled ->
            ( { model | colorScheme = toggleScheme model.colorScheme }, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    (Glob.succeed Basics.identity
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal "/")
        |> Glob.match Glob.wildcard
        |> Glob.toDataSource
    )
        |> DataSource.map Set.fromList


toggleMenu : MenuState -> MenuState
toggleMenu state =
    case state of
        Open ->
            Closed

        Closed ->
            Open


toggleScheme : ColorScheme -> ColorScheme
toggleScheme scheme =
    case scheme of
        Light ->
            Dark

        Dark ->
            Light

        NoPreference ->
            Light


colorSchemeDecoder : Decoder ColorScheme
colorSchemeDecoder =
    Decode.string
        |> Decode.andThen
            (\scheme ->
                case scheme of
                    "light" ->
                        Decode.succeed Light

                    "dark" ->
                        Decode.succeed Dark

                    "no-preference" ->
                        Decode.succeed Light

                    _ ->
                        Decode.fail "Unknown colorscheme"
            )


homeLink =
    Element.link
        [ Element.centerX
        , Element.padding 10
        , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Element.Border.color Palette.color.dark
        ]
        { url = "/"
        , label = Palette.blogHeading "tennety.art"
        }


navLink folderName =
    let
        url =
            Route.Folder_ { folder = folderName } |> Route.routeToPath |> String.join "/"
    in
    Element.link
        [ Element.width Element.fill
        , Element.paddingXY 25 15
        , Font.size (Palette.scaled 2)
        , Font.center
        ]
        { url = url, label = folderName |> Element.text }


nav : Model -> Page -> Data -> Element msg
nav model page folders =
    case model.menuState of
        Closed ->
            Element.none

        Open ->
            let
                backgroundColor =
                    case model.colorScheme of
                        Light ->
                            Palette.fromElmColor Color.white

                        Dark ->
                            Palette.color.darker

                        NoPreference ->
                            Palette.color.neutral
            in
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Background.color backgroundColor
                , Element.centerX
                , Element.htmlAttribute (Attr.class "menu")
                ]
                [ homeLink
                , Element.column
                    [ Element.Region.navigation
                    , Element.centerX
                    , Element.padding 15
                    , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                    , Element.Border.color Palette.color.dark
                    ]
                    (folders |> Set.toList |> List.map navLink)
                , Element.column
                    [ Element.Region.navigation
                    , Element.centerX
                    , Element.padding 15
                    ]
                    [ Element.newTabLink
                        [ Element.width Element.fill
                        , Element.paddingXY 25 15
                        , Font.size (Palette.scaled 2)
                        , Font.center
                        ]
                        { url = "https://instagram.com/tennety.art"
                        , label = Element.row [ Element.centerX ] [ Element.html Icons.instagram, Element.text " instagram" ]
                        }
                    , Element.newTabLink
                        [ Element.width Element.fill
                        , Element.paddingXY 25 15
                        , Font.size (Palette.scaled 2)
                        , Font.center
                        ]
                        { url = "https://shop.tennety.art"
                        , label = Element.row [ Element.centerX ] [ Element.html Icons.shoppingBag, Element.text " shop" ]
                        }
                    ]
                ]


menuButton : (Msg -> msg) -> MenuState -> Element msg
menuButton msgMap state =
    let
        icon =
            case state of
                Open ->
                    Icons.close

                Closed ->
                    Icons.menu
    in
    Input.button
        [ Element.padding 10
        , Element.htmlAttribute (Attr.title "menu")
        , Element.htmlAttribute (Attr.attribute "aria-label" "menu")
        ]
        { onPress = Just (msgMap MenuToggled)
        , label = Element.html icon
        }


colorSchemeToggle : (Msg -> msg) -> ColorScheme -> Element msg
colorSchemeToggle msgMap scheme =
    let
        icon =
            case scheme of
                Light ->
                    Icons.moon

                Dark ->
                    Icons.sun

                NoPreference ->
                    Icons.sun
    in
    Input.button
        [ Element.padding 10
        , Element.alignRight
        ]
        { onPress = Just (msgMap ColorSchemeToggled)
        , label = Element.html icon
        }


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    let
        ( fontColor, backgroundColor, bodyClass ) =
            case model.colorScheme of
                Light ->
                    ( Palette.color.darkest, Palette.fromElmColor Color.white, "light" )

                Dark ->
                    ( Palette.color.lightest, Palette.color.darker, "dark" )

                NoPreference ->
                    ( Palette.color.neutral, Palette.color.neutral, "" )
    in
    { body =
        pageView.body
            |> Element.layout
                [ Element.width Element.fill
                , Element.htmlAttribute (Attr.class bodyClass)
                , Font.color fontColor
                , Element.Background.color backgroundColor
                , Font.size 20
                , Font.family [ Font.typeface "Yrsa" ]
                , Element.inFront (nav model page sharedData)
                , Element.inFront (menuButton toMsg model.menuState)
                , Element.inFront (colorSchemeToggle toMsg model.colorScheme)
                ]
    , title = pageView.title
    }
