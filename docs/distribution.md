# Look Library — distribution

Where a published look goes after it is on the site. Read alongside `run-procedure.md`.

Nothing in here changes how a look is made. Distribution is a seventh step that runs **only
after** `publish_look` has succeeded, and it never gates publication — a look that fails to post
is still a published look.

## One rule that prevents the obvious mistake

The generated frames carry **no type, no logos, no layout**. That rule is about generation and it
does not change.

Export slides are a different artefact. A carousel slide is a designed page, and type on it is
expected. Set type in the layout, over or beside the frame — never ask an image model to render
words into a picture.

## Slack

The push is a single message per published look, sent as Brad through the Slack connector, so it
arrives from a person rather than a bot.

The message body is not composed by hand. It is rendered from the row:

```sql
select public.look_slack_post(9);
```

which returns, in order: the look number, artist and work; the hook, so the lesson travels with
the picture; the four frame URLs each on its own line with its caption, which Slack unfurls into
previews; the treatment string in a code block so it can be copied in one click; the product; the
source credit; and the deep link to the recipe.

The function is not `security definer`, so RLS applies to it exactly as it applies to the site: a
draft cannot be posted by accident.

### Sending it

| | |
|---|---|
| Workspace | **not yet decided** — see below |
| Channel id | **unset** |
| Tool | `slack_send_message`, or `slack_send_message_draft` where a human should see it first |

**In a shared workspace, post a draft, not a message.** The routine runs unattended on a
schedule. A draft lands in Brad's Slack for him to read and send; a message lands in front of
colleagues with nobody having looked at it. Use `slack_send_message` directly only in a channel
where Brad is the only reader.

If the channel is unset, skip the push, say so in the run report, and carry on. Never guess a
channel.

## Instagram carousel — not built, specified

The intent: turn each look into a carousel that teaches the look and hands over the recipe, so
the audience can run it themselves.

### Slide plan, ten slides

Built on the standard viral-carousel shape — hook, example, explanation, practical detail, one
call to action — with the look's own material in each slot.

| Slides | Job | Content |
|---|---|---|
| 1 | Stop the scroll | The strongest frame, full bleed. One short headline in type. Nothing else. |
| 2–3 | Build interest with an example | Two source plates, credited. This is the look in the wild. |
| 4–5 | Retain attention | The card rows that carry the mechanism — light, colour, lens, the device — set as type. One idea per slide. |
| 6–9 | Practical information | The treatment string broken into readable chunks, plus the remaining frames as proof it transfers. |
| 10 | Simple CTA | Where the full recipe lives, and an invitation to run the string. |

The headline for slide 1 is the one piece of new writing. Everything else already exists on the
row.

### What the API will and will not accept

Verified against Meta's content-publishing docs, September 2026.

- **JPEG only.** Frames are stored as PNG. The export needs a JPEG rendition; the PNG stays the
  master and is never replaced.
- **Ten items maximum**, which is why the plan is ten.
- **Every item must share one aspect ratio**, between 4:5 and 1.91:1. Use 4:5 — most feed height
  per slide.
- **Caption caps at 2,200 characters.** Treatment strings currently run 487 to 1,846 and hooks
  add another 300 to 550, so the two together do not reliably fit. **The treatment belongs on the
  slides, the caption carries the hook and the link.**
- Publishing is three calls: one container per slide with `is_carousel_item=true`, then a parent
  container with `media_type=CAROUSEL` and the children, then publish. Each container needs a
  moment to process before the next call.
- Source images must be publicly fetchable by Meta. The `frames` bucket already is.

### What is missing before any of this can run

1. An Instagram **professional** account (Business or Creator) for the library, linked to a
   Facebook Page.
2. A Meta app with `instagram_business_content_publish`. Posting only to an account Brad owns
   means the app can stay in development mode with him added as a role, which avoids app review.
3. A long-lived access token, stored in `private_secrets` — never in the repo.
4. A renderer for the slides. The site is one dependency-free HTML file and should stay that way;
   the natural home is a small separate export that reads the row and writes ten JPEGs.

Until 1 to 3 exist there is nothing to wire, and item 4 is the only part that can be built early.
