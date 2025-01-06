module Move where

import Prelude

import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Number (atan2, cos, sin, sqrt, pi)

-- Extended CurrentPos to include movement state
type CurrentPos =
  { x :: Number -- position
  , y :: Number
  , vx :: Number -- velocity
  , vy :: Number
  , rotation :: Number -- current facing angle
  , wanderAngle :: Number -- for wandering behavior
  , energy :: Number -- affects movement characteristics
  }

type MousePos = Maybe { x :: Int, y :: Int }

-- Constants for movement adjustment
maxSpeed :: Number
maxSpeed = 2.0

turnSpeed :: Number
turnSpeed = 0.6

acceleration :: Number
acceleration = 0.6

friction :: Number
friction = 0.95

wanderStrength :: Number
wanderStrength = 1.0

-- Initialize a new CurrentPos
initialPos :: CurrentPos
initialPos =
  { x: 0.0
  , y: 0.0
  , vx: 0.0
  , vy: 0.0
  , rotation: 0.0
  , wanderAngle: 0.0
  , energy: 1.0
  }

-- Helper function to calculate angle between two points
getAngle :: CurrentPos -> { x :: Number, y :: Number } -> Number
getAngle current target =
  atan2 (target.y - current.y) (target.x - current.x)

-- Helper function to calculate distance between two points
getDistance :: CurrentPos -> { x :: Number, y :: Number } -> Number
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

followUpdate :: CurrentPos -> MousePos -> CurrentPos
followUpdate current Nothing = wanderUpdate current
followUpdate current (Just mouse) =
  let
    -- Convert mouse position to Numbers
    targetPos = { x: toNumber mouse.x, y: toNumber mouse.y }

    -- Calculate desired angle and distance
    targetAngle = getAngle current targetPos
    distance = getDistance current targetPos

    -- Update energy based on distance
    newEnergy =
      if distance > 100.0 then min 1.0 (current.energy + 0.05)
      else max 0.2 (current.energy - 0.02)

    -- Calculate angle difference and smooth rotation
    angleDiff = normalizeAngle (targetAngle - current.rotation)
    newRotation = current.rotation + (angleDiff * turnSpeed)

    -- Update wander angle
    newWanderAngle = current.wanderAngle + 0.1 * sin (current.wanderAngle * 0.5)

    -- Combine target direction with wandering
    effectiveAngle = newRotation + (wanderStrength * sin newWanderAngle)

    -- Calculate acceleration based on energy and facing direction
    ax = acceleration * cos effectiveAngle * newEnergy
    ay = acceleration * sin effectiveAngle * newEnergy

    -- Update velocity with acceleration and friction
    newVx = (current.vx + ax) * friction
    newVy = (current.vy + ay) * friction

    -- Apply speed limit
    speed = sqrt (newVx * newVx + newVy * newVy)
    speedFactor = if speed > maxSpeed then maxSpeed / speed else 1.0

    finalVx = newVx * speedFactor
    finalVy = newVy * speedFactor

    -- Update position
    newX = current.x + finalVx
    newY = current.y + finalVy
  in
    { x: newX
    , y: newY
    , vx: finalVx
    , vy: finalVy
    , rotation: newRotation
    , wanderAngle: newWanderAngle
    , energy: newEnergy
    }

-- Update function for wandering behavior when no mouse input
wanderUpdate :: CurrentPos -> CurrentPos
wanderUpdate current =
  let
    -- Gradually decrease energy when wandering
    newEnergy = max 0.2 (current.energy - 0.01)

    -- Update wander angle
    newWanderAngle = current.wanderAngle + 0.1

    -- Calculate new rotation with wandering
    newRotation = current.rotation + 0.1 * sin newWanderAngle

    -- Calculate acceleration
    ax = acceleration * 0.3 * cos newRotation * newEnergy
    ay = acceleration * 0.3 * sin newRotation * newEnergy

    -- Update velocity
    newVx = (current.vx + ax) * friction
    newVy = (current.vy + ay) * friction

    -- Apply speed limit
    speed = sqrt (newVx * newVx + newVy * newVy)
    speedFactor = if speed > maxSpeed * 0.5 then (maxSpeed * 0.5) / speed else 1.0

    finalVx = newVx * speedFactor
    finalVy = newVy * speedFactor

    -- Update position
    newX = current.x + finalVx
    newY = current.y + finalVy
  in
    { x: newX
    , y: newY
    , vx: finalVx
    , vy: finalVy
    , rotation: newRotation
    , wanderAngle: newWanderAngle
    , energy: newEnergy
    }
