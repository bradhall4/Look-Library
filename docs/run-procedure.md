# Look Library — the run procedure

One run produces one entry. Read `config.md` first for the ids and the ledger.

The job in six steps:

1. Find a look — an auteur, a cultural niche, or a current trend.
2. Pull their references.
3. Decompose it: the principles underneath, and the technique on the surface.
4. Generate new frames from those references, with a placeholder product in some of them.
5. Look at the frames and judge them against the references.
6. If they hold, publish.

---

## 0. Point at the right database

`get_project_url` must return `llnydhsfqyeyvckypxmk`. Several Supabase connectors are attached
and the others belong to a different account. Anything else, stop.

## 1. Find a look

Read the ledger in `config.md`, take the next number, and do not repeat an artist.

**Check the queue first.** Brad adds artists and looks he wants covered:

```sql
select * from public.queue_next();
```

If it returns a row, that is the look — take it, and honour the note. The queue overrides the
selection filter, including the rotation: a queued artist gets made whether or not it fits the
current bias. After the look publishes:

```sql
select * from public.queue_mark_used(<queue id>, <look_no>);
```

If a queued entry turns out to be unworkable — no usable references anywhere, or the body of
work has no decomposable look in it — set its status to `'skipped'` with a reason in the note
rather than silently self-selecting past it, and say so in the report.

**Only when the queue is empty**, self-select using the selection filter in `config.md`. Hunt
named artists and named publications; generic trend queries return listicles with nothing
decomposable in them.

Whichever way the look arrived, the plates decide everything after this. A queued name is a
starting point, not a decision about what the look is.

## 2. Pull the references

Four or five frames by the artist, each demonstrating something specific.

**Spread them across the artist's range, not one series.** The plates you choose define the look
you capture, so five images pulled from a single article or a single campaign will give you that
campaign rather than the artist. Look 007 was built twice for exactly this reason: the first five
plates all came from one piece about Bourdin's Charles Jourdan Polaroids, which produced a
faithful decomposition of *that trick* and missed the far bigger mechanism running through his
work. If every plate shares a prop, a client or a year, go and find others before writing a word. Mirror each into
storage so the site never depends on someone else's URL:

```sql
select net.http_post(
  url := 'https://llnydhsfqyeyvckypxmk.supabase.co/functions/v1/mirror-frame',
  body := jsonb_build_object('url', '<source image url>', 'path', 'look-NNN/ref-1.jpg'),
  headers := '{"Content-Type":"application/json"}'::jsonb,
  timeout_milliseconds := 30000);
```

Asynchronous — confirm each landed rather than assuming:

```sql
select id, status_code, content::jsonb->>'ok' as ok, content::jsonb->>'path'
from net._http_response order by id desc limit 10;
```

The function accepts `media.flora.ai` and `m.itsnicethat.com` only. For any other host, put the
image on the Flora canvas first and mirror from the `media.flora.ai` URL that comes back.

## 3. Decompose — open the plates first

**Open every plate and look at it before writing a word.** This step decides whether the look
replicates, and every failure the library has had traces back to skipping it.

Two things come out of this, and the entry needs both:

**The principle.** Why the look works, where it came from, what problem the artist was solving.
The idea that survives when none of the craft is attached. This is the part worth stealing.

**The technique.** What is physically true of these frames: lens and geometry, light, colour,
subject placement, capture medium and texture, and who is in the frame. Every kinetic look has a
physical cause — name it, never describe a mood.

Two rules keep this honest:

- **Every clause in the treatment string must be true of at least three of the five plates.**
  Fewer than two and it is a reputation feature — cut it, however strongly you associate it with
  the artist. Read the finished string back clause by clause and ask *which plates show this?*
- **If the treatment string could have been written without opening the plates, it is wrong.**
  That catches both failure modes: writing the artist's reputation, and pasting forward the last
  look's settings.

Two things the model gets wrong unless told, and both belong in the string:

