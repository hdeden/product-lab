# 04_requirements

## Purpose
- Define functional and non-functional requirements for the HRMS product.

## Inputs
- 03_synthesis outputs.
- HRIS Design v0.1.

## Outputs
- Product requirements ready for BA design and tech spec.

## Functional Requirements
- Attendance must support clock-in/clock-out via mobile with GPS tagging.
- Attendance should support selfie verification and anti-fraud checks (location spoofing/root detection).
- System must support shift scheduling (multi-shift, multi-location) and notify employees of changes.
- Employees must be able to request leave and permits; managers/HR must approve or reject.
- Leave balance must auto-update after approval.
- Overtime requests and late/early permissions must be supported and feed payroll.
- Payroll must calculate salary using attendance, leave, overtime, and configured components.
- Payroll must support PPh21 and BPJS calculations per Indonesian rules.
- Employees must access digital payslips and history in the mobile app.
- Admins must manage employee data, organization structure, policies, and payroll components.
- Admins must access reports for attendance, leave, overtime, and payroll.
- Role-based access control and audit logs must be available for admin actions.

## Non-Functional Requirements
- Mobile-first UX for employees; web dashboard for admins.
- Bahasa Indonesia UI and support materials.
- Multi-tenant SaaS architecture with tenant data isolation.
- Data security: encryption at rest and in transit, backups, and access controls.
- Compliance with Indonesian labor and data privacy regulations.
- Scalability to 10,000+ users with stable performance at peak times.
- Monitoring and logging for uptime and operational insight.

## Constraints
- Target UMKM price sensitivity; features should not overcomplicate onboarding.
- Phase delivery must prioritize attendance, leave, and payroll first.
