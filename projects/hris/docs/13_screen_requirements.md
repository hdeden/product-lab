# 13_screen_requirements

## Purpose
- Capture screen requirements for the current HRIS MVP flow implemented in the Flutter app.

## Scope
- Screens included: Auth, Dashboard, Attendance, Profile.

## Global UX
- Mobile-first layouts with responsive constraints for web.
- Consistent card-based layout and primary action placement.
- Error states are visible inline with clear messages.
- All screen access requires an authenticated session.

## Screen: Auth
### Purpose
- Let users sign in or sign up with tenant metadata.

### Components
- Email input (required).
- Password input (required).
- Tenant ID input (required on sign up).
- Role input (optional on sign up, default employee).
- Primary action button (Sign in / Create account).
- Secondary toggle (switch between sign in and sign up).
- Inline error message container.
- Helper text about tenant ID and emulator URL.

### Functional Requirements
- Validate required fields before submit.
- Sign in uses email + password.
- Sign up sends tenant_id and role in user metadata.
- Display auth error messages.

### States
- Loading: disable buttons while request in flight.
- Error: show auth error in styled container.

## Screen: Dashboard
### Purpose
- Provide a landing view with user identity and quick actions.

### Components
- Welcome card with email.
- Info chips: Tenant ID, Role.
- Quick actions: Attendance, Profile.
- Next steps callout card.
- App bar with sign out action.

### Functional Requirements
- Fetch profile data from users + user_roles tables.
- Display tenant and role for current user.
- Navigate to Attendance and Profile routes.
- Sign out ends session and returns to Auth.

### States
- Loading: full screen progress indicator.
- Error: show load error with text explanation.

## Screen: Attendance
### Purpose
- Record clock-in/out events with location and show recent activity.

### Components
- Clock status card with Clock In / Clock Out buttons.
- Status message container (success or error).
- Recent events list (type, time, location).

### Functional Requirements
- Request location permissions and read GPS coordinates.
- Insert attendance_events with tenant_id, user_id, event_type, event_time, lat/long.
- Refresh recent events after insert.
- Show location in status and list (lat/long).

### States
- Loading: progress indicator while events load.
- Submitting: disable clock buttons.
- Error: show failure message in status container.

## Screen: Profile
### Purpose
- Show tenant and role context; allow basic personal detail updates.

### Components
- Identity card (email, tenant ID, role).
- Personal details form (full name, phone).
- Save button with status feedback.

### Functional Requirements
- Load tenant and role for current user.
- Load employee_profiles record by user_id.
- Upsert employee_profiles with full_name and phone.
- Show success or error message after save.

### States
- Loading: progress indicator on initial load.
- Saving: disable save button and show Saving state.
- Error: show load/save error in status container.
