module Move where

import Prelude

import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Number (abs, cos, sin)
import Misc (Point, getDistance, getRotation)
import Sprite as S

type ObjectState =
  { position :: Point
  , spriteState :: S.State
  , rotation :: Number
  , distanceToKeep :: Number
  }

initialState :: ObjectState
initialState =
  { position: { x: 110.0, y: 110.0 }
  , spriteState: S.getState S.Idle
  , rotation: 0.0
  , distanceToKeep: 133.0
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
    aceleration fn =
      if distance < current.distanceToKeep then 0.0
      else (1.2 * fn rotation) + (fn rotation * distance * 0.005)

    ax = aceleration cos
    ay = aceleration sin

    x = current.position.x + ax
    y = current.position.y + ay

    moving = abs ax + abs ay /= 0.0
    distanceToKeep = if moving then 133.0 else 200.0
    args = { moving, rotation, distance }
    spriteState = S.updateState current.spriteState args
  in
    { position: { x, y }, spriteState, rotation, distanceToKeep }
