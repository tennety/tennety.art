module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Element exposing (Element)
import Element.Region
import Head
import Head.Seo as Seo
import Html.Attributes as Attr
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
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


data : DataSource.DataSource Data
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
            { url = "images/index-covers/hummer-swing-bw.png" |> Path.fromString |> Pages.Url.fromPath
            , alt = "hummingbird cover image"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Various pieces and projects I've worked on over the years"
        , locale = Nothing
        , title = "The Art of Chandu Tennety"
        }
        |> Seo.website


type alias Data =
    ()


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "The Art of Chandu Tennety"
    , body =
        Element.column
            [ Element.Region.mainContent
            , Element.centerX
            ]
            [ Shared.homeLink sharedModel
            , Element.image
                [ Element.width Element.fill
                , Element.htmlAttribute (Attr.class "hero-image")
                , Element.centerX
                ]
                { src = "images/index-covers/hummer-swing-bw.png"
                , description = "Article cover photo"
                }
            ]
    }
