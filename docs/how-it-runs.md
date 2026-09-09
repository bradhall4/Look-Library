# Look Library — how it runs

## The routine

A local Claude Code scheduled task, `look-library`, Mon/Wed/Fri 4pm local.
Prompt lives at `~/.claude/scheduled-tasks/look-library/SKILL.md`.

It runs locally rather than in the cloud for one reason: **it has to look at the pictures.**
Steps 3 and 5 of `run-procedure.md` are visual judgements, and a run that cannot see its own
frames cannot make them. A local session downloads a frame with `curl` and opens it with the
`Read` tool. The scheduled cloud session could not — no browser, no image-capable tool, and a
sandbox whose shell could not even reach the Supabase host (`CONNECT tunnel failed, 403`); it
only ever reached the database through MCP.

The trade: scheduled tasks run while the desktop app is open. If it is closed when one is due,
it fires on next launch.

If the cloud is ever worth revisiting, the deciding question is whether Supabase and Flora exist
as **claude.ai connectors** rather than Claude Code MCP servers — cloud routines can only use
the former, and they do get `Bash` and `Read`.

## The draft gate

`public.looks.status` defaults to `'draft'`, and the anon read policy is
`using (status = 'published')`, so the site cannot show an unreviewed row even by accident.

```sql
select look_no, artist, work, status from public.looks where status = 'draft';
select * from public.publish_look(4);
```

Going back to instant publishing is one policy: `using (status = 'published')` -> `using (true)`.

## The operating docs

Git is the source of truth. The database mirrors it, and the run reads the database.

```
docs/*.md  ->  runbook_fetch()  ->  public.runbook  ->  the run
```

The database pulls from git rather than the run pulling from git, so a failed pull leaves the
run with the last good copy instead of no copy.

To update: edit `docs/`, commit, push, then

```sql
select public.runbook_fetch();      -- wait ~5 seconds
select doc_slug, http_status, applied from public.runbook_apply();
select slug, length(body), updated_at from public.runbook order by slug;
```

Two phases because pg_net only dispatches on transaction commit — one function cannot fire a
request and read its own response.

**Check that it took.** `raw.githubusercontent.com` is CDN-cached and a sync run straight after
a push can be served the previous version while still reporting 200 and `applied = true`.
`runbook_fetch` appends a unique query string per call to defeat this, but if a byte count is
unchanged after a real edit, it did not take.

## Objects

| Object | Purpose |
|---|---|
| `public.looks` | One row per entry. `status` gates publication. |
| `public.publish_look(n)` | Promotes a draft. |
| `public.runbook` | Mirror of `docs/`, read by the run. |
| `public.runbook_fetch(branch)` / `runbook_apply()` | Two-phase sync from git. |
| `mirror-frame` edge function | Copies an image into the `frames` bucket. Host allowlist, 25MB cap, unauthenticated by design — the only key a caller could hold is the publishable one that already ships in the page. |
