module Main where

import Prelude

import Data.Either (either)
import Data.Tuple.Nested ((/\))
import Deku.Core (Nut)
import Deku.DOM as D
import Deku.DOM.Listeners as DL
import Deku.Do as Deku
import Deku.Hooks (useState)
import Deku.Toplevel (SSROutput, hydrateInBody, ssrInBody)
import Effect (Effect)
import Effect.Exception (throw)
import Foreign (Foreign)
import Yoga.JSON (read, writeImpl)

app :: Nut
app = Deku.do
  setNumber /\ number <- useState true
  D.div_
    [ D.h1__ "Hello world"
    , D.button [ DL.runOn DL.click $ number <#> not >>> setNumber ] [ D.text_ "Count Toggle" ]
    , D.p_ [ D.text $ number <#> show ]
    ]

-- setup --

hydrate :: Foreign -> Effect (Effect Unit)
hydrate cacheObj = fromJSON cacheObj >>= flip hydrateInBody app

generate :: Effect Foreign
generate = ssrInBody app <#> writeImpl

fromJSON :: Foreign -> Effect SSROutput
fromJSON = read >>> either (throw <<< show) pure
