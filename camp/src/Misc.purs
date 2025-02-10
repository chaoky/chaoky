module Misc where

import Prelude

import CSS as CSS
import CSS.Common as CSM
import Data.Number (atan2, pi, sqrt)
import Deku.Attribute (Attribute)
import Deku.CSS (render)
import Deku.DOM.Attributes as DA

type Point = { x :: Number, y :: Number }

type Degrees = Number

-- Calculate angle between two points TODO: normalize
getRotation :: Point -> Point -> Degrees
getRotation current target =
  let
    normal = normalize { y: target.y - current.y, x: target.x - current.x }
    radians = atan2 normal.y normal.x
  in
    radians

-- Normalize a vector
normalize :: Point -> Point
normalize vec =
  let
    magnitude = sqrt (vec.x * vec.x + vec.y * vec.y)
  in
    if magnitude == 0.0 then { x: 0.0, y: 0.0 }
    else { x: vec.x / magnitude, y: vec.y / magnitude }

-- Calculate distance between two points
getDistance :: Point -> Point -> Number
getDistance current target =
  sqrt
    ( (target.x - current.x) * (target.x - current.x) +
        (target.y - current.y) * (target.y - current.y)
    )

-- Helper to normalize angle difference
normalizeAngle :: Number -> Number
normalizeAngle angle
  | angle > pi = angle - 2.0 * pi
  | angle < -pi = angle + 2.0 * pi
  | otherwise = angle

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

