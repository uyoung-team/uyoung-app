# Supabase Setup and Cleanup Guide

This document summarizes the Supabase-side work that has been added while implementing `uyoung-app` features.
It is meant for teammates who need to understand what exists already and how to keep the SQL Editor organized.

## What has been added so far

### 1. friend_photos metadata support
Purpose:
- Let calendar, timeline, and photo detail use photo metadata instead of only upload time.

Key columns:
- `taken_at`
- `latitude`
- `longitude`
- `location_name`

File:
- `docs/sql/01_friend_photos_metadata.sql`

### 2. Storage policies for photo upload
Purpose:
- Allow authenticated users to upload and read files in the `friend_photos` bucket.

File:
- `docs/sql/02_storage_friend_photos_policies.sql`

### 3. Shared album support
Purpose:
- Create album tables so island members can create albums and add island photos into them.

Tables:
- `public.memory_albums`
- `public.memory_album_photos`

File:
- `docs/sql/memory_album_tables.sql`

### 4. Comment and sticker persistence
Purpose:
- Persist comments, sticker selection, and sticker placement on photos.

Table:
- `public.photo_comments`

File:
- `docs/sql/photo_comments.sql`

### 5. Verification / debugging queries
Purpose:
- Check whether profiles, assets, memberships, photos, and policies exist as expected.

File:
- `docs/sql/05_debug_queries.sql`

## Recommended execution order for a new environment

1. `docs/sql/01_friend_photos_metadata.sql`
2. `docs/sql/02_storage_friend_photos_policies.sql`
3. `docs/sql/memory_album_tables.sql`
4. `docs/sql/photo_comments.sql`
5. `docs/sql/05_debug_queries.sql`

## How to use SQL Editor without getting lost

### Recommended snippet structure
Create or rename snippets in Supabase SQL Editor like this:
- `01 friend_photos metadata setup`
- `02 storage friend_photos policies`
- `03 memory albums and photo access control`
- `04 photo comments with rls access control`
- `99 debug queries`

### Good practice
- Use setup snippets only for schema/policy changes.
- Use debug snippets only for `select` checks.
- Avoid mixing unrelated work into one long snippet unless it is temporary.

## How to know if a snippet has already been applied

### For columns
Use `information_schema.columns`.
Example:
```sql
select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name = 'friend_photos'
order by ordinal_position;
```

### For policies
Use `pg_policies`.
Example:
```sql
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname in ('public', 'storage')
order by schemaname, tablename, policyname;
```

### For buckets
Use `storage.buckets`.
Example:
```sql
select id, name, public
from storage.buckets
order by name;
```

## Troubleshooting

### Error: policy already exists
Meaning:
- The policy has already been created before.

What to do:
- Either leave it alone if it is correct, or
- use `drop policy if exists ...` and then create it again.

### Error: relation does not exist
Meaning:
- The table was never created, or the code is expecting an outdated table name.

What to do:
- Check current schema using `information_schema.tables`.
- Compare the app code with the actual table names.

### Upload works locally but fails in app with 403 Unauthorized
Meaning:
- Storage RLS or table RLS is missing or incorrect.

What to do:
- Re-check bucket policies in `storage.objects`.
- Re-check table policies in `pg_policies`.
