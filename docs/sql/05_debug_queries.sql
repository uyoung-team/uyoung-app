-- Purpose:
-- Common verification queries used while integrating Supabase-backed flows.
-- These are read-only queries and safe to run repeatedly.

-- 1. profiles
select id, nickname, user_code, avatar_url, created_at
from public.profiles
order by created_at desc
limit 20;

-- 2. user_assets
select user_id, pearl_count, updated_at
from public.user_assets
order by updated_at desc
limit 20;

-- 3. island membership
select *
from public.island_members
where user_id = 'YOUR_USER_ID';

-- 4. friend_photos for calendar/timeline
select id, island_id, uploader_id, image_url, description, created_at, taken_at, latitude, longitude, location_name
from public.friend_photos
order by coalesce(taken_at, created_at) desc
limit 100;

-- 5. friend_photos for a month
select id, island_id, image_url, created_at, taken_at, location_name
from public.friend_photos
where coalesce(taken_at, created_at) >= '2026-06-01'
  and coalesce(taken_at, created_at) < '2026-07-01'
order by coalesce(taken_at, created_at) asc;

-- 6. existing policies
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname in ('public', 'storage')
order by schemaname, tablename, policyname;
