-- Purpose:
-- Enable authenticated users to read/upload/update/delete files in the friend_photos bucket.
-- This file is safe to re-run because it drops policies before re-creating them.

select id, name, public
from storage.buckets
where name = 'friend_photos';

drop policy if exists "friend_photos 조회 허용" on storage.objects;
drop policy if exists "friend_photos 업로드 허용" on storage.objects;
drop policy if exists "friend_photos 수정 허용" on storage.objects;
drop policy if exists "friend_photos 삭제 허용" on storage.objects;

create policy "friend_photos 조회 허용"
on storage.objects
for select
to authenticated
using (bucket_id = 'friend_photos');

create policy "friend_photos 업로드 허용"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'friend_photos');

create policy "friend_photos 수정 허용"
on storage.objects
for update
to authenticated
using (bucket_id = 'friend_photos')
with check (bucket_id = 'friend_photos');

create policy "friend_photos 삭제 허용"
on storage.objects
for delete
to authenticated
using (bucket_id = 'friend_photos');

select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
order by policyname;
