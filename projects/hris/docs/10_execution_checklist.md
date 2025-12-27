# 10_execution_checklist

## Purpose
- Provide a technical execution checklist for the HRIS MVP and Phase 2 scope.

## Inputs
- 04_requirements
- 05_ba_design
- 06_tech_spec
- 07_implementation_plan

## Outputs
- Actionable build checklist with phase gates.

## Phase 0: Project Setup
- [ ] Confirm environments (dev/staging/prod) and Supabase project setup.
- [ ] Define tenant onboarding flow and seed roles.
- [ ] Establish repo structure under `projects/hris/` (`app/`, `backend/`, `docs/`).
- [ ] Document API boundaries (PostgREST vs Edge Functions).

## Phase 1: MVP Build
### Data and Auth
- [ ] Implement core tables: tenants, users, employees, attendance, leave, payroll_runs, payslips.
- [ ] Configure Supabase Auth and JWT claims for tenant_id and role.
- [ ] Enforce RLS tenant isolation and role-based access.
- [ ] Add audit logging for admin actions.

### Attendance
- [ ] Mobile clock-in/out with GPS capture.
- [ ] Selfie capture and storage (optional at MVP).
- [ ] Anti-fraud checks (basic device checks and GPS radius).

### Leave
- [ ] Leave types and balances setup.
- [ ] Leave request flow with approval.
- [ ] Auto-update leave balance after approval.

### Payroll Basics
- [ ] Configurable salary components and deductions.
- [ ] Basic payroll aggregation from attendance/leave.
- [ ] Generate and store digital payslips.

### Employee Self-Service
- [ ] Employee profile, attendance history, leave balance.
- [ ] Payslip access with self-only permissions.

### Admin Web
- [ ] Employee CRUD and org structure.
- [ ] Approval queues (leave, overtime/late-early).
- [ ] Attendance and leave reports (basic).

### Notifications
- [ ] Push notification setup for approvals and reminders.

### Release Readiness
- [ ] MVP data seeding for pilot tenants.
- [ ] Pilot onboarding checklist and support playbook.
- [ ] Minimal monitoring and error tracking.

## Phase 2: Core Feature Complete
- [ ] Statutory payroll (BPJS, PPh21) calculations and validations.
- [ ] Overtime and late/early rules feeding payroll.
- [ ] Advanced shift scheduling (calendar, rotation, multi-location).
- [ ] Full reporting dashboard and export.
- [ ] Security hardening (RLS audit, penetration test baseline).
- [ ] Performance tuning and index review.

## Phase 4: Scaling and Expansion
- [ ] Offline attendance sync for low-connectivity locations.
- [ ] Queue-based batch payroll runs.
- [ ] Observability dashboards (errors, latency, usage).
- [ ] Backup/restore drill and disaster recovery plan.
