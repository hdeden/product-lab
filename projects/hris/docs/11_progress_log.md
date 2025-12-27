# 11_progress_log

## 2025-12-27
- Initialized Supabase project config under `projects/hris/supabase/`.
- Added migration for auth + tenant setup with roles, triggers, and RLS.
- Applied migration to local Docker Supabase (manual `docker exec`).
- Created initial tenant and owner user for local development.
- Updated HRIS docs to align MVP vs Phase 2 payroll scope.
- Scaffolded Flutter app in `projects/hris/app_flutter/`.
- Added Supabase auth flow (login/signup with tenant_id metadata).
- Confirmed Flutter dependencies installed and app running in Chrome.
- Added tenant-aware profile fetch for current user and role.
- Added lightweight profile screen with a route from the dashboard.
- Attendance status now shows lat/long; recent events list includes location.
- Attendance MVP migration added and applied to local Supabase.
- Fixed profile loading by adding self-read RLS policies and metadata fallback.
- Added editable profile fields backed by employee_profiles.
- Added attendance MVP (clock in/out UI + attendance_events table).
- Added GPS capture for attendance events using geolocator.
