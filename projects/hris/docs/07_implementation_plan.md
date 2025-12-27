# 07_implementation_plan

## Purpose
- Outline phased delivery from MVP to scale with a Supabase + Flutter stack.

## Inputs
- 03_synthesis outputs.
- HRIS Design v0.1 roadmap.

## Outputs
- Phased plan with milestones and deliverables.

## Plan

### Phase 0: Research and Planning
- Stakeholder interviews for cafe and security operators.
- Define MVP scope and prioritize features.
- Produce wireframes and UX prototypes.
- Supabase setup: project, environments (dev/staging/prod), and baseline schema draft.

### Phase 1: MVP
- Flutter employee app: attendance (GPS + optional selfie), leave requests.
- Flutter admin web: basic employee management and approvals.
- Supabase Auth + RBAC with RLS policies per tenant.
- Core tables: tenants, users, employees, attendance, leave, payroll_runs, payslips.
- Edge Functions for payroll calculation and approvals.
- Supabase Storage for payslips and attachments.
- Pilot with 1-2 partner companies.

### Phase 2: Core Feature Complete
- Advanced shift scheduling and multi-location support.
- Overtime and late/early rules with payroll integration.
- Full payroll with BPJS and PPh21.
- Reporting dashboards and export.
- Security hardening: audit logs, RLS review, policy tests.
- Performance optimization: indexes, query tuning, caching patterns.

### Phase 3: Launch and Early Growth
- Public beta and onboarding for first 5-10 clients.
- Feedback loop and rapid fixes.
- Customer support playbooks and documentation.
- Monitoring dashboards for Supabase usage and error rates.

### Phase 4: Scaling and Expansion
- Scale Supabase project: read replicas, compute upgrades, storage lifecycle rules.
- Edge Function hardening and queue-based batch payroll runs if needed.
- Optional integrations (bank export, POS, fingerprint devices).
- Add-on modules if demand justifies (recruitment, performance).

### Phase 5: Maturity
- Continuous improvement, analytics, and advanced insights.
- Segmented packages for micro and enterprise clients.
- Compliance reviews and optional certifications.
