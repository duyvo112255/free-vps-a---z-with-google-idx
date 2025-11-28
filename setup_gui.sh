cat << 'EOF' > setup_gui.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo ">> [1/6] DANG CHUAN BI HE THONG..."
sudo pkill cloudflared 2>/dev/null
sudo pkill VBoxSVC 2>/dev/null
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get install -y wget curl sudo > /dev/null 2>&1

echo ">> [2/6] DANG CAI DAT GIAO DIEN KDE PLASMA (DEP & HIEN DAI)..."
echo "   (Qua trinh nay mat khoang 3-5 phut vi giao dien rat nang...)"
sudo apt-get install -y kde-plasma-desktop sddm xorg dbus-x11 x11-xserver-utils > /dev/null 2>&1

echo ">> [3/6] DANG CAI DAT CONG CU (JAVA, FIREFOX, RDP)..."
sudo apt-get install -y xrdp firefox-esr openjdk-17-jre > /dev/null 2>&1

echo ">> [4/6] DANG CAU HINH REMOTE DESKTOP..."
sudo systemctl enable xrdp
sudo systemctl start xrdp
echo "/usr/bin/startplasma-x11" > ~/.xsession

cat <<POLKIT | sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
POLKIT
sudo systemctl restart xrdp

if id "duyvo" &>/dev/null; then
    echo "duyvo:admin" | sudo chpasswd
else
    sudo useradd -m -s /bin/bash duyvo
    echo "duyvo:admin" | sudo chpasswd
    sudo usermod -aG sudo duyvo
    sudo -u duyvo echo "/usr/bin/startplasma-x11" > /home/duyvo/.xsession
fi

echo ">> [5/6] DANG CAI DAT CLOUDFLARE..."
if ! command -v cloudflared &> /dev/null; then
    wget -q -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
fi

echo ">> [6/6] DANG MO CONG KET NOI..."
rm -f cf_log.txt
nohup cloudflared tunnel --url tcp://localhost:3389 > cf_log.txt 2>&1 &

sleep 8
LINK=$(grep -o 'https://.*\.trycloudflare.com' cf_log.txt | head -n 1)
HOSTNAME=$(echo $LINK | sed 's/https:\/\///')

echo ""
echo "=========================================================="
echo "   ✅ CAI DAT THANH CONG! (KDE PLASMA EDITION)"
echo "=========================================================="
echo "1. Chay lenh nay tren CMD Windows (Bo https://):"
echo "   files_cf.exe access tcp --hostname $HOSTNAME --url 127.0.0.1:5555"
echo ""
echo "2. Ket noi Remote Desktop: 127.0.0.1:5555"
echo "   User: duyvo"
echo "   Pass: admin"
echo "=========================================================="
EOF

sudo bash setup_gui.sh
