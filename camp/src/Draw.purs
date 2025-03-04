module Draw where

import Prelude

import CSS as CSS
import CSS.Cursor as Cursor
import Data.Array (range)
import Data.Tuple.Nested ((/\))
import Deku.CSS (render)
import Deku.Core (Nut, useState)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.DOM.Listeners as DL
import Deku.Do as Deku
import Misc (css, displayFlex)

canva :: Nut
canva = Deku.do
  D.div
    [ css $ displayFlex
        *> CSS.flexDirection CSS.row
        *> squareBorder CSS.borderLeft
        *> squareBorder CSS.borderTop
    ]
    (divSquare 10)

divSquare :: Int -> Array Nut
divSquare n =
  repeat n $ D.div_ $ repeat n square

square :: Nut
square = Deku.do
  setHovering /\ hovering <- useState false
  D.div
    [ DL.mouseenter_ \_ -> setHovering true
    , DL.mouseleave_ \_ -> setHovering false
    , DA.style $ hovering <#>
        \x -> render $ pure unit
          *> (if x == true then CSS.backgroundColor CSS.black else pure unit)
          *> squareBorder CSS.borderBottom
          *> squareBorder CSS.borderRight
          *> CSS.maxWidth (CSS.px 50.0)
          *> CSS.maxHeight (CSS.px 50.0)
          *> CSS.height (CSS.vw 8.0)
          *> CSS.width (CSS.vw 8.0)
          *> CSS.cursor Cursor.pointer
    ]
    []

squareBorder :: forall a. (CSS.Stroke -> CSS.Size CSS.LengthUnit -> CSS.Color -> a) -> a
squareBorder fn = fn CSS.solid (CSS.px 1.0) CSS.black

repeat :: forall a. Int -> a -> Array a
repeat n x =
  range 0 n # map (\_ -> x)
