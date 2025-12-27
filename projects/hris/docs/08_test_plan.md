# 08_test_plan

## Purpose
- Define test coverage for MVP and early releases.

## Inputs
- 04_requirements outputs.
- 05_ba_design flows.

## Outputs
- Test scope, scenarios, and acceptance criteria.

## Test Scope
- Attendance (GPS, selfie, offline/online behavior).
- Leave and approval workflows.
- Overtime and late/early rules.
- Payroll calculations (salary components, BPJS, PPh21).
- Employee self-service (payslips, balances, history).
- Admin dashboard (data management, reports, access control).
- Notifications and audit logging.

## Test Scenarios
- Clock-in/out with valid GPS and within shift window.
- Reject attendance with spoofed GPS or invalid device.
- Leave request approval updates leave balance and payroll.
- Payroll matches expected results with sample data sets.
- Payslip access restricted to owner.
- Admin role access is enforced for sensitive operations.
- Report exports generate correct totals.

## Non-Functional Tests
- Peak load simulation at typical attendance hours.
- Data encryption and access control checks.
- Backup and restore validation.

## Pilot Testing
- Run pilot with cafe and security partners.
- Capture usability feedback on mobile UX and admin workflow.
- Track error rates, support tickets, and adoption metrics.
