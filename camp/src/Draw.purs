module Draw where

import Prelude

import CSS ((&))
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
    [ css $ displayFlex *> CSS.flexDirection CSS.row ]
    (divSquare 10)

divSquare n =
  repeat n
    $ D.div [ css $ squareStyle *> CSS.flexDirection CSS.column ]
    $ repeat n square

square = Deku.do
  setHovering /\ hovering <- useState false
  D.div
    [ DL.mouseenter_ \_ -> setHovering true
    , DL.mouseleave_ \_ -> setHovering false
    , DA.style $ hovering <#> \x -> render $ squareStyle *>
        if x == true then CSS.backgroundColor CSS.black else pure unit
    ]
    []

squareStyle = do
  CSS.minHeight (CSS.vw $ 80.0 / 10.0)
  CSS.minWidth (CSS.vw $ 80.0 / 10.0)
  CSS.display CSS.flex
  CSS.borderRight CSS.solid (CSS.px 1.0) CSS.black
  CSS.borderBottom CSS.solid (CSS.px 1.0) CSS.black
  CSS.cursor Cursor.pointer

repeat :: forall a. Int -> a -> Array a
repeat n x =
  range 0 n # map (\_ -> x)

