module Metadata exposing (ArticleMetadata, IndexMetadata, Metadata(..), PageMetadata, PreviewType(..), decoder)

import Data.Author
import Date exposing (Date)
import Dict exposing (Dict)
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath exposing (PagePath)


type Metadata
    = Page PageMetadata
    | Article ArticleMetadata
    | Author Data.Author.Author
    | BlogIndex IndexMetadata


type PreviewType
    = Summary
    | Image


type alias ArticleMetadata =
    { title : String
    , description : String
    , published : Date
    , author : Data.Author.Author
    , image : ImagePath Pages.PathKey
    , thumb : ImagePath Pages.PathKey
    , draft : Bool
    , shopLink : Maybe (PagePath Pages.PathKey)
    }


type alias PageMetadata =
    { title : String
    , image : ImagePath Pages.PathKey
    }


type alias IndexMetadata =
    { title : String
    , previewType : PreviewType
    }


decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "page" ->
                        Decode.map2 PageMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "image" imageDecoder)
                            |> Decode.map Page

                    "blog-index" ->
                        Decode.map2 IndexMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "previewType"
                                Decode.string
                                |> Decode.maybe
                                |> Decode.map (Maybe.withDefault "summary")
                                |> Decode.andThen
                                    (\previewType ->
                                        if previewType == "image" then
                                            Decode.succeed Image

                                        else
                                            Decode.succeed Summary
                                    )
                            )
                            |> Decode.map BlogIndex

                    "author" ->
                        Decode.field "name" Data.Author.decoder |> Decode.map Author

                    "blog" ->
                        Decode.map8 ArticleMetadata
                            (Decode.field "title" Decode.string)
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
                            (Decode.field "author" Data.Author.decoder)
                            (Decode.field "image" imageDecoder)
                            (Decode.field "thumb" imageDecoder)
                            (Decode.field "draft" Decode.bool
                                |> Decode.maybe
                                |> Decode.map (Maybe.withDefault False)
                            )
                            (Decode.field "shop-link" shopLinkDecoder
                                |> Decode.maybe
                            )
                            |> Decode.map Article

                    _ ->
                        Decode.fail <| "Unexpected page type " ++ pageType
            )


imageDecoder : Decoder (ImagePath Pages.PathKey)
imageDecoder =
    Decode.string
        |> Decode.andThen
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        Decode.fail "Couldn't find image."

                    Just imagePath ->
                        Decode.succeed imagePath
            )


shopLinkDecoder : Decoder (PagePath Pages.PathKey)
shopLinkDecoder =
    Decode.string
        |> Decode.map Pages.PagePath.external


findMatchingImage : String -> Maybe (ImagePath Pages.PathKey)
findMatchingImage imageAssetPath =
    Pages.allImages
        |> List.Extra.find
            (\image ->
                ImagePath.toString image
                    == imageAssetPath
            )
