# QEMU NetCTL

QEMU NetCTL is a simple Bash-based Virtual LAN Manager for QEMU virtual machines.  
It allows you to create, manage, and restore isolated LAN environments using Linux bridges and TAP interfaces.

---

## ✨ Features

- Create and delete **LANs** (Linux bridges).
- Create and delete **TAP interfaces**.
- Attach and detach TAP devices to/from LANs.
- Save and restore full LAN configurations (including attached TAPs).
- Colorful help menu with author information.
- Lightweight and portable (pure Bash, no dependencies except `ip` and `brctl`).

---

## 📦 Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/tuhin-su/public-toos.git
cd public-toos/qemu-netctl
chmod +x qemu-netctl.sh
```

(Optional) Move it to a system-wide location:

```bash
sudo mv qemu-netctl.sh /usr/local/bin/qemu-netctl
```

---

## 🚀 Usage

Run the script with:

```bash
qemu-netctl <command> [options]
```

### Commands

| Command | Description |
|---------|-------------|
| `create <lan>` | Create a new LAN (Linux bridge) |
| `delete <lan>` | Delete an existing LAN |
| `list` | List all saved LAN configurations |
| `tap-create <tap>` | Create a TAP interface |
| `tap-delete <tap>` | Delete a TAP interface |
| `attach <lan> <tap>` | Attach TAP device to LAN |
| `detach <lan> <tap>` | Detach TAP device from LAN |
| `save <lan>` | Save LAN configuration with all attached TAPs |
| `restore <lan>` | Restore LAN and its TAP devices |
| `help` | Show help menu |

---

## 🛠 Examples

### Create a LAN
```bash
qemu-netctl create mylan
```

### Create a TAP interface
```bash
qemu-netctl tap-create tap0
```

### Attach TAP to LAN
```bash
qemu-netctl attach mylan tap0
```

### Save LAN with attached TAPs
```bash
qemu-netctl save mylan
```

### Restore LAN with TAPs
```bash
qemu-netctl restore mylan
```

### Delete TAP
```bash
qemu-netctl tap-delete tap0
```

### Delete LAN
```bash
qemu-netctl delete mylan
```

---

## 💡 Notes

- LANs are implemented as Linux bridges (`brctl` / `ip link`).
- TAP devices must be created before attaching to a LAN.
- Saved configs are stored in:
  ```
  ~/.qemu-netctl/networks/
  ```

---

## 👤 Author

**Tuhin BG**  
GitHub: [https://github.com/tuhin-su/public-toos.git](https://github.com/tuhin-su/public-toos.git)

---
