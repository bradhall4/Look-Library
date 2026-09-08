# Look Library — the run procedure

Read after `config.md`. This is the end-to-end sequence for one autonomous run, written so a
fresh scheduled session with no memory can complete a look and have it appear on the public
site without anyone touching anything afterwards.

The site reads Supabase at runtime. **Writing the row IS publishing.** There is no deploy step,
no build, no cache to clear, and nothing for Claude Code or a human to do afterwards.

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

## 5. Write the treatment string

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

## 9. Write the row

This is the publish. Every column below is what the site reads; anything omitted degrades
gracefully but leaves a hole on the page.

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
- `mode` is `refined` normally; `social` only for the Friday social format in
  `social-fridays.md`.
- Storage URLs are `https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/...`.

## 10. Confirm it published

```sql
select look_no, artist, product, jsonb_array_length(frames) as frames,
       jsonb_array_length(references_) as plates, hero_url is not null as hero
from public.looks order by look_no desc limit 3;
```

Then fetch the row the way the site does, to prove the public path works:

`https://llnydhsfqyeyvckypxmk.supabase.co/rest/v1/looks?select=*&order=look_no.desc&limit=1`
with header `apikey: sb_publishable_E3Bzai6bleUJp2YrYVwpWQ_pSjHD9Nf`

If that returns the new row, the site is already showing it. Nothing else is required.

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
| Publish | `insert into public.looks` | No |
| Site shows it | Runtime fetch, no deploy | No |
| Site *code* changes | git push, Netlify CD | Yes |

The only thing that needs a person is changing how the page itself looks or behaves. Adding
looks is fully self-contained.
