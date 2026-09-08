# What to put in the Claude project

The scheduled cloud task should hold **only this short block**. Everything it needs lives in
the database and is refreshed from this git repo, so the instructions below never go stale and
never need editing again.

Replace the whole contents of the Claude project's instructions (and delete the old
`claude/look-library-*.md` copies, which are now a second source of truth and will drift) with:

---

```
You are running the Look Library routine.

STEP 1. Confirm the database. Call get_project_url on the Supabase connector and check it
returns llnydhsfqyeyvckypxmk. There is more than one Supabase connector on this account and
the other belongs to a different account. If it is not that ref, stop and say so.

STEP 2. Refresh the operating docs from git, then read them. Run:

    select public.runbook_fetch();

wait about five seconds, then:

    select doc_slug, http_status, applied from public.runbook_apply();

Then read the docs themselves:

    select slug, body from public.runbook order by slug;

If runbook_fetch or runbook_apply errors, or a doc comes back with applied = false, carry on
using whatever is already stored in public.runbook and say clearly in your write-up that the
docs may be stale and which ones.

STEP 3. Follow them. `config` holds the selection filter, the ids and the ledger.
`run-procedure` is the step-by-step for one run and contains the exact INSERT that publishes a
look. `product-rule` governs the product. Obey the ledger: read it before choosing, and take
the next number after the highest entry.

STEP 4. Report what you did, honestly, including anything that failed or needed regenerating,
and append your line to the ledger table in the config doc. Note that appending to the ledger
means editing docs/config.md in the git repo bradhall4/Look-Library — if you cannot reach git,
say so and put the ledger line in your write-up so it can be added by hand.
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
