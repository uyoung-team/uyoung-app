create table if not exists public.photo_comments (
  id uuid primary key default gen_random_uuid(),
  photo_id uuid not null references public.friend_photos(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  sticker_asset text,
  sticker_dx_ratio double precision,
  sticker_dy_ratio double precision,
  sticker_size double precision,
  created_at timestamptz not null default now()
);

alter table public.photo_comments enable row level security;

create policy "photo_comments select"
on public.photo_comments
for select
to authenticated
using (
  exists (
    select 1
    from public.friend_photos fp
    join public.island_members im on im.island_id = fp.island_id
    where fp.id = photo_comments.photo_id
      and im.user_id = auth.uid()
  )
);

create policy "photo_comments insert"
on public.photo_comments
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.friend_photos fp
    join public.island_members im on im.island_id = fp.island_id
    where fp.id = photo_comments.photo_id
      and im.user_id = auth.uid()
  )
);
