# Uyoung App Project Rules

## 1. Goal
- Rebuild the app as a clean Flutter + Supabase project.
- Use the old project only to understand business rules, feature flow, table usage, and required UX.
- Keep the new project structure, naming, and assets independent from the old codebase.

## 2. Current Project Structure

### `lib/app`
- Holds app-level composition only.
- Current responsibilities:
  - app bootstrap
  - `MaterialApp` root
  - route registration
  - provider registration

### `lib/core`
- Holds cross-cutting foundations.
- Current responsibilities:
  - constants
  - theme tokens
  - app theme
  - Supabase initialization and client access

### `lib/shared`
- Holds reusable code shared by multiple features.
- Current responsibilities:
  - common widgets
  - shared services such as asset path constants

### `lib/features`
- Holds feature-first modules.
- Current features:
  - `login`
  - `home`
  - `attendance`
  - `memory`
  - `calendar`
  - `shop`
  - `my_page`

## 3. Feature Layer Rules

Each feature currently follows this structure:

- `data/`
  - `*_service.dart`
  - `*_repository.dart`
- `presentation/viewmodels`
- `presentation/pages`

Role of each layer:

### `service`
- Lowest feature-level access point for external systems
- Uses Supabase client or other platform/network integrations later
- Should not contain widget logic

### `repository`
- Wraps one or more services
- Shapes data for UI consumption
- Central place to hide query details from view models

### `viewmodel`
- Uses `ChangeNotifier`
- Manages loading, error, and screen state
- Calls repository methods
- Does not render UI

### `page`
- Entry screen for a feature
- Observes provider/view model state
- Composes widgets only

## 4. Provider Rules

- State management standard is `provider`
- Feature screen state uses `ChangeNotifier`
- App-wide registration belongs in `lib/app/providers/app_providers.dart`
- Do not register unused providers early
- Keep one logical change per commit whenever possible.
- Add provider wiring only when the feature is actually connected to the app flow

## 5. Routing Rules

- App routes are managed in `lib/app/routes/app_router.dart`
- Keep `login` outside the bottom tab shell
- Keep `attendance` as a standalone feature, not a bottom tab
- Current main tab shell includes:
  - home
  - memory
  - calendar
  - shop
  - my_page

## 6. Theme and Design Token Rules

Theme files live under `lib/core/theme`.

Current token split:
- `app_colors.dart`
- `app_spacing.dart`
- `app_radius.dart`
- `app_typography.dart`
- `app_theme.dart`

Guidelines:
- Keep tokens simple and easy to replace
- Avoid feature-specific colors inside global tokens
- Do not hard-code repeated spacing, radius, or colors inside feature pages when a token already exists
- Delay strong brand styling decisions until actual design direction is confirmed

## 7. Asset Rules

Current asset structure:
- `assets/fonts`
- `assets/icons/common`
- `assets/images/common`
- `assets/images/home`
- `assets/images/attendance`
- `assets/images/memory`
- `assets/images/calendar`
- `assets/images/shop`
- `assets/images/my_page`

Rules:
- New asset paths should follow the existing structure first
- Shared icons belong in `assets/icons/common`
- Shared images belong in `assets/images/common`
- Feature-specific assets belong in that feature folder
- Use descriptive names based on purpose, not old filenames
- Centralize path strings in `lib/shared/services/asset_paths.dart`

## 8. Supabase Rules

Current Supabase layer:
- `lib/core/network/supabase_initializer.dart`
- `lib/core/network/supabase_client_provider.dart`

Rules:
- Read environment values from `--dart-define`
- Supported keys currently:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- App startup should remain safe even when values are missing
- Widgets must not call Supabase directly
- Query logic should enter through `service` and be surfaced through `repository`

## 9. Responsive Rules

Current project target is mobile-first.

Rules:
- Build phone layouts first
- Avoid locking UI to a single device width
- Prefer padding, flexible widgets, and constrained content instead of absolute sizing
- For larger screens, extend layouts by:
  - keeping content centered
  - adding max-width constraints where needed
  - preserving the same information hierarchy
- Do not create separate tablet-only code paths unless a screen truly needs it

## 10. Implementation Rules for the Next Phase

- Start from real placeholders, then replace them feature by feature
- Do not copy old implementation files directly
- Migrate only the minimum logic needed for each feature step
- Prefer incremental changes over broad refactors
- Keep the project analyzable after each task
