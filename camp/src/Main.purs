module Main where

import Prelude

import CSS as CSS
import CSS.Common as CSM
import Control.Monad.ST.Class (liftST)
import Data.Either (either)
import Data.List.Lazy (head)
import Data.Maybe (fromMaybe)
import Data.Tuple.Nested ((/\))
import Debug (trace)
import Deku.CSS (render)
import Deku.Core (Nut, useState)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.DOM.Listeners as DL
import Deku.Do as Deku
import Deku.Toplevel (SSROutput, hydrateInBody, ssrInBody)
import Effect (Effect)
import Effect.Exception (throw)
import FRP.Event (Event, create, fold)
import FRP.Event.AnimationFrame (animationFrame')
import FRP.Event.Mouse (getMouse, withPosition)
import FRP.Poll (Poll, sham)
import Foreign (Foreign)
import Move (MousePos, ObjectState, followUpdate, initialState)
import Sprite (spriteName)
import Yoga.JSON (read, writeImpl)

app :: Event MousePos -> Nut
app event = Deku.do
  D.div
    [ DA.style_ $ render $ CSS.display CSS.flex *> CSS.flexDirection CSS.column *> CSS.alignItems CSM.center ]
    [ D.h4__ "Camp Leo"
    , D.pre__ art
    , followNut event
    ]

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
