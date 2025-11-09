#!/bin/bash

# Variables - customize if needed
APP_NAME="ABDownloadManager"
APP_DIR="$HOME/ABDownloadManager"
BINARY="$APP_DIR/bin/ABDownloadManager"
ICON="$APP_DIR/icon.png"   # Optional: set path to icon if exists
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

# Check if binary exists
if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at $BINARY"
    exit 1
fi

# Create applications directory if it doesn't exist
mkdir -p "$HOME/.local/share/applications"

# Write the .desktop file
cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$APP_NAME
Comment=Download manager application
Exec=$BINARY
Icon=$ICON
Terminal=false
Type=Application
Categories=Network;Utility;
EOL

# Make the .desktop file executable
chmod +x "$DESKTOP_FILE"

# Update desktop database (optional but recommended)
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications"
fi

echo "✅ $APP_NAME launcher created at $DESKTOP_FILE"

