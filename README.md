# Raven Portal

A dungeon-crawler-themed gameshow app. This is my project, built with help
from Claude.

## Architecture

Raven Portal is a Rails 8 **API-only** backend, built to sit behind a
React frontend (coming in a later phase). There are no server-rendered
views — every endpoint returns JSON.

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
  gate access by role. Users have a `role` of `user` or `admin`; a
  `UserPolicy` decides who can view which user records.
- **CORS**: [rack-cors](https://github.com/cyu/rack-cors) allows requests
  from the frontend's origin (`FRONTEND_ORIGIN` env var, defaults to the
  Vite dev server at `http://localhost:5173`) and exposes the
  `Authorization` header so the frontend can read the JWT.
- **Testing**: [RSpec](https://rspec.info/) — model, request, and policy
  specs.

### API endpoints (so far)

| Method | Path                  | Description                          |
|--------|-----------------------|---------------------------------------|
| POST   | `/api/v1/signup`      | Register a new crawler                |
| POST   | `/api/v1/login`       | Sign in, returns JWT + refresh token   |
| DELETE | `/api/v1/logout`      | Revoke the current JWT + refresh tokens |
| POST   | `/api/v1/refresh`     | Exchange a refresh token for a new JWT |
| GET    | `/api/v1/me`          | Current user's profile                |
| GET    | `/api/v1/users/:id`   | View a user (self or admin only)       |

## Setup

* Ruby version: see `.ruby-version`
* Requires a running Postgres server (connection settings via
  `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`
  env vars — see `config/database.yml`)
* `bin/setup` installs dependencies and prepares the database
* `bundle exec rspec` runs the test suite
