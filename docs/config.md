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

### The two questions to ask before committing

1. **Is it exciting and vibrant?**
2. **Is the concept or approach applicable to an eye-catching advertisement?**

The second one is the sharper filter, and it is really asking: *is this look a portable
mechanism, or is it a subject?* A mechanism can be pointed at anything. A subject cannot.

- **Hype Williams passes.** Drown a room in one colour and light it only with what is in the
  room. That is a lighting instruction. It works on a car, a gym, a DJ, a phone.
- **Max Manavi-Huber passes.** Hard flash freezing the subject while the ambient drags a ghost
  off every edge. Also an instruction, also portable to anything that moves.
- **Lola Raban is the near miss.** Beautifully observed, but the look is welded to its subject —
  the specific world of fashion workers and their tools. Strip the subject away and there is no
  transferable instruction left, which means it cannot be pointed at a client's product. Good
  photography, wrong shelf.

If you cannot finish the sentence "the mechanism is ___ and you could point it at a running shoe
tomorrow", it is a subject and not a look. Put it back.

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

## Flora canvas: group the references, one group per output

**Do not dump every plate into every generation.** Sort the plates into themed groups during
decomposition, and wire each group to its own output node with its own prompt. A group of two or
three plates that share a mechanism gives the model a coherent instruction; all five at once
gives it an average.

Verified on a scratch canvas 10 Sep: two groups from the same artist, each with its own prompt,
produced two clearly distinct images that each carried their own group's DNA — one the vast
empty field and hard shadow of its pair, the other the mirror and the hands-over-face of its
pair, fused into a single new frame.

### Building it

```
flora_add_to_canvas(project_id, diagram, node_params)
```

```
graph LR
  genA["placeholder"]
  genB["placeholder"]
  mcp_upload_<a> --> genA
  mcp_upload_<b> --> genA
  mcp_upload_<c> --> genB
  mcp_upload_<d> --> genB
```

with `node_params` carrying the real prompt and settings per node:

```json
{"genA": {"prompt": "...", "model": "is2i-gemini-3-pro", "aspect_ratio": "3:2", "resolution": "2K"}}
```

Rules that bite:

- **`graph LR`.** `flowchart LR` is silently unrecognised and drops every edge.
- **Existing nodes appear as bare ids inside edges and are never re-declared.** This is add-only;
  re-declaring `n3["label"]` creates a *second* node instead of editing the first.
- **A node's mermaid label becomes its prompt**, which is why a node declared with both a label
  and a `content_url` is rejected. Declare new generation nodes with a throwaway label and set
  the real prompt through `node_params`, which overrides it.
- **The ids you wrote are not the ids you get.** The response returns a diagram with reassigned
  ids — `genA` came back as `n6`. Read them from the response; your own ids are not valid for
  running.
- **Adding a node does not run it.** Building the graph is free; only `flora_run_canvas_nodes`
  spends. So the structure can be laid out and checked before a penny goes out.
- Flora reads each group as a separate **Workflow** in `flora_get_canvas`, which is a free check
  that the wiring is what you intended.

### Running it

```
flora_run_canvas_nodes(workspace_id, project_id, node_ids=["n5","n6"])
```

**This returns one entry per node, each pairing `node_id` with its own `run_id`.** That is the
fix for the caption misassignment that hit looks 001–003: the two test runs above were created
two milliseconds apart — the exact condition that scrambled things before — and the mapping was
still unambiguous because every entry carried its node.

Earlier versions of this document said to avoid the canvas path and use one `flora_generate`
call per frame. That advice came from the old handoff notes and was never tested. It is wrong:
the canvas path is now preferred, because it groups references properly, keeps the prompt and
the model on the canvas as provenance, lets a single frame be re-run later without rebuilding
anything, and binds outputs to nodes explicitly.

`flora_generate` is still fine for a one-off, and it wires its own edges from
`reference_node_ids`. Use it when there is no grouping to express.

### Getting plates onto the canvas

`flora_create_asset` with `project_id` set fetches server-side and lands the image as its own
node, id `mcp_upload_<asset suffix>`. Read ids with `flora_list_canvas_nodes`. Flora's fetch
allowlist is far broader than its docs suggest — it pulled from Biscuit Filmworks, WhiteWall,
SHOWstudio and the Independent without complaint. Test rather than assume.

## Ledger — looks already covered

Do not repeat an artist or treatment on this list. Next look is **007**.

| # | Date | Artist | Work | Lane | Notes |
|---|------|--------|------|------|-------|
| 001 | 2026-09-04 | Ana Paganini | "200 Summers Later" | current | Transfers well; the anachronism device is the strong part. Built on stillness, so it sits outside the energy bias — treat as the reference entry for format, not for selection. |
| 002 | 2026-09-06 | Hype Williams | "Hype Flood" | archive | One saturated colour flooding the frame, practicals as the only light, crushed blacks, still deadpan subject inside architecture. Product: smart glasses. |
| 003 | 2026-09-07 | William Klein | "Vogue in the Street" | archive | 28mm at point-blank, 1/8 second so subject and background both smear with one sharp anchor. No product; predates the rule. |
| 004 | 2026-09-09 | Max Manavi-Huber | "Flash Against Nothing" | current | Hard flash freezes the athlete while the ambient exposure drags a translucent ghost off every frozen edge; camera on the ground, wide, body cropped at the jaw, half the frame left as empty sky, snow or black air. Product: sports drink can. Clean modern digital — no grain, deliberately not look 002's answer. |
| 005 | 2026-09-09 | Angelo Cerisara | "Close Enough to Sweat" | current | From the queue, so it overrode the rotation and gave two `current` runs in a row. Long lens uncomfortably close, camera locked square or straight down or low, the face never shown whole, moisture on every surface, one near-monochrome field per frame with exactly one saturated accent. Clean modern digital — Nano Banana Pro, not the film vocabulary of 002. Products: Google Pixel 10 and a lipstick, one per frame. Both product frames were regenerated once for being too glossy — the fix was naming the untidiness explicitly. Plates are frame grabs from Biscuit Filmworks; Instagram is not fetchable. |
| 006 | 2026-09-09 | Lola Raban | "Attributes of the Trade" | current | The near miss that produced the vibrancy test. Beautifully observed but welded to its subject, so nothing lifts out onto a product. Left published as the worked counter-example. |
| 007 | 2026-09-09 | Guy Bourdin | "Seen Twice" | archive | The mechanism is doubling — mirror, shadow, twin, or one body part repeated into pattern — inside a saturated colour collision, bodies held as props. Built for advertising: he ran Charles Jourdan for twelve years. Products: Google Pixel 10 and an ice cream cone. The sandals frame is subject matter, not a placement — Bourdin shot shoes for a living. First plate set was rejected: all five came from one It's Nice That article about the Charles Jourdan Polaroids, which captured that series rather than the artist. |
| 006 | 2026-09-09 | Lola Raban | "Attributes of the Trade" | current | **Deliberate exception** — restrained, still, no motion or flash, first off-axis run since 001. Sander-style trade typology: dead square to the subject, camera level, full-length or torso-cropped, flat ambient light, tools of the trade worn on the body, the room left exactly as found. Colour negative film — grain is load-bearing and only appeared once the medium led the prompt's first clause. GPT Image 2, not the Nano Banana Pro of 004/005. Products: Google Pixel 10 and a tan leather tote. The Pixel only reads at torso crop; at full length it is an unreadable slab. Queue was empty. |
