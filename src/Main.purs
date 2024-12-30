module Main where

import Prelude

import App (app)
import Data.Either (either)
import Deku.Toplevel (SSROutput, hydrateInBody)
import Effect (Effect)
import Effect.Exception (throw)
import Foreign (Foreign)
import Yoga.JSON (read)

main :: Foreign -> Effect Unit
main cacheObj = do
  cache <- fromJSON cacheObj
  _ <- hydrateInBody cache app
  pure unit

fromJSON :: Foreign -> Effect SSROutput
fromJSON = read >>> either (throw <<< show) pure
