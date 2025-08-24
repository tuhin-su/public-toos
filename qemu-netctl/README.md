# 🌐 qemu-netctl – Virtual LAN Manager for QEMU

A lightweight **Bash tool** to manage isolated virtual LANs for QEMU VMs, similar to VMware/VirtualBox “VMnet” networks.
It allows you to create, delete, list, attach, and restore virtual LANs.
Supports **pure LAN**, **LAN + DHCP**, or **LAN + DHCP + NAT** setups.

---

## ✨ Features

* 🖧 Create isolated **virtual LANs** (switch-like bridges).
* 🔌 Attach/detach VM tap interfaces to LANs.
* 🚮 Remove LANs cleanly.
* 💾 Save/restore LAN configs (`lan_name.config`).
* 🔒 Host isolation by default (unless NAT enabled).
* 🎨 Colorful CLI help with author + GitHub link.

---

## 📦 Installation

```bash
git clone https://github.com/tuhin-su/public-toos.git
cd public-toos
chmod +x qemu-netctl
sudo mv qemu-netctl /usr/local/bin/
```

---

## ⚡ Usage

### 🟢 Create a LAN

```bash
qemu-netctl create lan1
```

Creates an isolated pure LAN (`lan1`).
This acts like a dumb Ethernet switch — no DHCP, no internet.

---

### 🟢 Create a LAN with DHCP

```bash
qemu-netctl create lan2 --dhcp
```

Adds a `dnsmasq` DHCP server, auto-assigning IPs.

---

### 🟢 Create a LAN with DHCP + NAT (Internet access)

```bash
qemu-netctl create lan3 --dhcp --nat
```

VMs in `lan3` will get IPs and have outbound internet (via host NAT).

---

### 🔗 Attach VM to LAN

Start QEMU VM with:

```bash
qemu-system-x86_64 -m 2G \
  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  -device e1000,netdev=net0
```

Then attach it:

```bash
qemu-netctl attach lan1 tap0
```

---

### 📜 List LANs

```bash
qemu-netctl list
```

---

### 🚮 Delete LAN

```bash
qemu-netctl delete lan1
```

---

### 💾 Save LAN config

```bash
qemu-netctl save lan1
```

Saves `lan1.config` into `/etc/qemu-netctl/lan1.config`.

---

### 🔄 Restore LAN

```bash
qemu-netctl restore lan1
```

---

## 🎨 Colorful Help Menu

Run:

```bash
qemu-netctl help
```

You’ll see:

```
==========================================
   🌐 QEMU Virtual LAN Manager (qemu-netctl)
==========================================
 Author  : Tuhin Su
 GitHub  : https://github.com/tuhin-su/public-toos.git

 Usage:
   qemu-netctl create <lan_name> [--dhcp] [--nat]
   qemu-netctl delete <lan_name>
   qemu-netctl attach <lan_name> <tap_dev>
   qemu-netctl list
   qemu-netctl save <lan_name>
   qemu-netctl restore <lan_name>
   qemu-netctl help

 Options:
   --dhcp    Enable DHCP server (dnsmasq)
   --nat     Enable NAT + Internet sharing

 Example:
   qemu-netctl create lan1 --dhcp --nat
   qemu-netctl attach lan1 tap0
==========================================
```

---

## 🛠️ Implementation Notes

* Uses `ip link` + `brctl` (bridge-utils) for LAN creation.
* Optionally runs `dnsmasq` for DHCP and `iptables` for NAT.
* Configs stored in `/etc/qemu-netctl/`.
* LANs are **ephemeral** — lost on reboot unless saved/restored.

---

## ⚠️ Important

* Requires **root privileges** (`sudo`).
* Does **not** interfere with Docker, KVM networks, or host network unless NAT enabled.
* Works best with QEMU TAP networking (`-netdev tap`).

---

## 📖 Example Workflow

1. Create an isolated LAN:

   ```bash
   qemu-netctl create labnet
   ```

2. Start two VMs with TAP NICs.

3. Attach them:

   ```bash
   qemu-netctl attach labnet tap0
   qemu-netctl attach labnet tap1
   ```

   ✅ Now both VMs can ping each other, but have no internet.

4. Enable internet:

   ```bash
   qemu-netctl delete labnet
   qemu-netctl create labnet --dhcp --nat
   ```

   ✅ VMs now get IPs + internet.

---