- **Capture medium.** Film stock or video format, grain, softness, whether highlights bloom,
  whether blacks are clean or muddy. Omit it and you get a clean modern digital image wearing
  the look as a costume.
- **Casting.** Image models default to white subjects. A body of work almost always depicts a
  specific community; reproducing the look with a generic cast is unfaithful to the reference
  and erases the culture it came from. Write casting with the same specificity as a lens, and
  vary it across the four frames.

The treatment string itself is one paragraph, no line breaks, that works pasted in front of any
subject. State what IS in the frame — negative instructions get ignored.

## 4. Generate

Four frames, four different subjects, one identical treatment string. At least one modern,
campaign-plausible subject. Two products per `product-rule.md` — one of them always a Google
Pixel 10, the other rotating — one product per frame and never the same object twice. The
control frame stays clean.

**Put the imperfections in the string, every time.** The default output of any image model is
too clean, too symmetrical and too new, and product frames drift that way hardest. Name what is
untidy: handled surfaces, worn counters, uneven skin, off-centre framing, dust, fingerprints.
Take the specifics from the plates — whatever is actually scuffed or crooked or greasy in them
is what belongs in the string.

**One `flora_generate` call per frame.** Never match outputs to captions by position — canvas
runs return ids in a different order than the nodes were passed, and that has put captions on
the wrong pictures more than once.

**Pick the model against what the plates are**, not out of habit. See `config.md`. If two
attempts fail the same way, change the model rather than escalating the wording — a model cannot
be talked into a house style it does not have.

## 5. Judge the frames against the references

Open every frame. For each one:

- Does it resemble the **plates**, or only the words? Put them side by side.
- Did the mechanism transfer — the specific physical thing the look depends on?
- Does the caption match the picture, matched by eye?
- Did the product survive: readable, naturally placed, no mangled logos or invented type?

Anything that fails gets regenerated, not published with an apology attached.

**Never overwrite a storage path that has already been published.** Replacement means a new
path, e.g. `look-NNN/v2/<slug>.png`. Storage sits behind a CDN, so overwriting leaves stale
copies at edges you cannot see: the row is right, the origin is right, and the reader still gets
the old picture. Verify with a plain GET — no `?t=` cache-buster, no `Cache-Control: no-cache`,
because both bypass the exact cache that would serve the reader the wrong image.

## 6. Publish

Follow the shape of look 001, which is the reference entry: <https://look-library.netlify.app/#001>

**Write about the look, not about the picture.** The principles, the history, the technique, and
how to reproduce it. A verdict that narrates what is literally in the frame is wasted space —
the frame is right there. Frame captions are the exception: those stay short and concrete, in
the style of "Period figure on modern tarmac".

```sql
insert into public.looks (
  look_no, captured_on, artist, work, lane, era, disciplines,
  hook, treatment, device, energy_source, product, mode,
  palette, card, verdict, frames, references_, social,
  hero_url, flora_url, source_url, source_name
) values (...);
```

| Column | What it carries |
|---|---|
| `hook` | One or two sentences teaching the artist, their approach, and what the look is. A lesson, not a teaser. |
| `treatment` | The paste-able string. |
| `device` | The transferable idea that works with none of the craft attached. |
| `energy_source` | The physical cause of the energy. |
| `card` | Technical rows: capture, light, colour, tonality, lens, composition, performance, casting. |
| `verdict` | Judgement at the level of principle — what transfers, what it depends on, where it breaks. |
| `frames` | `{role, caption, url}`. Roles used so far: Control, Modern transfer, Sport, Night, Environment, Tonal extreme, Object transfer. |
| `references_` | `{url, credit, note}` per plate. Trailing underscore because REFERENCES is reserved. |
| `product` | Short physical description plus category. |

`status` defaults to `'draft'` and RLS hides drafts from the site — do not set it. A run that
cannot see its own frames should stop here and say so; a draft costs nothing.

When all four frames have been looked at and hold:

```sql
select * from public.publish_look(<look_no>);
```

Confirm as a reader would, then append the ledger line in `config.md` and push.
