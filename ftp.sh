sudo bash <<'EOF'
# ============================
# 📁 FTP setup for WaydroidShared (Arch Linux)
# ============================

FTP_USER="waydroidftp"
FTP_PASS="changeme"
SHARE_DIR="$HOME/WaydroidShared"

echo "🛠️ Setting up permanent FTP server for $SHARE_DIR..."

# 1. Ensure the shared folder exists
mkdir -p "$SHARE_DIR"
chmod 755 "$SHARE_DIR"

# 2. Install vsftpd if not present
if ! pacman -Qi vsftpd &>/dev/null; then
  pacman -Sy --noconfirm vsftpd
fi

# 3. Create dedicated FTP user (no shell access)
useradd -d "$SHARE_DIR" -s /usr/sbin/nologin "$FTP_USER" 2>/dev/null || true
echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R "$FTP_USER":"$FTP_USER" "$SHARE_DIR"

# 4. Backup original vsftpd config
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak 2>/dev/null || true

# 5. Get LAN IP address safely
LAN_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

# 6. Write new vsftpd config
cat <<CFG >/etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pam_service_name=vsftpd
user_sub_token=\$USER
local_root=$SHARE_DIR
pasv_min_port=40000
pasv_max_port=40100
pasv_address=$LAN_IP
seccomp_sandbox=NO
CFG

# 7. Restart and enable service
systemctl restart vsftpd
systemctl enable vsftpd

# 8. Display connection info
echo "✅ FTP server ready!"
echo "🌐 Connect via: ftp://$LAN_IP"
echo "👤 Username: $FTP_USER"
echo "🔑 Password: $FTP_PASS"
echo "📁 Folder: $SHARE_DIR"
echo
echo "💡 To change the password later, run: sudo passwd $FTP_USER"
EOF
