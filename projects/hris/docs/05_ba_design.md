# 05_ba_design

## Purpose
- Translate requirements into business flows and rules for HRIS operations.

## Inputs
- 04_requirements outputs.

## Outputs
- Core business processes, roles, and rules.

## Roles
- Employee: clock-in/out, request leave/overtime, view payslips.
- Manager/Supervisor: approve requests, view team attendance.
- HR/Admin: manage data, configure policies, run payroll, access reports.
- Owner/Finance: review payroll and cost reports.

## Core Flows

### Attendance Flow
1. Employee opens mobile app and clocks in/out.
2. System captures GPS location and optional selfie.
3. Attendance is stored and visible to admin in real time.
4. Anti-fraud checks flag suspicious entries for review.

### Leave Flow
1. Employee submits leave/permit request with dates and reason.
2. Manager/HR receives notification.
3. Approval or rejection is recorded.
4. Leave balance updates automatically and syncs to payroll.

### Overtime/Late Flow
1. Employee submits overtime request or late/early notice.
2. Manager approves based on policy.
3. Approved overtime feeds payroll calculations.

### Payroll Flow
1. Admin configures salary components (statutory BPJS/PPh21 rules in Phase 2).
2. System aggregates attendance, leave, and overtime for period.
3. Payroll is calculated and reviewed.
4. Payslips are generated and published in employee app.
5. Bank transfer export or API integration is prepared (phase-dependent).

## Business Rules
- Attendance requires GPS within allowed radius and valid device.
- Leave approval requires manager or HR based on org policy.
- Payroll must follow Indonesian labor rules for overtime and statutory deductions.
- Access to payroll data is restricted by role.

### MVP Notes
- Phase 1 focuses on basic payroll components and digital payslips.
- Statutory payroll (BPJS, PPh21) and advanced rules move to Phase 2.

### Default Policy Settings (Configurable)

#### Leave Types and Quotas
- Annual leave: 12 days per year after 12 months of service.
- Sick leave: paid with doctor note; tracked separately from annual leave.
- Maternity leave: 3 months total (1.5 months before + 1.5 months after).
- Miscarriage leave: 1.5 months.
- Paternity leave: 2 days.
- Marriage leave: 3 days.
- Child circumcision/baptism: 2 days.
- Family death leave (spouse/child/parent): 2 days.
- Unpaid leave: allowed with manager approval.

#### Overtime Rules
- Standard workweek: 40 hours per week (5x8 or 6x7 hours).
- Overtime rate: 1.5x for first hour, 2x for subsequent hours.
- Overtime cap: 4 hours per day, 18 hours per week.
- Meal allowance: granted when overtime >= 3 hours (configurable amount).

#### Late/Early Penalties
- Late <= 15 minutes: warning only.
- Late 16-60 minutes: deduct 0.5 hour equivalent.
- Late > 60 minutes: deduct 1 hour equivalent.
- Early leave uses same thresholds unless approved.

#### Payroll Components (Defaults)
- Earnings: base salary, fixed allowance, variable allowance, overtime pay, bonus, THR.
- Deductions: BPJS Kesehatan, BPJS Ketenagakerjaan, PPh21, lateness deduction, unpaid leave.
- THR: 1 month base salary after 12 months; prorated for shorter tenure.

#### Statutory Contribution Defaults
- BPJS Kesehatan: 1% employee, 4% employer (subject to caps).
- BPJS Ketenagakerjaan:
  - JHT: 2% employee, 3.7% employer.
  - JKK: employer only, default 0.24% (risk class configurable).
  - JKM: employer only, 0.3%.
  - JP: 1% employee, 2% employer (subject to caps).
  - Note: statutory defaults apply when Phase 2 payroll is enabled.

#### Approval Hierarchy (Default)
- Employee requests -> direct manager approves -> HR final approval.
- Payroll runs require HR approval and finance/owner sign-off.

## Reports
- Attendance summary (daily/weekly/monthly).
- Leave and overtime usage.
- Payroll summary and cost breakdown.
