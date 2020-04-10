module Index exposing (view)

import Data.Author
import Date
import Element exposing (Element)
import Element.Border
import Element.Font
import Html.Attributes as Attr
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.ImagePath as ImagePath
import Pages.Platform exposing (Page)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> PagePath Pages.PathKey
    -> Metadata.IndexMetadata
    -> Element msg
view posts currentPagePath indexMetadata =
    let
        entries =
            posts
                |> List.filterMap
                    (\( path, metadata ) ->
                        case metadata of
                            Metadata.Page meta ->
                                Nothing

                            Metadata.Author _ ->
                                Nothing

                            Metadata.Article meta ->
                                if meta.draft then
                                    Nothing

                                else
                                    if (shareDirectory path currentPagePath) then
                                        Just ( path, meta )
                                    else
                                        Nothing

                            Metadata.BlogIndex _ ->
                                Nothing
                    )
    in
        case indexMetadata.previewType of
            Metadata.Image ->
                Element.column
                    [ Element.spacing 20 ]
                    [ title indexMetadata.title
                    , Element.wrappedRow
                        [ Element.spacing 40
                        , Element.alignLeft
                        , Element.width (Element.fill |> Element.maximum 600)
                        ]
                        (entries |> List.map imageSummary)
                    ]

            Metadata.Summary ->
                Element.column [ Element.spacing 20 ] (entries |> List.map postSummary)


postSummary :
    ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> Element msg
postSummary ( postPath, post ) =
    articleIndex post
        |> linkToPost postPath


imageSummary :
    ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> Element msg
imageSummary ( postPath, post ) =
    imageIndex post
        |> linkToPost postPath


linkToPost : PagePath Pages.PathKey -> Element msg -> Element msg
linkToPost postPath content =
    Element.link []
        { url = PagePath.toString postPath, label = content }


title : String -> Element msg
title text =
    [ Element.text text ]
        |> Element.paragraph
            [ Element.Font.size 36
            , Element.Font.center
            , Element.Font.family [ Element.Font.typeface "IM Fell English" ]
            , Element.Font.semiBold
            , Element.padding 16
            ]


articleIndex : Metadata.ArticleMetadata -> Element msg
articleIndex metadata =
    Element.el
        [ Element.centerX
        , Element.width (Element.maximum 800 Element.fill)
        , Element.padding 40
        , Element.spacing 10
        , Element.Border.width 1
        , Element.Border.color (Element.rgba255 0 0 0 0.1)
        , Element.mouseOver
            [ Element.Border.color (Element.rgba255 0 0 0 1)
            ]
        ]
        (postPreview metadata)


imageIndex : Metadata.ArticleMetadata -> Element msg
imageIndex metadata =
    Element.image
        [ Element.width (Element.px 150)
        , Element.height (Element.px 150)
        , Element.htmlAttribute (Attr.class "image-preview")
        ]
        { src = ImagePath.toString metadata.thumb, description = metadata.description }


readMoreLink =
    Element.text "Continue reading >>"
        |> Element.el
            [ Element.centerX
            , Element.Font.size 18
            , Element.alpha 0.6
            , Element.mouseOver [ Element.alpha 1 ]
            , Element.Font.underline
            , Element.Font.center
            ]


postPreview : Metadata.ArticleMetadata -> Element msg
postPreview post =
    Element.textColumn
        [ Element.centerX
        , Element.width Element.fill
        , Element.spacing 30
        , Element.Font.size 18
        ]
        [ title post.title
        , Element.row [ Element.spacing 10, Element.centerX ]
            [ Data.Author.view [ Element.width (Element.px 40) ] post.author
            , Element.text post.author.name
            , Element.text "•"
            , Element.text (post.published |> Date.format "MMMM ddd, yyyy")
            ]
        , post.description
            |> Element.text
            |> List.singleton
            |> Element.paragraph
                [ Element.Font.size 22
                , Element.Font.center
                , Element.Font.family [ Element.Font.typeface "Yrsa" ]
                ]
        , readMoreLink
        ]


-- UTILITIES

pathList : PagePath Pages.PathKey -> List String
pathList rawPath =
    rawPath |> PagePath.toString |> String.split "/"


shareDirectory : PagePath Pages.PathKey -> PagePath Pages.PathKey -> Bool
shareDirectory pagePath otherPagePath =
    List.map2 Tuple.pair (pathList pagePath) (pathList otherPagePath)
    |> not << List.any (\(a, b) -> a /= b)
