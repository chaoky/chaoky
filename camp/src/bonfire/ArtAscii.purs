module ArtAscii where

import Prelude

import Frames (frame)
import CSS (Color, fontSize, textWhitespace, whitespacePreWrap)
import CSS.Color (rgb)
import CSS.Font (color)
import CSS.Overflow (hidden, overflowY)
import CSS.Size (px)
import Data.Array (groupBy)
import Data.Array.NonEmpty (head, toArray)
import Data.String.Utils (fromCharArray, lines, toCharArray)
import Deku.CSS (render)
import Deku.DOM as D
import Deku.DOM.Attributes as DA
import Deku.Hooks (Nut, (<#~>))
import FRP.Event (Event, fold)
import FRP.Poll (Poll, sham)

type ObjectState =
  { index :: Int
  , elapsed :: Number
  }

initialState :: ObjectState
initialState =
  { index: 0
  , elapsed: 0.0
  }

update :: ObjectState -> Unit -> ObjectState
update current _event
  | current.elapsed < 1.0 = current { index = current.index, elapsed = current.elapsed + 0.2 }
  | otherwise =
      let
        index = if frame (current.index + 1) == "" then 0 else current.index + 1
      in
        { index, elapsed: 0.0 }

canva :: Event Unit -> Nut
canva event =
  let
    getIndex = sham $ fold update initialState event
  in
    D.div
      []
      [ renderBonfireFrame $ getBonfireFrame <$> getIndex ]

renderBonfireFrame :: Poll (Array String) -> Nut
renderBonfireFrame p = p <#~> renderFrame

renderFrame :: Array String -> Nut
renderFrame lines =
  D.code
    [ DA.style_ $ render
        $ overflowY hidden
            *> textWhitespace whitespacePreWrap
            *> fontSize (px 5.0)
    ]
    $ lines <#> renderLine

renderLine :: String -> Nut
renderLine line =
  D.div
    [ DA.style_ $ render
        $ textWhitespace whitespacePreWrap
            *> color (getCharColor line)
    ]
    $ toCharArray line # (groupBy \a b -> a == b) <#> span
  where
  span x = D.span
    [ DA.style_ $ render $ color $ getCharColor $ head x ]
    [ D.text_ $ fromCharArray $ toArray x ]

getCharColor :: String -> Color
getCharColor char
  | otherwise = (rgb 0 0 0)

type BonfireFrame = Array String

getBonfireFrame :: ObjectState -> BonfireFrame
getBonfireFrame state = frame state.index # lines
