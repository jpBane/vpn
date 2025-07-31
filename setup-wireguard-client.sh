#!/bin/bash

set -e

echo "🔄 System aktualisieren..."
sudo apt update && sudo apt upgrade -y

echo "📦 WireGuard installieren..."
sudo apt install wireguard wireguard-tools -y

echo "🔐 Schlüssel generieren..."
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

PRIVATE_KEY=$(cat privatekey)
SERVER_PUBLIC_KEY="SERVER_PUBLIC_KEY" # ← Ersetze durch den Public Key des Servers
SERVER_ENDPOINT="your.server.com:51820" # ← Ersetze mit IP oder Domain + Port des Servers

echo "📝 Konfiguration erstellen..."
sudo bash -c "cat > /etc/wireguard/wg0.conf" <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "🚀 WireGuard aktivieren..."
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

echo "✅ Der WireGuard-Client ist bereit 🔒"
