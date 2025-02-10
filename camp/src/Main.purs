module Main where

import Prelude

import CSS as CSS
import Control.Monad.ST.Class (liftST)
import Data.Either (either)
import Data.Tuple.Nested ((/\))
import Debug (trace)
import Deku.CSS (render)
import Deku.Core (Nut, useState)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.DOM.Listeners as DL
import Deku.Toplevel (SSROutput, hydrateInBody, ssrInBody)
import Draw as Draw
import Effect (Effect)
import Effect.Exception (throw)
import FRP.Event (Event, create, fold)
import FRP.Event.AnimationFrame (animationFrame')
import FRP.Event.Mouse (getMouse, withPosition)
import FRP.Poll (Poll, sham)
import Foreign (Foreign)
import Misc (displayFlex, fullscreen, gap, imageRendering)
import Move (MousePos, ObjectState, followUpdate, initialState)
import Sprite (spriteName)
import Yoga.JSON (read, writeImpl)

app :: Event MousePos -> Nut
app event = Deku.do
  D.div
    [ DA.style_ $ render $ displayFlex *> fullscreen *> gap "20px" ]
    [ D.h4__ "Leo :: Camp"
    , D.pre__ art
    , followNut event
    , D.div [ DA.style_ $ render $ displayFlex ]
        [ link "https://github.com/chaoky" "github"
        , link "https://www.linkedin.com/in/leonardo-d-a32973116/" "linkedin"
        , link "https://bsky.app/profile/leo.camp" "bluesky"
        ]
    , Draw.canva
    ]

link :: String -> String -> Nut
link href label = D.a [ DA.href_ href, DA.target_ "__blank" ] [ D.text_ label ]

followNut :: Event MousePos -> Nut
followNut event = D.div
  [ DA.style $ sham $ (fold followUpdate initialState event) <#> drawSprite ]
  []

drawSprite :: ObjectState -> String
drawSprite { position, spriteState } = render do
  CSS.backgroundImage $ CSS.url spriteName
  CSS.backgroundPosition $ CSS.positioned (CSS.px $ spriteState.point.x) (CSS.px spriteState.point.y)
  CSS.position CSS.absolute
  CSS.transform (CSS.translate (CSS.px position.x) (CSS.px position.y))
  CSS.zIndex 999
  CSS.width (CSS.px 32.0)
  CSS.height (CSS.px 32.0)
  CSS.top (CSS.px 0.0)
  CSS.left (CSS.px 0.0)
  imageRendering "pixelated"

text :: forall (a ∷ Type). Show a ⇒ Poll a → Nut
text = D.text <<< map show

art :: String
art =
  """
                                ) 
                               ( `(
                             `')    )  
                             `(    ( 
     ___________               ) /\ ( 
    /         / \            (  // | (`
   /         /   \         _ -.;_/ \\--._ 
  /         /     \       (_;-// | \ \-'.\
 /_________/-------\_     ( `.__ _  ___,')
"         "                `'(_ )_)(_)_)'
  """

-- setup --

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

generate :: Effect Foreign
generate = do
  { event } <- liftST create
  cache <- ssrInBody $ app event
  pure $ writeImpl cache

fromJSON :: Foreign -> Effect SSROutput
fromJSON = read >>> either (throw <<< show) pure
