port module Pages exposing (PathKey, allPages, allImages, application, images, isValidRoute, pages)

import Color exposing (Color)
import Head
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Mark
import Pages.Platform
import Pages.ContentCache exposing (Page)
import Pages.Manifest exposing (DisplayMode, Orientation)
import Pages.Manifest.Category as Category exposing (Category)
import Url.Parser as Url exposing ((</>), s)
import Pages.Document as Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Directory as Directory exposing (Directory)


type PathKey
    = PathKey


buildImage : List String -> ImagePath PathKey
buildImage path =
    ImagePath.build PathKey ("images" :: path)



buildPage : List String -> PagePath PathKey
buildPage path =
    PagePath.build PathKey path


directoryWithIndex : List String -> Directory PathKey Directory.WithIndex
directoryWithIndex path =
    Directory.withIndex PathKey allPages path


directoryWithoutIndex : List String -> Directory PathKey Directory.WithoutIndex
directoryWithoutIndex path =
    Directory.withoutIndex PathKey allPages path


port toJsPort : Json.Encode.Value -> Cmd msg


application :
    { init : ( userModel, Cmd userMsg )
    , update : userMsg -> userModel -> ( userModel, Cmd userMsg )
    , subscriptions : userModel -> Sub userMsg
    , view : userModel -> List ( PagePath PathKey, metadata ) -> Page metadata view PathKey -> { title : String, body : Html userMsg }
    , head : metadata -> List (Head.Tag PathKey)
    , documents : List ( String, Document.DocumentHandler metadata view )
    , manifest : Pages.Manifest.Config PathKey
    , canonicalSiteUrl : String
    }
    -> Pages.Platform.Program userModel userMsg metadata view
application config =
    Pages.Platform.application
        { init = config.init
        , view = config.view
        , update = config.update
        , subscriptions = config.subscriptions
        , document = Document.fromList config.documents
        , content = content
        , toJsPort = toJsPort
        , head = config.head
        , manifest = config.manifest
        , canonicalSiteUrl = config.canonicalSiteUrl
        , pathKey = PathKey
        }



allPages : List (PagePath PathKey)
allPages =
    [ (buildPage [ "about" ])
    , (buildPage [ "comics", "butterfly" ])
    , (buildPage [ "comics", "catch-yourself" ])
    , (buildPage [ "comics", "handouts" ])
    , (buildPage [ "comics" ])
    , (buildPage [ "comics", "smiley-face" ])
    , (buildPage [ "illustration", "hummer" ])
    , (buildPage [ "illustration" ])
    , (buildPage [ "illustration", "loon" ])
    , (buildPage [ "illustration", "warbler" ])
    , (buildPage [  ])
    ]

pages =
    { about = (buildPage [ "about" ])
    , comics =
        { butterfly = (buildPage [ "comics", "butterfly" ])
        , catchYourself = (buildPage [ "comics", "catch-yourself" ])
        , handouts = (buildPage [ "comics", "handouts" ])
        , index = (buildPage [ "comics" ])
        , smileyFace = (buildPage [ "comics", "smiley-face" ])
        , directory = directoryWithIndex ["comics"]
        }
    , illustration =
        { hummer = (buildPage [ "illustration", "hummer" ])
        , index = (buildPage [ "illustration" ])
        , loon = (buildPage [ "illustration", "loon" ])
        , warbler = (buildPage [ "illustration", "warbler" ])
        , directory = directoryWithIndex ["illustration"]
        }
    , index = (buildPage [  ])
    , directory = directoryWithIndex []
    }

images =
    { author =
        { tennety = (buildImage [ "author", "tennety.jpeg" ])
        , directory = directoryWithoutIndex ["author"]
        }
    , comics =
        { butterfly = (buildImage [ "comics", "butterfly.jpg" ])
        , catchYourself = (buildImage [ "comics", "catch-yourself.png" ])
        , handouts = (buildImage [ "comics", "handouts.jpg" ])
        , smileyFaceLores = (buildImage [ "comics", "SmileyFace-lores.jpeg" ])
        , directory = directoryWithoutIndex ["comics"]
        }
    , iconPng = (buildImage [ "icon-png.png" ])
    , icon = (buildImage [ "icon.svg" ])
    , illustration =
        { hummerFull = (buildImage [ "illustration", "hummer-full.png" ])
        , loon = (buildImage [ "illustration", "loon.png" ])
        , warbler = (buildImage [ "illustration", "warbler.png" ])
        , directory = directoryWithoutIndex ["illustration"]
        }
    , indexCovers =
        { hummerSwingBw = (buildImage [ "index-covers", "hummer-swing-bw.png" ])
        , directory = directoryWithoutIndex ["indexCovers"]
        }
    , thumbnails =
        { butterfly = (buildImage [ "thumbnails", "butterfly.jpg" ])
        , catchYourself = (buildImage [ "thumbnails", "catch-yourself.png" ])
        , handouts = (buildImage [ "thumbnails", "handouts.jpg" ])
        , smiley = (buildImage [ "thumbnails", "smiley.png" ])
        , directory = directoryWithoutIndex ["thumbnails"]
        }
    , directory = directoryWithoutIndex []
    }

