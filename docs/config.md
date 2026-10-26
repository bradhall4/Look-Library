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

**Hunt commercial photography, not high art.** Campaign work, advertising, fashion and music
imagery — pictures made to sell something. The gallery canon is not the pool; the pool is the
work that already has a client attached, because that work has solved the exact problem this
library exists to solve.

The default bias, which most runs should satisfy:

- **Vibrant.** Saturated, high-contrast, colour used as a decision rather than as whatever the
  room was doing.
- **Dynamic.** Motion, flash, distortion, speed, physicality. Something is happening.
- **Cool and hype-y.** The work that gets screenshotted, reposted and ripped off. If nobody is
  copying it, it is not the shelf.
- **Trendy.** Of right now, or the thing right now is quoting.
- **Comedic or stylistic.** Absurdity played straight, staging pushed past the plausible, a
  visual joke or a hard stylistic conceit. This axis is new and it is the one most likely to be
  under-served, because the photographic reflex pulls toward seriousness.

A look only needs to be strong on two or three of these. A look that is strong on none of them
is not vibrant enough for this shelf, however well made it is.

**Roughly one run in five may go outside commercial work** — fine art, documentary, archive —
but only when the mechanism is so strong it obviously lifts into a campaign. Say plainly in the
write-up that it is a deliberate exception, and prove the lift rather than asserting it.

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

**Comedic and surreal commercial.** TOILETPAPER (Cattelan & Ferrari), Nadia Lee Cohen, Juergen
Teller, Martin Parr, Charlie Engman, Torbjørn Rødland, Tim Walker, Maurizio Cattelan. Absurdity
shot dead straight is the richest untapped seam here.

**Hyper-saturated and stylistic.** Miles Aldridge, David LaChapelle, Daniel Sannwald, Mert &
Marcus, Erik Madigan Heck, Viviane Sassen, Glen Luchford.

**Contemporary hype.** Gabriel Moses, Renell Medrano, Micaiah Carter, Campbell Addy, Myles
Loftin, Quil Lemons, Tyler Mitchell, Ronan Mckenzie, Bolade Banjo, Oliver Hadlee Pearch, Jordan
Hemingway, Harley Weir, Thomas Prior, Ryan McGinley, Petra Collins, Carlota Guerrero.

**Campaigns worth decomposing as campaigns**, not as photographers: Jacquemus (surreal scale
comedy), Loewe, Diesel, Marc Jacobs, Moncler, Bottega Veneta, Nike and Jordan, Aesop, Skims.

**Commercial directors with a photographic look.** Traktor, Tom Kuntz, Andreas Nilsson, Ringan
Ledwidge, Martin de Thurah, Vincent Haycock, Daniels.

**The best single source of names is an agency roster** — Art Partner, Art + Commerce, Webber,
CLM, Management+Artists, Streeters, Anderson Hopkins. These are lists of working commercial
photographers with portfolios attached, which is exactly the pool, and they update constantly.

Award archives are the other reliable seam: Cannes Lions, D&AD, Lürzer's Archive, Ads of the
World, and Campaign's and Adweek's best-of rounds.

Sources that work for images: It's Nice That (`m.itsnicethat.com/original_images/` is fetchable
by Flora), Frameset, Biscuit Filmworks and other production-company director pages. Flora's
fetch allowlist is far wider than its docs suggest — WhiteWall, SHOWstudio and the Independent
all worked. **Never search generic trend phrases** — they return SEO listicles with nothing
decomposable in them. Hunt named photographers, named campaigns, named rosters.

Already used, do not repeat: see the ledger.

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

For proof frames use `flora_generate`, one call per frame, passing the plates as
`reference_node_ids` and varying the prompt. This is the method.

Grouping the plates into themed subsets, each wired to its own output node on the canvas, was
built and tested on 10 Sep and the results were not better — rejected on the pictures, not on
the plumbing. Do not rebuild it. (For the record, the canvas path does bind outputs to nodes
correctly; `flora_run_canvas_nodes` returns one entry per node with its own `run_id`. The
scrambled-ids warning in earlier versions of this file was inherited from the old handoff notes
and is not true. It is simply not the reason to avoid the path — the output quality is.)

