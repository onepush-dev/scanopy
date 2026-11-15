# Scanopy server on Railway: the official upstream image (scanopy/scanopy v0.20.0, AGPL-3.0), app unmodified.
# This layer only bakes Railway defaults (plain template values don't survive template generation):
# port 8080, bundled UI path, secure session cookies behind Railway's HTTPS edge, and a start wrapper
# that creates the owner account on first boot (Community Edition allows one organization), so a
# fresh public URL can never be claimed by someone else.
FROM ghcr.io/scanopy/scanopy/server:v0.20.0
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/scanopy"
COPY railway/start.sh /opt/railway/start.sh
ENV SCANOPY_SERVER_PORT=8080 \
    SCANOPY_WEB_EXTERNAL_PATH=/app/static \
    SCANOPY_USE_SECURE_SESSION_COOKIES=true \
    SCANOPY_ADMIN_EMAIL=admin@scanopy.local \
    SCANOPY_ORG_NAME="My Network" \
    SCANOPY_SITE_NAME=Home
EXPOSE 8080
ENTRYPOINT ["/opt/railway/start.sh"]
CMD ["server"]
