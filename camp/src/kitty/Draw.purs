module Draw where

import Prelude

import CSS as CSS
import Components (imageRendering)
import Deku.CSS (render)
import Deku.Core (Nut)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import FRP.Event (Event, fold)
import FRP.Poll (sham)
import Move (MousePos, ObjectState, followUpdate, initialState)
import Sprite (spriteName)

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

