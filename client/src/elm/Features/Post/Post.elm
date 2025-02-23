module Features.Post.Post exposing (post)

import Css
import Array
import Url
import Html.Styled.Attributes exposing (css, href, target)
import Html.Styled exposing (a, div, span, text, Html)
import Url.Parser exposing (parse)

import Utils.Date exposing (parseTimestamp)

import Core.Model.Types exposing (Model)
import Core.Message exposing (Message)
import Core.Route.Parsers exposing (postUrlParser)

import Features.Post.Constants exposing (constants)
import Features.Post.Model.Query exposing (parsePostFeatureContent)
import Features.Post.Model.Types exposing (PostFeatureContent)

import Components.Article exposing (article)
import Components.Keywords exposing (keywords)

getPostId : String -> String
getPostId =
  String.split "/"
    >> Array.fromList
    >> Array.get 2
    >> Maybe.withDefault ""

getPostSourceUrl : String -> String
getPostSourceUrl url =
  let
    postId = getPostId url
  in
    constants.postsSourceUrl ++ postId ++ "/" ++ postId ++ constants.postSourceExtension

getDiscussOnTwitterUrl : PostFeatureContent -> String
getDiscussOnTwitterUrl content =
  let
    baseUrl = "https://twitter.com/search?q=balov bohdan "
    urlWithPostTitle = baseUrl ++ content.postMeta.title
    urlEncoded = Url.percentDecode urlWithPostTitle
  in
    Maybe.withDefault "https://twitter.com/balov_bohdan" urlEncoded

parseKeywords : String -> List String
parseKeywords words =
  words
    |> String.split ","
    |> List.map String.trim

getTimeToRead : PostFeatureContent -> String
getTimeToRead content =
  let
    koefficient = 0.0008
    textLength = toFloat <| String.length <| content.post.text
    timeToRead = String.fromInt <| ceiling <| (textLength * koefficient)
  in
    timeToRead ++ " mins to read"

header : Model -> PostFeatureContent -> Html Message
header model content =
  let
    publishedOnDirty = String.toInt content.postMeta.publishedOn
    publishedOn =
      case (publishedOnDirty) of
        Nothing -> "unknown"
        Just value -> parseTimestamp value
  in
    div
      [ css
          [ Css.displayFlex
          , Css.property "gap" "5px"
          , Css.fontSize <| Css.rem 0.8
          ]
      ]
      [ span
          [ css [ Css.color model.theme.textSecondary ] ]
          [ text ("Published on " ++ publishedOn) ]
      , span
          [ css [ Css.color model.theme.textSecondary ] ]
          [ text "•" ]
      , span
          [ css [ Css.color model.theme.textSecondary ] ]
          [ text (getTimeToRead content) ]
      ]

sourceButton : Model -> String -> String -> Html Message
sourceButton model url name =
  a
    [ href url
    , target "__blank"
    , css [ Css.color model.theme.accent ]
    ]
    [ text name ]

source : Model -> PostFeatureContent -> Html Message
source model content =
  div
    [ css
        [ Css.displayFlex
        , Css.flexWrap Css.wrap
        , Css.property "gap" "10px"
        ]
    ]
    [ sourceButton
        model
        (getDiscussOnTwitterUrl content)
        "Discuss on Twitter"
    , sourceButton
        model
        (getPostSourceUrl model.url.path)
        "Open on GitHub"
    ]

meta : Model -> PostFeatureContent -> Html Message
meta model content =
  div
    [ css
        [ Css.displayFlex
        , Css.property "gap" "40px"
        , Css.flexDirection Css.column
        , Css.alignItems Css.flexEnd
        , Css.paddingBottom <| Css.px 10
        , Css.boxSizing Css.borderBox
        , Css.marginTop <| Css.px 40
        ]
    ]
    [ source model content
    , keywords
        { model = model
        , keywords = parseKeywords content.postMeta.keywords
        }
    ]

post : Model -> Html Message
post model =
  let
    postId = parse postUrlParser model.url
  in
    if postId == Nothing then
      text "This post doesn't exist... :("
    else
      let
        content = parsePostFeatureContent model.featureData.content
      in
        div
          []
          [ article
              { model = model
              , content = content.post.text
              , header = header model content
              , meta = meta model content
              }
          ]
