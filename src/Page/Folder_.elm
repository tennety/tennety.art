module Page.Folder_ exposing (Data, Model, Msg, page)

import AssetPath exposing (AssetPath(..), FilePath, ImagePath)
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date
import Element exposing (Element)
import Element.Font
import Head
import Head.Seo as Seo
import Html.Attributes as Attr
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path exposing (Path)
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
    thumbList
        |> DataSource.andThen
            (\allThumbs ->
                fileList routeParams
                    |> DataSource.map
                        (List.map
                            (\{ path, slug } ->
                                let
                                    (AssetPath pathName) =
                                        path
                                in
                                DataSource.File.onlyFrontmatter (postFrontmatterDecoder slug allThumbs) pathName
                            )
                        )
            )
        |> DataSource.resolve
        |> DataSource.map (List.sortWith publishDateDesc)


fileList : RouteParams -> DataSource (List PathWithSlug)
fileList routeParams =
    Glob.succeed (\path slug -> PathWithSlug (AssetPath path) slug)
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.match (Glob.literal routeParams.folder)
        |> Glob.match (Glob.literal "/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


thumbList : DataSource (List (AssetPath ImagePath))
thumbList =
    Glob.succeed (\thumbPath -> thumbPath |> String.replace "public/" "" |> AssetPath)
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "public/images/")
        |> Glob.match Glob.wildcard
        |> Glob.match (Glob.literal "/")
        |> Glob.match Glob.wildcard
        |> Glob.toDataSource


type alias PathWithSlug =
    { path : AssetPath FilePath
    , slug : String
    }


type alias Preview =
    { name : String
    , thumb : AssetPath ImagePath
    , description : String
    , published : Date.Date
    }


type alias Data =
    List Preview


publishDateDesc : Preview -> Preview -> Order
publishDateDesc metadata1 metadata2 =
    Date.compare metadata2.published metadata1.published


postFrontmatterDecoder : String -> List (AssetPath ImagePath) -> Decoder Preview
postFrontmatterDecoder name allThumbs =
    Decode.map3 (Preview name)
        (Decode.field "thumb"
            (Decode.string
                |> Decode.map AssetPath
                |> Decode.andThen
                    (\assetPath ->
                        if List.member assetPath allThumbs then
                            Decode.succeed assetPath

                        else
                            Decode.fail "thumbnail not found"
                    )
            )
        )
        (Decode.field "description" Decode.string)
        (Decode.field "published"
            (Decode.string
                |> Decode.andThen
                    (\isoString ->
                        case Date.fromIsoString isoString of
                            Ok date ->
                                Decode.succeed date

                            Err error ->
                                Decode.fail error
                    )
            )
        )


seoImage : String -> Maybe Preview -> Seo.Image
seoImage folder maybeMetadata =
    let
        url =
            case maybeMetadata of
                Just preview ->
                    let
                        (AssetPath thumb) =
                            preview.thumb
                    in
                    thumb

                Nothing ->
                    "images/index-covers/hummer-swing-bw.png"
    in
    { url = url |> Path.fromString |> Pages.Url.fromPath
    , alt = folder
    , dimensions = Nothing
    , mimeType = Nothing
    }


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "tennety.art"
        , image = seoImage static.routeParams.folder (List.head static.data)
        , description = static.routeParams.folder
        , locale = Nothing
        , title = static.routeParams.folder
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


postThumb : Path -> Preview -> Element Msg
postThumb path metadata =
    let
        (AssetPath thumbPath) =
            metadata.thumb

        url slug =
            path |> Path.toSegments |> (\l -> l ++ [ slug ]) |> Path.join |> Path.toAbsolute

        content =
            Element.image
                [ Element.width (Element.px 150)
                , Element.height (Element.px 150)
                , Element.htmlAttribute (Attr.class "image-preview")
                ]
                { src = thumbPath, description = metadata.description }
    in
    Element.link [ Element.centerX, Element.width Element.fill ]
        { url = url metadata.name, label = content }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.routeParams.folder
    , body =
        Element.column
            [ Element.spacing 40 ]
            [ title static.routeParams
            , Element.wrappedRow
                [ Element.spacing 80
                ]
                (static.data |> List.map (postThumb static.path))
            ]
    }
