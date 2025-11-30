cat << 'EOF' > xcfe.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "========================================================"
echo "   CAI DAT GIAO DIEN GUI (XFCE4 - SIEU MUOT - KHONG LAG)"
echo "========================================================"

# --- 1. DỌN DẸP RÁC CŨ (Để tránh xung đột) ---
echo ">> [1/5] Dang don dep he thong..."
sudo pkill cloudflared 2>/dev/null
sudo systemctl stop xrdp 2>/dev/null
sudo apt-get remove --purge -y kde* gnome* > /dev/null 2>&1
sudo apt-get autoremove -y > /dev/null 2>&1

# --- 2. CÀI GIAO DIỆN XFCE4 (Nhẹ, chuẩn cho VPS) ---
echo ">> [2/5] Dang cai dat XFCE4 Desktop..."
sudo apt-get update -y
sudo apt-get install -y xfce4 xfce4-goodies xserver-xorg-video-dummy wget curl sudo dbus-x11

# --- 3. CÀI JAVA 8 (Chuẩn cho Minecraft 1.16.5) & FIREFOX ---
echo ">> [3/5] Dang cai Java 8 & Firefox..."
# Cài kho Adoptium Java
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
echo "deb https://packages.adoptium.net/artifactory/deb bullseye main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update -y
sudo apt-get install -y temurin-8-jdk firefox-esr

# --- 4. CÀI CHROME REMOTE DESKTOP ---
echo ">> [4/5] Dang cai Chrome Remote Desktop..."
wget -O crd.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install -y ./crd.deb
sudo apt-get install -f -y
rm -f crd.deb

# --- 5. CẤU HÌNH USER & PHIÊN LÀM VIỆC ---
echo ">> [5/5] Dang cau hinh User 'duyvo'..."

# Tạo user nếu chưa có
if ! id "duyvo" &>/dev/null; then
    sudo useradd -m -s /bin/bash duyvo
    sudo usermod -aG sudo duyvo
    echo "duyvo:admin" | sudo chpasswd
fi

# Thêm quyền cho user
sudo usermod -a -G chrome-remote-desktop duyvo

# Cấu hình để Chrome Remote biết dùng XFCE (Quan trọng nhất để không đen màn hình)
sudo -u duyvo bash -c 'echo "exec /usr/bin/xfce4-session" > ~/.chrome-remote-desktop-session'

# Fix lỗi màn hình đen (PolicyKit)
sudo bash -c 'cat <<POLKIT > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
POLKIT'

echo ""
echo "========================================================"
echo "   ✅ CAI DAT HOAN TAT!"
echo "========================================================"
echo "CHỈ CÒN 1 BƯỚC KÍCH HOẠT CUỐI CÙNG:"
echo ""
echo "1. Tren may tinh Windows, mo trinh duyet vao link:"
echo "   https://remotedesktop.google.com/headless"
echo ""
echo "2. Bam 'Bat dau' -> 'Tiep theo' -> 'Uy quyen' -> Copy dong lenh Debian Linux."
echo ""
echo "3. QUAY LAI DAY VA CHAY 2 LENH SAU:"
echo "   su - duyvo"
echo "   (Dan dong lenh Google vao day roi Enter)"
echo "========================================================"
EOF

sudo bash xcfe.sh
