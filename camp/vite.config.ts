import { defineConfig, Plugin } from "vite";
import { generate } from "./output/Main"
import jsdomGlobal from 'jsdom-global'

jsdomGlobal();

type SSROutput = { html: string, boring: Object, livePortals: Object }

export default defineConfig({
  server: {
    port: 12345
  },
  plugins: [Thing()],
});

function Thing(): Plugin {
  return {
    name: "Thing",
    transformIndexHtml: {
      order: "pre",
      handler(html) {
        const cache: SSROutput = generate();
        const hydrate = `
          import { hydrate } from '/output/Main'
          hydrate({
            html: document.body.innerHTML,
            boring: ${JSON.stringify(cache.boring)},
            livePortals: ${JSON.stringify(cache.livePortals)},
          })();
        `;
        return {
          html,
          tags: [
            { tag: "script", injectTo: "head", attrs: { type: "module" }, children: hydrate },
            { tag: "div", injectTo: "body", children: cache.html }
          ]
        }
      }
    }
  }
}
