# Look Library — social Fridays

Read alongside `config.md` and `product-rule.md`.

**Monday and Wednesday stay as they are: the refined lane, archive and editorial.
Friday is social-first.** Set `mode` to `'refined'` or `'social'` on the row accordingly.

## What a Friday entry is

A visual treatment circulating on TikTok or Instagram right now, decomposed the same way
everything else here is. Same card, same treatment string, same four proof frames, same product
rule. What changes is where it came from and how the source is credited.

## The hard part, stated plainly

**Most of what trends on these platforms is a format, not a look.** A sound, a dance, a joke
structure, a caption convention. None of that decomposes into light and lens and grade, and none
of it is any use in a sell-in.

A Friday entry only qualifies if there is an actual visual treatment underneath: a grade, a
lighting trick, a lens or camera behaviour, a capture artefact, an edit rhythm, a colour rule.
"Everyone is using this transition" is not a look. "Everyone is shooting on the front camera
with the flash on in a dark room, and the blown-out foreground against black is the whole
aesthetic" is a look.

If a Friday scan turns up only formats and no treatments, say so and skip the run. A skipped
Friday beats a card describing a meme.

## Sourcing: editorial about the platforms, not the platforms

Brad's call, and it is the right one. Writing *about* trends is more reliable than scraping the
platforms, needs nothing to be awake at 4pm, and comes with a named writer who has already done
the work of deciding a thing is real.

**Use named editorial:** Dazed, i-D, The Face, Nylon, Hypebeast, Highsnobiety, Vulture, NYT
Styles, Garage, Business of Fashion, It's Nice That, Creative Review, Vogue's culture desk.

**Never use SEO content farms.** Measured: searching "tiktok trends 2026" and similar returns
SocialBee, Envato, Accio and yeetmagazine, all generated filler with nothing decomposable in it.
Search named publications, or search for the treatment itself, never for "trends".

**Optional enrichment:** the browser pane does load `tiktok.com/explore` fully, logged out, with
real thumbnails and creator handles. Verified. Use it to confirm a trend editorial claims is
happening actually looks like the description. Never depend on it. Server-side fetching of
TikTok is blocked by robots.txt and will always fail.

## Showing the source: links, not embeds, not mirrors

Archive plates get mirrored into the `frames` bucket because they are stills used as generation
reference. **Social content is neither mirrored nor embedded.** It is linked.

That keeps the platform serving its own content, keeps attribution with the creator, avoids
copying someone's post into Brad's storage, and keeps the site a single dependency-free file.

Record in the `social` column as an array of:

```json
{"platform":"tiktok","url":"https://www.tiktok.com/@handle/video/123",
 "creator":"@handle","note":"what the treatment is doing in this one"}
```

Put the editorial piece itself in `source_url` and `source_name`. Leave `references_` empty for
social entries unless there are stills genuinely worth mirroring as generation reference.

## Generation still happens

Four proof frames as always, one treatment string, four different subjects, the product in two
of them, never the control. The whole point is adapting a platform-native look into commercial
imagery. A Friday entry with no generated frames is a bookmark, not a recipe.

Expect these to be harder. Platform looks often depend on capture artefacts (front-facing lens
distortion, hard on-camera flash, heavy sharpening, compression, screen glare) that image models
smooth away by default. Name the artefact explicitly in the treatment string and say in the
verdict whether it survived.

## Credit

Name the creator in the card and in the verdict where the look is genuinely theirs rather than
ambient. If one person started it, say so. If the editorial names an originator, carry that
through.
