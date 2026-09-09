# Look Library — running config

Standing setup for the routine. Read this first, then `run-procedure.md` for the six steps of a
run. Also here: `product-rule.md`, `site.md`, `social-fridays.md`, `how-it-runs.md`.

**Read the ledger before writing to it** and take the next number after the highest entry. Two
runs once collided because that was skipped.

## What the library is for

Brad is a senior creative director. These looks exist to be worked into live commercial
campaigns, not admired. Every entry is a recipe: the source, the method reduced to a paste-able
string, and four frames proving it survives a change of subject.

## Selection filter

Find a look from **an auteur, a cultural niche, or a current trend**.

The default bias, which most runs should satisfy:

- **Commercially applicable.** Could this survive a client, a product and a deadline?
- **Youth-facing.** Street, sport, music, skate, club, fashion, gaming, subculture.
- **Full of energy.** Kinetic, loud, saturated, physical. Motion, flash, distortion, speed,
  colour. This is the axis most likely to be missed, because the canonical "great photographer"
  reflex pulls toward stillness and restraint.

**Roughly one run in four or five should deliberately break that bias** — high-brow, classic,
restrained, or otherwise off-axis. Rotate across high and low brow, classic and modern. Make it
a real outlier rather than a near-miss, and say plainly in the write-up that it is a deliberate
exception.

Energy is a mechanism, not a mood. Every kinetic look has a physical cause: shutter speed and
whether the blur is subject or camera; flash ratio; lens width combined with subject proximity;
handheld amplitude; saturation and contrast pushed past documentary. A card that says
"energetic, youthful feel" and stops has failed.

### Where to look

Kinetic archive: Hype Williams, William Klein, Jean-Paul Goude, David LaChapelle, Ari
Marcopoulos, Larry Clark, Nick Knight / SHOWstudio, Gondry, Jonze, Cunningham, Åkerlund, Guy
Bourdin, early skate video, 90s rave photography, Provoke-era Japanese street photography.

Contemporary: Gabriel Moses, Tyler Mitchell, Harley Weir, Jordan Hemingway, and whoever is
currently shooting the sport and music work that gets ripped off.

For the deliberate exceptions: the classical and high-brow canon is fair game — Penn, Leiter,
Deakins, Sander — provided the entry still explains how to reproduce it commercially.

Sources that work: It's Nice That (images at `m.itsnicethat.com/original_images/` are fetchable
by Flora), Frameset. Institutional fallbacks when a site 403s: Wikimedia Commons, MoMA, Tate,
ICP. **Never search generic trend phrases** — they return SEO listicles with nothing
decomposable in them.

## Schedule

Mon / Wed / Fri, 4pm America/Los_Angeles, run by the local Claude Code task `look-library`.
See `how-it-runs.md`.

## Destinations

- **Supabase**, project ref `llnydhsfqyeyvckypxmk`. Several Supabase connectors are attached and
  the others belong to a different account — verify with `get_project_url` before any write.
  - `public.looks`, one row per entry. RLS: anon reads only `status = 'published'`.
  - Storage bucket `frames`, public. `look-NNN/<slug>.png`, `look-NNN/ref-N.jpg`.
  - Edge function `mirror-frame` at `/functions/v1/mirror-frame`, called from SQL via
    `net.http_post`. Body `{"url": ..., "path": ...}`. Host allowlist, 25MB cap.
- **Site:** `look-library.netlify.app`, reads Supabase at runtime, so adding a look never needs
  a deploy. Repo `bradhall4/Look-Library`, linked to Netlify — deploying the page is a push.
- **Flora workspace:** `ws_qd78p1ntmp1zkgrjb9n8hvv8117v9y4x`. One project per look,
  `LOOK NNN — YYYY-MM-DD — Artist, "Work"`.
- **Notion:** data source `f9a55be3-b959-43aa-a6bb-7d6ee43523a5`.

## Generation

Four frames per run, one `flora_generate` call per frame, passing the plate node ids as
`reference_node_ids`.

**Choose the model against what the plates are.** This matters as much as the treatment string,
and prompting harder cannot make a model produce a house style it does not have.

| Plates are… | Use | Notes |
|---|---|---|
| Photographic, film-era, degraded, documentary | `i2i-gpt-image-2-i2i` | ~$0.27/frame, 90–220s. Leave `resolution` at 1k; higher reintroduces crispness. Picks up the plates' dimensions on its own. |
| Clean, modern, glossy, hyperreal, studio | `is2i-gemini-3-pro` | ~$0.18/frame, faster, composes cleanly. Its house style is glossy, which is a fault only when the look is not. |

Other image-to-image models are available via `flora_list_models`; test two before settling if
neither obviously fits. Note the prefix trap: `i2i-gemini-3-pro` is not a real id, the working
one is `is2i-gemini-3-pro`, and Flora reports executed ids with an `is2i-` prefix regardless of
what you passed.

Getting a model to stop rendering plastic is a matter of describing **people and materials**
rather than cameras — skin, fabric, how people behave, what is left un-composed. Whether you
want that at all depends entirely on the plates.

## Flora canvas notes

`flora_create_asset` with `project_id` set fetches server-side and lands the image as its own
node, id `mcp_upload_<suffix>`. Read ids with `flora_list_canvas_nodes` or `flora_list_assets`.
Flora's fetch allowlist is broader than its docs suggest — test rather than assume.

For proof frames use `flora_generate`, never the mermaid canvas-graph path: it returns run ids
in a different order than the nodes were passed.

## Ledger — looks already covered

Do not repeat an artist or treatment on this list. Next look is **006**.

| # | Date | Artist | Work | Lane | Notes |
|---|------|--------|------|------|-------|
| 001 | 2026-09-04 | Ana Paganini | "200 Summers Later" | current | Transfers well; the anachronism device is the strong part. Built on stillness, so it sits outside the energy bias — treat as the reference entry for format, not for selection. |
| 002 | 2026-09-06 | Hype Williams | "Hype Flood" | archive | One saturated colour flooding the frame, practicals as the only light, crushed blacks, still deadpan subject inside architecture. Product: smart glasses. |
| 003 | 2026-09-07 | William Klein | "Vogue in the Street" | archive | 28mm at point-blank, 1/8 second so subject and background both smear with one sharp anchor. No product; predates the rule. |
| 004 | 2026-09-09 | Max Manavi-Huber | "Flash Against Nothing" | current | Hard flash freezes the athlete while the ambient exposure drags a translucent ghost off every frozen edge; camera on the ground, wide, body cropped at the jaw, half the frame left as empty sky, snow or black air. Product: sports drink can. Clean modern digital — no grain, deliberately not look 002's answer. |
| 005 | 2026-09-09 | Angelo Cerisara | "Close Enough to Sweat" | current | From the queue, so it overrode the rotation and gave two `current` runs in a row. Long lens uncomfortably close, camera locked square or straight down or low, the face never shown whole, moisture on every surface, one near-monochrome field per frame with exactly one saturated accent. Clean modern digital — Nano Banana Pro, not the film vocabulary of 002. Product: lipstick (beauty), rotating off tech and food. Plates are frame grabs from Biscuit Filmworks; Instagram is not fetchable. |
