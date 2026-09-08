# Look Library — the public site

Companion to `config.md`. Covers the site itself: how it is built, how it gets data, and how to
deploy it.

## Live

`https://look-library.netlify.app` — deployed and working.
Netlify site id `c425ddf3-3686-495a-bcd7-4ac211ae25c6`, team "2Player" (`brad-niwzk9k`).

## Shape

One self-contained HTML file at `site/index.html`. No build step, no bundler, no dependencies
beyond Google Fonts. `netlify.toml` sets `publish = "site"` with an empty build command.

It fetches `/rest/v1/looks?select=*&order=look_no.desc` from Supabase with the publishable key,
which is public by design and safe to commit. **Adding a recipe therefore never requires a
deploy.** Only changes to the page's own code do.

## Design

- Newsreader (serif) for display and prose, IBM Plex Mono for technical data and labels. The
  serif is deliberate: a recipe reads as instruction.
- The 2Player wordmark appears twice and small, inlined as a data URI. Its typeface appears
  nowhere else. The mark has enough personality to run the whole page, and a reference library
  that looks like a games brand stops reading as reference.
- Cool near-white ground, printer's red as the only accent, hairline rules.
- A global nav sits in the masthead: Why, Index, Latest. They are buttons, not anchors, because
  the URL hash is already the deep link to a recipe (`#003`).
- Every source plate and frame opens in a fullscreen lightbox: one flat gallery per recipe with
  the plates first, arrow keys to step, Escape to close it without closing the recipe beneath.
- Arrow keys also step between recipes from the detail bar.
- Images hold their box with a shimmer and fade in as they decode, so the grid does not jump
  while full-size frames arrive.
- Index is one tile per look. Detail view is four numbered sections: **01 The source** (original
  plates, credited, each noting what it demonstrates), **02 The recipe** (ingredients, palette,
  the copyable method, the device underneath), **03 What it yields** (generated frames plus the
  honest verdict), **04 The workings** (Flora canvas, source article).
- Social entries get a "Doing the rounds" section of plain credited links instead of plates, and
  a red SOCIAL flag on the tile and detail header.

## Robustness

Rows are normalised on the way in, because the CMS is written by a scheduled task and by hand:

- JSON arriving as a string is parsed; unparseable degrades to empty rather than throwing.
- Null arrays, missing hero images, malformed palette hexes and missing cards all degrade.
- `hero_url` falls back to the first frame.
- Both `references_` and `references` are accepted.
- Section numbers compute themselves, so an entry with no source plates still reads 01, 02, 03.
- Broken images hide rather than leaving holes.
- Filters generate from the data and appear once there are four or more entries.

Smoke-tested against deliberately messy rows with no page errors.

## Deploying

`bradhall4/Look-Library` (capital L, hyphen — the lowercase name in older notes does not exist)
is pushed and linked in Netlify under Continuous deployment, so **deploying the page is a push
to `main`**. Adding a look still needs no deploy at all.

Fallback, from a machine with normal network access:

```
cd "~/Claude/Projects/2Player/Look Library/site"
npx -y netlify-cli@26.2.0 deploy --prod --dir=. --site=c425ddf3-3686-495a-bcd7-4ac211ae25c6
```

Pin `26.2.0` while Node here is v20.20.2 — current netlify-cli requires >=22.13.

Better: once `bradhall4/look-library` is pushed and linked in Netlify under Continuous
deployment, deploying is a git push.

## What does not work, and why

From a Cowork cloud session, **every Netlify host returns 403 at the CONNECT stage** of the
egress proxy: `api.netlify.com`, `app.netlify.com`, `netlify-mcp.netlify.app`, even
`look-library.netlify.app`. This is an org egress policy, not a Netlify auth problem, and it
cannot be routed around. Four separate deploy approaches failed identically before the cause was
found. Do not spend time re-diagnosing it.

Git pushes from a Cowork session are also scoped: the proxy will only inject credentials for
repositories attached as session sources. Claude Code with the repo attached does not have
either constraint.

## Known gap

No favicon. The 2Player wordmark is roughly 4:1 and illegible at 16px. It needs the "2" glyph
cropped out into a square viewBox as a separate `favicon.svg`.
