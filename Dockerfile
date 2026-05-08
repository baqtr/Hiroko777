# Heroku authorized XMR mining container
# Use only on an app/dyno where you have explicit written permission from Heroku/Salesforce.
FROM debian:bookworm-slim

ARG XMRIG_VERSION=6.26.0

ENV XMR_POOL="pool.supportxmr.com:3333" \
    WORKER_NAME="heroku-worker" \
    XMR_THREADS="auto" \
    XMR_DONATE_LEVEL="1" \
    PORT="8080"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl tar procps python3 \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fL --retry 5 --retry-delay 3 \
      -o /tmp/xmrig.tgz \
      "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz"; \
    mkdir -p /opt/xmrig; \
    tar -xzf /tmp/xmrig.tgz -C /opt/xmrig --strip-components=1; \
    chmod +x /opt/xmrig/xmrig; \
    rm -f /tmp/xmrig.tgz

WORKDIR /app
COPY start.sh /app/start.sh
COPY start_web.sh /app/start_web.sh
COPY health_server.py /app/health_server.py
RUN chmod +x /app/start.sh /app/start_web.sh

CMD ["/app/start.sh"]
