#!/bin/bash
# Waydroid Manual Installer Script for Arch Linux
# Installs Waydroid and manually handles the system image download.

set -e

echo "=== Waydroid Manual Installer for Arch Linux ==="

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root (sudo bash $0)"
    exit 1
fi

# Update system
echo "→ Updating system..."
pacman -Syu --noconfirm

# Install dependencies
echo "→ Installing dependencies..."
pacman -S --noconfirm git base-devel wget curl sudo lsof unzip jq

# Install yay if missing
if ! command -v yay &>/dev/null; then
    echo "→ Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /
fi

# Install Waydroid (base package only)
echo "→ Installing Waydroid base package..."
yay -S --noconfirm waydroid

# Prepare image details
IMG_DIR="/usr/share/waydroid-extra/images"
IMG_FILE="lineage-20.0-20250823-VANILLA-waydroid_x86_64-system.zip"
IMG_PATH="${IMG_DIR}/${IMG_FILE}"
IMG_URL="https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_x86_64/${IMG_FILE}/download"

echo "→ Preparing image directory at: ${IMG_DIR}"
mkdir -p "${IMG_DIR}"

# Show debug info
echo "→ Download URL: ${IMG_URL}"
echo "→ Destination file: ${IMG_PATH}"
echo

# Download if not present
if [ ! -f "${IMG_PATH}" ]; then
    echo "→ Downloading Waydroid system image (this may take a while)..."
    wget --no-verbose -O "${IMG_PATH}" "${IMG_URL}"
else
    echo "✓ Image already exists at ${IMG_PATH} — skipping download."
fi

# Verify file
if [ ! -s "${IMG_PATH}" ]; then
    echo "❌ Download failed or file is empty. Please check your internet or the URL."
    exit 1
fi

# Initialize Waydroid
echo "→ Initializing Waydroid container with local image..."
waydroid init --system_zip "${IMG_PATH}"

# Enable and start the container service
echo "→ Enabling Waydroid service..."
systemctl enable --now waydroid-container

echo "✅ Waydroid installation completed successfully!"
echo "You can start Waydroid using: waydroid session start"
