#!/bin/sh
# Generate Xray config at runtime (Cloady template equivalent, Render edition).
# Env: CLIENT_ID = 32 hex chars (UUID without hyphens)
#      WS_PATH  = WebSocket path, e.g. xR7mQ9vT2kL8p (no leading slash)
#      PORT     = set by Render
#      RENDER_EXTERNAL_HOSTNAME = set by Render, used only for the printed link
set -eu

case "${CLIENT_ID:-}" in
  ????????????????????????????????) ;;
  *) echo "CLIENT_ID must be exactly 32 hexadecimal characters" >&2; exit 1 ;;
esac
case "$CLIENT_ID" in
  *[!0-9a-fA-F]*) echo "CLIENT_ID must be exactly 32 hexadecimal characters" >&2; exit 1 ;;
esac

ID=$(printf '%s' "$CLIENT_ID" | sed -E 's/^(.{8})(.{4})(.{4})(.{4})(.{12})$/\1-\2-\3-\4-\5/' | tr 'A-F' 'a-f')
WS="${WS_PATH#/}"
PORT="${PORT:-10000}"
HOST="${RENDER_EXTERNAL_HOSTNAME:-${PUBLIC_HOST:-}}"

cat > /tmp/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "::",
      "port": $PORT,
      "protocol": "vless",
      "settings": { "clients": [{ "id": "$ID" }], "decryption": "none" },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/$WS" } },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"], "routeOnly": true }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
  ],
  "routing": {
    "rules": [
      { "type": "field", "protocol": ["bittorrent"], "outboundTag": "block" },
      { "type": "field", "port": "25", "outboundTag": "block" },
      {
        "type": "field",
        "ip": ["0.0.0.0/8", "10.0.0.0/8", "100.64.0.0/10", "127.0.0.0/8", "169.254.0.0/16", "172.16.0.0/12", "192.168.0.0/16", "fc00::/7", "fe80::/10", "::1/128"],
        "outboundTag": "block"
      }
    ]
  }
}
EOF

echo "Xray is listening on port $PORT (VLESS + WebSocket, path /$WS)"
if [ -n "$HOST" ]; then
  echo "VLESS client link: vless://${ID}@${HOST}:443?encryption=none&security=tls&sni=${HOST}&type=ws&host=${HOST}&path=%2F${WS}#Render"
fi

exec /usr/bin/xray -config /tmp/config.json
















































