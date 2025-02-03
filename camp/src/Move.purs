module Move where

import Prelude

import Data.Int (toNumber)
import Data.List.Lazy (uncons)
import Data.Maybe (Maybe(..), fromJust, fromMaybe)
import Data.Number (abs, cos, sin, (%))
import Debug (trace)
import Misc (Point, getDistance, getRotation, normalizeAngle)
import Partial.Unsafe (unsafePartial)
import Sprite as S

initialState :: ObjectState
initialState =
  { position: { x: 110.0, y: 110.0 }
  , spriteState: S.getState S.Idle
  , rotation: 0.0
  , tick: 0.0
  }

type ObjectState =
  { position :: Point
  , spriteState :: S.State
  , rotation :: Number
  , tick :: Number
  }

type MousePos = Maybe { x :: Int, y :: Int }

followUpdate :: ObjectState -> MousePos -> ObjectState
followUpdate current Nothing = current
followUpdate current (Just mouse_) =
  let
    tick = if current.tick < 100.0 then current.tick + 0.25 else 0.0
    mouse = { x: toNumber mouse_.x, y: toNumber mouse_.y }
    distance = getDistance current.position mouse

    newRotation = getRotation current.position mouse
    rotationDiff = newRotation - current.rotation
    rotation = current.rotation + rotationDiff

    ax = if distance < 133.0 then 0.0 else (1.2 * cos rotation) + (cos rotation * distance * 0.005)
    ay = if distance < 133.0 then 0.0 else (1.2 * sin rotation) + (sin rotation * distance * 0.005)
    x = current.position.x + ax
    y = current.position.y + ay

    sprite = if abs ax + abs ay == 0.0 then S.Idle else rotation # S.spriteFromAngle
    spriteState =
      if sprite == current.spriteState.sprite then
        if tick % 2.0 == 0.0 then
          let
            { head, tail } = unsafePartial $ fromJust $ uncons current.spriteState.points
          in
            current.spriteState { points = tail }
        else
          current.spriteState
      else sprite # S.getState
  in
    { position: { x, y }, spriteState, rotation, tick }
