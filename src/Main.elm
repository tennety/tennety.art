module Main exposing (main)

import Color
import Data.Author as Author
import Date
import DocumentSvg
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Input as Input
import Element.Region
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Icons
import Index
import Json.Decode
import Markdown
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Directory as Directory exposing (Directory)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Palette


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "tennety.art - Chandu Tennety's Art Portfolio"
    , iarcRatingId = Nothing
    , name = "tennety.art"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "tennety.art"
    , sourceIcon = images.iconPng
    }


type alias Rendered =
    Element Msg


type MenuState
    = Open
    | Closed

-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


main : Pages.Platform.Program Model Msg Metadata Rendered
main =
    Pages.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , head = head
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        }


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata Rendered )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                Html.div [] [ Markdown.toHtml [] markdownBody ]
                    |> Element.html
                    |> List.singleton
                    |> Element.paragraph [ Element.width Element.fill ]
                    |> Ok
        }


type alias Model =
    {  menuState: MenuState }


init : ( Model, Cmd Msg )
init =
    ( { menuState = Closed }, Cmd.none )


type Msg =
    ToggleMenu


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleMenu ->
            ({ model | menuState = toggleMenu model.menuState }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Html Msg }
view model siteMetadata page =
    let
        { title, body } =
            pageView model siteMetadata page
    in
    { title = title
    , body =
        body |>
            Element.layout
                [ Element.width Element.fill
                , Font.size 20
                , Font.family [ Font.typeface "Yrsa" ]
                , Font.color (Element.rgba255 0 0 0 0.8)
                , Element.inFront ( nav model.menuState page.path )
                , Element.inFront ( menuButton model.menuState )
                ]
    }


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Element Msg }
pageView model siteMetadata page =
    case page.metadata of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                [ Element.column
                    [ Element.Region.mainContent
                    , Element.centerX
                    ]
                    [ homeLink
                    , pageImageView metadata.image
                    , page.view
                    ]
                ]
                    |> Element.row [ Element.width Element.fill ]
            }

        Metadata.Article metadata ->
            { title = metadata.title
            , body =
                Element.row [ Element.width Element.fill ]
                    [ Element.column
                        [ Element.padding 30
                        , Element.spacing 40
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        ]
                        (Element.column [ Element.spacing 10 ]
                            [ Element.row [ Element.spacing 10 ]
                                [ Author.view [] metadata.author
                                , Element.column [ Element.spacing 10, Element.width Element.fill ]
                                    [ Element.paragraph [ Font.bold, Font.size 24 ]
                                        [ Element.text metadata.author.name
                                        ]
                                    , Element.paragraph [ Font.size 16 ]
                                        [ Element.text metadata.author.bio ]
                                    ]
                                ]
                            ]
                            :: (publishedDateView metadata |> Element.el [ Font.size 16, Font.color (Element.rgba255 0 0 0 0.6) ])
                            :: Palette.blogHeading metadata.title
                            :: articleImageView metadata.image
                            :: [ page.view ]
                        )
                    ]
            }

        Metadata.Author author ->
            { title = author.name
            , body =
                Element.row
                    [ Element.width Element.fill
                    ]
                    [ Element.column
                        [ Element.padding 30
                        , Element.spacing 20
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        ]
                        [ Palette.blogHeading author.name
                        , Author.view [] author
                        , Element.paragraph [ Element.centerX, Font.center ] [ page.view ]
                        ]
                    ]
            }

        Metadata.BlogIndex indexMetadata ->
            { title = indexMetadata.title ++ " - tennety.art"
            , body =
                Element.row [ Element.width Element.fill ]
                    [ Element.column
                        [ Element.padding 20, Element.centerX ]
                        [ Index.view siteMetadata page.path indexMetadata ]
                    ]
            }


articleImageView : ImagePath Pages.PathKey -> Element msg
articleImageView articleImage =
    Element.image
        [ Element.width Element.fill ]
        { src = ImagePath.toString articleImage
        , description = "Article cover photo"
        }


pageImageView : ImagePath Pages.PathKey -> Element msg
pageImageView articleImage =
    Element.image
        [ Element.width Element.fill
        , Element.htmlAttribute ( Attr.class "hero-image" )
        ]
        { src = ImagePath.toString articleImage
        , description = "Article cover photo"
        }


