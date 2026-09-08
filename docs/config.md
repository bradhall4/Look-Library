# Look Library — running config

Standing setup for the three-times-a-week art direction look routine. A fresh scheduled
session should read this first: it holds every id the run needs and the ledger of what has
already been covered.

**Before writing anything to the ledger, read it first and take the next number after the
highest entry.** Two runs collided on 002 because a ledger entry was overwritten by hand.

## Selection filter — read before choosing anything

Brad is a senior creative director. These looks exist to be worked into live commercial
campaigns, not admired. Bias hard toward:

- **Commercially applicable.** Could this treatment survive a client, a product and a deadline?
- **Youth-facing.** Street, sport, music, skate, club, fashion, gaming, subculture. Not
  corporate, not sentimental, not middle-aged.
- **Full of energy.** Kinetic, loud, saturated, physical. Motion, flash, distortion, speed,
  colour. This is the axis Brad most wants and the one most likely to be missed, because the
  canonical "great photographer" reflex pulls toward stillness and restraint.

**Roughly one run in five may deliberately break this filter** for something too good to skip.
Brad explicitly wants to be surprised occasionally. Make it a real outlier, not a near-miss, and
say plainly in the write-up that it is a deliberate exception.

### What this does to the archive lane

Point the archive lane at the kinetic canon, not the contemplative one:

Hype Williams, William Klein, Jean-Paul Goude, David LaChapelle, Ari Marcopoulos, Larry Clark,
Nick Knight / SHOWstudio, Michel Gondry, Spike Jonze, Chris Cunningham, Jonas Akerlund, Guy
Bourdin, early skate video and 90s rave photography, Provoke-era Japanese street photography
(are-bure-boke: grainy, blurry, out of focus, as stated doctrine).

Contemporary: Gabriel Moses, Tyler Mitchell, Harley Weir, Jordan Hemingway, plus whoever is
currently shooting the sport and music work that gets ripped off.

### Energy is a mechanism, not a mood

Every kinetic look has a physical cause. The card carries an **Energy source** row for it:
shutter speed and whether blur is subject or camera; slow-sync or rear-curtain flash and the
ambient-to-flash ratio; lens width combined with subject proximity (wide and close is the single
most common cause); handheld amplitude, whip pans, camera mounted to the subject; saturation and
contrast pushed past documentary; cut rhythm and frame rate for motion looks.

A card that says "energetic, youthful feel" and stops has failed. Say what produces it.

## Schedule

Mon / Wed / Fri, 4:00pm America/Los_Angeles. Cron `0 23 * * 1,3,5` (4pm PDT).
Pinned to PDT: when the US falls back to PST in November the run lands at 3pm local until the
cron is moved to `0 0 * * 2,4,6`.

## Destinations

- **Supabase (the CMS):** connector `mcp__SB_2Player__`, project ref `llnydhsfqyeyvckypxmk`.
  **There are two Supabase connectors on this account. The other one belongs to a different
  account and must never be written to.** Verify with `get_project_url` before any write.
  - Table `public.looks`, public read RLS, writes via the connector only.
  - Public storage bucket `frames`, paths `look-NNN/<slug>.png` and `look-NNN/ref-N.jpg`.
  - Edge function `mirror-frame` at
    `https://llnydhsfqyeyvckypxmk.supabase.co/functions/v1/mirror-frame`, called from SQL with
    `net.http_post` (pg_net is enabled). Body `{"url": <flora url>, "path": "look-NNN/<slug>.png"}`,
    timeout 30000.
- **Public site:** `look-library.netlify.app`, Netlify site id
  `c425ddf3-3686-495a-bcd7-4ac211ae25c6`, team "2Player" (`brad-niwzk9k`). Reads Supabase at
  runtime, so it never needs redeploying when a look is added.
- **Notion:** "Look Library" database, data source `f9a55be3-b959-43aa-a6bb-7d6ee43523a5`.
- **Flora workspace:** `ws_qd78p1ntmp1zkgrjb9n8hvv8117v9y4x` ("2Player Workspace").
  One project per look, `LOOK NNN — YYYY-MM-DD — Artist, "Work"`.
- **Retired:** the old Artifact library. Do not republish it.

## Generation settings

4 generations per run, model `i2i-gemini-3-pro` (Nano Banana Pro), 2K, 1:1 unless the look
demands otherwise. Measured cost $0.18 each, $0.72 per run, roughly $9/month. Flora reports the
executed model id as `t2i-gemini-3-pro` even with reference edges wired; verified by eye that the
reference does reach the model, so ignore the reported id.

## Flora canvas wiring, with the traps

`flora_create_asset` with `project_id` set fetches the image server-side and lands it as its own
canvas node, id `mcp_upload_<asset suffix>`. Read ids with `flora_list_assets` (note:
`flora_list_canvas_nodes` has been blocked by the auto-mode classifier), then
`flora_add_to_canvas` with bare node ids on both sides of the edge. Then `flora_run_canvas_nodes`.

- A mermaid node label becomes that node's prompt, so a node declared with a label AND a
  `content_url` is rejected as mutually exclusive. Never declare reference nodes in the diagram.
- The keyword must be `graph LR`. `flowchart LR` is silently unrecognised and drops every edge
  while still creating the nodes.
- Run ids return in a different order than the node ids passed. Match outputs by looking at them.

Flora's fetch allowlist is far broader than its docs imply. `m.itsnicethat.com` worked directly.
Test rather than assume a host is blocked.

## Source list

Confirmed working: It's Nice That (images at `m.itsnicethat.com/original_images/`, fetchable by
Flora; cookie wall on articles, decline non-essential and continue). Frameset (`frameset.app`).

To pressure-test: Art of the Title, Creative Review, AIGA Eye on Design, Booooooom, Ads of the
World, Promonews, Vimeo Staff Picks, Dazed, i-D, Free Skate Mag, individual portfolios.
Institutional fallbacks when those 403: Wikimedia Commons, MoMA, Tate, ICP.

## Hard-won rules

- **Never search "photography trends 2026" or similar.** Generic trend queries return SEO
  listicle slop with nothing decomposable in it. Hunt named sources and named artists.
- **Four proof stills = four different subjects under one identical treatment string.** A look
  that only works on one subject is a photograph, not a look. At least one must be a modern,
  youth-facing, campaign-plausible subject.
- **State the frame as what IS in it.** Negative instructions get ignored by the model.
- **Look at the reference before writing the card, and at the output before publishing.**
- **Do not declare a run failed because a list looks empty.** Flora projects and rows can appear
  minutes after a run reports in. Check twice, some time apart, before concluding anything.
- Alternate lanes roughly half current / half kinetic archive.

## Ledger — looks already covered

Do not repeat an artist or treatment on this list. Next look is **004**.

| # | Date | Artist | Work | Lane | Status |
|---|------|--------|------|------|--------|
| 001 | 2026-09-04 | Ana Paganini | "200 Summers Later" | current | Transfers well, and the anachronism device is strong. But the look is built on stillness and would NOT pass the energy filter added after this run. Kept as a reference point for what the library is steering away from. |
| 002 | 2026-09-06 | Hype Williams | "Fisheye Chrome Maximalism" | archive | Car interior frame is strong. Three of four rendered a circular fisheye floating in black; treatment string since rewritten to say full-frame barrel distortion. DJ frame fails, regenerate it. |
| 003 | 2026-09-07 | William Klein | "Vogue in the Street" | archive | Proximity and crop right, subject came back frozen sharp so the slow-shutter mechanism did not transfer. Treatment string rewritten to say BOTH subject and background smear. Needs retesting. |
