-- HRIS Supabase schema baseline (tables, indexes, RLS policies)
-- Assumes pgcrypto for gen_random_uuid and auth.users exists.

create extension if not exists pgcrypto;

-- Core tenants
create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

-- Users mapped to tenants (auth.users is source of truth for auth)
create table if not exists public.users (
  id uuid primary key,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

-- Roles and user-role mapping
create table if not exists public.roles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table if not exists public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  role_id uuid not null references public.roles(id) on delete restrict,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Employee records
create table if not exists public.employees (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  user_id uuid references public.users(id) on delete set null,
  manager_user_id uuid references public.users(id) on delete set null,
  employee_code text,
  status text not null default 'active',
  hired_at date,
  created_at timestamptz not null default now(),
  constraint employees_user_id_unique unique (user_id),
  constraint employees_employee_code_unique unique (tenant_id, employee_code)
);

create table if not exists public.employee_profiles (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.employees(id) on delete cascade,
  full_name text not null,
  phone text,
  address text,
  created_at timestamptz not null default now(),
  constraint employee_profiles_employee_id_unique unique (employee_id)
);

-- Organization and locations
create table if not exists public.org_units (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.locations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  latitude numeric,
  longitude numeric,
  radius_meters integer,
  created_at timestamptz not null default now()
);

-- Shifts and assignments
create table if not exists public.shifts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  location_id uuid references public.locations(id) on delete set null,
  name text not null,
  start_time time not null,
  end_time time not null,
  created_at timestamptz not null default now()
);

create table if not exists public.shift_assignments (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.employees(id) on delete cascade,
  shift_id uuid not null references public.shifts(id) on delete cascade,
  assigned_date date not null,
  created_at timestamptz not null default now()
);

-- Attendance
create table if not exists public.attendance_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  event_type text not null check (event_type in ('clock_in', 'clock_out')),
  event_time timestamptz not null,
  latitude numeric,
  longitude numeric,
  selfie_url text,
  device_id text,
  created_at timestamptz not null default now()
);

-- Leave
create table if not exists public.leave_types (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  paid boolean not null default true,
  annual_quota integer,
  created_at timestamptz not null default now()
);

