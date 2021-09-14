module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Element exposing (Element)
import Element.Background
import Element.Region
import Head
import Head.Seo as Seo
import Html.Attributes as Attr
import Page exposing (Page, StaticPayload)
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


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


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


type alias Data =
    ()


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = ""
    , body =
        Element.column
            [ Element.Background.color (sharedModel |> Shared.colorValues |> .backgroundColor)
            , Element.Region.mainContent
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
            , Element.none
            ]
    }
