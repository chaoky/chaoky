module Draw where

import Prelude

import CSS as CSS
import CSS.Cursor as Cursor
import CSS.TextAlign as CSST
import Data.Array (range)
import Data.Tuple.Nested ((/\))
import Deku.CSS (render)
import Deku.Core (Nut, useState)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.DOM.Listeners as DL
import Deku.Do as Deku
import FRP.Poll (Poll)
import Misc (displayFlex)
import Web.UIEvent.KeyboardEvent (key)

canva :: Nut
canva = Deku.do
  setChar /\ char <- useState "/"
  let
    divSquare = repeat 20 $ D.div_ $ repeat 20 $ square char
  D.div
    [ DA.style_ $ render do
        displayFlex
        CSS.flexDirection CSS.row
        squareBorder CSS.borderLeft
        squareBorder CSS.borderTop
    , DL.keypress_ \k -> setChar (key k)
    , DA.tabindex_ "0"
    ]
    divSquare

square :: Poll String -> Nut
square char = Deku.do
  setHovering /\ isHovering <- useState false
  setText /\ text <- useState ""
  D.div
    [ DL.mouseenter_ \_ -> setHovering true
    , DL.mouseleave_ \_ -> setHovering false
    , DA.style $ isHovering <#>
        \hovering -> render do
          when hovering $ CSS.backgroundColor CSS.black
          squareBorder CSS.borderBottom
          squareBorder CSS.borderRight
          CSS.width (CSS.em 1.5)
          CSS.height (CSS.em 1.5)
          CSS.cursor Cursor.pointer
          CSS.display CSS.flex
    , DL.click $ char <#> \c -> \_ -> setText c
    ]
    [ D.p
        [ DA.style_ $ render do
            CSS.flexGrow 1.0
            CSS.fontSize (CSS.em 1.5)
            CSST.textAlign CSST.center
            CSS.padding (CSS.px 0.0) (CSS.px 0.0) (CSS.px 0.0) (CSS.px 0.0)
            CSS.margin (CSS.px 0.0) (CSS.px 0.0) (CSS.px 0.0) (CSS.px 0.0)
        ]
        [ D.text text ]
    ]

squareBorder :: forall a. (CSS.Stroke -> CSS.Size CSS.LengthUnit -> CSS.Color -> a) -> a
squareBorder fn = fn CSS.solid (CSS.px 1.0) CSS.black

repeat :: forall a. Int -> a -> Array a
repeat n x =
  range 0 n # map (\_ -> x)
