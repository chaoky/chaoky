module Main where

import Prelude

import ArtAscii as ArtAscii
import CSS (flexEnd, noneTextDecoration, rgb, textDecoration)
import CSS as CSS
import CSS.Font (color)
import Control.Monad.ST.Class (liftST)
import Data.Either (either)
import Deku.CSS (render)
import Deku.Core (Nut)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.Toplevel (SSROutput, hydrateInBody, ssrInBody)
import Effect (Effect)
import Effect.Exception (throw)
import FRP.Event (Event, create, fold)
import FRP.Event.AnimationFrame (animationFrame')
import FRP.Event.Mouse (getMouse, withPosition)
import FRP.Poll (Poll, sham)
import Foreign (Foreign)
import Misc (css, displayFlex, fullscreen, gap, imageRendering)
import Move (MousePos, ObjectState, followUpdate, initialState)
import Sprite (spriteName)
import Yoga.JSON (read, writeImpl)

app :: Event MousePos -> Nut
app event = Deku.do
  D.div
    [ DA.style_ $ render $ displayFlex *> fullscreen *> gap "5em" ]
    [ followNut event
    , D.h4__ "Leo :: Camp"
    , D.div [ DA.style_ $ render $ displayFlex ]
        [ link "https://github.com/chaoky" "github"
        , link "https://www.linkedin.com/in/leonardo-d-a32973116/" "linkedin"
        , link "https://bsky.app/profile/leo.camp" "bluesky"
        ]
    , D.div [ css $ CSS.display CSS.flex *> CSS.alignItems flexEnd *> gap "2em" ] [ D.pre__ art, ArtAscii.canva (event <#> (\_ -> unit)) ]
    ]

link :: String -> String -> Nut
link href label = D.a
  [ DA.href_ href
  , DA.target_ "__blank"
  , css $ textDecoration noneTextDecoration *> color (rgb 0 0 0)
  ]
  [ D.text_ label ]

followNut :: Event MousePos -> Nut
followNut event = D.div
  [ DA.style $ sham $ (fold followUpdate initialState event) <#> drawSprite ]
  []

drawSprite :: ObjectState -> String
drawSprite { position, spriteState } = render do
  CSS.backgroundImage $ CSS.url spriteName
  CSS.backgroundPosition $ CSS.positioned (CSS.px $ spriteState.point.x) (CSS.px spriteState.point.y)
  CSS.position CSS.absolute
  CSS.transform (CSS.translate (CSS.px position.x) (CSS.px position.y))
  CSS.zIndex 999
  CSS.width (CSS.px 32.0)
  CSS.height (CSS.px 32.0)
  CSS.top (CSS.px 0.0)
  CSS.left (CSS.px 0.0)
  imageRendering "pixelated"

text :: forall (a ∷ Type). Show a ⇒ Poll a → Nut
text = D.text <<< map show

art :: String
art =
  """
                     
                     
                     
                     
     ___________     
    /         / \    
   /         /   \   
  /         /     \  
 /_________/-------\_
"         "          
  """

-- setup --

hydrate :: Foreign -> Effect (Effect Unit)
hydrate cacheObj = do
  cache <- fromJSON cacheObj
  mouse <- mousePosition
  hydrateInBody cache $ app mouse

mousePosition :: Effect (Event MousePos)
mousePosition = do
  mouse <- getMouse
  { event } <- animationFrame' (withPosition mouse)
  pure $ event <#> _.pos

generate :: Effect Foreign
generate = do
  { event } <- liftST create
  cache <- ssrInBody $ app event
  pure $ writeImpl cache

fromJSON :: Foreign -> Effect SSROutput
fromJSON = read >>> either (throw <<< show) pure
