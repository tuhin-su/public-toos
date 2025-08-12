#!/bin/bash
# Chrome Remote Desktop auto-setup script for Ubuntu (GNOME Edition)
# Author: tuhin-su
# Date: 2025-08-12

USER_NAME=$(whoami)

echo "=== Chrome Remote Desktop Setup for GNOME user: $USER_NAME ==="

# Update system
sudo apt update && sudo apt upgrade -y

# Install Google Chrome
if ! command -v google-chrome &>/dev/null; then
    echo "[+] Installing Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt install -y /tmp/chrome.deb
    rm /tmp/chrome.deb
else
    echo "[✓] Google Chrome already installed."
fi

# Install Chrome Remote Desktop
if ! dpkg -l | grep -q chrome-remote-desktop; then
    echo "[+] Installing Chrome Remote Desktop..."
    wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb -O /tmp/crd.deb
    sudo apt install -y /tmp/crd.deb
    rm /tmp/crd.deb
else
    echo "[✓] Chrome Remote Desktop already installed."
fi

# Configure CRD session for GNOME
echo "[+] Configuring CRD session for GNOME..."
echo "exec /usr/bin/gnome-session" > /home/$USER_NAME/.chrome-remote-desktop-session
chown $USER_NAME:$USER_NAME /home/$USER_NAME/.chrome-remote-desktop-session

# Enable CRD service at boot
echo "[+] Enabling CRD service..."
sudo systemctl enable chrome-remote-desktop@$USER_NAME

# Disable suspend/hibernate to keep system reachable
echo "[+] Disabling suspend and hibernate..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Instructions for linking Google account
echo
echo "=== IMPORTANT ==="
echo "1. Open this link in Chrome: https://remotedesktop.google.com/headless"
echo "2. Sign in with your Google account."
echo "3. Click 'Set up another computer' → Choose 'Linux'."
echo "4. Copy the command shown there and paste it into this terminal."
echo "5. After setup, Chrome Remote Desktop will auto-start after every reboot."
echo
echo "[✓] Setup complete."
