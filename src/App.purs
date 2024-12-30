module App where

import Prelude
import Deku.Control (text_, text)
import Deku.DOM as D
import Deku.DOM.Listeners as DL
import Deku.Core (Nut)
import Data.Tuple.Nested ((/\))
import Deku.Hooks (useState)
import Deku.Do as Deku

app :: Nut
app = Deku.do
  setNumber /\ number <- useState true
  D.div_
    [ D.h1__ "Hello world"
    , D.button [ DL.runOn DL.click $ number <#> not >>> setNumber ] [ text_ "Count up!" ]
    , D.p_ [ text $ number <#> show ]
    ]
