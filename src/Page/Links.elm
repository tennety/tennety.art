module Page.Links exposing (Data, Model, Msg, page)

import Browser.Dom exposing (Element)
import DataSource exposing (DataSource)
import Element exposing (Color, Element)
import Element.Border
import Element.Font
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Icons
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


type alias Data =
    List Link


type alias Link =
    { name : String
    , icon : Html Never
    , href : String
    }


data : DataSource Data
data =
    DataSource.succeed
        [ { name = "WTF bird sticker", icon = Icons.coffee, href = "https://ko-fi.com/s/75c2e18f62" }
        , { name = "Read a free comic", icon = Icons.bookOpen, href = "https://ko-fi.com/album/The-Marionette-P5P0G3Z7F" }
        , { name = "Buy me a tea", icon = Icons.coffee, href = "https://ko-fi.com/tennetyart" }
        , { name = "Commission me", icon = Icons.pencil, href = "https://ko-fi.com/tennetyart/commissions" }
        , { name = "Website", icon = Icons.externalLink, href = "https://tennety.art" }
        , { name = "Instagram", icon = Icons.instagram, href = "https://instagram.com/tennety.art" }
        ]


title : String -> Element msg
title staticTitle =
    [ Element.text staticTitle ]
        |> Element.paragraph
            [ Element.Font.size 36
            , Element.Font.center
            , Element.Font.family [ Element.Font.typeface "IM Fell English" ]
            , Element.Font.semiBold
            , Element.padding 16
            ]


linky : Color -> Link -> Element Never
linky shadowColor link =
    Element.newTabLink
        [ Element.Border.shadow { offset = ( 0, 1 ), size = 1.0, blur = 5.0, color = shadowColor }
        , Element.Border.rounded 4
        , Element.Border.width 1
        , Element.centerX
        , Element.padding 10
        , Element.mouseOver
            [ Element.Border.shadow { offset = ( 0, 0 ), size = 0.0, blur = 3.0, color = shadowColor }
            ]
        ]
        { url = link.href, label = Element.row [ Element.spaceEvenly ] [ Element.html link.icon, Element.text (" " ++ link.name) ] }


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "links"
    , body =
        Element.column
            [ Element.spacing 40 ]
            [ title "links"
            , Element.column
                [ Element.spacing 80 ]
                (static.data |> List.map (linky (sharedModel |> Shared.colorValues |> .borders)))
            ]
    }
