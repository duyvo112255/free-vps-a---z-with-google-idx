cat << 'EOF' > kde.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "========================================================"
echo "   CAI DAT KDE PLASMA (DA FIX LOI DEN MAN HINH)"
echo "========================================================"

# --- 1. DỌN DẸP & CHUẨN BỊ ---
echo ">> [1/5] Dang don dep he thong..."
sudo pkill cloudflared 2>/dev/null
sudo systemctl stop xrdp 2>/dev/null
# Xóa XFCE/Gnome cũ để tránh xung đột
sudo apt-get remove --purge -y xfce4* gnome* > /dev/null 2>&1
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get update -y

# --- 2. CÀI GIAO DIỆN KDE PLASMA ---
echo ">> [2/5] Dang tai KDE Plasma (Mat 5-8 phut, vui long doi)..."
sudo apt-get install -y kde-plasma-desktop sddm xorg dbus-x11 x11-xserver-utils wget curl sudo

# --- 3. CÀI ỨNG DỤNG (CHROME + JAVA 8) ---
echo ">> [3/5] Dang cai Chrome & Java..."
# Cài Java 8 (Chuẩn cho Minecraft 1.16.5)
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
echo "deb https://packages.adoptium.net/artifactory/deb bullseye main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update -y
sudo apt-get install -y temurin-8-jdk

# Cài Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# --- 4. CÀI CHROME REMOTE DESKTOP ---
echo ">> [4/5] Dang cai Chrome Remote Desktop..."
wget -O crd.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install -y ./crd.deb
sudo apt-get install -f -y
rm -f crd.deb

# --- 5. CẤU HÌNH ANTI-CRASH (QUAN TRỌNG NHẤT) ---
echo ">> [5/5] Dang cau hinh chong sap..."

# Tạo user duyvo
if ! id "duyvo" &>/dev/null; then
    sudo useradd -m -s /bin/bash duyvo
    sudo usermod -aG sudo duyvo
    echo "duyvo:admin" | sudo chpasswd
fi
sudo usermod -a -G chrome-remote-desktop duyvo

# --- FIX: TẮT HIỆU ỨNG 3D CỦA KDE ---
# Tạo file config tắt Compositor để không cần GPU vẫn chạy được
sudo -u duyvo mkdir -p /home/duyvo/.config
sudo -u duyvo bash -c 'cat <<CONFIG > /home/duyvo/.config/kwinrc
[Compositing]
Enabled=false
OpenGLIsUnsafe=true
CONFIG'

# Cấu hình session khởi động
sudo -u duyvo bash -c 'cat <<SESSION > ~/.chrome-remote-desktop-session
export DESKTOP_SESSION=plasma
export XDG_CURRENT_DESKTOP=KDE
# Tắt tăng tốc phần cứng Qt
export QT_X11_NO_MITSHM=1
# Chạy KDE
exec /usr/bin/startplasma-x11
SESSION'

echo ""
echo "========================================================"
echo "   ✅ CAI DAT KDE HOAN TAT!"
echo "========================================================"
echo "HAY LAM BUOC CUOI CUNG DE KICH HOAT:"
echo ""
echo "1. Tren may tinh Windows, vao link:"
echo "   https://remotedesktop.google.com/headless"
echo ""
echo "2. Bam 'Bat dau' -> 'Tiep theo' -> 'Uy quyen' -> Copy ma Debian Linux."
echo ""
echo "3. QUAY LAI DAY VA CHAY 2 LENH SAU:"
echo "   su - duyvo"
echo "   (Dan ma Google vao day roi Enter)"
echo "========================================================"
EOF

sudo bash kde.sh