allImages : List (ImagePath PathKey)
allImages =
    [(buildImage [ "author", "tennety.jpeg" ])
    , (buildImage [ "comics", "butterfly.jpg" ])
    , (buildImage [ "comics", "catch-yourself.png" ])
    , (buildImage [ "comics", "handouts.jpg" ])
    , (buildImage [ "comics", "SmileyFace-lores.jpeg" ])
    , (buildImage [ "icon-png.png" ])
    , (buildImage [ "icon.svg" ])
    , (buildImage [ "illustration", "hummer-full.png" ])
    , (buildImage [ "illustration", "loon.png" ])
    , (buildImage [ "illustration", "warbler.png" ])
    , (buildImage [ "index-covers", "hummer-swing-bw.png" ])
    , (buildImage [ "thumbnails", "butterfly.jpg" ])
    , (buildImage [ "thumbnails", "catch-yourself.png" ])
    , (buildImage [ "thumbnails", "handouts.jpg" ])
    , (buildImage [ "thumbnails", "smiley.png" ])
    ]


isValidRoute : String -> Result String ()
isValidRoute route =
    let
        validRoutes =
            List.map PagePath.toString allPages
    in
    if
        (route |> String.startsWith "http://")
            || (route |> String.startsWith "https://")
            || (route |> String.startsWith "#")
            || (validRoutes |> List.member route)
    then
        Ok ()

    else
        ("Valid routes:\n"
            ++ String.join "\n\n" validRoutes
        )
            |> Err


content : List ( List String, { extension: String, frontMatter : String, body : Maybe String } )
content =
    [ 
  ( ["about"]
    , { frontMatter = """{"title":"about the author","name":"Chandu Tennety","type":"author"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["comics", "butterfly"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"The Transformation of Things","description":"Comic re-interpretation of Ike no Taiga's `Dreaming of a Butterfly (or a Butterfly Dreaming of Zhuangzi)`","image":"/images/comics/butterfly.jpg","thumb":"/images/thumbnails/butterfly.jpg","published":"2019-09-09"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["comics", "catch-yourself"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"Catch Yourself","description":"Do you ever catch yourself falling?","image":"/images/comics/catch-yourself.png","thumb":"/images/thumbnails/catch-yourself.png","published":"2019-09-01"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["comics", "handouts"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"Looking for Handouts","description":"Never amount to anything, they said.","image":"/images/comics/handouts.jpg","thumb":"/images/thumbnails/handouts.jpg","published":"2019-08-16"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["comics"]
    , { frontMatter = """{"title":"comics","type":"blog-index","previewType":"image"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["comics", "smiley-face"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"Smiley Face","description":"Late night conversation with my child","image":"/images/comics/SmileyFace-lores.jpeg","thumb":"/images/thumbnails/smiley.png","published":"2019-06-12"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["illustration", "hummer"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"Hummingbird on Swing","description":"Ballpoint pen illustration of a hummingbird on swing","image":"/images/illustration/hummer-full.png","thumb":"/images/illustration/hummer-full.png","published":"2019-09-10"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["illustration"]
    , { frontMatter = """{"title":"illustration","type":"blog-index","previewType":"image"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["illustration", "loon"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"Common loon","description":"Ballpoint pen illustration of a common loon","image":"/images/illustration/loon.png","thumb":"/images/illustration/loon.png","published":"2019-09-21"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["illustration", "warbler"]
    , { frontMatter = """{"type":"blog","author":"Chandu Tennety","title":"Wilson's Warbler","description":"Color pencil illustration of a Wilson's warbler","image":"/images/illustration/warbler.png","thumb":"/images/illustration/warbler.png","published":"2017-12-15"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( []
    , { frontMatter = """{"title":"tennety.art","image":"/images/index-covers/hummer-swing-bw.png","type":"page"}
""" , body = Nothing
    , extension = "md"
    } )
  
    ]
