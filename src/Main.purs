module Main where

import CSS (LengthUnit, Size, absolute, alignItems, backgroundImage, backgroundPosition, column, display, flex, flexDirection, height, left, offset, position, positioned, px, top, transform, translate, url, width, zIndex)
import CSS.Common (center)
import Control.Monad.ST.Class (liftST)
import Data.Either (either)
import Data.Int (toNumber)
import Data.Tuple.Nested ((/\))
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
import Move (CurrentPos, MousePos, followUpdate, initialPos)
import Prelude (class Show, Unit, bind, discard, map, negate, not, pure, show, (#), ($), (*>), (<#>), (<<<), (>>>))
import Yoga.JSON (read, writeImpl)

app :: Event MousePos -> Nut
app event = Deku.do
  setNumber /\ number <- useState true
  D.div
    [ DA.style_ $ render $ display flex *> flexDirection column *> alignItems center ]
    [ D.h1__ "Leo's Camp"
    , D.button [ DL.runOn DL.click $ number <#> not >>> setNumber ] [ D.text_ "Count Toggle" ]
    , D.p_ [ text number ]
    , followNut event
    ]

followNut :: Event MousePos -> Nut
followNut event = D.div
  [ DA.style $ sham $ (fold followUpdate initialPos event) <#> followCss ]
  []

data Action = Idle | Left | Right
type Sprite = { x :: Size LengthUnit, y :: Size LengthUnit }

sprite :: Action -> Sprite
sprite a =
  let
    s = case a of
      Idle -> { x: -96, y: -96 }
      Left -> { x: -96, y: -96 }
      Right -> { x: -96, y: -96 }
  in
    { x: px $ toNumber s.x, y: px $ toNumber s.y }

followCss :: CurrentPos -> String
followCss pos = render do
  backgroundImage $ url "https://choco.rip/images/oneko.gif"
  backgroundPosition $ positioned (px (-96.0)) (px (-96.0))
  position absolute
  transform (translate (px pos.x) (px pos.y))
  zIndex 999
  width (px 32.0)
  height (px 32.0)
  top (px 0.0)
  left (px 0.0)

text :: forall (a ∷ Type). Show a ⇒ Poll a → Nut
text = D.text <<< map show

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
