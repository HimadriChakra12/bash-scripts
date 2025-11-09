sudo bash -c '
SHARE_DIR="$HOME/WaydroidShared"
WAYDROID_MEDIA="/var/lib/waydroid/data/media/0/Shared"

echo "🛠️  Setting up fully automated Waydroid file sharing..."

# Create local and Waydroid dirs
mkdir -p "$SHARE_DIR" "$WAYDROID_MEDIA"

# Enable external storage (only needs to be set once)
waydroid prop set persist.waydroid.enable_external_storage true

# Create helper script
cat <<EOF >/usr/local/bin/waydroid-share.sh
#!/bin/bash
SHARE_DIR="$HOME/WaydroidShared"
WAYDROID_MEDIA="/var/lib/waydroid/data/media/0/Shared"

case "\$1" in
  start)
    mkdir -p "\$SHARE_DIR" "\$WAYDROID_MEDIA"
    if mountpoint -q "\$WAYDROID_MEDIA"; then
      echo "Already mounted."
    else
      mount --bind "\$SHARE_DIR" "\$WAYDROID_MEDIA"
      echo "Mounted \$SHARE_DIR → \$WAYDROID_MEDIA"
    fi
    ;;
  stop)
    if mountpoint -q "\$WAYDROID_MEDIA"; then
      umount "\$WAYDROID_MEDIA"
      echo "Unmounted \$WAYDROID_MEDIA"
    fi
    ;;
  *)
    echo "Usage: \$0 {start|stop}"
    ;;
esac
EOF

chmod +x /usr/local/bin/waydroid-share.sh

# Create systemd service for auto-mount/unmount
cat <<EOF >/etc/systemd/system/waydroid-share.service
[Unit]
Description=Auto-mount shared folder for Waydroid
After=waydroid-container.service
Before=waydroid-container-stop.service

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/local/bin/waydroid-share.sh start
ExecStop=/usr/local/bin/waydroid-share.sh stop

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable
systemctl daemon-reload
systemctl enable --now waydroid-share.service

echo "✅ All set!"
echo "📁 Linux shared folder: $SHARE_DIR"
echo "📱 In Waydroid: /sdcard/Shared"
echo "🧩 Auto-mount and unmount will now happen with Waydroid."
'

