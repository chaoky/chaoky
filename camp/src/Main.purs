module Main where

import Prelude

import ArtAscii as ArtAscii
import Components (css, displayFlex, fullscreen, gap, link)
import Control.Monad.ST.Class (liftST)
import Data.Either (either)
import Deku.CSS (render)
import Deku.Core (Nut)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.Toplevel (SSROutput, hydrateInBody, ssrInBody)
import Draw (followNut)
import Effect (Effect)
import Effect.Exception (throw)
import FRP.Event (Event, create)
import FRP.Event.AnimationFrame (animationFrame')
import FRP.Event.Mouse (getMouse, withPosition)
import Foreign (Foreign)
import Move (MousePos)
import Yoga.JSON (read, writeImpl)

app :: Event MousePos -> Nut
app event = Deku.do
  D.div
    [ DA.style_ $ render $ displayFlex *> fullscreen *> gap "5em" ]
    [ followNut event
    , D.h4__ "Leo :: Camp"
    , D.div [ css $ displayFlex *> gap ".3em" ]
        [ link { href: "https://github.com/chaoky", target: "_blank", label: "github" }
        , link { href: "https://www.linkedin.com/in/leonardo-d-a32973116/", target: "_blank", label: "linkedin" }
        , link { href: "https://bsky.app/profile/leo.camp", target: "_blank", label: "bluesky" }
        ]
    , ArtAscii.canva (event <#> (\_ -> unit))
    , link { href: "/articles", target: "_self", label: "articles" }
    ]

-- generate ssr output
generate :: Effect Foreign
generate = do
  { event } <- liftST create
  cache <- ssrInBody $ app event
  pure $ writeImpl cache

-- runs after page load
hydrate :: Foreign -> Effect (Effect Unit)
hydrate cacheObj = do
  cache <- fromJSON cacheObj
  mouse <- mousePosition
  hydrateInBody cache $ app mouse

mousePosition :: Effect (Event MousePos)
mousePosition = do
  mouse <- getMouse
  { event } <- animationFrame' (withPosition mouse)
  pure $ event <#> _.pos

fromJSON :: Foreign -> Effect SSROutput
fromJSON = read >>> either (throw <<< show) pure
