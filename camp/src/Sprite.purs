module Sprite (State, Sprite(..), getState, updateState, spriteFromAngle, spriteName) where

import Prelude

import Data.Number (pi)
import Misc (Point, Degrees)

data Sprite
  = Idle
  | Alert
  | Tired
  | Sleeping
  | ScratchSelf
  | ScratchWallN
  | ScratchWallS
  | ScratchWallE
  | ScratchWallW
  | N
  | NE
  | E
  | SE
  | S
  | SW
  | W
  | NW

derive instance eqSprite :: Eq Sprite

type State =
  { sprite :: Sprite
  , point :: Point
  , animateTick :: Int
  , idleTick :: Int
  }

type Vars =
  { rotation :: Degrees
  , moving :: Boolean
  , distance :: Number
  }

getState :: Sprite -> State
getState sprite =
  { sprite, animateTick: 0, idleTick: 0, point: spriteToOffset sprite }

updateState :: State -> Vars -> State
updateState state vars =
  let
    idleTick = if vars.moving then 0 else state.idleTick + 1
    sprite = case vars.distance, idleTick, vars.moving of
      _, _, false | vars.distance < 30.0 -> Alert
      _, _, false | between 600 700 idleTick -> Tired
      _, _, false | idleTick > 900 -> Sleeping
      _, _, false | between 80 160 idleTick -> ScratchSelf
      _, _, false -> Idle
      _, _, true -> spriteFromAngle vars.rotation
    point = if state.sprite == sprite then state.point else spriteToOffset sprite
  in
    updateAnimate state { idleTick = idleTick, sprite = sprite, point = point }

updateAnimate :: State -> State
updateAnimate state@{ point, animateTick } =
  if animateTick == 9 then
    state { point = next point, animateTick = 0 }
  else
    state { animateTick = animateTick + 1 }

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

spriteToOffset :: Sprite -> Point
spriteToOffset = case _ of
  Idle -> idle1
  Alert -> alert1
  Tired -> tired1
  Sleeping -> sleep1
  ScratchSelf -> scratch1
  ScratchWallN -> wallN1
  ScratchWallS -> wallS1
  ScratchWallE -> wallE1
  ScratchWallW -> wallW1
  N -> north1
  NE -> ne1
  E -> east1
  SE -> se1
  S -> south1
  SW -> sw1
  W -> west1
  NW -> nw1

next :: Point -> Point
next p
  | p == scratch1 = scratch2
  | p == scratch2 = scratch3
  | p == scratch3 = scratch1
  | p == wallN1 = wallN2
  | p == wallN2 = wallN1
  | p == wallS1 = wallS2
  | p == wallS2 = wallS1
  | p == wallE1 = wallE2
  | p == wallE2 = wallE1
  | p == wallW1 = wallW2
  | p == wallW2 = wallW1
  | p == sleep1 = sleep2
  | p == sleep2 = sleep1
  | p == north1 = north2
  | p == north2 = north1
  | p == ne1 = ne2
  | p == ne2 = ne1
  | p == east1 = east2
  | p == east2 = east1
  | p == se1 = se2
  | p == se2 = se1
  | p == south1 = south2
  | p == south2 = south1
  | p == sw1 = sw2
  | p == sw2 = sw1
  | p == west1 = west2
  | p == west2 = west1
  | p == nw1 = nw2
  | p == nw2 = nw1
  | otherwise = p

idle1 = { x: -96.0, y: -96.0 }
alert1 = { x: -224.0, y: -96.0 }
scratch1 = { x: -160.0, y: 0.0 }
scratch2 = { x: -192.0, y: 0.0 }
scratch3 = { x: -224.0, y: 0.0 }
wallN1 = { x: 0.0, y: 0.0 }
wallN2 = { x: 0.0, y: -32.0 }
wallS1 = { x: -224.0, y: -32.0 }
wallS2 = { x: -192.0, y: -64.0 }
wallE1 = { x: -64.0, y: -64.0 }
wallE2 = { x: -64.0, y: -96.0 }
wallW1 = { x: -128.0, y: 0.0 }
wallW2 = { x: -128.0, y: -32.0 }
tired1 = { x: -96.0, y: -64.0 }
sleep1 = { x: -64.0, y: 0.0 }
sleep2 = { x: -64.0, y: -32.0 }
north1 = { x: -32.0, y: -64.0 }
north2 = { x: -32.0, y: -96.0 }
ne1 = { x: 0.0, y: -64.0 }
ne2 = { x: 0.0, y: -96.0 }
east1 = { x: -96.0, y: 0.0 }
east2 = { x: -96.0, y: -32.0 }
se1 = { x: -160.0, y: -32.0 }
se2 = { x: -160.0, y: -64.0 }
south1 = { x: -192.0, y: -96.0 }
south2 = { x: -224.0, y: -64.0 }
sw1 = { x: -160.0, y: -96.0 }
sw2 = { x: -192.0, y: -32.0 }
west1 = { x: -128.0, y: -64.0 }
west2 = { x: -128.0, y: -96.0 }
nw1 = { x: -32.0, y: 0.0 }
nw2 = { x: -32.0, y: -32.0 }

spriteName :: String
spriteName = "/oneko.gif"
