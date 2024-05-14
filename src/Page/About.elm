module Page.About exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Element exposing (Element)
import Element.Font as Font
import Element.Region
import Head
import Head.Seo as Seo
import Html.Attributes as Attr
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Palette
import Path
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
    ()


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "tennety.art"
        , image =
            { url = "images/author/tennety.jpeg" |> Path.fromString |> Pages.Url.fromPath
            , alt = "artist photo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "about the artist"
        , locale = Nothing
        , title = "About the Artist"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "about the artist"
    , body =
        Element.column
            [ Element.spacing 70
            , Element.Region.mainContent
            , Element.centerX
            , Font.center
            ]
            [ Palette.blogHeading "about the artist"
            , Element.image
                [ Element.width (Element.px 175)
                , Element.htmlAttribute (Attr.class "avatar")
                , Element.centerX
                ]
                { src = "images/author/tennety.jpeg"
                , description = "Chandu Tennety"
                }
            , Element.paragraph
                [ Element.width (Element.fill |> Element.maximum 500)
                , Element.spacing (Palette.scaled 1)
                , Element.htmlAttribute (Attr.class "content")
                , Font.size (Palette.scaled 2)
                ]
                [ Element.text "Chandu Tennety" |> Element.el [ Font.bold ]
                , Element.text " is a self-taught artist and has been drawing for as long as he can remember. He lives in Ohio with his musician spouse and daughter (an artist in her own right) and loves to linger in the spaces between reality and metaphor."
                ]
            ]
    }
