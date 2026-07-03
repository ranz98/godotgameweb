# Hide & Seek — Web (Vercel)

Two things live here:
- **`webgame/`** — a standalone, lightweight **single-player** Godot project
  (Compatibility renderer, primitives only, no assets, no networking). This is
  what you export to the browser. It is **separate from the desktop project** —
  the desktop `.exe` game is untouched.
- **`index.html` + `vercel.json`** — what Vercel serves. Right now `index.html`
  is a placeholder; the Godot Web export replaces it.

The desktop game (multiplayer, GLB characters, ultra graphics) does **not** run
on web as-is: browsers can't do Forward+ (WebGL2 only), can't do ENet/UDP, and
the 150 MB of textures/GLBs are too heavy. So this web build is the lean core:
**walk around and hide in shadows, survive a countdown.**

## Export the web build (in Godot)
1. Open **`vercelversion/webgame/`** as a project in Godot (it's already set to
   the **Compatibility** renderer).
2. Project → **Export** → Add a **Web** preset (install the Web export templates
   if prompted).
3. **Export Project…** with the export path set to the **parent folder** as
   **`../index.html`** — i.e. it writes `index.html`, `index.wasm`, `index.pck`,
   `index.js` into `vercelversion/` (overwriting the placeholder).
4. Test locally: `python -m http.server` in `vercelversion/`, open the page.
   (Godot web needs to be served over http, not opened as a file.)

## Deploy
Because the repo is connected to Vercel, just commit & push:
```
git add -A && git commit -m "web build" && git push
```
Vercel redeploys automatically. `vercel.json` sets the COOP/COEP headers Godot
web needs.

⚠️ GitHub rejects files > 100 MB. This lean build should be well under that
(no big assets). If a future build's `.pck` is too big, deploy with the Vercel
CLI (`vercel --prod`) instead of git, or shrink assets.

## Online multiplayer later
See `MULTIPLAYER.md`. Short version: web needs WebSocket or WebRTC (not ENet),
and a server that isn't Vercel (PartyKit, or a small headless Godot server on
Fly/Render). That's a separate build on top of this.
