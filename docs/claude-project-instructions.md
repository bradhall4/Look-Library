# What to put in the Claude project

The scheduled cloud task should hold **only this short block**. Everything it needs lives in
the database and is refreshed from this git repo, so the instructions below never go stale and
never need editing again.

**B is the one to paste** into the Claude project's instructions, replacing everything (and
delete the old `claude/look-library-*.md` copies — they are now a second source of truth and
will drift). **A is a free dry run**: paste it once first to prove the plumbing before spending
about $1.10 on a real run.

---

## A. Dry run — checks the plumbing, generates nothing, costs nothing

```
Look Library — plumbing check only. Do not generate anything and do not write any look.

1. get_project_url on the Supabase connector must return llnydhsfqyeyvckypxmk. Several
   Supabase connectors are attached and the others belong to a different account. If it is
   not that ref, stop.
2. select public.runbook_fetch();      -- wait ~5 seconds
   select doc_slug, http_status, doc_bytes, applied from public.runbook_apply();
   select slug, length(body), updated_at from public.runbook order by slug;
3. select look_no, artist, work, product from public.looks order by look_no desc limit 3;
4. Fetch this as a reader would, with no auth beyond the key and no cache-busting:
   https://llnydhsfqyeyvckypxmk.supabase.co/rest/v1/looks?select=look_no,artist&order=look_no.desc&limit=1
   header  apikey: sb_publishable_E3Bzai6bleUJp2YrYVwpWQ_pSjHD9Nf
5. Confirm Flora is reachable: flora_list_workspaces, and confirm
   ws_qd78p1ntmp1zkgrjb9n8hvv8117v9y4x is present.

Report: which of the five passed, the exact failure for any that did not, and the highest
look_no currently published. Change nothing.
```

## B. The real run — paste this as the scheduled task's prompt

```
You are running the Look Library routine. Work autonomously and report honestly at the end.

1 — CONFIRM THE DATABASE
get_project_url must return llnydhsfqyeyvckypxmk. Several Supabase connectors are attached
and the others belong to a different account. If it is not that ref, stop and say so.

2 — LOAD THE OPERATING DOCS
  select public.runbook_fetch();      -- wait ~5 seconds
  select doc_slug, http_status, applied from public.runbook_apply();
  select slug, body from public.runbook order by slug;
If a doc reports applied = false, continue on what is stored and say which may be stale.
config = selection filter, ids, ledger.  run-procedure = the sequence and the INSERT that
publishes.  product-rule = the product.

3 — DO THE RUN
Follow run-procedure exactly. In outline: read the ledger and take the next number; choose a
look and a product; mirror four or five source plates; build the evidence table and write the
treatment string from the plates alone; generate four frames with one flora_generate call per
frame; open and check every frame; mirror them; insert the row.

4 — NON-NEGOTIABLES. Each of these has broken a previous run.
- Write the treatment from the plates, never from what the artist is famous for. If the string
  could have been written without opening the plates, it is wrong.
- Do not paste forward the last look's settings. Grain, crushed blacks and anti-gloss language
  are one look's answer, not the house style. Pick the model against what the plates are.
- One flora_generate call per frame. Never match outputs to captions by position.
- Open every frame before writing the row and match each to its caption by eye.
- Never write to a storage path that has already been published. Replacing a frame means a new
  path, e.g. look-NNN/v2/<slug>.png.
- Verify images with a plain GET. No ?t= cache-buster, no Cache-Control: no-cache — both hide
  the stale-CDN failure you are checking for.
- Captions describe the picture, not the prompt.

5 — WRITE THE ROW AS A DRAFT
`status` defaults to 'draft' — do not set it. RLS hides drafts from the public site, so an
unreviewed look cannot reach the page. Do NOT stop because you cannot see the images: a
scheduled session has no browser, that is expected, and the draft state exists precisely for
it. Finish the run, write the draft, and say in your report that it needs eyes.
Confirm it landed:
  select look_no, artist, status, jsonb_array_length(frames) from public.looks
  order by look_no desc limit 1;
status must read 'draft'. It will NOT appear on the public REST endpoint. That is correct.

6 — REPORT
What you chose and why, the product, anything that failed or needed regenerating, the four
frame URLs so they can be reviewed, and the ledger line to add to docs/config.md in
bradhall4/Look-Library. If you cannot reach git, say so and put the line in your write-up.
A reviewer with image vision promotes it later with:  select * from public.publish_look(N);
```

---

## Why the docs come from the database and not straight from GitHub

The run could in principle fetch `raw.githubusercontent.com` itself. It is not trusted to,
because the Cowork egress proxy returns 403 at the CONNECT stage for entire hosts — it did
exactly that to every Netlify domain, which is why deploys had to move out of Cowork. If GitHub
is ever on the wrong side of that policy, a run that fetches its own instructions gets nothing.

Supabase is the one host the run is already guaranteed to reach, because it writes every look
through it. So:

```
git repo (source of truth)
   |  pg_net http_get, called by runbook_fetch()
   v
public.runbook  (always reachable by the run)
   |  select
   v
the scheduled run
```

The database pulls from git rather than the run pulling from git. If the pull fails, the run
still has the last good copy instead of no copy.

## Updating the docs remotely

Edit the markdown in `docs/` in this repo, commit, push. Then either wait for the next run,
which refreshes automatically in STEP 2, or force it immediately:

```sql
select public.runbook_fetch();
-- wait ~5 seconds
select * from public.runbook_apply();
```

`runbook_fetch(branch)` takes an optional branch name if you want to test doc changes from a
branch before merging.

**Verify the sync actually took.** `raw.githubusercontent.com` is CDN-cached, so a sync run
immediately after a push can be served the previous version — and because it still returns 200
and reports `applied = true`, it looks like it worked. This happened on 8 Sep: two corrected
docs synced clean and the database kept the old text. `runbook_fetch` now appends a unique
query string per call so each fetch is its own cache key, but check anyway when it matters:

```sql
select slug, length(body), updated_at from public.runbook order by slug;
```

If the byte count is identical to the previous sync after a real edit, it did not take.

## The objects involved

| Object | What it does |
|---|---|
| `public.runbook` | slug, title, body, git_path, updated_at. RLS on, no policies, revoked from anon and authenticated. Only a privileged connection reads it. |
| `public.runbook_pending` | Holds the in-flight pg_net request ids between the two phases. |
| `public.runbook_fetch(branch)` | Fires one `net.http_get` per doc at raw.githubusercontent.com. |
| `public.runbook_apply()` | Reads the responses and upserts them into `public.runbook`. |

Two phases because **pg_net only dispatches a request when the transaction commits**, so a
single function cannot fire a request and read its response. Anything that tries returns nulls.

## Checking what the run will actually read

```sql
select slug, git_path, length(body) as bytes, updated_at
from public.runbook order by slug;
```

If `updated_at` is older than your last push, the sync has not run since.
