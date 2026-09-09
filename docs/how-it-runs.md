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

## The queue

Artists and looks Brad wants covered. The run takes the oldest pending entry before falling back
to the selection filter.

```sql
select * from public.queue_add('Artist Name', 'why, and where the references are', 'https://...');
select id, artist, status, added_at from public.queue order by added_at;
```

`queue_next()` is what the run reads; `queue_mark_used(id, look_no)` closes an entry once the
look publishes. Status is `pending`, `used` or `skipped`.

Note that many artist links are not fetchable — Instagram in particular is login-walled, and a
share link with an `stkn` token is tied to one person's session and should not be stored. Put a
durable public source in `source_url` (portfolio, agency page, editorial coverage) and leave the
social link out of it.

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

**Sync by commit SHA, not by branch name.** `raw.githubusercontent.com` is CDN-cached, and a
sync straight after a push gets served the previous version while still reporting 200 and
`applied = true` — a silent stale read. A unique query string per request does not reliably
defeat it. A commit SHA is immutable, so it cannot be served stale:

```sql
select public.runbook_fetch('<full commit sha>');   -- git rev-parse HEAD
```

`runbook_fetch` takes any git ref, so the SHA goes straight in where the branch name would.
Plain `runbook_fetch()` still works and is fine for a scheduled run reading docs that were
pushed hours ago; use the SHA whenever you have just pushed.

Either way, check `length(body)` changed. Note it counts characters, not bytes, so a file with
em-dashes will read slightly smaller than `wc -c` reports.

## Objects

| Object | Purpose |
|---|---|
| `public.looks` | One row per entry. `status` gates publication. |
| `public.publish_look(n)` | Promotes a draft. |
| `public.runbook` | Mirror of `docs/`, read by the run. |
| `public.runbook_fetch(branch)` / `runbook_apply()` | Two-phase sync from git. |
| `mirror-frame` edge function | Copies an image into the `frames` bucket. Host allowlist, 25MB cap, unauthenticated by design — the only key a caller could hold is the publishable one that already ships in the page. |
