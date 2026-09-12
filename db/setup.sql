-- Look Library — full database setup.
-- Paste into the Supabase SQL Editor for project llnydhsfqyeyvckypxmk and run once.
-- Safe to re-run: creates are guarded, the insert upserts on look_no.

-- ---------------------------------------------------------------
-- 1. Table
-- ---------------------------------------------------------------
create table if not exists public.looks (
  id            bigint generated always as identity primary key,
  look_no       integer not null unique,
  captured_on   date    not null,
  artist        text    not null,
  work          text,
  lane          text    not null default 'current',
  era           text,
  disciplines   text[]  not null default '{}',
  hook          text    not null,
  treatment     text    not null,
  device        text,
  energy_source text,
  palette       jsonb   not null default '[]'::jsonb,
  card          jsonb   not null default '[]'::jsonb,
  verdict       jsonb   not null default '[]'::jsonb,
  frames        jsonb   not null default '[]'::jsonb,
  hero_url      text,
  flora_url     text,
  source_url    text,
  source_name   text,
  references_   jsonb   not null default '[]'::jsonb,
  product       text,
  mode          text    not null default 'refined',
  social        jsonb   not null default '[]'::jsonb,
  created_at    timestamptz not null default now()
);

comment on table public.looks is
  'One art direction look per row. Written by the scheduled Look Library task, read anonymously by the public site.';

-- These four arrived after the table was first created. Guarded so this file
-- can be re-run against an existing database as well as a fresh one.
alter table public.looks add column if not exists references_ jsonb not null default '[]'::jsonb;
alter table public.looks add column if not exists product     text;
alter table public.looks add column if not exists mode        text not null default 'refined';
alter table public.looks add column if not exists social      jsonb not null default '[]'::jsonb;

create index if not exists looks_look_no_desc on public.looks (look_no desc);

-- ---------------------------------------------------------------
-- 2. Read-only to the world. Writes only via the service role key,
--    which lives in the scheduled task and never in the browser.
-- ---------------------------------------------------------------
alter table public.looks enable row level security;

drop policy if exists "looks are publicly readable" on public.looks;
create policy "looks are publicly readable"
  on public.looks for select
  to anon, authenticated
  using (true);

-- ---------------------------------------------------------------
-- 3. Public bucket for mirrored frames, so the site never depends
--    on media.flora.ai staying up.
-- ---------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('frames', 'frames', true, 26214400,
        array['image/png','image/jpeg','image/webp'])
on conflict (id) do nothing;

drop policy if exists "frames are publicly readable" on storage.objects;
create policy "frames are publicly readable"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'frames');

