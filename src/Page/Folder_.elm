module Page.Folder_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Element exposing (Element)
import Element.Font
import Element.Region exposing (description)
import Head
import Head.Seo as Seo
import Html.Attributes as Attr
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Set
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { folder : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    (Glob.succeed Basics.identity
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal "/")
        |> Glob.match Glob.wildcard
        |> Glob.toDataSource
    )
        |> DataSource.map Set.fromList
        |> DataSource.map Set.toList
        |> DataSource.map (List.map RouteParams)


data : RouteParams -> DataSource Data
data routeParams =
    fileList routeParams
        |> DataSource.map
            (List.map
                (DataSource.File.onlyFrontmatter postFrontmatterDecoder)
            )
        |> DataSource.resolve


fileList : RouteParams -> DataSource (List String)
fileList routeParams =
    Glob.succeed Basics.identity
        |> Glob.match (Glob.literal "content/")
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal routeParams.folder)
        |> Glob.match (Glob.literal "/")
        |> Glob.match Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


type alias Preview =
    { thumb : String
    , description : String
    , published : String
    }


type alias Data =
    List Preview


postFrontmatterDecoder : Decoder Preview
postFrontmatterDecoder =
    Decode.map3 Preview
        (Decode.field "thumb" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "published" Decode.string)


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


title : RouteParams -> Element msg
title route =
    [ Element.text route.folder ]
        |> Element.paragraph
            [ Element.Font.size 36
            , Element.Font.center
            , Element.Font.family [ Element.Font.typeface "IM Fell English" ]
            , Element.Font.semiBold
            , Element.padding 16
            ]


postThumb : Preview -> Element Msg
postThumb metadata =
    Element.image
        [ Element.width (Element.px 150)
        , Element.height (Element.px 150)
        , Element.htmlAttribute (Attr.class "image-preview")
        ]
        { src = metadata.thumb, description = metadata.description }


linkToPost : String -> Element msg -> Element msg
linkToPost postPath content =
    Element.link [ Element.centerX, Element.width Element.fill ]
        { url = postPath, label = content }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.routeParams.folder
    , body =
        Element.column
            [ Element.padding 20
            , Element.centerX
            ]
            [ Element.column
                [ Element.spacing 20 ]
                [ title static.routeParams
                , Element.wrappedRow
                    [ Element.spacing 40 ]
                    (static.data |> List.map (postThumb >> linkToPost "/"))
                ]
            ]
    }
