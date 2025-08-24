# Install
```bash
# Debian/Ubuntu/Kali (dnsmasq optional if you want DHCP):
sudo apt update
sudo apt install -y iproute2 iptables dnsmasq

# Install the tool:
sudo install -m 0755 qemu-netctl /usr/local/bin/qemu-netctl
sudo mkdir -p /etc/qemu-netctl

```

# How to use
## A) NAT network with DHCP (VMware-like “NAT”)
```bash
sudo qemu-netctl create natnet true true true
sudo qemu-netctl addvm natnet vm1
```
### copy the printed -netdev/-device flags into your ashqemu command

## B) Host-only with DHCP
```bash
sudo qemu-netctl create hostonly true false true
sudo qemu-netctl addvm hostonly vmA
```
## C) Pure isolated L2 (no host, no DHCP)
```bash
sudo qemu-netctl create lan1 false false false
sudo qemu-netctl addvm lan1 vmX
```


# Optional: auto-restore saved networks at boot
Create a tiny service that restores any configs you place in /etc/qemu-netctl/autorestore.d.
```bash
# 4.1) helper script
sudo tee /usr/local/bin/qemu-netctl-autorestore >/dev/null <<'SH'
#!/bin/bash
set -euo pipefail
CONF_DIR="/etc/qemu-netctl"
AUTO_DIR="$CONF_DIR/autorestore.d"
[ -d "$AUTO_DIR" ] || exit 0
shopt -s nullglob
for f in "$AUTO_DIR"/*.config; do
  # shellcheck disable=SC1090
  source "$f"
  /usr/local/bin/qemu-netctl restore "$(basename "$f" .config)" || true
done
SH
sudo chmod +x /usr/local/bin/qemu-netctl-autorestore

# 4.2) systemd unit
sudo tee /etc/systemd/system/qemu-netctl-autorestore.service >/dev/null <<'UNIT'
[Unit]
Description=Auto-restore qemu-netctl networks
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/qemu-netctl-autorestore

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable qemu-netctl-autorestore
```

# Notes & tips

Firewalls/Docker safety

Subnets are 172.30.X.0/24 by default to avoid Docker’s usual 172.17.0.0/16 & 10.0.0.0/8.

iptables rules are per-LAN, tagged with comments and removed cleanly on delete.

dnsmasq binds only to the bridge of that LAN.

Using your own router (Docker or VM)

Create with dhcp=false internet=false and attach your router container/VM to the bridge.

Or keep dhcp=true but internet=false and let your router do NAT upstream.

QEMU device model

The snippet uses e1000 for broad guest compatibility. Swap to virtio-net-pci for better performance:

-device virtio-net-pci,netdev=<id>


nftables

This script uses iptables (nft backend is fine). If you’re pure-nft only with nft command and no iptables-shim, install iptables-nft.

Cleanup on reboot

Runtime bridges/taps go away on reboot. Saved configs let you bring them back with restore (or auto-restore).

Need me to add a QEMU wrapper so you can do:
```bash
qemu-run --vmname vm1 --netdev natnet [..other qemu args..]
```
