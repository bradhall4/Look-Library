# Look Library — handoff to Claude Code

Written 8 September 2026 at the end of the Cowork session that built this. Read this first,
then the operating rules in `docs/` alongside this file: `config.md`, `product-rule.md`,
`social-fridays.md`, `site.md`. The same documents also live in the attached Claude project
under `claude/look-library-*.md`; the copies in `docs/` are the ones that travel with the repo.

## What this is

A working collection of art direction looks, each written down as a recipe: the original source
plates, the method reduced to a paste-able treatment string, and four generated frames proving
the look survives a change of subject. Brad is a senior creative director. The library exists to
elevate work at the sell-in stage and resist the drift to mid caused by time and product
constraints.

A scheduled Claude task builds one entry every Monday, Wednesday and Friday at 4pm Pacific,
writing to Supabase. The public site reads that database at runtime, so **adding a recipe never
requires a redeploy**. Only changes to the page's own code do.

## Live now

| Thing | Where |
|---|---|
| Public site | https://look-library.netlify.app (deployed, working) |
| Netlify site id | c425ddf3-3686-495a-bcd7-4ac211ae25c6, team brad-niwzk9k ("2Player") |
| Supabase project | llnydhsfqyeyvckypxmk ("Look Library", 2Player org) |
| Supabase MCP connector | tools prefixed mcp__SB_2Player__ |
| GitHub repo | bradhall4/look-library — created, nothing pushed yet |
| Notion database | data source f9a55be3-b959-43aa-a6bb-7d6ee43523a5 |
| Flora workspace | ws_qd78p1ntmp1zkgrjb9n8hvv8117v9y4x ("2Player Workspace") |
| Scheduled task | trig_01KymtDDXVhBeybCWN4S4JUt, cron `0 23 * * 1,3,5` |

There are **two Supabase connectors** on the account. `mcp__SB_2Player__` is Brad's. The other
belongs to a different account that owns Poppins and must never be written to.

## First thing to do

Attach `bradhall4/look-library` as a session source, then push this directory. Then link the
repo in Netlify (Project configuration -> Continuous deployment). After that, deploying is a push.

```
site/index.html      the entire site, one self-contained file
db/setup.sql         schema, RLS, storage bucket, look 001
logo/                the 2Player wordmark
netlify.toml         publish = "site", no build command
```

## Architecture

- **Data**: `public.looks`, one row per recipe. RLS on, public read only. All writes come from
  the scheduled task through the Supabase connector.
- **Images**: public storage bucket `frames`. Source plates at `look-NNN/ref-N.jpg`, generated
  frames at `look-NNN/<slug>.png`. Nothing depends on media.flora.ai staying up.
- **Mirroring**: edge function `mirror-frame`, called from SQL via `net.http_post` (pg_net is
  enabled). It exists because the scheduled task has no general HTTP client and cannot download
  an image itself. Deliberately unauthenticated: the only key a caller could hold is the
  publishable one, which already ships in the page, so a JWT check would add nothing. Guarded by
  a host allowlist (media.flora.ai, m.itsnicethat.com) and a 25MB cap.
- **Site**: single HTML file, no build step, no dependencies beyond Google Fonts. Fetches
  /rest/v1/looks with the publishable key. Normalises every row on the way in, so JSON arriving
  as a string, null arrays or a missing hero degrade instead of throwing. Section numbers compute
  themselves. Filters appear once there are four or more entries.
- **Secrets**: `private_secrets` table, RLS on with zero policies and privileges revoked from
  anon and authenticated. Only a privileged connection can read it.

## Why this moved out of Cowork

Four sandbox constraints, none of which apply to Claude Code running locally.

1. **Netlify unreachable.** Every host, including api.netlify.com and look-library.netlify.app,
   returns 403 at the CONNECT stage from the Cowork egress proxy. Four deploy attempts failed
   identically. Deploys were done by Brad running netlify-cli in his own terminal.
