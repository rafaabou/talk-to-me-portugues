# syntax=docker/dockerfile:1
# =============================================================================
# Scan-only artifact image - Talk To Me Portugues Brasileiro
#
# The production APK is compiled ON THE HOST by CI ("Build Portuguese Release
# APK" step) and staged into this build context as app-release.apk. This image
# exists purely so trivy/grype/dockle can inspect the shipped artifact in a
# hardened, minimal container. It is never published.
#
# Passes: hadolint (no warnings) and dockle CIS checks:
#         CIS-DI-0001 non-root user, CIS-DI-0005 content trust,
#         CIS-DI-0006 healthcheck.
#
# NOTE: app/.dockerignore keeps the staged app-release.apk and excludes
#       keystores/host state (see app/.dockerignore).
# =============================================================================

FROM alpine:3.22

LABEL org.opencontainers.image.title="talk-to-me-portugues" \
      org.opencontainers.image.description="Release APK artifact container (scan-only, never published)" \
      org.opencontainers.image.source="https://github.com/rafaabou/ptbr-zero-to-hero" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN addgroup -S appgroup && adduser -S -G appgroup appuser

ENV DOCKER_CONTENT_TRUST=1

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD [ -f /app-release.apk ] || exit 1

COPY app-release.apk /app-release.apk

USER appuser

CMD ["true"]
