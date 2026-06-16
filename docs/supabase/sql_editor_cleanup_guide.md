# SQL Editor Cleanup Guide

This guide explains how to clean up Supabase SQL Editor so teammates can work without getting lost.

## Goal

Keep only the final snippets that are still useful:

- setup snippets for schema and policies
- one debug snippet for read-only checks

## Recommended final structure

Create these folders in SQL Editor:

- `uyoung-app`
- `debug`

Inside `uyoung-app`, keep these snippets:
- `01 friend_photos metadata setup`
- `02 storage friend_photos policies`
- `03 memory albums and photo access control`
- `04 photo comments with rls access control`

Inside `debug`, keep this snippet:
- `99 debug queries`

## How to create folders and snippets

### Create folder
1. Open SQL Editor.
2. Click the `+` button near the search box.
3. Choose `Create a new folder`.
4. Create:
   - `uyoung-app`
   - `debug`

A folder does not contain SQL itself. It is only for organization.

### Create snippet
1. Click the `+` button.
2. Choose `Create a new snippet`.
3. Give it one of the recommended names.
4. Paste the SQL content.
5. Save it into the correct folder.

A snippet is the actual SQL document.

## Which local files map to which snippets

- `docs/sql/01_friend_photos_metadata.sql`
  -> `01 friend_photos metadata setup`
- `docs/sql/02_storage_friend_photos_policies.sql`
  -> `02 storage friend_photos policies`
- `docs/sql/memory_album_tables.sql`
  -> `03 memory albums and photo access control`
- `docs/sql/photo_comments.sql`
  -> `04 photo comments with rls access control`
- `docs/sql/05_debug_queries.sql`
  -> `99 debug queries`

## What to do with old snippets outside folders

If the same content has already been copied into the new organized snippets, old loose snippets can be deleted.

Usually safe to delete after migration:
- `friend_photos metadata setup`
- `Photo comments with RLS access control`
- `Memory Albums and Photo Access Control`

The old snippet `Populate missing user codes` should be handled like this:
- if it still contains useful read-only checks, move those queries into `debug/99 debug queries`
- then delete the old snippet
- if it contains nothing useful anymore, delete it directly

## Safe vs unsafe re-run rules

### Safe to re-run
- `select ...`
- `alter table ... add column if not exists ...`
- `drop policy if exists ...`
- `update ...`
- `insert ... on conflict ...`

### Usually not safe to re-run without cleanup
- `create table ...`
- `create policy ...`
- `create index ...`

If you run a `create policy` twice, you will often get:
- `policy already exists`

That does not necessarily mean the setup is broken.
It usually means the policy is already there.

## How to fix `policy already exists`

Option A:
- do nothing if the policy is already correct

Option B:
- drop and recreate the policy

Example:
```sql
drop policy if exists "memory_albums select" on public.memory_albums;
```
Then run the corresponding `create policy ...` again.

## How to review current backend state

### Check columns
```sql
select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name = 'friend_photos'
order by ordinal_position;
```

### Check policies
```sql
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname in ('public', 'storage')
order by schemaname, tablename, policyname;
```

### Check buckets
```sql
select id, name, public
from storage.buckets
order by name;
```

## Team workflow recommendation

1. Keep setup SQL in organized snippets.
2. Keep read-only checks only in `99 debug queries`.
3. When a setup file changes in the repo, update the matching snippet too.
4. Do not keep random one-off tabs once the SQL has been documented.
5. Use this guide together with:
   - `docs/sql/README.md`
   - `docs/supabase/README.md`
   - `docs/api_spec.md`
