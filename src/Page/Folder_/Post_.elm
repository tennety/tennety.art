module Page.Folder_.Post_ exposing (Data, Model, Msg, page)

import AssetPath exposing (..)
import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Date
import Element exposing (Element)
import Element.Font as Font
import Element.Region
import Head
import Head.Seo as Seo
import Html exposing (a)
import Html.Attributes as Attr
import List.NonEmpty exposing (NonEmpty)
import List.NonEmpty.Zipper exposing (Zipper)
import Markdown.Parser
import Markdown.Renderer
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Palette
import Path exposing (Path)
import Shared
import View exposing (View)


type alias Model =
    { book : Zipper (AssetPath ImagePath)
    }


type Msg
    = Next
    | Previous
    | First
    | Last


type alias RouteParams =
    { folder : String, post : String }


init : Maybe PageUrl -> Shared.Model -> StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init maybePageUrl sharedModel static =
    ( { book = List.NonEmpty.Zipper.fromNonEmpty static.data.images }, Cmd.none )


update : PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg )
update pageUrl navigationKey sharedModel static msg model =
    case msg of
        Next ->
            ( { model | book = List.NonEmpty.Zipper.attemptNext model.book }, Cmd.none )

        Previous ->
            ( { model | book = List.NonEmpty.Zipper.attemptPrev model.book }, Cmd.none )

        First ->
            ( { model | book = List.NonEmpty.Zipper.start model.book }, Cmd.none )

        Last ->
            ( { model | book = List.NonEmpty.Zipper.end model.book }, Cmd.none )


subscriptions : Maybe PageUrl -> RouteParams -> Path.Path -> Model -> Sub Msg
subscriptions maybePageUrl routeParams path model =
    Sub.none


page : PageWithState RouteParams Data Model Msg
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildWithLocalState { init = init, update = update, subscriptions = subscriptions, view = view }


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
    imageList routeParams
        |> DataSource.andThen
            (\folderImages ->
                file routeParams
                    |> DataSource.andThen
                        (\(AssetPath path) ->
                            DataSource.File.bodyWithFrontmatter (postDecoder folderImages) path
                        )
            )


file : RouteParams -> DataSource (AssetPath FilePath)
file routeParams =
    Glob.succeed AssetPath
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/")
        |> Glob.match (Glob.literal routeParams.folder)
        |> Glob.match (Glob.literal "/")
        |> Glob.match (Glob.literal routeParams.post)
        |> Glob.match (Glob.literal ".md")
        |> Glob.expectUniqueMatch


imageList : RouteParams -> DataSource (List (AssetPath ImagePath))
imageList routeParams =
    Glob.succeed (\thumbPath -> thumbPath |> String.replace "public/" "" |> AssetPath)
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "public/images/")
        |> Glob.match (Glob.literal routeParams.folder)
        |> Glob.match (Glob.literal "/")
        |> Glob.match Glob.wildcard
        |> Glob.toDataSource


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
    { body : List (Element Msg)
    , postType : String
    , title : String
    , author : String
    , images : NonEmpty (AssetPath ImagePath)
    , description : String
    , published : Date.Date
    , shopLink : Maybe String
    }


postDecoder : List (AssetPath ImagePath) -> String -> Decoder Data
postDecoder imagePathList body =
    Decode.map7 (Data (processMarkDown body))
        -- TODO: support single and multiple
        (Decode.field "type" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "author" Decode.string)
        (Decode.field "images"
            (Decode.list Decode.string
                |> Decode.map (List.map AssetPath)
                |> Decode.andThen
                    (\assetPaths ->
                        if List.all (\aPath -> List.member aPath imagePathList) assetPaths then
                            Decode.succeed assetPaths

                        else
                            Decode.fail "image not found"
                    )
                |> Decode.map fromData
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
        (Decode.field "shop-link" Decode.string |> Decode.maybe)


processMarkDown : String -> List (Element Msg)
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
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
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
            , shopLink static.data.shopLink
            , heroImage (List.NonEmpty.Zipper.current model.book) static.data.description
            , Element.paragraph
                [ Element.width (Element.fill |> Element.maximum 800)
                , Element.htmlAttribute (Attr.class "content")
                ]
                static.data.body
            ]
    }


heroImage : AssetPath a -> String -> Element msg
heroImage assetPath staticDataDescription =
    let
        (AssetPath imagePath) =
            assetPath
    in
    Element.image
        [ Element.width Element.fill
        , Element.htmlAttribute (Attr.class "hero-image")
        , Element.centerX
        ]
        { src = "/" ++ imagePath
        , description = staticDataDescription
        }



-- Jeroen said I could: https://jfmengels.net/safe-unsafe-operations-in-elm/


fromData : List a -> NonEmpty a
fromData list =
    case list of
        h :: xs ->
            List.NonEmpty.fromCons h xs

        [] ->
            fromData list
