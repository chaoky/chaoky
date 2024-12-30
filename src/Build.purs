module Build where

import Prelude

import App (app)
import Deku.Toplevel (SSROutput, ssrInBody)
import Effect (Effect)
import Effect.Console (log)
import FFI (jsdomGlobal)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Substitute (substitute)
import Yoga.JSON (writeJSON)

main :: Effect Unit
main = do
  _ <- jsdomGlobal
  cache <- ssrInBody app
  _ <- writeTextFile UTF8 "./index.html" $ html cache
  _ <- log "wrote to ./index.html"
  pure unit

html :: SSROutput -> String
html cache = substitute
  """
  <!DOCTYPE html>
  <html>
    <head>
      <title>My Awesome deku project</title>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width">
      <link rel="stylesheet" href="./src/style.css">
      <script type="module">
        import { main } from '/output/Main'
        main(${cache})();
      </script>
   </head>
   <body>
    ${body}
   </body>
  </html>
  """
  { body: cache.html, cache: writeJSON cache }
