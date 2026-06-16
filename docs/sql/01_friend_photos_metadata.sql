-- Purpose:
-- Add and verify metadata columns used by calendar, timeline, and photo detail.
-- Safe to re-run because each column uses IF NOT EXISTS.

select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name = 'friend_photos'
order by ordinal_position;

alter table public.friend_photos
add column if not exists taken_at timestamp with time zone;

alter table public.friend_photos
add column if not exists latitude double precision;

alter table public.friend_photos
add column if not exists longitude double precision;

alter table public.friend_photos
add column if not exists location_name text;

select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name = 'friend_photos'
order by ordinal_position;
