# Decision Log

A short running log of major decisions.

## Template
- Date:
- Decision:
- Rationale:
- Alternatives:
- Consequences:

- Date: 2025-12-27
- Decision: Use Supabase-only backend and Flutter-only frontend for the HRIS architecture baseline.
- Rationale: Single stack reduces integration overhead and speeds delivery for MVP while covering auth, database, storage, and server-side logic via Edge Functions.
- Alternatives: Separate web stack (React + Node/NestJS) with standalone backend services.
- Consequences: Business logic must live in Edge Functions and Postgres; Flutter Web admin UX may require extra optimization.

- Date: 2025-12-27
- Decision: Implement auth + tenant setup via Supabase migration with RLS and auth triggers; bootstrap first owner user via service role in local Docker.
- Rationale: Enables tenant isolation and role assignment from day one while unblocking local development without email confirmation.
- Alternatives: Manual SQL setup without triggers; external admin UI for user creation; defer RLS until later.
- Consequences: Requires tenant_id in auth metadata; local environment uses service role key for bootstrapping.
