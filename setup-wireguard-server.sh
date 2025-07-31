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
PUBLIC_KEY_CLIENT="CLIENT_PUBLIC_KEY" # ← Ersetze diesen Platzhalter mit dem tatsächlichen Public Key des Clients

echo "📝 Konfigurationsdatei erstellen..."
sudo bash -c "cat > /etc/wireguard/wg0.conf" <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
SaveConfig = true

[Peer]
PublicKey = $PUBLIC_KEY_CLIENT
AllowedIPs = 10.0.0.2/32
EOF

echo "🔁 IP-Forwarding aktivieren..."
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p

echo "🚀 WireGuard aktivieren..."
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

echo "✅ Fertig! Dein WireGuard-Server läuft 🎉"