create table if not exists public.leave_balances (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.employees(id) on delete cascade,
  leave_type_id uuid not null references public.leave_types(id) on delete cascade,
  balance numeric not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.leave_requests (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.employees(id) on delete cascade,
  manager_id uuid references public.users(id) on delete set null,
  leave_type_id uuid not null references public.leave_types(id) on delete restrict,
  start_date date not null,
  end_date date not null,
  reason text,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

-- Overtime
create table if not exists public.overtime_requests (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.employees(id) on delete cascade,
  manager_id uuid references public.users(id) on delete set null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  reason text,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

-- Payroll
create table if not exists public.payroll_runs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  period_start date not null,
  period_end date not null,
  status text not null default 'draft',
  created_at timestamptz not null default now()
);

create table if not exists public.payroll_items (
  id uuid primary key default gen_random_uuid(),
  payroll_run_id uuid not null references public.payroll_runs(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  gross_pay numeric not null default 0,
  total_deductions numeric not null default 0,
  net_pay numeric not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.payslips (
  id uuid primary key default gen_random_uuid(),
  payroll_run_id uuid not null references public.payroll_runs(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  file_url text,
  created_at timestamptz not null default now()
);

-- Policies and audit
create table if not exists public.policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  key text not null,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  actor_user_id uuid references public.users(id) on delete set null,
  action text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Seed roles
insert into public.roles (name)
values ('owner'), ('hr_admin'), ('manager'), ('employee')
on conflict (name) do nothing;

-- Helper: assign default role to a new user
create or replace function public.assign_default_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role_id uuid;
  v_role_name text;
begin
  v_role_name := coalesce(new.raw_user_meta_data ->> 'role', 'employee');
  select id into v_role_id from public.roles where name = v_role_name;
  if v_role_id is null then
    raise exception 'invalid role: %', v_role_name;
  end if;

  insert into public.user_roles (user_id, role_id, tenant_id)
  values (new.id, v_role_id, (new.raw_user_meta_data ->> 'tenant_id')::uuid)
  on conflict do nothing;

  return new;
end;
$$;

-- Trigger to sync auth.users -> public.users
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
begin
  v_tenant_id := (new.raw_user_meta_data ->> 'tenant_id')::uuid;
  if v_tenant_id is null then
    raise exception 'tenant_id required in user metadata';
  end if;

  insert into public.users (id, tenant_id, email)
  values (new.id, v_tenant_id, new.email)
  on conflict (id) do update
    set tenant_id = excluded.tenant_id,
        email = excluded.email;

  return new;
end;
$$;

-- Trigger to create employee + profile on signup
create or replace function public.handle_new_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
  v_employee_id uuid;
  v_full_name text;
begin
  v_tenant_id := (new.raw_user_meta_data ->> 'tenant_id')::uuid;
  if v_tenant_id is null then
    raise exception 'tenant_id required in user metadata';
  end if;

  v_full_name := coalesce(new.raw_user_meta_data ->> 'full_name', new.email);

  select id into v_employee_id
  from public.employees
  where user_id = new.id;

  if v_employee_id is null then
    insert into public.employees (tenant_id, user_id)
    values (v_tenant_id, new.id)
    returning id into v_employee_id;

    insert into public.employee_profiles (employee_id, full_name)
    values (v_employee_id, v_full_name);
  end if;

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create trigger on_auth_user_role_assign
after insert on auth.users
for each row execute function public.assign_default_role();

create trigger on_auth_user_employee_init
after insert on auth.users
for each row execute function public.handle_new_employee();

-- Indexes
create index if not exists idx_users_tenant_id on public.users (tenant_id);
create index if not exists idx_employees_tenant_id on public.employees (tenant_id);
create index if not exists idx_employees_manager_user_id on public.employees (manager_user_id);
create index if not exists idx_attendance_employee_time on public.attendance_events (employee_id, event_time);
create index if not exists idx_leave_requests_manager_status on public.leave_requests (manager_id, status, created_at);
create index if not exists idx_overtime_requests_manager_status on public.overtime_requests (manager_id, status, created_at);
create index if not exists idx_payroll_items_run_employee on public.payroll_items (payroll_run_id, employee_id);
create index if not exists idx_shift_assignments_employee_shift on public.shift_assignments (employee_id, shift_id);

-- RLS setup
alter table public.tenants enable row level security;
alter table public.users enable row level security;
alter table public.user_roles enable row level security;
alter table public.employees enable row level security;
alter table public.employee_profiles enable row level security;
alter table public.org_units enable row level security;
alter table public.locations enable row level security;
alter table public.shifts enable row level security;
alter table public.shift_assignments enable row level security;
alter table public.attendance_events enable row level security;
alter table public.leave_types enable row level security;
alter table public.leave_balances enable row level security;
alter table public.leave_requests enable row level security;
alter table public.overtime_requests enable row level security;
alter table public.payroll_runs enable row level security;
alter table public.payroll_items enable row level security;
alter table public.payslips enable row level security;
alter table public.policies enable row level security;
alter table public.audit_logs enable row level security;

-- Note: tenant_id must be present in JWT claims for these policies.

-- Tenant isolation
create policy tenant_isolation_users on public.users
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_user_roles on public.user_roles
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_employees on public.employees
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_employee_profiles on public.employee_profiles
for all using (
  exists (
    select 1 from public.employees e
    where e.id = public.employee_profiles.employee_id
      and e.tenant_id = auth.jwt() ->> 'tenant_id'
  )
) with check (
  exists (
    select 1 from public.employees e
    where e.id = public.employee_profiles.employee_id
      and e.tenant_id = auth.jwt() ->> 'tenant_id'
  )
);

create policy tenant_isolation_org_units on public.org_units
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_locations on public.locations
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_shifts on public.shifts
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_attendance on public.attendance_events
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_leave_types on public.leave_types
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_payroll_runs on public.payroll_runs
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_policies on public.policies
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

create policy tenant_isolation_audit_logs on public.audit_logs
for all using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');

-- Employee self access
create policy employee_self_attendance on public.attendance_events
for select using (employee_id = auth.uid());

create policy employee_self_leave_requests on public.leave_requests
for select using (employee_id = auth.uid());

create policy employee_self_leave_balances on public.leave_balances
for select using (
  exists (
    select 1 from public.employees e
    where e.id = public.leave_balances.employee_id
      and e.user_id = auth.uid()
  )
);

create policy employee_self_payslips on public.payslips
for select using (employee_id = auth.uid());

create policy employee_profile_self_update on public.employee_profiles
for update using (
  exists (
    select 1 from public.employees e
    where e.id = public.employee_profiles.employee_id
      and e.user_id = auth.uid()
  )
);

-- Manager access and approvals (based on employees.manager_user_id)
create policy manager_employees_read on public.employees
for select using (manager_user_id = auth.uid());

create policy manager_leave_read on public.leave_requests
for select using (
  exists (
    select 1 from public.employees e
    where e.id = public.leave_requests.employee_id
      and e.manager_user_id = auth.uid()
  )
);

create policy manager_overtime_read on public.overtime_requests
for select using (
  exists (
    select 1 from public.employees e
    where e.id = public.overtime_requests.employee_id
      and e.manager_user_id = auth.uid()
  )
);

create policy manager_attendance_read on public.attendance_events
for select using (
  exists (
    select 1 from public.employees e
    where e.id = public.attendance_events.employee_id
      and e.manager_user_id = auth.uid()
  )
);

create policy manager_shift_assignments_read on public.shift_assignments
for select using (
  exists (
    select 1 from public.employees e
    where e.id = public.shift_assignments.employee_id
      and e.manager_user_id = auth.uid()
  )
);

create policy manager_employee_profiles_read on public.employee_profiles
for select using (
  exists (
    select 1 from public.employees e
    where e.id = public.employee_profiles.employee_id
      and e.manager_user_id = auth.uid()
  )
);

create policy manager_leave_approval on public.leave_requests
for update using (
  exists (
    select 1 from public.employees e
    where e.id = public.leave_requests.employee_id
      and e.manager_user_id = auth.uid()
  )
);

create policy manager_overtime_approval on public.overtime_requests
for update using (
  exists (
    select 1 from public.employees e
    where e.id = public.overtime_requests.employee_id
      and e.manager_user_id = auth.uid()
  )
);

-- HR/Admin access via roles
create policy hr_admin_access_employees on public.employees
for all using (
  exists (
    select 1 from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid()
      and r.name in ('owner', 'hr_admin')
      and ur.tenant_id = public.employees.tenant_id
  )
);

create policy hr_admin_access_user_roles on public.user_roles
for all using (
  exists (
    select 1 from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid()
      and r.name in ('owner', 'hr_admin')
      and ur.tenant_id = public.user_roles.tenant_id
  )
);

create policy hr_admin_access_leave_balances on public.leave_balances
for all using (
  exists (
    select 1 from public.employees e
    join public.user_roles ur on ur.user_id = auth.uid()
    join public.roles r on r.id = ur.role_id
    where e.id = public.leave_balances.employee_id
      and r.name in ('owner', 'hr_admin')
      and ur.tenant_id = e.tenant_id
  )
);

create policy hr_admin_access_employee_profiles on public.employee_profiles
for all using (
  exists (
    select 1 from public.employees e
    join public.user_roles ur on ur.user_id = auth.uid()
    join public.roles r on r.id = ur.role_id
    where e.id = public.employee_profiles.employee_id
      and r.name in ('owner', 'hr_admin')
      and ur.tenant_id = e.tenant_id
  )
);

-- Tenant consistency checks
create or replace function public.assert_same_tenant_manager()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
  v_manager_tenant uuid;
begin
  if new.manager_user_id is null then
    return new;
  end if;

  v_tenant_id := new.tenant_id;
  select tenant_id into v_manager_tenant from public.users where id = new.manager_user_id;

  if v_manager_tenant is null or v_manager_tenant <> v_tenant_id then
    raise exception 'manager_user_id must belong to same tenant';
  end if;

  return new;
end;
$$;

create or replace function public.assert_same_tenant_request_manager()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_employee_tenant uuid;
  v_manager_tenant uuid;
begin
  if new.manager_id is null then
    return new;
  end if;

  select tenant_id into v_employee_tenant from public.employees where id = new.employee_id;
  select tenant_id into v_manager_tenant from public.users where id = new.manager_id;

  if v_employee_tenant is null or v_manager_tenant is null or v_employee_tenant <> v_manager_tenant then
    raise exception 'manager_id must belong to same tenant as employee';
  end if;

  return new;
end;
$$;

create trigger employees_manager_tenant_check
before insert or update on public.employees
for each row execute function public.assert_same_tenant_manager();

create trigger leave_requests_manager_tenant_check
before insert or update on public.leave_requests
for each row execute function public.assert_same_tenant_request_manager();

create trigger overtime_requests_manager_tenant_check
before insert or update on public.overtime_requests
for each row execute function public.assert_same_tenant_request_manager();
