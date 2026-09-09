# Look Library — the run procedure

Read after `config.md`. This is the end-to-end sequence for one autonomous run, written so a
fresh scheduled session with no memory can complete a look and have it appear on the public
site without anyone touching anything afterwards.

The site reads Supabase at runtime, so there is no deploy step, no build and no cache to clear.

**But writing the row is no longer publishing.** Rows are written with `status = 'draft'`, and
RLS hides drafts from the site — the public page literally cannot see them. A look goes live
only when someone who can see images has looked at the frames and promoted it.

This exists because a scheduled cloud session has no browser and cannot see an image, so it
cannot perform the plate-comparison and caption-matching checks in steps 5 and 7. Every
unreviewed run so far has shipped a defect: a glass ball floating in black, captions on the
wrong pictures, subjects frozen when the whole look was a slow shutter. **If you cannot see the
frames, that is not a reason to stop — write the row as a draft and say plainly in your report
that it needs eyes.**

---

## 0. Verify you are pointed at the right database

There is more than one Supabase connector on this account and the other one belongs to a
different account. Call `get_project_url` first and confirm it returns
`llnydhsfqyeyvckypxmk`. If it does not, stop and say so. Never write to the other project.

## 1. Read the ledger, take the next number

Read the ledger table at the bottom of `config.md`. Take the next number after the highest
entry. Two runs once collided on 002 because this step was skipped.

Also read the existing rows so you do not repeat an artist:

```sql
select look_no, artist, work, lane, product from public.looks order by look_no;
```

## 2. Choose the look

Apply the selection filter in `config.md`: commercially applicable, youth-facing, full of
energy, roughly alternating current and kinetic-archive lanes. Hunt named artists and named
publications. Never search generic trend phrases.

## 3. Choose the product

Apply `product-rule.md`. One product, appropriate to the world the look already lives in,
described by physical form and never by brand name. Rotate the category away from recent runs.

## 4. Collect the source plates

Four or five frames by the artist that each demonstrate something specific. Mirror each into
storage so the site never depends on a third-party URL:

```sql
select net.http_post(
  url := 'https://llnydhsfqyeyvckypxmk.supabase.co/functions/v1/mirror-frame',
  body := jsonb_build_object('url', '<source image url>', 'path', 'look-NNN/ref-1.jpg'),
  headers := '{"Content-Type":"application/json"}'::jsonb,
  timeout_milliseconds := 30000);
```

The call is asynchronous. Confirm each one landed before moving on — do not assume:

```sql
select id, status_code, content::jsonb->>'ok' as ok, content::jsonb->>'path' as path
from net._http_response order by id desc limit 10;
```

The function only accepts `media.flora.ai` and `m.itsnicethat.com`. For any other host, put the
image on the Flora canvas first and mirror from the `media.flora.ai` URL that comes back.

## 5. Decompose the plates, THEN write the treatment string

This is the step that decides whether the look replicates, and it is where look 002 failed.

**The treatment string is a description of the plates in front of you, not of the artist's
reputation.** The failure mode is writing what you know about the artist — what they are famous
for, what a critic would say about them — instead of what is visibly true of the five images
you actually chose. The model then obeys the words over the pictures, and you get a frame that
matches the description of the artist and looks nothing like their work.

### 5a. Build the evidence table first

Open each plate. For each one, write down only what is observable:

| | Lens & geometry | Light | Colour | Subject placement | Capture medium & texture | Who is in frame |
|---|---|---|---|---|---|---|
| ref-1 | | | | | | |
| ref-2 | | | | | | |
| ref-3 | | | | | | |
| ref-4 | | | | | | |
| ref-5 | | | | | | |

Describe what is there, not what it evokes. "Straight lines stay straight, no barrel
distortion" is an observation. "Signature fisheye maximalism" is a memory.

