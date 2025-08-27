# 📘 qemu-netctl – Virtual LAN & TAP Manager for QEMU

## 🔹 Overview

`qemu-netctl` is a simple **network management utility** for QEMU that allows you to easily:

* Create and manage **virtual LANs** using Linux bridges.
* Create and manage **TAP interfaces** for connecting QEMU VMs.
* Attach/detach TAP interfaces to virtual LANs.
* Save and restore network configurations.

This tool is designed for users who want a **lightweight alternative** to complex network managers, providing quick commands for building **isolated LANs** or **bridged VM networks**.

---

## 🔹 Features

* Create/delete **virtual LANs (bridges)**.
* Create/delete **TAP interfaces**.
* Attach/detach TAP interfaces to/from LANs.
* Save and restore LAN configurations.
* Clean and colorized CLI interface.
* Works with `iproute2` (no legacy `brctl` needed).

---

## 🔹 Requirements

* Linux host with:

  * `iproute2` (installed by default on most distros).
  * `sudo` privileges.
* QEMU/KVM installed.
* Kernel support for **TAP/TUN devices**.

---

## 🔹 Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/tuhin-su/public-toos.git
cd public-toos/qemu-netctl
chmod +x qemu-netctl
sudo cp qemu-netctl /usr/local/bin/
```

Now you can run it as a global command:

```bash
qemu-netctl help
```

---

## 🔹 Usage

General syntax:

```bash
qemu-netctl <command> [options]
```

---

### 🟢 LAN Commands

#### 1. Create a LAN

```bash
qemu-netctl create mylan
```

* Creates a Linux bridge named `br-mylan`.
* Saves config under `~/.qemu-netctl/networks/mylan.config`.

#### 2. Delete a LAN

```bash
qemu-netctl delete mylan
```

* Removes `br-mylan` bridge and deletes config file.

#### 3. List LANs

```bash
qemu-netctl list
```

* Shows all saved LAN configurations.

#### 4. Attach a TAP to LAN

```bash
qemu-netctl attach mylan tap0
```

* Attaches TAP device `tap0` to bridge `br-mylan`.

#### 5. Detach a TAP from LAN

```bash
qemu-netctl detach mylan tap0
```

* Removes TAP `tap0` from bridge `br-mylan`.

#### 6. Save LAN configuration

```bash
qemu-netctl save mylan
```

* Stores LAN settings for later restoration.

#### 7. Restore LAN

```bash
qemu-netctl restore mylan
```

* Recreates `br-mylan` if missing, based on saved config.

---

### 🟣 TAP Commands

#### 1. Create TAP Interface

```bash
qemu-netctl tap-create tap0
```

* Creates TAP interface `tap0`.
* Brings it **UP**.

#### 2. Delete TAP Interface

```bash
qemu-netctl tap-delete tap0
```

* Shuts down and deletes TAP interface `tap0`.

---

### 🟠 General Commands

#### Help

```bash
qemu-netctl help
```

Shows usage menu with available commands.

---

## 🔹 Practical Example: Two QEMU VMs on Same LAN

1. Create a TAP for each VM:

   ```bash
   qemu-netctl tap-create tap0
   qemu-netctl tap-create tap1
   ```

2. Create a LAN:

   ```bash
   qemu-netctl create lablan
   ```

3. Attach both TAPs to LAN:

   ```bash
   qemu-netctl attach lablan tap0
   qemu-netctl attach lablan tap1
   ```

4. Run QEMU with TAP networking:

   ```bash
   qemu-system-x86_64 -hda vm1.img -netdev tap,id=n1,ifname=tap0,script=no,downscript=no -device e1000,netdev=n1
   qemu-system-x86_64 -hda vm2.img -netdev tap,id=n2,ifname=tap1,script=no,downscript=no -device e1000,netdev=n2
   ```

✅ Now both VMs are on the same virtual LAN (`br-lablan`) and can ping each other.

5. Cleanup:

   ```bash
   qemu-netctl detach lablan tap0
   qemu-netctl detach lablan tap1
   qemu-netctl tap-delete tap0
   qemu-netctl tap-delete tap1
   qemu-netctl delete lablan
   ```

---

## 🔹 Advanced Usage

### 🌐 Internet Access (via NAT)

If you want your LAN-connected VMs to also access the internet, enable **NAT** on the bridge:

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sysctl -w net.ipv4.ip_forward=1
```

This lets VMs reach the outside world via host’s internet.

---

## 🔹 Security Notes

* Running TAP/bridge requires **root privileges** → `sudo` is used.
* Only trusted users should run this tool.
* Always clean up TAPs and bridges when not in use.

---

## 🔹 Author

* **Name**: Tuhin BG
* **GitHub**: [https://github.com/tuhin-su/public-toos.git](https://github.com/tuhin-su/public-toos.git)

---

✅ With this guide, anyone can use `qemu-netctl` to set up **custom VM networks** in seconds.

Do you also want me to add a **diagram (ASCII or image)** showing how VMs, TAPs, and bridges connect (like `VM1 ↔ TAP0 ↔ br-lan ↔ TAP1 ↔ VM2`)?
