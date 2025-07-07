module Components where

import Prelude

import CSS (color, rgb)
import Deku.Core (Nut)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import CSS as CSS
import CSS.Common as CSM
import Deku.Attribute (Attribute)
import Deku.CSS (render)

type Link =
  { href :: String
  , target :: String
  , label :: String
  }

link :: Link -> Nut
link { href, target, label } = D.a
  [ DA.href_ href
  , DA.target_ target
  , css $ color (rgb 0 0 0)
  ]
  [ D.text_ label ]

displayFlex :: CSS.StyleM Unit
displayFlex = CSS.display CSS.flex *> CSS.flexDirection CSS.column *> CSS.alignItems CSM.center

css :: forall (r ∷ Row Type) (f ∷ Type -> Type). Applicative f ⇒ CSS.StyleM Unit → f (Attribute (style ∷ String | r))
css x = DA.style_ $ render x

imageRendering :: String -> CSS.StyleM Unit
imageRendering = CSS.key $ CSS.fromString "image-rendering"

gap :: String -> CSS.StyleM Unit
gap = CSS.key $ CSS.fromString "gap"

fullscreen :: CSS.StyleM Unit
fullscreen = CSS.minWidth (CSS.vw 100.0) *> CSS.maxWidth (CSS.vw 100.0)
