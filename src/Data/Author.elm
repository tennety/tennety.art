module Data.Author exposing (Author, all, decoder, view)

import Element exposing (Element)
import Html.Attributes as Attr
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)


type alias Author =
    { name : String
    , avatar : ImagePath Pages.PathKey
    , bio : String
    }


all : List Author
all =
    [ { name = "Chandu Tennety"
      , avatar = Pages.images.author.tennety
      , bio = "Chandu Tennety is a self-taught artist and has been drawing for as long as he can remember. He lives in Ohio with his musician spouse and daughter (an artist in her own right) and loves to linger in the spaces between reality and metaphor."
      }
    ]


decoder : Decoder Author
decoder =
    Decode.string
        |> Decode.andThen
            (\lookupName ->
                case List.Extra.find (\currentAuthor -> currentAuthor.name == lookupName) all of
                    Just author ->
                        Decode.succeed author

                    Nothing ->
                        Decode.fail ("Couldn't find author with name " ++ lookupName ++ ". Options are " ++ String.join ", " (List.map .name all))
            )


view : List (Element.Attribute msg) -> Author -> Element msg
view attributes author =
    Element.image
        (Element.width (Element.px 175)
            :: Element.htmlAttribute (Attr.class "avatar")
            :: attributes
        )
        { src = ImagePath.toString author.avatar, description = author.name }
