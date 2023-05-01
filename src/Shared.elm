module Shared exposing (Data, Model, Msg(..), SharedMsg(..), colorValues, homeLink, template)

import Browser.Navigation
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
import Palette exposing (ColorPreference(..))
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
    , colorPreference : ColorPreference
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
                    Decode.decodeValue colorPreferenceDecoder val

                PreRenderFlags ->
                    Ok Dark

        colorScheme =
            case decodeResult of
                Ok pref ->
                    pref

                Err _ ->
                    Dark
    in
    ( { menuState = Closed, colorPreference = colorScheme }
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
            ( { model | colorPreference = toggleScheme model.colorPreference }, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    (Glob.succeed Basics.identity
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.oneOf ( ( "md", () ), [ ( "/", () ) ] ))
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


toggleScheme : ColorPreference -> ColorPreference
toggleScheme scheme =
    case scheme of
        Light ->
            Dark

        Dark ->
            Light


colorPreferenceDecoder : Decoder ColorPreference
colorPreferenceDecoder =
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


colorValues model =
    Palette.colorScheme model.colorPreference


homeLink model =
    Element.link
        [ Element.centerX
        , Element.paddingEach { bottom = 10, left = 10, right = 10, top = 0 }
        , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Element.Border.color (model |> colorValues |> .borders)
        ]
        { url = "/"
        , label = Palette.blogHeading "tennety.art"
        }


navLink folderName =
    let
        folderNameNoTrailingPeriod =
            String.replace "." "" folderName

        url =
            Route.Folder_ { folder = folderNameNoTrailingPeriod } |> Route.routeToPath |> Path.join |> Path.toAbsolute
    in
    Element.link
        [ Element.width Element.fill
        , Element.paddingXY 25 15
        , Font.size (Palette.scaled 2)
        , Font.center
        ]
        { url = url, label = folderNameNoTrailingPeriod |> Element.text }


nav : Model -> Page -> Data -> Element msg
nav model page folders =
    case model.menuState of
        Closed ->
            Element.none

        Open ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Background.color (model |> colorValues |> .backgroundColor)
                , Element.centerX
                , Element.htmlAttribute (Attr.class "menu")
                , Element.paddingXY 70 65
                ]
                [ homeLink model
                , Element.column
                    [ Element.Region.navigation
                    , Element.centerX
                    , Element.padding 15
                    , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                    , Element.Border.color (model |> colorValues |> .borders)
                    ]
                    (folders |> Set.toList |> List.map navLink)
                ]


menuButton : (Msg -> msg) -> Model -> Element msg
menuButton msgMap model =
    let
        icon =
            case model.menuState of
                Open ->
                    Icons.close

                Closed ->
                    Icons.menu

        size =
            Palette.scaled 3
    in
    Element.el
        [ Element.padding (Palette.scaled 2)
        , Element.alignLeft
        ]
        (Input.button
            [ Element.Border.rounded (size // 2)
            , Element.focused [ Element.Border.glow (model |> colorValues |> .borders) 1 ]
            , Element.Region.description "menu button"
            , Element.htmlAttribute (Attr.title "menu")
            , Element.htmlAttribute (Attr.attribute "aria-label" "menu")
            ]
            { onPress = Just (msgMap MenuToggled)
            , label = Element.el [ Element.centerX, Element.centerY, Element.height (Element.px size), Element.width (Element.px size), Font.color (model |> colorValues |> .foregroundColor) ] (Element.html icon)
            }
        )


colorSchemeToggle : (Msg -> msg) -> Model -> Element msg
colorSchemeToggle msgMap model =
    let
        ( icon, desc ) =
            case model.colorPreference of
                Light ->
                    ( Icons.moon, "dark" )

                Dark ->
                    ( Icons.sun, "light" )

        size =
            Palette.scaled 3
    in
    Element.el
        [ Element.padding (Palette.scaled 2)
        , Element.alignRight
        , Element.alpha 0.4
        ]
        (Input.button
            [ Element.Border.rounded (size // 2)
            , Element.focused [ Element.Border.glow (model |> colorValues |> .borders) 1 ]
            , Element.Region.description ("change colorscheme to " ++ desc)
            , Element.htmlAttribute (Attr.title "colorscheme toggle")
            , Element.htmlAttribute (Attr.attribute "aria-label" "colorscheme toggle")
            ]
            { onPress = Just (msgMap ColorSchemeToggled)
            , label = Element.el [ Element.height (Element.px size), Element.width (Element.px size), Font.color (model |> colorValues |> .foregroundColor) ] (Element.html icon)
            }
        )


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
    { body =
        [ pageView.body ]
            |> Element.column
                [ Element.padding 40
                , Element.centerX
                ]
            |> Element.layout
                [ Element.width Element.fill
                , Element.htmlAttribute (Attr.class (model |> colorValues |> .bodyClass))
                , Font.color (model |> colorValues |> .foregroundColor)
                , Element.Background.color (model |> colorValues |> .backgroundColor)
                , Element.padding (Palette.scaled 2)
                , Font.size (Palette.scaled 1)
                , Font.family [ Font.typeface "Yrsa" ]
                , Font.extraLight
                , Element.inFront (nav model page sharedData)
                , Element.inFront (menuButton toMsg model)
                , Element.inFront (colorSchemeToggle toMsg model)
                ]
    , title = pageView.title
    }
