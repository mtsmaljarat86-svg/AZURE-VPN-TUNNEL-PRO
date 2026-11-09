#!/usr/bin/env bash
set -Eeuo pipefail

PUBLIC_IP="${1:-}"
WG_PORT="51820"
WG_IF="wg0"
WG_DIR="/etc/wireguard"
CLIENT_DIR="/root/wireguard-client"
SERVER_CONF="${WG_DIR}/${WG_IF}.conf"

fail() { echo "ERROR: $*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || fail "Run with sudo."
[[ "$PUBLIC_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || fail "Pass the Azure public IPv4 as the first argument."

. /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || fail "Ubuntu only."
[[ ! -e "$SERVER_CONF" ]] || fail "$SERVER_CONF already exists; refusing to overwrite."

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y wireguard qrencode iptables

WAN_IF="$(ip -4 route show default | awk 'NR==1 {print $5}')"
[[ -n "$WAN_IF" ]] || fail "Could not detect default network interface."

install -d -m 700 "$WG_DIR" "$CLIENT_DIR"
umask 077
SERVER_PRIVATE="$(wg genkey)"
SERVER_PUBLIC="$(printf '%s' "$SERVER_PRIVATE" | wg pubkey)"
CLIENT_PRIVATE="$(wg genkey)"
CLIENT_PUBLIC="$(printf '%s' "$CLIENT_PRIVATE" | wg pubkey)"
CLIENT_PSK="$(wg genpsk)"

cat > "$SERVER_CONF" <<EOF
[Interface]
Address = 10.77.0.1/24
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIVATE}
SaveConfig = false
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${WAN_IF} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${WAN_IF} -j MASQUERADE

[Peer]
PublicKey = ${CLIENT_PUBLIC}
PresharedKey = ${CLIENT_PSK}
AllowedIPs = 10.77.0.2/32
EOF
chmod 600 "$SERVER_CONF"

cat > /etc/sysctl.d/99-wireguard-forward.conf <<'EOF'
net.ipv4.ip_forward=1
EOF
sysctl --system >/dev/null

cat > "${CLIENT_DIR}/iphone.conf" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = 10.77.0.2/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = ${SERVER_PUBLIC}
PresharedKey = ${CLIENT_PSK}
Endpoint = ${PUBLIC_IP}:${WG_PORT}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
chmod 600 "${CLIENT_DIR}/iphone.conf"
qrencode -o "${CLIENT_DIR}/iphone-qr.png" < "${CLIENT_DIR}/iphone.conf"
chmod 600 "${CLIENT_DIR}/iphone-qr.png"

systemctl enable --now "wg-quick@${WG_IF}"
systemctl is-active --quiet "wg-quick@${WG_IF}" || fail "WireGuard service did not start."

echo "WireGuard configured. Allow UDP ${WG_PORT} in Azure NSG and host firewall."
echo "Client config: ${CLIENT_DIR}/iphone.conf"
