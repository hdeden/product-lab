-- Attendance events for MVP clock-in/out.

create table if not exists public.attendance_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,
  user_id uuid not null references public.users(id) on delete cascade,
  event_type text not null check (event_type in ('clock_in', 'clock_out')),
  event_time timestamptz not null,
  latitude numeric,
  longitude numeric,
  created_at timestamptz not null default now()
);

create index if not exists idx_attendance_events_user_time
on public.attendance_events (user_id, event_time desc);

alter table public.attendance_events enable row level security;

create policy attendance_self_read on public.attendance_events
for select using (user_id = auth.uid());

create policy attendance_self_insert on public.attendance_events
for insert with check (user_id = auth.uid());
