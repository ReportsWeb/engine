# Reports.Web engine image (trial).
# - Port 3107: PDF rendering API (POST /render/pdf with PREPEJ JSON, GET /health) by the C++ WebAssembly engine.
# - /opt/reports.web: browser runtime (designer, previewer, fonts, barcode) used by the samples.
#   `docker run --rm -v <volume>:/export ghcr.io/reportsweb/engine export-runtime` copies it into a volume.
# Without a license file the output carries a red "SAMPLE" mark. Mount the purchased license at
# /app/reports-web.license (or set PAO_REPORTS_LICENSE_FILE) to remove it.
FROM node:22-alpine

LABEL org.opencontainers.image.title="Reports.Web engine" \
      org.opencontainers.image.description="Reports.Web report engine (C++ WebAssembly): PREPEJ JSON to PDF over HTTP, plus the browser designer/previewer runtime. Trial build." \
      org.opencontainers.image.source="https://github.com/ReportsWeb/engine" \
      org.opencontainers.image.url="https://www.pao.ac/reports.web/" \
      org.opencontainers.image.vendor="Pao@Office" \
      org.opencontainers.image.licenses="LicenseRef-Pao-Reports-Web-Trial" \
      org.opencontainers.image.version="1.0.0"

WORKDIR /app
COPY context/server/ /app/
COPY context/reports.web/ /opt/reports.web/
COPY export-runtime /usr/local/bin/export-runtime
RUN chmod 0755 /usr/local/bin/export-runtime && chown -R root:root /app /opt/reports.web && chmod -R a+rX /app /opt/reports.web

ENV REPORTS_ENGINE_ROOT=/app \
    REPORTS_ENGINE_PORT=3107 \
    NODE_ENV=production
EXPOSE 3107
USER node
HEALTHCHECK --interval=5s --timeout=3s --retries=20 \
  CMD node -e "fetch('http://127.0.0.1:3107/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "--max-old-space-size=384", "server.mjs"]