**Capture medium is a column in its own right and is the easiest one to forget.** Film stock or
video format, grain size, how soft the optical detail is, whether highlights bloom and clip,
whether blacks are clean or muddy and compressed, whether there is chroma noise in the shadows.
A treatment that gets colour and staging right but omits the medium produces a clean modern
digital image wearing the look as a costume — too sharp, too much dynamic range, too much
micro-contrast. If the plates are 1990s video, say so and describe the degradation.

**"Who is in frame" is also a column, and the model will get it wrong by default.** Image
models default to white subjects unless told otherwise. If the plates depict a specific
community — and a body of work almost always does — then reproducing the look with a generic
cast is both unfaithful to the references and erases the culture the work came from. Write the
casting into the subject clause with the same specificity you would give a lens: who these
people are, their ages and builds, how they are styled. Vary it across the four frames rather
than shooting the same person four times.

### 5b. Keep only what the majority of plates support

**Every clause in the treatment string must be true of at least three of the five plates.**
Anything supported by fewer than two is a reputation feature: cut it, however strongly you
associate it with the artist. If a feature appears in exactly two, it may go in only as a
qualified option ("often", "in some frames"), never as a core instruction.

Then read the finished string back against the table and ask, clause by clause: *which plates
show this?* If you cannot name them, the clause is invented.

### 5c. Worked example of getting it wrong

Look 002's string told the model the subject's "body bows outward", the "architecture bends
into a curve", "straight lines bow at the borders", the key bounces off "chrome, patent leather
or metallic surface", and the subject sits "dead centre, filling and slightly overwhelming the
frame".

Not one of those five things is present in any of the five plates. The plates are undistorted,
have no chrome in them, and place the subject mid-size inside a large dark interior. What the
plates actually share is a single saturated colour flooding the whole frame, practical fixtures
as the only light source, crushed detail-free blacks, and a still deadpan subject standing
inside architecture rather than filling the frame.

The string described the Hype Williams everyone remembers. The plates are the Hype Williams that
was chosen. The model did what it was told, which is why three of four frames came back as a
glass ball floating in black.

Looks 001 and 003 replicated well precisely because their strings are literal readings of their
plates — Hasselblad, open shade, muted green-grey; 28mm, 1/8 second, pushed grain.

### 5d. Beating the AI sheen — the model is half the job

A correct treatment string still comes back looking rendered rather than photographed: skin
too clean, everything evenly lit and legible, crowds arranged facing camera, fabric with a
plastic sheen. That is not a fault in the string, and no amount of technical camera language
fixes it. It is the model's house style, and the fix is partly a different model and partly a
different **kind** of instruction.

Tested on look 002, eight ways, same plates and same subject (8 Sep 2026):

| | Approach | Model | Result |
|---|---|---|---|
| A | Full technical string | Nano Banana Pro | Sharp, glossy, arranged. 3–5× the plates' detail energy. |
| B | Same string | Krea 2 References | Plate-range texture |
| C | Same string | Flux 2 Pro | Very sharp |
| D | Same string | Flux Kontext Max | Plate-range texture |
| E | Terse, let plates carry it | Krea 2 References | Plate-range texture |
| F | VHS degradation language | Nano Banana Pro | Closer, still clean |
| G | Scanned scratched print | Flux 2 Max | Sharpest of all — asking harder for degradation did the opposite |
| **H** | **Anti-gloss: materials and people** | **GPT Image 2** | **Chosen. The only one that reads as documentary.** |

**What won was describing people and materials, not cameras.** The H prompt said: skin matte
and uneven with visible pores and blemishes, shine only where sweat actually sits; fabric
creased and worn, pilled and scuffed at the cuffs; nothing retouched, nothing symmetrical,
nobody posed like a model; ordinary-looking people with ordinary faces, caught standing still
rather than styled; the crowd half-turned away and partly occluded rather than facing camera.

The result had matte unlit skin, a crowd doing its own thing, genuine unreadable darkness
instead of everything exposed, a matte creased jacket instead of a glossy balloon, and real
clutter in frame — an exit sign, speaker boxes, a pillar cropping the edge.

