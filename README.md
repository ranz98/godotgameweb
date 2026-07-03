# Hide & Seek — Web (Vercel) build

Static Godot 4 **Web** export of the game, hosted on Vercel. This is a separate
git repo from the desktop project (the desktop project ignores this folder).

## Important web caveats (read first)
1. **Renderer:** the browser build MUST use the **Compatibility** renderer
   (WebGL2). Forward+ (the desktop renderer) does not run in browsers, so
   **SDFGI / SSR / SSIL / volumetric fog do nothing on web** — the web version
   will look flatter than desktop. In Godot: Project Settings → Rendering →
   Renderer → set Rendering Method to **Compatibility** (or add a web override)
   before exporting.
2. **Multiplayer:** the desktop game uses **ENet (UDP)**, which browsers cannot
   use. Web multiplayer needs **WebSocket** or **WebRTC** instead — see
   `MULTIPLAYER.md`. Vercel itself cannot host the realtime server (its
   functions are short-lived); PartyKit / a small Godot server does.
3. **Download size:** the 2048² textures + `.glb` characters make a big `.pck`.
   For web, shrink textures (e.g. 512²) and consider fewer assets, or loading
   will be slow.

## Export from Godot into this folder
1. Set the renderer to **Compatibility** (see above).
2. Project → Export → **Web** preset → **Export Project…**
3. Export path: this folder, filename **`index.html`**.
   (Produces `index.html`, `index.wasm`, `index.pck`, `index.js`, etc.)

## Deploy to Vercel
Option A — CLI (simplest):
```
npm i -g vercel
cd vercelversion
vercel            # first run links/creates the project
vercel --prod     # promote to production
```
Option B — Git: push this folder's repo to GitHub, then "Import Project" in the
Vercel dashboard (Framework preset: **Other**, output dir: this folder root).

`vercel.json` here sets the COOP/COEP headers Godot web needs for
SharedArrayBuffer (required if you enable threads in the export preset).
