# Web multiplayer options

The desktop game uses Godot's high-level multiplayer over **ENet (UDP)**.
**Browsers cannot do UDP**, so the exact desktop netcode will not run on web.
Also: **Vercel cannot host the realtime server** — Vercel functions are
short-lived, but a multiplayer game needs a persistent connection. Vercel hosts
the *client*; something else hosts the *server*.

## Option A — WebSocketMultiplayerPeer (least code change) ✅ recommended first
Swap `ENetMultiplayerPeer` for `WebSocketMultiplayerPeer`. This keeps ALL of the
existing high-level netcode (MultiplayerSpawner, MultiplayerSynchronizer, the
@rpc calls) — you only change how the peer is created.
- Web clients connect with `wss://your-server`.
- The **server** must be a **headless Godot instance** running
  `WebSocketMultiplayerPeer.create_server()`. A browser cannot be the server.
- Host that headless server on a platform that allows long-lived processes:
  **Fly.io / Render / Railway / a VPS** (free tiers exist). NOT Vercel, NOT
  PartyKit (PartyKit runs JS, not Godot).
- Needs `wss://` (TLS) because the Vercel page is https.

## Option B — PartyKit (web-native, more work)
PartyKit runs *your TypeScript* on Cloudflare's edge (WebSockets + rooms +
state). It pairs nicely with a Vercel front-end. BUT PartyKit cannot run Godot,
so you can't use Godot's high-level multiplayer through it. Instead you would:
- Use Godot's low-level `WebSocketPeer` in the client to connect to the PartyKit
  room URL.
- **Rewrite the netcode as explicit messages** (JSON or bytes): join, spawn,
  position updates, hide, tag, phase/timer, roles, scores — i.e. re-implement
  what MultiplayerSpawner/Synchronizer/@rpc do today, by hand.
- Write the **PartyKit server** (`server.ts`) that relays messages and holds
  authoritative match state (roles, caught, timer).
This is the most scalable/serverless-friendly path and fits Vercel, but it's a
real rewrite of `game.gd`/`player.gd` networking.

## Option C — WebRTC (true browser P2P)
`WebRTCMultiplayerPeer` gives real peer-to-peer in the browser, but needs a tiny
**signaling server** (WebSocket) to broker connections — PartyKit or a small
Node server can be that signaler. More moving parts than A.

## Recommendation
- Fastest to working web multiplayer: **Option A** (WebSocket peer + a cheap
  headless Godot server on Fly/Render). Reuses today's code almost entirely.
- If you specifically want the **PartyKit + Vercel** stack: **Option B**, and
  budget for a netcode rewrite + a `server.ts`.

A single-player / local web demo (no online) works on Vercel with zero server.
