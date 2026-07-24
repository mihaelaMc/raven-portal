# Raven Portal

A dungeon-crawler-themed gameshow app. This is my project, built with help
from Claude.

## Architecture

Raven Portal is a Rails 8 **API-only** backend plus a **React** frontend
(`frontend/`). The backend renders no HTML — every endpoint returns JSON —
and the frontend consumes it over CORS.

- **Database**: Postgres. Solid Queue/Cache/Cable (Rails 8's built-in
  background job, caching, and Action Cable adapters) ride on the same
  Postgres database in development/test, and on their own SQLite files in
  production.
- **Authentication**: [Devise](https://github.com/heartcombo/devise) +
  [devise-jwt](https://github.com/waiting-for-dev/devise-jwt). Login and
  signup return a short-lived JWT access token (in the `Authorization`
  response header) plus a longer-lived refresh token (in the JSON body).
  Refresh tokens are stored as a SHA-256 digest, never in plaintext, and
  rotate on every use. Logging out revokes the JWT via a denylist and
  revokes the user's outstanding refresh tokens.
- **Authorization**: [Pundit](https://github.com/varvet/pundit) policies
  gate access by role. Users have a `role` of `user` or `admin`.
- **Audit log**: logins, logouts, signups, password changes, profile
  edits, and admin actions are recorded asynchronously (ActiveJob) to an
  `audit_logs` table with no foreign keys, so history survives user
  deletion. Admins can query it with filters.
- **Email**: ActionMailer sends a welcome email on signup and an optional
  security alert on password change (per-user preference). Letter Opener
  previews emails in development; production is configured for Resend's
  SMTP relay.
- **Rate limiting**: [rack-attack](https://github.com/rack/rack-attack)
  throttles login attempts and overall request volume per IP.
- **CORS**: [rack-cors](https://github.com/cyu/rack-cors) allows requests
  from the frontend's origin (`FRONTEND_ORIGIN` env var, defaults to the
  Vite dev server at `http://localhost:5173`) and exposes the
  `Authorization` header so the frontend can read the JWT.
- **Frontend**: Vite + React, React Router, Axios (auto-attaches the JWT,
  silently refreshes on 401), TanStack Table + React Query for the admin
  user table, React Hook Form + Zod for forms, Tailwind CSS. Tokens live
  in memory only — never localStorage.
- **Testing**: [RSpec](https://rspec.info/) — model, request, policy,
  job, and mailer specs.

### API endpoints (so far)

| Method | Path                   | Description                                       |
|--------|------------------------|---------------------------------------------------|
| POST   | `/api/v1/signup`       | Register a new crawler                            |
| PATCH  | `/api/v1/signup`       | Change password (requires current password)       |
| POST   | `/api/v1/login`        | Sign in, returns JWT + refresh token              |
| DELETE | `/api/v1/logout`       | Revoke the current JWT + refresh tokens           |
| POST   | `/api/v1/refresh`      | Exchange a refresh token for a new JWT            |
| GET    | `/api/v1/me`           | Current user's profile                            |
| GET    | `/api/v1/users`        | List users, paginated + searchable (admin only)   |
| GET    | `/api/v1/users/:id`    | View a user (self or admin)                       |
| PATCH  | `/api/v1/users/:id`    | Update name/avatar/settings; role is admin-only   |
| DELETE | `/api/v1/users/:id`    | Delete a user (self or admin)                     |
| GET    | `/api/v1/audit_logs`   | Query the audit log with filters (admin only)     |

## Setup

Backend (from the repo root):

* Ruby version: see `.ruby-version`
* Requires a running Postgres server (connection settings via
  `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`
  env vars — see `config/database.yml`)
* `bin/setup` installs dependencies and prepares the database
* `bin/rails server` runs the API on port 3000
* `bundle exec rspec` runs the test suite

Frontend (in `frontend/`):

* `npm install`, then `cp .env.example .env`
* `npm run dev` serves the app at http://localhost:5173
