-- Attendance MVP tables and policies

create table if not exists public.attendance_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  event_type text not null check (event_type in ('clock_in', 'clock_out')),
  event_time timestamptz not null default now(),
  latitude numeric,
  longitude numeric,
  created_at timestamptz not null default now()
);

create index if not exists idx_attendance_user_time
  on public.attendance_events (user_id, event_time desc);

alter table public.attendance_events enable row level security;

create policy tenant_isolation_attendance on public.attendance_events
for all using (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid)
with check (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

create policy self_attendance_access on public.attendance_events
for select using (user_id = auth.uid());

create policy self_attendance_insert on public.attendance_events
for insert with check (user_id = auth.uid());
