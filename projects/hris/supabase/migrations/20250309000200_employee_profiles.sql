-- Employee profile table for editable user details.

create table if not exists public.employee_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint employee_profiles_user_id_unique unique (user_id)
);

create or replace function public.touch_employee_profiles_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger employee_profiles_set_updated_at
before update on public.employee_profiles
for each row execute function public.touch_employee_profiles_updated_at();

alter table public.employee_profiles enable row level security;

create policy employee_profiles_self_read on public.employee_profiles
for select using (user_id = auth.uid());

create policy employee_profiles_self_write on public.employee_profiles
for insert with check (user_id = auth.uid());

create policy employee_profiles_self_update on public.employee_profiles
for update using (user_id = auth.uid())
with check (user_id = auth.uid());