### A second pass got it the rest of the way

The chosen approach was still a little too composed and too well exposed. Three additions closed
it, and they are worth adding to any look that needs to read as photographed:

- **Crushed darks, stated as a refusal.** "Most of the frame falls away into unreadable dark and
  stays there; do not expose for legibility." Models want everything visible; say that you do not.
- **Accidental framing, described concretely.** Subject pushed off-centre toward one edge, heads
  and limbs cropped by the frame, a shoulder or the back of a head blocking the near foreground,
  horizon slightly off level, dead space where a composed shot would not leave it. "Imperfect
  framing" on its own does nothing — name the specific accidents.
- **Attitude over pose.** "Real attitude and effortless swagger — people who know the camera is
  there and do not care, caught mid-movement between poses rather than arranged in one." This
  replaced an earlier instruction to be "still and deadpan", which had flattened the subjects
  into mannequins. Deadpan is not the same as absent.

Measured against the plates (grain/detail energy 1.5–2.2), the progression on the club frame was
7.1 for the original technical string, 2.9 for the anti-gloss brief, and 2.8 after this pass,
with the share of the frame in true black rising to 71%.

### What generalises, and what does not

Everything above was learned on one look. Most of it is specific to that look. Keep the method,
throw away the settings.

**Always, for any look:**

- Decompose the plates before writing anything, and keep only what three of five support.
- **Describe the model's output failure in the vocabulary of the failure.** Look 002 came back
  too glossy, so the fix was language about skin, fabric and behaviour. A look that comes back
  too muddy, too flat, too busy or too static needs the opposite vocabulary. The transferable
  rule is *name the axis you are failing on and write to it* — not "add grain".
- **Match the model to the medium in the plates**, and test at least two before settling.
  Escalating the prompt cannot make a model do what it does not do.
- Check the output against the plates, not against your prompt.

**Only when the plates call for it:**

- Grain, crushed blacks, halation, muddy compression, soft mushy detail, anti-gloss language
  about pores and worn fabric, accidental framing, swagger caught mid-movement, GPT Image 2 at
  1k. **All of that is Hype Flood's answer, not the library's.**

**The worked counter-example.** `config.md` points the archive lane at David LaChapelle, among
others. LaChapelle is glossy on purpose: saturated, hyperreal, immaculate skin, elaborate
constructed staging, everything lit and legible. Running the look-002 conclusions on a
LaChapelle plate set would destroy it — anti-gloss language, crushed blacks and accidental
framing are all *precisely wrong* there. The correct treatment for LaChapelle would ask for
retouched perfection, deliberate symmetry, and a composed frame, and would probably pick a
different model for exactly that reason.

The same applies to a clean modern studio look, a bright daylight fashion look, or anything
shot digitally. If the evidence table says the plates are sharp, clean and evenly lit, then
sharp, clean and evenly lit is the correct answer, and Nano Banana Pro is likely the better
model.

**If a treatment string you are writing could have been written without opening the plates, it
is wrong.** That test catches both failure modes: writing the artist's reputation, and pasting
forward the last look's settings.

### 5e. Then write it

One paragraph, no line breaks, that works pasted in front of any subject. State the frame as
what IS in it — negative instructions get ignored. Name the physical cause of the energy, not
the mood.

## 6. Generate the four proof frames — one call per frame

**Use `flora_generate`, once per frame. Do not use the mermaid-graph
`flora_run_canvas_nodes` path for proof frames.**

`flora_generate` returns one `run_id` per call, so each output is bound to the frame you asked
for. The canvas-graph path returns run ids in a different order than the nodes were passed,
which is how looks 001, 002 and 003 all shipped with captions on the wrong pictures. One call
per frame removes the entire class of bug.

```
flora_generate(
  workspace_id = "ws_qd78p1ntmp1zkgrjb9n8hvv8117v9y4x",
  project_id   = "prj_<the look's project>",
  type         = "image",
  model        = "is2i-gemini-3-pro",
  prompt       = "<treatment string>\n\nSubject: <the subject clause, with the product if this is a product frame>",
  params       = {"resolution": "2K", "aspect_ratio": "1:1"},
  reference_node_ids = ["mcp_upload_...", ...]
)
```

