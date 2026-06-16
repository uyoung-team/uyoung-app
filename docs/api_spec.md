# API Spec

`uyoung-app` is not built around a separate custom backend server.
Its application-facing data API is currently composed of:

- Supabase Auth
- Supabase PostgREST table access
- Supabase RPC functions
- Supabase Storage buckets

This document describes the current data contract used by the app so teammates can understand:

- which screen uses which table/RPC/bucket
- which fields are important
- what must exist in Supabase for the app to work

## 1. Authentication

### 1.1 Session and social login
Used by:
- login flow
- app boot gate
- invite link re-entry

Client usage:
- `auth.onAuthStateChange`
- `auth.currentSession`
- `auth.signInWithOAuth(...)`
- `auth.signOut()`

Redirect:
- `uyoung://login-callback`

Providers currently wired in code:
- Google
- Apple
- Other providers can be added if enabled in Supabase/Auth.

## 2. Tables

## 2.1 `profiles`
Purpose:
- user nickname
- profile image
- friend code / invite code style lookup

Used by:
- profile setup
- my page
- friend search / friend invite
- memory island member display

Important fields:
- `id uuid`
- `nickname text`
- `avatar_url text`
- `user_code text`
- `created_at timestamptz`

App behavior:
- profile setup upserts profile row by `id`
- `user_code` is generated if missing

## 2.2 `user_assets`
Purpose:
- pearl balance

Used by:
- home
- attendance
- my page

Important fields:
- `user_id uuid`
- `pearl_count integer`
- `updated_at timestamptz`

App behavior:
- if no row exists for current user, the app creates one with `pearl_count = 0`

## 2.3 `attendance_logs`
Purpose:
- attendance history
- attendance reward state

Used by:
- attendance board
- daily attendance status

Important fields:
- `id uuid`
- `user_id uuid`
- `check_in_date date`
- `reward_item text`
- `continuous_days integer`

Related RPC:
- `daily_check_in_and_draw`

## 2.4 `notices`
Purpose:
- notice list / notice detail

Used by:
- home notification fallback
- my page notice list

Important fields:
- `id uuid`
- `title text`
- `content text`
- `is_important boolean`
- `created_at timestamptz`

## 2.5 `notifications`
Purpose:
- user-specific notifications

Used by:
- home notification center

Important fields expected by app:
- `id`
- `user_id`
- `type`
- `title`
- `body`
- `is_read`
- `created_at`

Note:
- if this table does not exist, the app currently falls back to `notices`

## 2.6 `friends`
Purpose:
- friend relations

Used by:
- my page friend list
- delete friend

Important fields:
- `id uuid`
- `user_id uuid`
- `friend_id uuid`
- `created_at timestamptz`

Related RPC:
- `add_friend_by_code`

## 2.7 `inquiries`
Purpose:
- user support / inquiry history

Used by:
- my page inquiry list

Important fields:
- `id uuid`
- `user_id uuid`
- `category text`
- `title text`
- `content text`
- `image_url text`
- `status text`
- `answer text`
- `created_at timestamptz`

## 2.8 `islands`
Purpose:
- memory island master data

Used by:
- memory island list
- island detail/settings
- calendar filters
- invite link entry

Important fields:
- `id uuid`
- `name text`
- `description text`
- `owner_id uuid`
- `bg_image_url text`
- `theme_color text`
- `invite_code text`
- `created_at timestamptz`
- `updated_at timestamptz`

## 2.9 `island_members`
Purpose:
- which users belong to which island
- island-level user preferences

Used by:
- memory island list
- member inquiry page
- calendar island filter
- album permissions

Important fields:
- `id uuid`
- `island_id uuid`
- `user_id uuid`
- `role text`
- `joined_at timestamptz`
- `is_favorite boolean`
- `is_muted boolean`
- `last_visited_at timestamptz`

## 2.10 `friend_photos`
Purpose:
- core memory photo records for islands
- source of truth for calendar / timeline / photo detail / albums

Used by:
- memory island feed
- date view
- timeline view
- calendar
- album content
- photo detail

Important fields:
- `id uuid`
- `uploader_id uuid`
- `island_id uuid`
- `image_url text`
- `description text`
- `created_at timestamptz`
- `taken_at timestamptz`
- `latitude double precision`
- `longitude double precision`
- `location_name text`

Behavior:
- app uploads file to storage bucket first
- then inserts row into `friend_photos`
- `taken_at / latitude / longitude / location_name` are extracted from EXIF when possible
- calendar should use `coalesce(taken_at, created_at)`

## 2.11 `favorite_photos`
Purpose:
- per-user favorite photo state

Used by:
- favorite photo list
- photo detail favorite toggle

