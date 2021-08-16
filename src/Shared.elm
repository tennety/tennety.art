module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import DataSource
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)
import Element exposing (Element)
import Element.Border
import Element.Font as Font
import Element.Input as Input
import Element.Region
import Palette
import Icons


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

type SharedMsg
    = NoOp

type alias Folder =
    { name: String
    , path: String
    }

type alias Data =
    List Folder


type MenuState
    = Open
    | Closed

type alias Model =
    { menuState : MenuState
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
    ( { menuState = Open }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | menuState = Closed }, Cmd.none )

        MenuToggled -> 
            ( { model | menuState = toggleMenu model.menuState }, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    DataSource.succeed
        [ { name = "folder1", path = "/folder1" }
        , { name = "folder2", path = "/folder2" }
        ]
        
toggleMenu : MenuState -> MenuState
toggleMenu state =
    case state of
        Open ->
            Closed

        Closed ->
            Open

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


nav : MenuState -> Data -> Element msg
nav menuState folders =
    case menuState of
        Open ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
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
                    (List.map (.name >> Element.text) folders)
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
        Closed ->
            Element.none

menuButton : (Msg -> msg) -> MenuState -> Element msg
menuButton toMsg state =
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
        { onPress = Just (toMsg MenuToggled)
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
    { body =  pageView.body
                |> Element.layout
                    [ Element.width Element.fill
                    , Font.size 20
                    , Font.family [ Font.typeface "Yrsa" ]
                    , Element.inFront (nav model.menuState sharedData)
                    , Element.inFront (menuButton toMsg model.menuState)
                    ]
    , title = pageView.title
    }