The model id is **`is2i-gemini-3-pro`** (Nano Banana Pro). Not `i2i-`, not `t2i-`. A wrong id
fails the call. Measured cost $0.18 per frame, $0.72 per run.

Four frames, four different subjects, one identical treatment string. At least one modern,
youth-facing, campaign-plausible subject. The product appears in exactly two of the four; the
control frame is always the clean one.

Keep a written map of `run_id -> intended role and caption` as you go.

## 7. Look at every frame before you write anything

This is the step that has failed most often. Two published runs skipped it and both shipped
defects that were obvious the moment someone opened the images.

For each frame, open it and check:

1. **Does it match the caption you intend to give it?** Match by eye, never by position in a
   list. Three looks out of three got this wrong.
2. **Does it actually look like the source plates?** Put the plate and the output side by side.
   The failure mode is the model taking a word in the treatment literally instead of
   reproducing what the plates show. Look 002 said "fisheye" and got a glass ball floating in
   black rather than a Hype Williams frame. If the output does not resemble the plates, the
   treatment string is describing a word, not the look — rewrite it and regenerate.
3. **Did the mechanism transfer?** Name the specific physical thing the look depends on and
   confirm it is present. Slow shutter means the subject smears too, not just the background.
4. **Did the product survive?** Readable, naturally placed, no mangled logos, no invented type.

A frame that fails any of these gets regenerated, not published with an apology in the verdict.

## 8. Mirror the frames into storage

Same `net.http_post` call as step 4, with `look-NNN/<slug>.png` paths. Slug names must describe
the actual content, so that a file called `dj.png` is the DJ frame. Confirm each landed.

### Never overwrite a storage path that has already been published

**Replacing a frame means writing to a NEW path**, e.g. `look-NNN/v2/<slug>.png`, and pointing
the row at it. Storage sits behind a CDN. Overwriting an object at a path that has already been
served leaves stale copies cached at edges you cannot see, so the row is correct, the origin is
correct, and the reader still gets the old picture. Old objects are harmless once nothing links
to them; leave them.

This cost real time on look 002. Captions updated instantly because they come from the database,
while the images stayed on the previous version for the reader — the exact combination that
makes it look like a caption bug rather than a caching one.

**Verify the way a browser would.** A plain, header-free GET:

```
curl -s -o out.png "<public url>"     # then compare the checksum to the file you meant to publish
```

Do not verify with `Cache-Control: no-cache`, and do not verify with a `?t=` cache-buster. Both
bypass exactly the cache that is about to serve the reader the wrong image, so both report
success while the page is wrong. Checking from one machine also only proves one edge; a fresh
path is the only thing that proves it everywhere.

## 9. Write the row as a draft

Every column below is what the site reads; anything omitted degrades gracefully but leaves a
hole on the page. `status` defaults to `'draft'`, so simply do not set it.