Important fields inferred from project state:
- `id uuid`
- `user_id uuid`
- `island_id uuid`
- `photo_key text`
- `created_at timestamptz`

Related RPC:
- `get_my_favorite_photos`
- `toggle_favorite_photo`

## 2.12 `memory_albums`
Purpose:
- shared album containers inside an island

Used by:
- album tab
- add selected island photos into album

Important fields:
- `id uuid`
- `island_id uuid`
- `name text`
- `created_by uuid`
- `created_at timestamptz`

## 2.13 `memory_album_photos`
Purpose:
- join table between albums and friend photos

Used by:
- album detail
- add/remove photos from album

Important fields:
- `album_id uuid`
- `photo_id uuid`
- `created_at timestamptz`

## 2.14 `photo_comments`
Purpose:
- comments and sticker persistence on a photo

Used by:
- photo detail comment list
- sticker/comment creation
- sticker location update
- sticker delete

Important fields:
- `id uuid`
- `photo_id uuid`
- `user_id uuid`
- `content text`
- `sticker_asset text`
- `sticker_dx_ratio double precision`
- `sticker_dy_ratio double precision`
- `sticker_size double precision`
- `created_at timestamptz`

## 3. RPC Functions

## 3.1 `daily_check_in_and_draw`
Used by:
- attendance check-in

Expected role:
- determine whether user can check in today
- update attendance streak
- assign reward result
- return attendance result payload

## 3.2 `search_users`
Used by:
- memory island invite/search

Expected role:
- keyword search over users

## 3.3 `create_island_with_members`
Used by:
- memory island creation

Expected role:
- create island row
- add current user
- add invitees

## 3.4 `leave_island`
Used by:
- island exit

Expected role:
- remove current member from island
- clean up if needed

## 3.5 `invite_members_to_island`
Used by:
- island member invite

Expected role:
- add selected users to island membership

## 3.6 `add_friend_by_code`
Used by:
- my page add friend by profile code

## 3.7 `get_my_favorite_photos`
Used by:
- favorite photo page

## 3.8 `toggle_favorite_photo`
Used by:
- photo detail favorite toggle

## 4. Storage Buckets

## 4.1 `profile_images`
Purpose:
- profile photo upload

## 4.2 `island_backgrounds`
Purpose:
- island cover/background image upload

## 4.3 `friend_photos`
Purpose:
- island memory photos

## 4.4 `inquiry_images`
Purpose:
- inquiry attachment images

## 5. Feature Mapping

## 5.1 Login / session
Tables:
- none directly required for sign-in
- `profiles` after onboarding
- `user_assets` ensured after onboarding

## 5.2 Home
Tables:
- `user_assets`
- `notifications` or fallback `notices`

## 5.3 Attendance
Tables / RPC:
- `attendance_logs`
- `user_assets`
- `daily_check_in_and_draw`

## 5.4 Calendar
Tables:
- `island_members`
- `islands`
- `friend_photos`

Key date rule:
- use `coalesce(taken_at, created_at)` for grouping and month filtering

## 5.5 Memory island
Tables / RPC / storage:
- `islands`
- `island_members`
- `profiles`
- `friend_photos`
- `memory_albums`
- `memory_album_photos`
- `photo_comments`
- `favorite_photos`
- `search_users`
- `create_island_with_members`
- `invite_members_to_island`
- `leave_island`
- `get_my_favorite_photos`
- `toggle_favorite_photo`
- storage `friend_photos`
- storage `island_backgrounds`

## 5.6 My page
Tables / RPC / storage:
- `profiles`
- `user_assets`
- `friends`
- `inquiries`
- `notices`
- `add_friend_by_code`
- storage `profile_images`

## 6. Minimum Setup Checklist for a New Environment

Required tables must exist:
- `profiles`
- `user_assets`
- `attendance_logs`
- `notices`
- `friends`
- `inquiries`
- `islands`
- `island_members`
- `friend_photos`
- `favorite_photos`
- `memory_albums`
- `memory_album_photos`
- `photo_comments`

Required buckets must exist:
- `profile_images`
- `island_backgrounds`
- `friend_photos`
- `inquiry_images`

Required SQL setup files:
1. `docs/sql/01_friend_photos_metadata.sql`
2. `docs/sql/02_storage_friend_photos_policies.sql`
3. `docs/sql/memory_album_tables.sql`
4. `docs/sql/photo_comments.sql`

## 7. Notes

- This is an app-facing data spec, not a full REST/OpenAPI contract.
- Because the app uses Supabase directly, schema and RLS policy changes are effectively part of the backend API contract.
- If a table or column changes, both app code and SQL docs should be updated together.
