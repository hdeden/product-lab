# 06_tech_spec

## Purpose
- Describe the proposed technical architecture for the HRMS SaaS.

## Inputs
- 04_requirements outputs.
- 05_ba_design outputs.

## Outputs
- High-level system architecture and key components.

## Default Tech Stack (Editable)
- Frontend: Flutter for mobile (Android/iOS) and web admin.
- Backend platform: Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime).
- API: Supabase REST (PostgREST) plus Edge Functions for server-side business logic.
- Auth: Supabase Auth with role-based access enforced by RLS.
- File storage: Supabase Storage for payslips and attachments.
- Notifications: Firebase Cloud Messaging for mobile push.
- Observability: Supabase logs plus external error tracking as needed.

## Architecture Overview
- Multi-tenant SaaS backend serving multiple client companies.
- Flutter apps for employees (mobile) and admins (web).
- Supabase provides database, auth, storage, and Edge Functions.
- API layer uses PostgREST and Edge Functions for complex workflows.

## Core Components
- Auth and tenant management (role-based access, tenant isolation via RLS).
- Attendance service (GPS, selfie capture, fraud checks, shift rules).
- Leave and approval service.
 - Payroll service (Phase 2: PPh21, BPJS, overtime rules).
- Employee self-service portal endpoints.
- Reporting and analytics service.

## Data and Storage
- Central relational database with tenant isolation and audit logging.
- Encrypted storage for sensitive files (payslips, attachments).
- Backup and recovery plan with regular snapshots.

## Role Model (RBAC)
- owner: full tenant access, billing, org-wide settings.
- hr_admin: manage employees, policies, payroll runs, reports.
- manager: approve leave/overtime for direct reports, view team data.
- employee: self-service only (own attendance, leave, payslips).

## Core Data Model (High-Level)
- tenants: company profile, settings, subscription plan.
- users: auth accounts tied to tenant.
- employees: employment data linked to users.
- employee_profiles: personal details and contacts.
- roles: role catalog (owner/hr_admin/manager/employee).
- user_roles: user-to-role mapping by tenant.
- org_units: departments or branches.
- locations: work locations per tenant.
- shifts: shift definitions.
- shift_assignments: employee shift assignments.
- attendance_events: clock-in/out timestamps, GPS, selfie, device metadata.
- leave_types: leave categories and rules.
- leave_balances: per-employee balances.
- leave_requests: leave submissions and approvals.
- overtime_requests: overtime submissions and approvals.
- payroll_runs: payroll periods and status.
- payroll_items: earnings and deductions per employee.
- payslips: per-employee payroll results with file reference.
- policies: JSON configuration by tenant.
- audit_logs: admin actions and approvals.

## Keys and Relationships (Baseline)
- tenants: id (uuid, pk).
- users: id (uuid, pk) from auth.users; tenant_id (fk -> tenants.id).
- employees: id (uuid, pk); user_id (fk -> users.id); tenant_id (fk -> tenants.id).
- employee_profiles: id (uuid, pk); employee_id (fk -> employees.id).
- roles: id (uuid, pk); name (unique).
- user_roles: id (uuid, pk); user_id (fk -> users.id); role_id (fk -> roles.id); tenant_id (fk -> tenants.id).
- org_units: id (uuid, pk); tenant_id (fk -> tenants.id).
- locations: id (uuid, pk); tenant_id (fk -> tenants.id).
- shifts: id (uuid, pk); tenant_id (fk -> tenants.id); location_id (fk -> locations.id).
- shift_assignments: id (uuid, pk); employee_id (fk -> employees.id); shift_id (fk -> shifts.id).
- attendance_events: id (uuid, pk); employee_id (fk -> employees.id); tenant_id (fk -> tenants.id).
- leave_types: id (uuid, pk); tenant_id (fk -> tenants.id).
- leave_balances: id (uuid, pk); employee_id (fk -> employees.id); leave_type_id (fk -> leave_types.id).
- leave_requests: id (uuid, pk); employee_id (fk -> employees.id); manager_id (fk -> users.id).
- overtime_requests: id (uuid, pk); employee_id (fk -> employees.id); manager_id (fk -> users.id).
- payroll_runs: id (uuid, pk); tenant_id (fk -> tenants.id); period_start/period_end.
- payroll_items: id (uuid, pk); payroll_run_id (fk -> payroll_runs.id); employee_id (fk -> employees.id).
- payslips: id (uuid, pk); payroll_run_id (fk -> payroll_runs.id); employee_id (fk -> employees.id).
- policies: id (uuid, pk); tenant_id (fk -> tenants.id).
- audit_logs: id (uuid, pk); tenant_id (fk -> tenants.id); actor_user_id (fk -> users.id).

## Index Recommendations
- All tables: index on tenant_id.
- attendance_events: (employee_id, event_time).
- leave_requests: (manager_id, status, created_at).
- overtime_requests: (manager_id, status, created_at).
- payroll_items: (payroll_run_id, employee_id).
- shift_assignments: (employee_id, shift_id).

## RLS Policy Checklist
- Enforce tenant isolation on all tables via tenant_id.
- Employees can only view their own profile, attendance, leave, and payslips.
- Managers can view and approve requests for their reporting line.
- HR/Admin can view all tenant data and manage policies.
- Service role only for Edge Functions and scheduled jobs.
- Storage buckets scoped by tenant with per-file ownership checks.

## Edge Functions (Initial List)
- payroll_run_create: aggregate attendance/leave/overtime into payroll run.
- payroll_run_finalize: lock period, generate payslips, write audit logs.
- leave_approve: apply approval rules and update leave balance.
- overtime_approve: apply approval rules and update payroll inputs.
- attendance_submit: validate GPS/selfie and write attendance record.
- notification_dispatch: send push notifications for approvals and reminders.

## Sample RLS Policy Templates

### Base Tenant Isolation
```sql
alter table public.employees enable row level security;

create policy tenant_isolation_employees
on public.employees
for all
using (tenant_id = auth.jwt() ->> 'tenant_id')
with check (tenant_id = auth.jwt() ->> 'tenant_id');
```

### Employee Self-Access
```sql
create policy employee_self_read
on public.employees
for select
using (id = auth.uid());
```

### Manager Approval Scope
```sql
create policy manager_leave_approval
on public.leave_requests
for update
using (
  tenant_id = auth.jwt() ->> 'tenant_id'
  and manager_id = auth.uid()
);
```

### Admin Full Access
```sql
create policy admin_full_access
on public.employees
for all
using (role = 'admin')
with check (role = 'admin');
```

## Security and Compliance
- TLS for all data in transit.
- Encryption at rest for sensitive fields.
- Access control per role and audit trails for admin actions.
- Compliance with Indonesian labor regulations and data privacy expectations.

## Scalability and Reliability
- Scalable backend with monitoring and logging.
- Prepared for peak attendance windows (morning/shift changes).
- Staging and production environments with controlled releases.

## Integrations (Roadmap)
- Bank transfer export or API.
- Optional fingerprint device import.
- Optional POS or accounting integrations.
