# SQL Files Guide

This folder keeps the SQL that was added while integrating `uyoung-app` with Supabase.
The goal is to make it easy for multiple teammates to understand:

- what each SQL file is for
- whether it is safe to re-run
- which files create schema/policies vs. which files are just for debugging

## Recommended file order

1. `01_friend_photos_metadata.sql`
   - Adds metadata columns required by calendar, timeline, and photo detail.
   - Safe to re-run.
2. `02_storage_friend_photos_policies.sql`
   - Rebuilds storage bucket policies for `friend_photos`.
   - Safe to re-run because it drops policies first.
3. `memory_album_tables.sql`
   - Creates album tables and album RLS policies.
   - Not safe to re-run as-is if policies already exist.
   - If you need to re-run it, either remove existing policies manually or convert it to a drop-and-recreate version first.
4. `photo_comments.sql`
   - Creates comment/sticker table and RLS policies.
   - Not safe to re-run as-is if policies already exist.
5. `05_debug_queries.sql`
   - Read-only verification queries.
   - Safe to run anytime.

## How to organize SQL Editor in Supabase

We recommend keeping one snippet per purpose instead of mixing everything in one tab.

Recommended snippet names:
- `01 friend_photos metadata setup`
- `02 storage friend_photos policies`
- `03 memory albums and photo access control`
- `04 photo comments with rls access control`
- `99 debug queries`

## Safe vs unsafe re-run rules

### Safe to re-run
- `select ...`
- `alter table ... add column if not exists ...`
- `drop policy if exists ...`
- `update ...`
- `insert ... on conflict ...`

### Not safe to re-run without cleanup
- `create table ...`
- `create policy ...`
- `create index ...`

If a file contains `create policy ...` without `drop policy if exists`, running it twice will usually fail with an `already exists` error.

## Team workflow recommendation

1. Keep one purpose per SQL snippet.
2. Copy the final version into this `docs/sql` folder after it has been tested.
3. When a policy file changes, either:
   - make it drop-and-recreate so it is safe to re-run, or
   - add a note that it should only be run once.
4. Use `05_debug_queries.sql` for inspection instead of editing setup files.
