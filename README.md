# Scanopy on Railway

[Scanopy](https://github.com/scanopy/scanopy) (AGPL-3.0) — network diagrams and inventory that update themselves: hosts, services, subnets, VLANs and L2/L3 topology, discovered by a lightweight daemon on your network. Deploy the Scanopy server on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/tSt45y)

## What this template runs

- **scanopy**: `ghcr.io/onepush-dev/scanopy-server:v0.20.0`, the official `ghcr.io/scanopy/scanopy/server:v0.20.0` image (app unmodified) plus Railway defaults and a start wrapper. Public HTTPS domain on port 8080, healthcheck `/api/health`, restart policy Always, volume at `/data`.
- **Postgres**: Railway PostgreSQL with a volume. Holds all Scanopy data.

## Variables

| Service | Variable | Value | Notes |
|---|---|---|---|
| scanopy | `SCANOPY_ADMIN_PASSWORD` | `Scanopy1-` + generated secret | Password of the owner account created on first boot. |
| scanopy | `SCANOPY_DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Database connection. |
| scanopy | `SCANOPY_PUBLIC_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Used in invite, reset and daemon links. |
| Postgres | `POSTGRES_PASSWORD` | generated | Database password. |
| Postgres | `DATABASE_URL`, `PGHOST`, `PGPASSWORD`, `PGDATA` | references | Standard connection values. |

Baked into the image: `SCANOPY_SERVER_PORT=8080`, `SCANOPY_WEB_EXTERNAL_PATH=/app/static`, `SCANOPY_USE_SECURE_SESSION_COOKIES=true`, `SCANOPY_ADMIN_EMAIL=admin@scanopy.local`, `SCANOPY_ORG_NAME=My Network`, `SCANOPY_SITE_NAME=Home` (add a variable with the same name to override before first boot).

## How to use

1. Deploy, open the domain and sign in as `admin@scanopy.local` with `SCANOPY_ADMIN_PASSWORD` (scanopy service → Variables). Change the email and password in your account settings.
2. Scanopy Community Edition allows one organization, and the owner account is created on first boot, so nobody else can sign up on your URL. Invite teammates from the app.
3. Install the **Scanopy daemon on a machine inside your network** (Docker with host networking, or the Linux/macOS/Windows binary) and point it at your Railway URL. The daemon does the scanning and pushes results to the server; do not run the daemon on Railway, it cannot see your LAN.

## Notes

- Email (invites, password reset) needs SMTP: set `SCANOPY_SMTP_RELAY`, `SCANOPY_SMTP_PORT`, `SCANOPY_SMTP_USERNAME`, `SCANOPY_SMTP_PASSWORD`, `SCANOPY_SMTP_EMAIL` on the scanopy service. Optional.
- Not affiliated with Scanopy.
