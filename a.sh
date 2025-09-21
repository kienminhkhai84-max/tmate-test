#!/bin/bash
set -e

apt update -y
apt install -y tmate curl

WEBHOOK_URL="https://discord.com/api/webhooks/1415568104431419413/qeNlbGgONMRJ9-fHce9cZfO17W9LsMta9TMJtwkTItXzR3e27w2hEpwaKdn7SMRQTEun"
TMATE_SOCK="/tmp/tmate.sock"

# Dừng tmate cũ (nếu có)
pkill -f "tmate -S" 2>/dev/null || true

echo "[*] Starting tmate session..."
tmate -S "$TMATE_SOCK" new-session -d

echo "[*] Waiting for tmate to be ready..."
tmate -S "$TMATE_SOCK" wait tmate-ready

TMATE_SSH=""
while [ -z "$TMATE_SSH" ]; do
    TMATE_SSH=$(tmate -S "$TMATE_SOCK" display -p '#{tmate_ssh}' 2>/dev/null)
    [ -z "$TMATE_SSH" ] && sleep 1
done
echo "[*] TMATE SSH URL: $TMATE_SSH"

echo "[*] Sending SSH URL to Discord..."
curl -s -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\":\"TMATE SSH URL: $TMATE_SSH\"}" \
     "$WEBHOOK_URL"

# Chỉ attach khi chạy trực tiếp trong terminal
if [ -t 1 ]; then
    tmate -S "$TMATE_SOCK" attach
else
    echo "[*] Script finished – tmate session is running in background."
fi