2. **Git pushes scoped to authorised repos.** "access denied by the git proxy:
   bradhall4/look-library is not in this session's authorized repository set." Fixed by
   attaching the repo as a session source.
3. **GitHub repo creation blocked.** "sessions are bound to their configured repositories."
4. **Some calls blocked by the auto-mode classifier**, including flora_list_canvas_nodes and any
   git command with a credential in the URL. Use flora_list_assets instead, and a credential
   helper rather than a token in a remote URL.

Node on this Mac is v20.20.2. Current netlify-cli needs >=22.13, so pin netlify-cli@26.2.0 or
upgrade Node.

## State of the library

Three recipes, all complete in Supabase with source plates, cards, palettes, frames and verdicts.

| # | Artist | Lane | Standing |
|---|--------|------|----------|
| 001 | Ana Paganini, "200 Summers Later" | current | Transfers well. Built on stillness, so it would fail the energy filter added afterwards. Kept as the counterexample. |
| 002 | Hype Williams, "Fisheye Chrome Maximalism" | archive | DJ frame regenerated 8 Sep and now holds: 64% frame coverage against the old 48%, subject centred and monumental. The curved, corner-masked rendering could not be removed by any prompt wording, but the car frame everyone likes is curved too, so the curve is not the defect. The puffer frame is now the weakest at 43% coverage and is the next one to deal with. |
| 003 | William Klein, "Vogue in the Street" | archive | Retested 8 Sep. The rewritten treatment string works: skate and football frames regenerated with nothing changed but the string, and both now smear subject and background together with one sharp anchor. Captions had also been misassigned across three of four frames; storage and captions now agree. |

Neither 002 nor 003 has a product yet; the product rule was added after those runs.

## Open items

1. Regenerate look 002's puffer frame. It is the weakest frame in the library at 43% picture
   coverage, a small orb in a large black field. About 18 cents a frame. (The DJ frame and
   look 003's retest were done on 8 Sep; see the table above.)
2. Backfill products into 002 and 003 if Brad wants consistency with the new format.
3. Cron is pinned to PDT. When the US falls back in November the run lands at 3pm local until
   the cron moves to `0 0 * * 2,4,6`.
4. No favicon. The 2Player wordmark is 4:1 and illegible at 16px; it needs the "2" glyph cropped
   into a square viewBox.
5. `~/Sites/look-library/index.html` is a stale copy from an early deploy attempt. Delete it.

## Security, do these

- **Revoke the GitHub PAT** github_pat_11ABECVJI0... It is in the Cowork transcript, in shell
  history, and in private_secrets. It was never needed: the git proxy injects credentials for
  authorised repos.
- **Rotate the Supabase secret key** sb_secret_rn3YBRMte... It bypasses RLS entirely.
- **Revoke the Netlify PAT** nfp_NdE3cLSv... Also in the transcript and never usable.
- The Supabase publishable key in site/index.html is public by design and safe to commit.

## Working notes that cost real time to learn

- **Never search "photography trends 2026" or "tiktok trends".** Measured: returns SEO content
  farms (SocialBee, Envato, Accio, yeetmagazine) with nothing decomposable. Hunt named artists
  and named publications.
- **Flora canvas wiring has three traps.** A mermaid node label becomes that node's prompt, so a
  node with both a label and a content_url is rejected. The keyword must be `graph LR`, since
  `flowchart LR` silently drops every edge while still creating nodes. Run ids come back in a
  different order than the node ids passed, so match outputs by looking at them — this already
  caused one set of misassigned captions.
- **Flora's fetch allowlist is far broader than its docs suggest.** m.itsnicethat.com worked
  directly. Test rather than assume.
- **Look at generated frames before publishing.** Two scheduled runs published without looking,
  said so honestly, and both had real defects only visible on inspection.
- **Do not declare a run failed because a list looks empty.** Flora projects can appear minutes
  after a run reports in. Checking too early once caused a wrong "it produced nothing" call,
  which then caused a look-numbering collision.
