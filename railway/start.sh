#!/bin/sh
# Railway start wrapper for the Scanopy server. Starts the upstream server, waits for /api/health,
# then on first boot creates the owner account (SCANOPY_ADMIN_EMAIL / SCANOPY_ADMIN_PASSWORD) with the
# server's own setup + register API. Scanopy Community Edition allows a single organization, so once
# this account exists nobody else can sign up without an invite.
PORT_="${SCANOPY_SERVER_PORT:-8080}"
if [ -z "${SCANOPY_PUBLIC_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export SCANOPY_PUBLIC_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi
echo "railway: Scanopy server starting on port ${PORT_}, public URL ${SCANOPY_PUBLIC_URL:-unset}"
"$@" &
PID=$!
trap 'kill -TERM "$PID" 2>/dev/null; wait "$PID"; exit $?' TERM INT

B="http://127.0.0.1:${PORT_}"
i=0
until curl -fsS -o /dev/null "$B/api/health"; do
  i=$((i+1))
  if ! kill -0 "$PID" 2>/dev/null; then wait "$PID"; exit $?; fi
  [ $i -ge 300 ] && break
  sleep 1
done

if [ -n "${SCANOPY_ADMIN_PASSWORD:-}" ]; then
  J=$(mktemp)
  curl -s -o /dev/null -c "$J" -b "$J" -H 'Content-Type: application/json' -X POST "$B/api/auth/setup" \
    -d "{\"organization_name\":\"${SCANOPY_ORG_NAME:-My Network}\",\"site\":{\"name\":\"${SCANOPY_SITE_NAME:-Home}\"}}"
  CODE=$(curl -s -o /tmp/railway-register.json -w '%{http_code}' -c "$J" -b "$J" -H 'Content-Type: application/json' \
    -X POST "$B/api/auth/register" \
    -d "{\"email\":\"${SCANOPY_ADMIN_EMAIL}\",\"password\":\"${SCANOPY_ADMIN_PASSWORD}\",\"terms_accepted\":true}")
  rm -f "$J"
  case "$CODE" in
    200|201) echo "railway: created the owner account ${SCANOPY_ADMIN_EMAIL}; sign in with SCANOPY_ADMIN_PASSWORD from this service's Variables tab" ;;
    409|403) echo "railway: owner account already set up; sign in as ${SCANOPY_ADMIN_EMAIL} (or the account you created)" ;;
    *) echo "railway: could not create the owner account (HTTP ${CODE}): $(head -c 300 /tmp/railway-register.json)" >&2 ;;
  esac
  rm -f /tmp/railway-register.json
else
  echo "railway: SCANOPY_ADMIN_PASSWORD is empty, so the first person to open the URL can register the only organization" >&2
fi
wait "$PID"
