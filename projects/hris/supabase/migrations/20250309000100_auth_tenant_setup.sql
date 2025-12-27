-- Auth + tenant baseline schema for HRIS
-- Assumes auth.users is managed by Supabase Auth.

create extension if not exists pgcrypto;

create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.users (
  id uuid primary key,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

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

insert into public.roles (name)
values ('owner'), ('hr_admin'), ('manager'), ('employee')
on conflict (name) do nothing;

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

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create trigger on_auth_user_role_assign
after insert on auth.users
for each row execute function public.assign_default_role();

alter table public.tenants enable row level security;
alter table public.users enable row level security;
alter table public.user_roles enable row level security;
alter table public.roles enable row level security;

create policy tenant_self_access on public.tenants
for all using (id = (auth.jwt() ->> 'tenant_id')::uuid)
with check (id = (auth.jwt() ->> 'tenant_id')::uuid);

create policy tenant_isolation_users on public.users
for all using (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid)
with check (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

create policy users_self_read on public.users
for select using (id = auth.uid());

create policy tenant_isolation_user_roles on public.user_roles
for all using (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid)
with check (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

create policy user_roles_self_read on public.user_roles
for select using (user_id = auth.uid());

create policy roles_read on public.roles
for select using (true);
