# Look Library

A working collection of art direction looks, each written down as a recipe: the original
source, the method reduced to a paste-able string, and four generated frames proving it
survives a change of subject.

Built and maintained by a scheduled Claude task that runs Monday, Wednesday and Friday at 4pm
Pacific. Each run finds a look, decomposes it, generates proof frames in Flora, and writes a row
to Supabase. The site reads that database at runtime, so it never needs redeploying.

## What's in here

```
logo/Logo Flat Black.svg   the 2Player wordmark
site/index.html            the whole site, one self-contained file
db/setup.sql               schema, RLS policy, storage bucket, and look 001
```

## Deploying

`site/index.html` is the entire site. No build step, no dependencies beyond Google Fonts.
Drag the `site` folder onto the `look-library` project in Netlify and it is live.

Automated deploys do not currently work: the Netlify MCP upload is refused from Claude's
sandbox (403) and from the local shell (fetch failed), so deploys are manual for now.

## The data

- **Supabase project** `llnydhsfqyeyvckypxmk` ("Look Library", in the 2Player org)
- **Table** `public.looks`, public read only. All writes go through the scheduled task.
- **Bucket** `frames`, public. Holds both the mirrored source plates (`look-NNN/ref-N.jpg`)
  and the generated frames (`look-NNN/<slug>.png`).
- **Edge function** `mirror-frame` copies images out of Flora into that bucket, so nothing on
  the site depends on a URL we do not control.

The publishable key in `index.html` is public by design and safe to commit. The secret key is
not in this repo and must never be.

## Adding a look by hand

Follow the shape of the insert at the bottom of `db/setup.sql`. `references_` takes
`{url, credit, note}` per source plate, `frames` takes `{role, caption, url}`, `card` takes
`{label, value}`, `palette` takes `{name, hex}`, `verdict` takes `{title, body}`.

The trailing underscore on `references_` is because REFERENCES is a reserved word in SQL.
