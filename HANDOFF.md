# Look Library — current state

A working collection of art direction looks, each written down as a recipe: the original source
plates, the method reduced to a paste-able treatment string, and four generated frames proving
the look survives a change of subject. It exists to elevate work at the sell-in stage and resist
the drift to mid caused by time and product constraints.

Operating docs are in `docs/`: start at `config.md`, then `run-procedure.md`. `how-it-runs.md`
covers the scheduled task, the draft gate and the doc sync.

## Live

| Thing | Where |
|---|---|
| Public site | https://look-library.netlify.app |
| Repo | bradhall4/Look-Library, linked to Netlify — deploying the page is a push |
| Netlify site id | c425ddf3-3686-495a-bcd7-4ac211ae25c6, team "2Player" |
| Supabase | llnydhsfqyeyvckypxmk. Others on the account belong to a different account |
| Flora workspace | ws_qd78p1ntmp1zkgrjb9n8hvv8117v9y4x |
| Notion | data source f9a55be3-b959-43aa-a6bb-7d6ee43523a5 |
| Routine | local Claude Code task `look-library`, Mon/Wed/Fri 4pm |

```
site/index.html      the entire site, one self-contained file
db/setup.sql         schema, RLS, storage bucket, look 001
docs/                operating docs, mirrored into public.runbook
logo/                the 2Player wordmark
```

## Architecture

- **Data:** `public.looks`, one row per recipe. RLS on; anon reads only `status = 'published'`.
- **Images:** public bucket `frames`. Plates at `look-NNN/ref-N.jpg`, frames at
  `look-NNN/<slug>.png`. Nothing depends on a URL we do not control.
- **Mirroring:** edge function `mirror-frame`, called from SQL via `net.http_post`. It exists
  because the run has no general HTTP client. Host allowlist plus a 25MB cap.
- **Site:** one HTML file, no build step, no dependencies beyond Google Fonts. Fetches
  `/rest/v1/looks` with the publishable key and normalises every row on the way in, so a
  malformed field degrades rather than throwing. **Adding a look never needs a deploy.**
- **Secrets:** `private_secrets`, RLS on with zero policies and privileges revoked.

## State of the library

Three entries, all published. See the ledger in `docs/config.md` for what each one is and what
it taught. Next look is **004**.

## Open items

1. Regenerate look 002's basketball frame — the weakest at 43% picture coverage.
2. Backfill products into 001 and 003 if consistency with the current format is wanted.
3. Cron is pinned to local 4pm and follows the machine's clock; no DST action needed.
4. No favicon. The 2Player wordmark is 4:1 and illegible at 16px; it needs the "2" glyph
   cropped into a square viewBox.
5. `~/Sites/look-library/index.html` is a stale copy from an early deploy attempt. Delete it.
6. A probe object sits at `_selftest/pg-net-probe.png` in the bucket. Harmless, invisible to the
   site, delete whenever the storage API is to hand.
7. The old Cowork scheduled task `trig_01KymtDDXVhBeybCWN4S4JUt` must stay disabled — two
   schedulers would race for the same look number.

## Security, do these

- **Revoke the GitHub PAT** `github_pat_11ABECVJI0…`. In the Cowork transcript, shell history
  and `private_secrets`. Never needed; `gh` is authorised independently.
- **Rotate the Supabase secret key** `sb_secret_rn3YBRMte…`. It bypasses RLS. The scheduled task
  uses it, so update it there afterwards.
- **Revoke the Netlify PAT** `nfp_NdE3cLSv…`. Also exposed, never usable.
- The publishable key in `site/index.html` is public by design and safe to commit.
