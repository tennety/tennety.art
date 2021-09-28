module Page.Folder_.Post_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date
import Element exposing (Element)
import Element.Font as Font
import Element.Region
import Head
import Head.Seo as Seo
import Html.Attributes as Attr
import Markdown.Parser
import Markdown.Renderer
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Palette
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { folder : String, post : String }


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
    Glob.succeed RouteParams
        |> Glob.match (Glob.literal "content/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal "/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


data : RouteParams -> DataSource Data
data routeParams =
    file routeParams
        |> DataSource.andThen
            (\path -> DataSource.File.bodyWithFrontmatter postDecoder path)


file : RouteParams -> DataSource String
file routeParams =
    Glob.succeed Basics.identity
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.match (Glob.literal routeParams.folder)
        |> Glob.match (Glob.literal "/")
        |> Glob.match (Glob.literal routeParams.post)
        |> Glob.match (Glob.literal ".md")
        |> Glob.expectUniqueMatch


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
    { body : List (Element Never)
    , postType : String
    , title : String
    , author : String
    , image : String
    , description : String
    , published : Date.Date
    , shopLink : Maybe String
    }


postDecoder : String -> Decoder Data
postDecoder body =
    Decode.map7 (Data (processMarkDown body))
        -- TODO: support single and multiple
        (Decode.field "type" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "author" Decode.string)
        -- TODO: match against Glob in images
        (Decode.field "image" Decode.string)
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
        (Decode.field "shop-link" Decode.string |> Decode.maybe)


processMarkDown : String -> List (Element Never)
processMarkDown body =
    body
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Markdown error.")
        |> Result.andThen
            (\blocks ->
                Markdown.Renderer.render
                    Markdown.Renderer.defaultHtmlRenderer
                    blocks
            )
        |> Result.map
            (List.map Element.html)
        |> Result.withDefault [ Element.none ]


shopLink maybePath =
    case maybePath of
        Just shopPath ->
            Element.link
                [ Element.width Element.fill
                , Element.paddingXY 25 15
                , Font.center
                ]
                { url = shopPath
                , label = Element.text "Shop prints ≫"
                }

        Nothing ->
            Element.none


publishedDateView publishedDate =
    Element.text
        (publishedDate
            |> Date.format "MMMM ddd, yyyy"
        )


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = String.join " :: " [ static.routeParams.folder, static.routeParams.post ]
    , body =
        Element.column
            [ Element.padding 30
            , Element.spacing 20
            , Element.Region.mainContent
            , Element.centerX
            ]
            [ Palette.blogHeading static.data.title
            , Element.paragraph [ Font.size (Palette.scaled -1), Font.color (sharedModel |> Shared.colorValues |> .foregroundColor), Font.center ] [ publishedDateView static.data.published ]
            , Element.image
                [ Element.width Element.fill
                , Element.htmlAttribute (Attr.class "hero-image")
                , Element.centerX
                ]
                { src = "/" ++ static.data.image
                , description = static.data.description
                }
            , shopLink static.data.shopLink
            , Element.paragraph
                [ Element.width (Element.fill |> Element.maximum 800)
                , Element.htmlAttribute (Attr.class "content")
                ]
                static.data.body
            ]
    }
