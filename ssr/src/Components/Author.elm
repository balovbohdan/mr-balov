module Components.Author exposing (author)

import Css
import Css.Media
import Html.Styled exposing (div, a, p, text, Html)
import Html.Styled.Attributes exposing (css, href)

import Core.Theme exposing (Theme)
import Utils.Css exposing (mixCss)

type alias Props =
  { css: List Css.Style
  , theme: Theme
  , avatarHref: String
  }

avatar : Props -> Html message
avatar props =
  a
    [ href props.avatarHref
    , css
        [ Css.width (Css.px 100)
        , Css.height (Css.px 100)
        , Css.borderRadius (Css.pct 50)
        , Css.backgroundColor props.theme.secondary
        , Css.backgroundImage (Css.url "/assets/avatar.jpg")
        , Css.backgroundSize Css.cover
        , Css.backgroundPosition Css.center
        , Css.Media.withMedia
            [ Css.Media.only Css.Media.screen [ Css.Media.maxWidth (Css.px 400) ] ]
            [ Css.width <| Css.px 70, Css.height <| Css.px 70 ]
        ]
    ]
    []

sign : Html message
sign =
  div
    []
    [ p [] [ text "Software Development Blog" ]
    , p [] [ text "By Mr. Balov" ]
    ]

getAuthorCss : Props -> List Css.Style
getAuthorCss props =
  mixCss
    [ Css.displayFlex
    , Css.flexWrap Css.wrap
    , Css.property "gap" "20px"
    , Css.flexDirection Css.row
    , Css.alignItems Css.center
    ]
    props.css

author : Props -> Html message
author props =
  div
    [ css (getAuthorCss props) ]
    [ avatar props, sign ]
