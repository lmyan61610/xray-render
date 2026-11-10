# Xray (VLESS + WebSocket) for Render Free Web Service
# Based on the Cloady template image teddysun/xray:26.10.31.
# The start script generates /tmp/config.json at runtime from
# CLIENT_ID (32 hex chars, no hyphens) and WS_PATH, listening on $PORT.
FROM teddysun/xray:26.10.31
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD ["/bin/sh", "/usr/local/bin/start.sh"]