-- ---------------------------------------------------------------
-- 4. Look 001, matching what is live. Every image is served from the
--    public `frames` bucket, so nothing here depends on media.flora.ai.
-- ---------------------------------------------------------------
insert into public.looks (
  look_no, captured_on, artist, work, lane, era, disciplines,
  hook, treatment, device, palette, card, frames, verdict,
  references_, hero_url, flora_url, source_url, source_name
) values (
  1,
  '2026-09-04',
  'Ana Paganini',
  '200 Summers Later',
  'current',
  '2026',
  array['photography','art direction'],
  $hook$Photographing the events that happened just before photography existed. Battle reenactments shot as formal portraits, with the modern world deliberately left in frame.$hook$,
  $tx$Shot on a Hasselblad 500-series with an 80mm lens on 120 colour negative film, square 6x6 frame. Overcast daylight and open shade, soft wraparound modelling, shadowless. Muted cool green-grey palette in which the clothing is the only saturated element. Deep but open blacks, highlights rolling off softly. Fine even film grain, faint halation on the brightest whites. Subject crisply sharp, background falling away gently. Deadpan documentary stillness, the formality of a made portrait.$tx$,
  $dev$Build the world completely, then leave one honest modern object in shot. Martin Parr's advice to Paganini: the anachronism is a buffer against pure nostalgia. Works with none of the film craft attached.$dev$,
  $pal$[
    {"name":"Foliage","hex":"#1C2418"},
    {"name":"Mid green","hex":"#4A5A3E"},
    {"name":"Tarmac","hex":"#6E6E68"},
    {"name":"Flat sky","hex":"#D8DBD6"},
    {"name":"Linen","hex":"#E6E1D2"},
    {"name":"Bullion","hex":"#A8842C"}
  ]$pal$::jsonb,
  $card$[
    {"label":"Capture","value":"Hasselblad 500-series, 80mm normal lens, 120 colour negative. Square 6x6."},
    {"label":"Light","value":"Available only. Overcast or open shade, never direct sun. Shadowless wraparound modelling. No fill, no flash."},
    {"label":"Palette","value":"Muted cool green-grey across the frame, with exactly one saturated element: the costume."},
    {"label":"Tonality","value":"Blacks deep but open. Highlights roll off without clipping. Faint halation on the brightest whites."},
    {"label":"Grain","value":"Fine and even. Reads as film, never as texture overlay."},
    {"label":"Composition","value":"Deliberately inconsistent. Frontal full-length one frame, straight overhead the next. The look does not live in the framing."},
    {"label":"Performance","value":"Deadpan. Unsmiling, arms at sides, eyes into the lens. Sander and Dijkstra lineage."},
    {"label":"The tell","value":"A modern object left visible: tarmac and road markings under period boots, a parked minibus, a phone face-down."}
  ]$card$::jsonb,
  $fr$[
    {"role":"Control","caption":"Period figure on modern tarmac","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/control.png"},
    {"role":"Tonal extreme","caption":"White forms in dark undergrowth","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/tonal.png"},
    {"role":"Modern transfer","caption":"Teenagers on a municipal pitch","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/modern.png"},
    {"role":"Object transfer","caption":"Trestle table, meal finished","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/object.png"}
  ]$fr$::jsonb,
  $vd$[
    {"title":"It transfers.","body":"The tracksuit frame is the one that matters. Same treatment, wholly modern subject, and it reads as a real campaign frame rather than period pastiche."},
    {"title":"It needs one saturated element.","body":"The still life is weakest: with no costume in frame the palette rule has nothing to hold and the image drifts flat grey. Give it a red jacket or a painted door, or you get weather, not a look."},
    {"title":"The device outlives the look.","body":"The anachronism-as-buffer mechanic works with none of the film craft attached."}
  ]$vd$::jsonb,
  $rf$[
    {"credit":"Ana Paganini","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/ref-1.jpg",
     "note":"Frontal full-length on modern tarmac. The white road line under period boots is the whole device in one frame."},
    {"credit":"Ana Paganini","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/ref-2.jpg",
     "note":"Straight overhead, white linen against near-black undergrowth. Proof the look does not live in the framing."},
    {"credit":"Ana Paganini","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/ref-3.jpg",
     "note":"Banquet table, decorated uniforms, wine glasses. Costume carrying the only saturation in frame."},
    {"credit":"Ana Paganini","url":"https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/ref-4.jpg",
     "note":"Group in open shade. Shadowless wraparound modelling on every face."}
  ]$rf$::jsonb,
  'https://llnydhsfqyeyvckypxmk.supabase.co/storage/v1/object/public/frames/look-001/modern.png',
  'https://app.flora.ai/projects/ns7czycwas3vccgaa9v89kp9e58drvs6',
  'https://www.itsnicethat.com/articles/ana-paganini-200-summers-later-photography-project-060826',
  $sn$It's Nice That$sn$
)
on conflict (look_no) do update set
  captured_on = excluded.captured_on,
  artist      = excluded.artist,
  work        = excluded.work,
  hook        = excluded.hook,
  treatment   = excluded.treatment,
  device      = excluded.device,
  palette     = excluded.palette,
  card        = excluded.card,
  frames      = excluded.frames,
  verdict     = excluded.verdict,
  references_ = excluded.references_,
  hero_url    = excluded.hero_url;

-- Check it landed.
select look_no, artist, work, jsonb_array_length(frames) as frames from public.looks order by look_no desc;

-- ---------------------------------------------------------------------------
-- Distribution. See docs/distribution.md.
-- Renders a look as the Slack announcement post, so the format lives in one
-- place and a past look can be re-posted without retyping it. Deliberately not
-- security definer: RLS keeps drafts unpostable, exactly as it keeps them
-- invisible to the site.
-- ---------------------------------------------------------------------------
create or replace function public.look_slack_post(n int)
returns text
language sql
stable
as $fn$
  select format(
      E'*Look %1$s · %2$s — %3$s*\n%4$s\n\n%5$s\n\n*Paste this into any image model*\n```%6$s```\n\n*Product in frame:* %7$s\n*Source:* %8$s\n*Full recipe:* %9$s',
      to_char(l.look_no, 'FM000'),
      l.artist,
      l.work,
      coalesce(l.hook, ''),
      (select string_agg(format('%s — %s', f->>'caption', f->>'url'), E'\n' order by ord)
         from jsonb_array_elements(l.frames) with ordinality as t(f, ord)),
      l.treatment,
      coalesce(nullif(l.product, ''), 'none'),
      concat_ws(' · ', nullif(l.source_name, ''), nullif(l.source_url, '')),
      'https://look-library.netlify.app/#' || to_char(l.look_no, 'FM000')
    )
  from public.looks l
  where l.look_no = n;
$fn$;
