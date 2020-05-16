port module Main exposing (main)

import Color
import Data.Author as Author
import Date
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
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Markdown
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Directory as Directory exposing (Directory)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform
import Pages.StaticHttp as StaticHttp
import Palette


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = siteTagline
    , iarcRatingId = Nothing
    , name = siteName
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just siteName
    , sourceIcon = images.iconPng
    }


type alias Rendered =
    Element Msg


type MenuState
    = Open
    | Closed


type ColorScheme
    = Light
    | Dark
    | NoPreference



-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


main : Pages.Platform.Program Model Msg Metadata Rendered
main =
    Pages.Platform.application
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = \_ -> CloseMenu
        , generateFiles = \_ -> []
        , internals = Pages.internals
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
                    |> Element.paragraph [ Element.width (Element.fill |> Element.maximum 800) ]
                    |> Ok
        }


type alias Model =
    { menuState : MenuState
    , colorScheme : ColorScheme
    }


init : ( Model, Cmd Msg )
init =
    ( { menuState = Closed, colorScheme = Dark }, Cmd.none )


type Msg
    = ToggleMenu
    | CloseMenu
    | GotColorScheme Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleMenu ->
            ( { model | menuState = toggleMenu model.menuState }, Cmd.none )

        CloseMenu ->
            ( { model | menuState = Closed }, Cmd.none )

        GotColorScheme value ->
            case decodeValue colorSchemeDecoder value of
                Ok scheme ->
                    ( { model | colorScheme = scheme }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    colorScheme GotColorScheme


colorSchemeDecoder : Decoder ColorScheme
colorSchemeDecoder =
    Decode.string
        |> Decode.andThen
            (\scheme ->
                case scheme of
                    "light" ->
                        Decode.succeed Light

                    "dark" ->
                        Decode.succeed Dark

                    "no-preference" ->
                        Decode.succeed Light

                    _ ->
                        Decode.fail "Unknown colorscheme"
            )


port colorScheme : (Decode.Value -> msg) -> Sub msg


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Rendered -> { title : String, body : Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view siteMetadata page =
    StaticHttp.succeed
        { view =
            \model viewForPage ->
                let
                    { title, body } =
                        pageView model siteMetadata page viewForPage

                    ( fontColor, backgroundColor ) =
                        case model.colorScheme of
                            Light ->
                                ( Palette.color.darkest, Palette.fromElmColor Color.white )

                            Dark ->
                                ( Palette.color.lightest, Palette.color.darker )

                            NoPreference ->
                                ( Palette.color.neutral, Palette.color.neutral )
                in
                { title = title
                , body =
                    body
                        |> Element.layout
                            [ Element.width Element.fill
                            , Font.size 20
                            , Font.family [ Font.typeface "Yrsa" ]
                            , Font.color fontColor
                            , Element.Background.color backgroundColor
                            , Element.inFront (nav model.menuState model.colorScheme page.path)
                            , Element.inFront (menuButton model.menuState)
                            ]
                }
        , head = head page.frontmatter
        }


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> { path : PagePath Pages.PathKey, frontmatter : Metadata } -> Rendered -> { title : String, body : Element Msg }
pageView model siteMetadata page viewForPage =
    case page.frontmatter of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                Element.column
                    [ Element.Region.mainContent
                    , Element.centerX
                    ]
                    [ homeLink
                    , pageImageView metadata.image
                    , viewForPage
                    ]
            }

        Metadata.Article metadata ->
            { title = withSiteName metadata.title
            , body =
                Element.column
                    [ Element.padding 30
                    , Element.spacing 20
                    , Element.Region.mainContent
                    , Element.centerX
                    ]
                    [ Palette.blogHeading metadata.title
                    , Element.paragraph [ Font.size (Palette.scaled -1), Font.color Palette.color.neutral, Font.center ] [ publishedDateView metadata ]
                    , pageImageView metadata.image
                    , viewForPage
                    ]
            }

        Metadata.Author author ->
            { title = author.name
            , body =
                Element.column
                    [ Element.padding 30
                    , Element.spacing 20
                    , Element.Region.mainContent
                    , Element.centerX
                    ]
                    [ Palette.blogHeading "about the artist"
                    , Element.column
                        [ Element.spacing 30 ]
                        [ Author.view [ Element.centerX ] author
                        , Element.paragraph [ Font.size (Palette.scaled 2) ]
                            [ Element.text author.bio ]
                        ]
                    , Element.paragraph [ Element.centerX, Font.center ] [ viewForPage ]
                    ]
            }

        Metadata.BlogIndex indexMetadata ->
            { title = withSiteName indexMetadata.title
            , body =
                Element.column
                    [ Element.padding 20
                    , Element.centerX
                    ]
                    [ Index.view siteMetadata page.path indexMetadata ]
            }


pageImageView : ImagePath Pages.PathKey -> Element msg
pageImageView articleImage =
    Element.image
        [ Element.width Element.fill
        , Element.htmlAttribute (Attr.class "hero-image")
        , Element.centerX
        ]
        { src = ImagePath.toString articleImage
        , description = "Article cover photo"
        }


nav : MenuState -> ColorScheme -> PagePath Pages.PathKey -> Element Msg
nav menuState preferredColorScheme currentPath =
    case menuState of
        Open ->
            let
                backgroundColor =
                    case preferredColorScheme of
                        Light ->
                            Palette.fromElmColor Color.white

                        Dark ->
                            Palette.color.darker

                        NoPreference ->
                            Palette.color.neutral
            in
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Background.color backgroundColor
                , Element.centerX
                , Element.htmlAttribute (Attr.class "menu")
                ]
                [ homeLink
                , Element.column
                    [ Element.Region.navigation
                    , Element.centerX
                    , Element.padding 15
                    ]
                    [ highlightableDirLink currentPath pages.illustration.directory "illustration"
                    , highlightableDirLink currentPath pages.printmaking.directory "printmaking"
                    , highlightableDirLink currentPath pages.comics.directory "comics"
                    , highlightableLink currentPath pages.about "about"
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
        Open ->
            Closed

        Closed ->
            Open


menuButton : MenuState -> Element Msg
menuButton state =
    let
        icon =
            case state of
                Open ->
                    Icons.close

                Closed ->
                    Icons.menu
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
        , Element.Border.color Palette.color.dark
        ]
        { url = "/"
        , label = Palette.blogHeading siteName
        }


highlightableDirLink :
    PagePath Pages.PathKey
    -> Directory Pages.PathKey Directory.WithIndex
    -> String
    -> Element msg
highlightableDirLink currentPath linkDirectory displayName =
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
        [ Element.width Element.fill
        , Element.paddingXY 25 15
        , Font.size (Palette.scaled 2)
        , Font.center
        , fontStyle
        ]
        { url = linkDirectory |> Directory.indexPath |> PagePath.toString
        , label = Element.text displayName
        }


highlightableLink :
    PagePath Pages.PathKey
    -> PagePath Pages.PathKey
    -> String
    -> Element msg
highlightableLink currentPath linkPath displayName =
    let
        isHighlighted =
            PagePath.toString currentPath == PagePath.toString linkPath

        fontStyle =
            if isHighlighted then
                Font.bold

            else
                Font.regular
    in
    Element.link
        [ Element.width Element.fill
        , Element.paddingXY 25 15
        , Font.size (Palette.scaled 2)
        , Font.center
        , fontStyle
        ]
        { url = linkPath |> PagePath.toString
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
                , siteName = siteName
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
                , siteName = siteName
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
                , siteName = siteName
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
                , siteName = siteName
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


siteName : String
siteName =
    "tennety.art"


withSiteName : String -> String
withSiteName title =
    [ title, siteName ] |> String.join " - "


publishedDateView metadata =
    Element.text
        (metadata.published
            |> Date.format "MMMM ddd, yyyy"
        )
