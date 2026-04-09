# AGENTS.md

## Project Context
- This repository is a clean Flutter rebuild of an existing mobile app.
- The old project may be used as a feature reference only.
- Do not bring over legacy folder structure, asset naming, temporary UI, or ad-hoc patterns.

## Current App Structure
- `lib/app`: app entry composition, router, provider wiring
- `lib/core`: constants, theme tokens, Supabase bootstrap layer
- `lib/shared`: reusable widgets and shared services
- `lib/features`: feature-first modules such as `home`, `attendance`, `memory`, `calendar`, `shop`, `my_page`, `login`

## Working Rules
- Keep changes small and compile-safe.
- Prefer one focused commit per step.
- Follow the current project structure rather than proposing a new architecture mid-stream.
- Use `provider` for state wiring and `ChangeNotifier` for feature view models.
- Keep direct Supabase access inside the network/service layer, not in widgets.

## Feature Rules
- Default feature structure:
  - `data/service`
  - `data/repository`
  - `presentation/viewmodels`
  - `presentation/pages`
- Add more folders only when real complexity appears.
- Placeholder pages are acceptable until a feature begins implementation.

## UI Rules
- Reuse `shared/widgets` first before adding new common UI.
- Theme values should come from `core/theme`.
- Keep attendance as a feature outside the bottom tab unless the product structure is intentionally changed later.

## Asset Rules
- Store fonts in `assets/fonts`
- Store shared icons in `assets/icons/common`
- Store images in `assets/images/<feature>`
- Use clear, purpose-based names instead of legacy filenames

## Responsive Rules
- Build mobile-first layouts first.
- Avoid hard-coded large widths.
- For tablet expansion, prefer centered content with constrained max width instead of redesigning the whole screen.
