module Sprite where

import Prelude

import Data.List (List(..), (:))
import Data.List.Lazy as LL
import Data.Number (pi)
import Misc (Point, Degrees)

data Sprite
  = Idle
  | Alert
  | ScratchSelf
  | ScratchWallN
  | ScratchWallS
  | ScratchWallE
  | ScratchWallW
  | Tired
  | Sleeping
  | N
  | NE
  | E
  | SE
  | S
  | SW
  | W
  | NW
  | Pet
  | Happy

derive instance eqSprite :: Eq Sprite

type State =
  { sprite :: Sprite
  , points :: LL.List Point
  }

getState :: Sprite -> State
getState sprite =
  { sprite, points: LL.cycle $ LL.fromFoldable $ (\s -> { x: s.x * 32.0, y: s.y * 32.0 }) <$> getSpriteOffset sprite }

getSpriteOffset :: Sprite -> List Point
getSpriteOffset = case _ of
  Idle -> { x: -3.0, y: -3.0 } : Nil
  Alert -> { x: -7.0, y: -3.0 } : Nil
  ScratchSelf -> { x: -5.0, y: 0.0 } : { x: -6.0, y: 0.0 } : { x: -7.0, y: 0.0 } : Nil
  ScratchWallN -> { x: 0.0, y: 0.0 } : { x: 0.0, y: -1.0 } : Nil
  ScratchWallS -> { x: -7.0, y: -1.0 } : { x: -6.0, y: -2.0 } : Nil
  ScratchWallE -> { x: -2.0, y: -2.0 } : { x: -2.0, y: -3.0 } : Nil
  ScratchWallW -> { x: -4.0, y: 0.0 } : { x: -4.0, y: -1.0 } : Nil
  Tired -> { x: -3.0, y: -2.0 } : Nil
  Sleeping -> { x: -2.0, y: 0.0 } : { x: -2.0, y: -1.0 } : Nil
  N -> { x: -1.0, y: -2.0 } : { x: -1.0, y: -3.0 } : Nil
  NE -> { x: 0.0, y: -2.0 } : { x: 0.0, y: -3.0 } : Nil
  E -> { x: -3.0, y: 0.0 } : { x: -3.0, y: -1.0 } : Nil
  SE -> { x: -5.0, y: -1.0 } : { x: -5.0, y: -2.0 } : Nil
  S -> { x: -6.0, y: -3.0 } : { x: -7.0, y: -2.0 } : Nil
  SW -> { x: -5.0, y: -3.0 } : { x: -6.0, y: -1.0 } : Nil
  W -> { x: -4.0, y: -2.0 } : { x: -4.0, y: -3.0 } : Nil
  NW -> { x: -1.0, y: 0.0 } : { x: -1.0, y: -1.0 } : Nil
  Pet -> { x: -2.0, y: -1.0 } : { x: -2.0, y: 0.0 } : Nil
  Happy -> { x: -3.0, y: -3.0 } : { x: -2.0, y: -1.0 } : Nil

spriteFromAngle :: Degrees -> Sprite
spriteFromAngle angle
  | angle <= -7.0 * pi / 8.0 = W
  | angle <= -5.0 * pi / 8.0 = NW
  | angle <= -3.0 * pi / 8.0 = N
  | angle <= -1.0 * pi / 8.0 = NE
  | angle <= 1.0 * pi / 8.0 = E
  | angle <= 3.0 * pi / 8.0 = SE
  | angle <= 5.0 * pi / 8.0 = S
  | angle <= 7.0 * pi / 8.0 = SW
  | otherwise = W

spriteName :: String
spriteName = "/oneko.gif"