nav : MenuState -> PagePath Pages.PathKey -> Element Msg
nav menuState currentPath =
    case menuState of
        Open ->
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Background.color (Element.rgba255 255 255 255 1)
                , Element.centerX
                , Element.htmlAttribute (Attr.class "menu")
                ]
                [ homeLink
                , Element.column
                    [ Element.Region.navigation
                    , Element.centerX
                    , Element.padding 15
                    ]
                    [ highlightableLink currentPath pages.comics.directory "comics"
                    , highlightableLink currentPath pages.illustration.directory "illustration"
                    , Element.newTabLink
                        [ Element.width Element.fill
                        , Element.paddingXY 25 15
                        , Font.size (Palette.scaled 2)
                        , Font.center
                        ]
                        { url = "https://instagram.com/tennety.art"
                        , label = Element.row [] [ Element.html Icons.instagram, Element.text " instagram" ]
                        }
                    ]
                ]
        Closed ->
            Element.none


toggleMenu : MenuState -> MenuState
toggleMenu state =
    case state of
        Open -> Closed
        Closed -> Open


menuButton : MenuState -> Element Msg
menuButton state =
    let
        icon =
            case state of
                Open -> Icons.close
                Closed -> Icons.menu
    in
        Input.button
            [ Element.padding 10
            , Element.htmlAttribute (Attr.title "menu")
            , Element.htmlAttribute (Attr.attribute "aria-label" "menu")
            ]
            { onPress = Just ToggleMenu
            , label = Element.html icon
            }


homeLink =
  Element.link
    [ Element.centerX
    , Element.padding 10
    , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
    , Element.Border.color (Element.rgba255 100 100 100 0.8)
    ]
    { url = "/"
    , label = Palette.blogHeading "tennety.art"
    }


highlightableLink :
    PagePath Pages.PathKey
    -> Directory Pages.PathKey Directory.WithIndex
    -> String
    -> Element msg
highlightableLink currentPath linkDirectory displayName =
    let
        isHighlighted =
            currentPath |> Directory.includes linkDirectory
        fontStyle =
            if isHighlighted then
                Font.bold
            else
                Font.regular
    in
    Element.link
        ([ Element.width Element.fill
        , Element.paddingXY 25 15
        , Font.size (Palette.scaled 2)
        , Font.center
        ] ++ [fontStyle])
        { url = linkDirectory |> Directory.indexPath |> PagePath.toString
        , label = Element.text displayName
        }


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        Metadata.Page meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "tennety.art"
                , image =
                    { url = images.iconPng
                    , alt = "tennety art hummingbird logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website

        Metadata.Article meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "tennety.art"
                , image =
                    { url = meta.image
                    , alt = meta.description
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.article
                    { tags = []
                    , section = Nothing
                    , publishedTime = Just (Date.toIsoString meta.published)
                    , modifiedTime = Nothing
                    , expirationTime = Nothing
                    }

        Metadata.Author meta ->
            let
                ( firstName, lastName ) =
                    case meta.name |> String.split " " of
                        [ first, last ] ->
                            ( first, last )

                        [ first, middle, last ] ->
                            ( first ++ " " ++ middle, last )

                        [] ->
                            ( "", "" )

                        _ ->
                            ( meta.name, "" )
            in
            Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "tennety.art"
                , image =
                    { url = meta.avatar
                    , alt = meta.name ++ "'s art."
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.bio
                , locale = Nothing
                , title = meta.name ++ "'s art."
                }
                |> Seo.profile
                    { firstName = firstName
                    , lastName = lastName
                    , username = Nothing
                    }

        Metadata.BlogIndex indexMetadata ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "tennety.art"
                , image =
                    { url = images.iconPng
                    , alt = "tennety art hummingbird logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = indexMetadata.title
                }
                |> Seo.website


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://tennety.art/"


siteTagline : String
siteTagline =
    "Chandu Tennety's Art Portfolio"


publishedDateView metadata =
    Element.text
        (metadata.published
            |> Date.format "MMMM ddd, yyyy"
        )
