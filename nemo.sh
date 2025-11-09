#!/usr/bin/env bash
# ============================================================
# Nemo + Gruvbox aesthetic setup for Arch Linux + Hyprland
# ============================================================

set -e

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Installing dependencies..."
sudo pacman -S --needed --noconfirm \
  nemo gnome-themes-extra gtk-engine-murrine \
  libgdk-pixbuf2 python-gobject \
  gnome-tweaks xdg-desktop-portal-gtk \
  base-devel git

# Optional: AUR helper check (yay)
if ! command -v yay &>/dev/null; then
  echo ">>> Installing yay (AUR helper)..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

echo ">>> Installing Cinnamon dependencies for Nemo actions..."
yay -S --needed --noconfirm cinnamon-desktop-editor

echo ">>> Installing Gruvbox GTK + icons..."
mkdir -p ~/.themes ~/.icons
cd ~/.themes
if [ ! -d "Gruvbox-GTK-Theme" ]; then
  git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git
fi
cd ~/.icons
if [ ! -d "Gruvbox-Plus-Dark" ]; then
  git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git "Gruvbox-Plus-Dark"
fi

echo ">>> Setting GTK and icon theme (via gsettings)..."
gsettings set org.cinnamon.desktop.interface gtk-theme "Gruvbox-Dark-BL"
gsettings set org.cinnamon.desktop.interface icon-theme "Gruvbox-Plus-Dark"
gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"

echo ">>> Creating Nemo CSS config..."
mkdir -p ~/.config/nemo
cat > ~/.config/nemo/gtk.css <<'EOF'
/* Gruvbox dark aesthetic for Nemo */

.header-bar {
  background-color: #282828;
  border: none;
  padding: 4px;
  color: #ebdbb2;
}

.nemo-window-pane {
  background-color: #1d2021;
}

.nemo-list-view .view {
  background-color: #1d2021;
  color: #ebdbb2;
}

.nemo-list-view .view:selected {
  background-color: #3c3836;
  color: #fabd2f;
}
EOF

echo ">>> Creating desktop entry for Hyprland launch..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/nemo-hyprland.desktop <<'EOF'
[Desktop Entry]
Name=Nemo (Hyprland)
Exec=nemo --no-desktop %U
Terminal=false
Type=Application
Icon=system-file-manager
Categories=Utility;System;FileTools;FileManager;
StartupNotify=true
EOF

echo ">>> Cleaning up..."
rm -rf /tmp/yay 2>/dev/null || true

echo ">>> All done!"
echo
echo "✅ Nemo is installed and themed with Gruvbox!"
echo "Run it with: nemo --no-desktop"
echo
echo "If you want transparency, add to your Hyprland config:"
echo "  windowrulev2 = opacity 0.9, class:^(nemo)$"
echo "  windowrulev2 = blur, class:^(nemo)$"

