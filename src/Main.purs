module Main where

import Prelude

import CSS (StyleM, alignItems, column, display, flex, flexDirection)
import CSS.Common (center)
import Data.Either (either)
import Data.Tuple.Nested ((/\))
import Deku.CSS (render)
import Deku.Core (Attribute, Nut)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
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
  D.div [ style $ display flex *> flexDirection column *> alignItems center ]
    [ D.h1_ [ D.text_ "Leo's Camp" ]
    , D.button [ DL.runOn DL.click $ number <#> not >>> setNumber ] [ D.text_ "Count Toggle" ]
    , D.p_ [ D.text $ number <#> show ]
    ]

style :: forall r f. Applicative f => StyleM Unit -> f (Attribute (style :: String | r))
style x = DA.style_ $ render $ x

-- setup --

hydrate :: Foreign -> Effect (Effect Unit)
hydrate cacheObj = fromJSON cacheObj >>= flip hydrateInBody app

generate :: Effect Foreign
generate = ssrInBody app <#> writeImpl

fromJSON :: Foreign -> Effect SSROutput
fromJSON = read >>> either (throw <<< show) pure