```sql
insert into public.looks (
  look_no, captured_on, artist, work, lane, era, disciplines,
  hook, treatment, device, energy_source, product, mode,
  palette, card, verdict, frames, references_, social,
  hero_url, flora_url, source_url, source_name
) values (
  4,                              -- look_no, from the ledger
  current_date,                   -- captured_on
  'Artist Name',
  'Work or body of work',
  'archive',                      -- 'current' or 'archive'
  '1998',                         -- era
  array['photography','music video'],
  $hook$Two sentences. Who the artist is, how they work, and what the look consists of. This is a lesson, not a teaser: someone who has never heard of them should come away knowing the approach.$hook$,
  $tx$The full treatment string, one paragraph, paste-able in front of any subject.$tx$,
  $dev$The transferable idea underneath, which works even with none of the craft attached.$dev$,
  $en$The physical cause of the energy: shutter, flash ratio, lens width and proximity, handheld amplitude, saturation.$en$,
  $pr$sport sunglasses — wraparound, single curved lens, matte black, iridescent coating$pr$,
  'refined',                      -- mode: 'refined' or 'social'
  $pal$[{"name":"Name","hex":"#112233"}]$pal$::jsonb,
  $card$[{"label":"Capture","value":"..."},{"label":"Energy source","value":"..."}]$card$::jsonb,
  $vd$[{"title":"...","body":"..."}]$vd$::jsonb,
  $fr$[{"role":"Control","caption":"...","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-004/<slug>.png"}]$fr$::jsonb,
  $rf$[{"url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-004/ref-1.jpg","credit":"Artist Name","note":"What this plate demonstrates."}]$rf$::jsonb,
  $so$[]$so$::jsonb,
  'https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-004/<hero slug>.png',
  'https://app.flora.ai/projects/<canvas id>',
  'https://<source article>',
  $sn$Source Name$sn$
);
```

Notes that matter:

- `references_` has a trailing underscore because REFERENCES is a reserved word. The site
  accepts either spelling but write `references_`.
- `hook` is the description under the title on the page. It must be **1–2 sentences teaching
  the artist, their approach and what the look entails** — not a tagline.
- `card` should carry an **Energy source** row as well as the `energy_source` column.
- `frames` roles used so far: Control, Modern transfer, Sport, Night, Environment, Tonal
  extreme, Object transfer. The control frame is the clean, product-free one.
- **Frame captions are editorial captions, not prompt fragments.** Write what a picture editor
  would write under the image: short, concrete, describing what is in the frame. Do not paste
  back pieces of the generation prompt. "Free-throw line, empty court" is a caption. "Basketball
  player at the free-throw line, empty court, wearing the glasses" is a prompt with the
  scaffolding still attached. Match the house style set by look 001: "Period figure on modern
  tarmac", "Trestle table, meal finished".
- `mode` is `refined` normally; `social` only for the Friday social format in
  `social-fridays.md`.
- Storage URLs are `https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/...`.

## 10. Confirm the draft landed

```sql
select look_no, artist, product, jsonb_array_length(frames) as frames,
       jsonb_array_length(references_) as plates, hero_url is not null as hero
from public.looks order by look_no desc limit 3;
```

Add `status` to that select and confirm it says `draft`. The row will NOT appear on the public
REST endpoint, and that is correct — drafts are invisible to the site by design.

## 10b. Review and promote — needs a session that can see images

A person, or any session with image vision (Claude Code on the Mac), opens the four frames and
the plates and checks steps 5 and 7 for real: does each frame resemble the plates, did the
mechanism transfer, does each caption match the picture above it, did the product survive.

Fix anything that fails — remembering that replacing a frame means a **new storage path** — then:

```sql
select * from public.publish_look(4);
```

To see what is waiting:

```sql
select look_no, artist, work, status, captured_on from public.looks
where status = 'draft' order by look_no;
```

Going back to instant publishing, if the review queue is ever not worth it, is one policy:
`using (status = 'published')` becomes `using (true)`.

## 11. Update the ledger

Append the row to the ledger table in `config.md` with an honest one-line status, including
anything that failed or needed regenerating.

---

## What autonomy depends on

| Need | Mechanism | Needs a human? |
|---|---|---|
| Pick a look and write the recipe | The scheduled session | No |
| Fetch and mirror source plates | `net.http_post` to `mirror-frame` | No |
| Generate frames | `flora_generate`, one call per frame | No |
| Move frames into storage | `net.http_post` to `mirror-frame` | No |
| Write the draft | `insert into public.looks` | No |
| Look at the frames | Needs image vision | **Yes** |
| Publish | `select public.publish_look(N)` | **Yes** |
| Site shows it | Runtime fetch, no deploy | No |
| Site *code* changes | git push, Netlify CD | Yes |

The only thing that needs a person is changing how the page itself looks or behaves. Adding
looks is fully self-contained.
