create table if not exists public.memory_albums (
  id uuid primary key default gen_random_uuid(),
  island_id uuid not null references public.islands(id) on delete cascade,
  name text not null,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.memory_album_photos (
  album_id uuid not null references public.memory_albums(id) on delete cascade,
  photo_id uuid not null references public.friend_photos(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (album_id, photo_id)
);

alter table public.memory_albums enable row level security;
alter table public.memory_album_photos enable row level security;

create policy "memory_albums select"
on public.memory_albums
for select
to authenticated
using (
  exists (
    select 1
    from public.island_members im
    where im.island_id = memory_albums.island_id
      and im.user_id = auth.uid()
  )
);

create policy "memory_albums insert"
on public.memory_albums
for insert
to authenticated
with check (
  exists (
    select 1
    from public.island_members im
    where im.island_id = memory_albums.island_id
      and im.user_id = auth.uid()
  )
);

create policy "memory_album_photos select"
on public.memory_album_photos
for select
to authenticated
using (
  exists (
    select 1
    from public.memory_albums a
    join public.island_members im on im.island_id = a.island_id
    where a.id = memory_album_photos.album_id
      and im.user_id = auth.uid()
  )
);

create policy "memory_album_photos insert"
on public.memory_album_photos
for insert
to authenticated
with check (
  exists (
    select 1
    from public.memory_albums a
    join public.island_members im on im.island_id = a.island_id
    where a.id = memory_album_photos.album_id
      and im.user_id = auth.uid()
  )
);

create policy "memory_album_photos delete"
on public.memory_album_photos
for delete
to authenticated
using (
  exists (
    select 1
    from public.memory_albums a
    join public.island_members im on im.island_id = a.island_id
    where a.id = memory_album_photos.album_id
      and im.user_id = auth.uid()
  )
);