## Ledger — looks already covered

Do not repeat an artist or treatment on this list. Next look is **019** — take the number from `max(look_no)` in `public.looks`, not from this table: 012–014 exist as unpublished drafts and are not ledgered.

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
| 008 | 2026-09-11 | Ari Marcopoulos | "Proof of Custody" | archive | Back on the energy bias after the 006 exception. The mechanism is the burned-in quartz date stamp — small orange dot-matrix digits in a corner, horizontal at bottom right in a landscape frame and turned onto the left edge in an upright one, because the stamp sits at a fixed point on the film gate. Pocket compact on consumer colour negative, 38mm, available light only, subject dead centre at standing eye height, location left as found. Plates deliberately span 2011–2017 and two sources (It's Nice That plus his own site) so the set is one instrument across his range, not one series. **GPT Image 2 refuses the full plate set**: two plates — a child, and an identifiable Jay-Z — trip the content checker and every prompt carrying them failed in ~12s with GENERATION_PROMPT_MODERATED. Generating from the other three plates cleared it. Brad notes Seedance 5 as an alternative model when this happens. Both landscape frames were regenerated once: the model put the stamp rotated on the left edge in a horizontal frame, which is physically impossible, fixed by stating the orientation rule explicitly. Products: Google Pixel 10 and over-ear headphones — both tech, deliberately opposite materials (held glass vs worn matte fabric), which is a harder transfer test than two unrelated categories. Queue was empty. |
| 009 | 2026-09-11 | TOILETPAPER | "Straight Face" | current | Back to `current` after two archive runs, and the first entry on the comedic/hard-stylistic axis the selection filter flags as most under-served. The mechanism is deadpan delivery: exactly one wrong thing — a substitution, a scale error, or an object doing a job it was never made for — inside an otherwise correct picture, shot with catalogue light and catalogue framing so nothing in the frame acknowledges it. Hard frontal flash close to the lens axis, perpendicular camera (dead level or directly overhead), saturated seamless field or a built corner with the wall/floor join left visible, warm organic subject against a cold field. Nano Banana Pro (`is2i-gemini-3-pro`), chosen because the plates are clean glossy studio digital — deliberately not look 008's GPT Image 2, and the model's glossy house style is correct here rather than a fault. Plates span three commissions (Kenzo KENZINE Vol.3 2014, Dazed/Yohji AW14, Dakis Joannou 2013); the TOILETPAPER magazine pages found via the Michela Natella set-design feature sharpened the read but were rejected as plates because each carries a printed TOILETPAPER logo stamp that would teach the model to render type. Products: Google Pixel 10 and a glass fragrance bottle (beauty, rotating away from 008's tech pairing). Two frames regenerated once each: the Pixel came back with a corner camera module until the bar was described as spanning rail to rail, and the outdoor frame's pasta read as a stiff dry bunch against an all-cool palette until the shirt was made tomato red and the spaghetti explicitly named as cooked and wet. The Google G still renders soft and would need comping. Note for reuse: "warm subject on a cold field" is true of four of five plates but as a standing rule it pushed three of four frames onto blue-green — name the field colour per frame. Queue was empty. |
| 010 | 2026-09-14 | Loris Russier | "Small in the Field" | current | From the queue (entry 2), so it overrode the rotation. A motion director, so every plate is a frame grab — five jobs, 2023–2026, pulled from PRETTYBIRD rather than his own reel site as the queue note instructed. The mechanism is ratio: one continuous field of a single material running unbroken edge to edge and given the great majority of the frame, the subject alone and centred inside it, reading as one flat tone at maximum contrast, one light behind or above, camera square to the world. Not look 002 — Hype floods a neutral room with coloured light and keeps the subject big; here the colour belongs to the material itself and the subject is given less frame than its surroundings. **Both candidate models were tested on the same prompt and the pictures decided it, not the table.** GPT Image 2 pushed the scale further but rendered the sand smooth and empty at 1280px; Nano Banana Pro (`is2i-gemini-3-pro`) held the dense fine texture the look depends on at 2752px, so it won despite being 009's model too. Note for reuse: the aerial variant kills any product — a phone at that scale is a speck — so both product frames had to use the eye-level variant. The night frame was regenerated once: the first attempt lit the whole car park evenly, and the fix was stating positively that the space is unlit and that the only light in the picture is the phone screen. Making the product the single light source satisfies the one-source rule and keeps it readable, but only works for objects that emit light. Products: Google Pixel 10 and a tomato-red quilted puffer (fashion, rotating away from 009's beauty). No Google G rendered at all, which is cleaner than a mangled one. |
| 011 | 2026-09-16 | Hans Feurer | "The Covered Eye" | archive | Self-selected; queue was empty, and archive was due after two `current` runs. The mechanism is occlusion: one object brought into physical contact with the face so it covers the eyes edge to edge and runs out past two frame edges, leaving the mouth as the only face, with the covering carrying the single non-skin colour and the background emptied to one continuous tone. Hard high sun as the only source, long lens wide open, head cropped at the top edge, pore-level skin texture. Plates deliberately span 1980s Kenzo-era transparency to Vogue Germany 2017 and two sources (It's Nice That plus his own portfolio), so the set is one device across forty years rather than one series. **GPT Image 2 refuses this plate set** — `GENERATION_PROMPT_MODERATED` in ~14s, almost certainly the two near-nude Kenzo-era plates, the same failure class as look 008. That forced Nano Banana Pro (`is2i-gemini-3-pro`) for a third run running; it was not a taste decision and next run should deliberately test a different model. Products: Google Pixel 10 and an unlabelled glass soda bottle (food and drink, rotating away from 010's fashion). The bottle is the best product frame the library has produced — laid across the eyes with the sun behind it, it is simultaneously the covering, the colour rule and the light effect, throwing an orange caustic onto the cheek. **The phone is the standing problem:** three attempts and the Pixel camera bar never spanned rail to rail, defaulting to an older Pixel visor panel even when described as a plain physical band rather than a camera. That looks structural, not verbal — the crop shows the phone edge-on and cropped, so any product identified by a detail on a flat face will lose it here. No mangled type or invented logo rendered at all, which is the cleaner failure. One frame regenerated twice; the first attempt also put a parapet and skyline behind the subject and the two-material reading collapsed, fixed by stating positively that the whole background is open sky. **Process note:** one plate was mirrored from the wrong index and was not noticed until the storage copies were opened at the end — the gold-wrapped figure, not the mint hooded coat. The frames were already generated from it, so the fix was to correct the reference note and cut the one treatment clause (wet gloss past the lip line) that dropped to 2 of 5 plates without the intended plate. Verify plates by opening the mirrored copy, not by trusting the download index. |
| 015 | 2026-10-10 | Martin Parr | "Flash at the Buffet" | archive | Self-selected; queue was empty. Second archive run in a row, chosen deliberately: the comedic axis is still the most under-served and Parr is its most-copied commercial source. The mechanism is light out of proportion to the subject — a flash fired from the lens in broad daylight at arm's length, camera looking steeply down at hands, laps and plates, faces cropped off, one loud saturated field per frame, older ordinary bodies, everything already handled, and one small absurd adjacency played straight. Plates span three sources and twenty-five years: Real Food (1994–2015, via Hyperallergic), the 2018 Gucci watch campaign (It's Nice That) and Gucci Cruise 2019 (Creative Review) — the Gucci work is the proof it was bought commercially unchanged. Two Real Food plates with large printed type (the God Bless America cookie, the Spam tins) were rejected as plates so the model would not learn to render type. **Model chosen by bake-off on the control prompt:** GPT Image 2.5 Flare (`is2i-gpt-image-2-5-flare`, 2k, ~$0.16/frame, ~35s) beat GPT Image 2 (~$0.30, softer, less saturated, cocktail stick floating loose) — which breaks the three-run Nano Banana Pro streak (009–011) as 011 asked, and is the first published look on Flare. No moderation trouble: no children, celebrities or nudity in the plates. Products: Google Pixel 10 and a blank tangerine sun cream tube (beauty, rotating away from 011's food). No regenerations — all four passed first time. The downward-from-behind angle shows the back of a held phone, so the Pixel camera visor and G rendered cleanly for once; note the model draws the visor as the real Pixel 10's inset pill rather than a rail-to-rail bar, which is correct to the device. The model renders crisp digital rather than film grain — closer to the Gucci plates than to Real Food; grade for the film version. |
| 016 | 2026-10-12 | Miles Aldridge | "Dressed for the Wrong Room" | current | Self-selected; queue was empty, and `current` was due after two archive runs (011, 015). Hyper-saturated and stylistic with a dark domestic comedy, so it sits on the vibrant and comedic axes without repeating 015's found-flash answer: this comedy is designed, not noticed. The mechanism is glamour out of proportion to the occasion — one person styled to a full 1960s film-star finish, set down in an ordinary room doing something mundane, wardrobe dyed the exact colour of the set, two or three saturated hues colliding, something gone slightly wrong that nobody reacts to, a sullen, glazed or screaming face and never a smile, one hard key with plenty of fill. Plates are five Vogue Italia-era prints spread across series (I Only Want You To Love Me #1, A Perfect Mum #4, Dog Lady #2, Actress #6, A Family Portrait #13), pulled from 1stdibs/Christophe Guye listings, uploaded to Flora by signed URL and mirrored from media.flora.ai; the Family Portrait was cropped locally to strip the gallery's white margins. Rejected as plates for legible type: the Heinz ketchup print (A Drop of Red), the diner with a Tabasco label (A Precious Glam), the vanity with a Grand Marnier label (Actress #4), and the brick-wall frame with Nike-marked footballs. Charlie Engman and Gabriel Moses were considered and put back — Engman's fetchable work is welded to its subject (his mother) and partly nude; Moses's low-key dark field is too close to 002. **Model chosen by three-way bake-off on the Control prompt:** GPT Image 2.5 Flare (`is2i-gpt-image-2-5-flare`, 2k, ~$0.16) won on the pictures — it alone built the whole room from the colour pair and matched the shoes to the bench; Nano Banana Pro left the walls grey and muted, Seedream 5 Pro (first test in the library) went dark and gritty with deep shadow pools. Same model as 015, but chosen by this run's test on these plates. No moderation trouble despite children in two plates, consistent with Flare clearing what GPT Image 2 refuses. Products: Google Pixel 10 in lemongrass, held back-to-camera under a salon hood dryer (G and the real three-lens visor rendered clean), and a blank tomato-red ketchup squeeze bottle that has just shot a stripe down a dress shirt (food, rotating away from 015's beauty) — the bottle matches the booth and jacket, so the colour rule absorbs the product rather than spotlighting it. Casting deliberately moved off the plates' near-uniform white models: Black, South Asian, Latino and East Asian subjects across four decades; the look did not move, which shows the period finish is the mechanism. No regenerations — all four passed first time. Note for reuse: this look needs a dressed set and matched wardrobe; without the colour discipline the styling reads as fancy dress, and a smile kills it. |
| 017 | 2026-10-23 | Erik Madigan Heck | "Colour as the set, 2012–2015" | current | Self-selected; queue was empty, and `current` was due after 015 (archive) and 016 (current). The mechanism is the set replaced by one saturated colour: one hue fills the whole frame, the figure is dressed in a contrasting hue, the horizon is removed and most of the frame is left as empty field, with hard even light from no visible source and no cast shadow on the field. Plates are five single-subject frames across 2012–2015 and three clients (Junya Watanabe 2015, Guinevere Van Seenus 2014, Drôle d'Oiseau 2014, Study In Purple 2012, Red, White & Blue 2014), all from one Surface feature. Two of the five are right-hand panels cropped locally from two-panel Surface composites, mapped to their titles by colour because the page's caption order does not confirm which panel carries which title. Rejected: an Amazon feature portrait (a white-backdrop portrait with none of the field mechanism), and an ETRO campaign set whose host does not resolve. **Model chosen by plates, no bake-off:** Nano Banana Pro (`is2i-gemini-3-pro`), because the plates are clean studio digital with a glossy finish. The model keeps full three-dimensional modelling on skin and cloth, where Heck flattens to block form, so the verdict is that the colour device transfers and the flattening does not. Products: Google Pixel 10 (matte sage, held to the ear) and a compact matte black camera (rotating, tech; the last tech product was 008's headphones). Regenerations: the camera frame twice, first for a hard straight edge across the body, then for a plinth edge; a head-and-shoulders crop with the field running to the bottom edge fixed it. Cast moved off the plates' pale fashion models: Black, South Asian, East Asian and Afro-Caribbean adults. Slack push skipped: no channel configured. Cost: six runs at $0.18, $1.08 total. |
| 018 | 2026-10-26 | David LaChapelle | "The Casualty Sells the Shoes" | archive | Self-selected; queue was empty, and archive was due after two `current` runs (016, 017). Comedic and hyper-saturated, on the axis the filter calls most under-served, without repeating 015's found flash or 016's designed glamour: this comedy is slapstick aftermath. The mechanism is the casualty as mannequin — a fully styled person lies flattened and faceless under a giant inflatable version of an ordinary consumer thing (crab, burger), the cause still in frame, debris scattered round, so the legs and shoes inherit the hero position; wide lens at ground level along the legs or steeply overhead, hard strobe at full power against daylight, one lacquered red against grass green or asphalt, colour transparency gloss. Plates span 1994–2005 from the studio's own site (davidlachapelle.com, a Wix site whose images only resolve from the per-work pages): Crustacean Invasion, Death by Hamburger and Spectator Sport (all 2001, the inflatable device), Untitled (Sofa) 2005 and Untitled (Walk of Fame) 1994 (the aftermath gag without an inflatable), uploaded to Flora by URL and mirrored from media.flora.ai. Rejected: the Happy Socks 2013 campaign (strong, commercial, but dancers mid-pose — a different mechanism, and near-nude), Lavazza 2002 (printed LAVAZZA type on the props, 523px), Diesel Make Love Not Walls (type and layout), and the Coca-Cola and Wonder Bread prints (legible marks). The Walk of Fame star carries a printed name and was kept as location. **Model chosen by three-way bake-off on the Control prompt:** GPT Image 2.5 Flare (`is2i-gpt-image-2-5-flare`, 2k, $0.156) won on strobe and saturation; Nano Banana Pro came back flat and ambient at 1408px; Seedream 5 Pro rendered the transparency-film finish best but lit with sun rather than strobe — worth testing for the period version. **Flare's first Control attempt was refused (GENERATION_PROMPT_MODERATED) when the string said accident and body**; rewording to cartoon slapstick, subject explicitly unhurt, cleared it with the same five plates, and is the right brief anyway. Products: a plain unmarked tomato-red running shoe (footwear, rotating away from 017's tech) on a flattened runner, soles to the lens — the most product-native look the library has had — and Google Pixel 10 held up by a casualty still filming under a giant rubber duck, seen from overhead so the back shows: full-width camera bar and G rendered clean. Cast moved off the plates' white fashion models (Black, South Asian, East Asian, Afro-Caribbean), though with faces removed it reads mostly through skin and styling. No regenerations — all four passed first time. Slack push skipped: no channel configured. Cost: two bake-off frames rejected ($0.18 NBP, $0.194 Seedream), one moderated Flare attempt, four Flare frames at $0.156; about $1.15 total including the refused attempt, $1.00 if it was not charged. |
