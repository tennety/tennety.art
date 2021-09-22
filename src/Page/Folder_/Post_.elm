module Page.Folder_.Post_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date
import Head
import Head.Seo as Seo
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Page.Folder_ exposing (PathWithSlug)
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
            (\{ path, slug } -> DataSource.File.bodyWithFrontmatter postDecoder path)


file : RouteParams -> DataSource PathWithSlug
file routeParams =
    Glob.succeed PathWithSlug
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.match (Glob.literal routeParams.folder)
        |> Glob.match (Glob.literal "/")
        |> Glob.capture (Glob.literal routeParams.post)
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
    { body : String
    , postType : String
    , title : String
    , author : String
    , image : String
    , published : Date.Date
    }


postDecoder : String -> Decoder Data
postDecoder body =
    Decode.map5 (Data body)
        (Decode.field "type" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "author" Decode.string)
        -- TODO: match against Glob in images
        (Decode.field "image" Decode.string)
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


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    let
        _ =
            Debug.log "data" static.data
    in
    View.placeholder "Folder_.Post_"
