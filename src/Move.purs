module Move where

import Prelude

import CSS (distance)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Number (abs, cos, sin)
import Debug (trace)
import Misc (Point, getDistance, getRotation, normalizeAngle)
import Sprite as S

initialState :: ObjectState
initialState =
  { position: { x: 110.0, y: 110.0 }
  , spriteState: S.getState S.Idle
  , rotation: 0.0
  }

type ObjectState =
  { position :: Point
  , spriteState :: S.State
  , rotation :: Number
  }

type MousePos = Maybe { x :: Int, y :: Int }

followUpdate :: ObjectState -> MousePos -> ObjectState
followUpdate current Nothing = current
followUpdate current (Just mouse_) =
  let
    mouse = { x: toNumber mouse_.x, y: toNumber mouse_.y }
    distance = getDistance current.position mouse

    newRotation = getRotation current.position mouse
    rotationDiff = newRotation - current.rotation
    rotation = current.rotation + rotationDiff

    ax = if distance < 133.0 then 0.0 else (1.2 * cos rotation) + (cos rotation * distance * 0.005)
    ay = if distance < 133.0 then 0.0 else (1.2 * sin rotation) + (sin rotation * distance * 0.005)
    x = current.position.x + ax
    y = current.position.y + ay

    _ = trace (distance) \_ -> unit

    sprite = if abs ax + abs ay == 0.0 then S.Idle else rotation # S.spriteFromAngle
    spriteState =
      if sprite == current.spriteState.sprite then
        current.spriteState
      else sprite # S.getState
  in
    { position: { x, y }, spriteState, rotation }
