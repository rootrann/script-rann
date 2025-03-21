#! /bin/bash

# update dan upgrade
echo "===================================================="

echo "              mengupdate system Linux               "

echo "===================================================="

apt update
apt upgrade -y

check_error() {
    if [ $? -ne 0 ]; then
        echo "Error saat menjalankan perintah sebelumnya. Periksa log dan coba lagi."
        exit 1
    fi
}

# mounting cd
echo "===================================================="

echo "             masukkan DVD 1,2,dan 3 nya             "

echo "===================================================="

for i in {1..3}; do  # Ganti jumlah sesuai dengan jumlah DVD yang diperlukan
   echo "Masukkan DVD $i dan tekan ENTER untuk melanjutkan..."
    read -p "Tekan ENTER Ketika selesai Memasukkan DVD $i..."
    mount /dev/cdrom /mnt || { echo "Gagal mount DVD $i!"; exit 1; }
    apt-cdrom add || { echo "Gagal menambahkan DVD $i ke sources.list!"; exit 1; }
    umount /mnt
    echo "DVD $i selesai diproses."
done

#update
apt update

# Menginstal packet yang di perlukan

# Menginstal packet yang di perlukan
echo "===================================================="

echo "Menginstall packet yang di perlukan untuk prestashop"

echo "===================================================="

apt install apache2 mariadb-server php php-mysql php-gd php-xml php-intl php-zip php-curl php-mbstring php-cli php-bcmath zip unzip -y
check_error "Gagal Mengkonfigurasi Packet!"

# konfigurasi database
echo "===================================================="

echo "              Mengkonfigurasi database              "

echo "===================================================="
nama_database="prestashop_db"
DB_USER="rann"
DB_PASS="zahrann"
service mariadb start
service mysql start

mysql -u root -e "create database $nama_database;"
mysql -u root  -e "create user '$DB_USER'@'localhost' identified by '$DB_PASS';"
mysql -u root -e "grant all privileges on $nama_database.* TO '$DB_USER'@'localhost' identified by '$DB_PASS';"
mysql -u root -e "flush privileges;"
mysql -u root -e "quit"
check_error "Gagal Mengkonfigurasi Database!"

# install web prestashop
echo "===================================================="

echo "          MengDownload prestashop_8.2.0.zip         "

echo "===================================================="

wget -O /root/prestashop_8.2.0.zip https://github.com/PrestaShop/PrestaShop/releases/download/8.2.0/prestashop_8.2.0.zip
check_error "Gagal MenDownload prestashop_8.2.0.zip!"
unzip /root/prestashop_8.2.0.zip -d /root/

#Memindahkan prestashop.zip
echo "===================================================="

echo "      Memindahkan & mengekstrak prestashop.zip      "

echo "===================================================="

mv /root/prestashop.zip /var/www/html
unzip /var/www/html/prestashop.zip -d /var/www/html
mv /var/www/html/index.html /root/

# Izin akses
echo "===================================================="

echo "               Memberi Hak izin akses               "

echo "===================================================="
chmod -R 755 /var/www/html/
chown -R www-data:www-data /var/www/html/
a2enmod rewrite
check_error "Gagal Izin Akses!"

# restart apache & mysql
service apache2 restart
service mysql restart
service apache2 start
service mariadb start
service mysql start
check_error "Gagal Merestart!"

echo "Installasi dan Konfigurasi PrestaShop Sudah Selesai!"

echo "Silakan konfigurasi PrestaShop yang Di web browser"
read -p "Apakah sudah Mengkonfigurasi PrestaShop yang di Web Browser? (sudah/belum): " CONFIRM
echo "jawaban kamu : $CONFIRM"
if [ "$CONFIRM" = "sudah" ]; then
    mv /var/www/html/install /var/www/html/install-
    mv /var/www/html/admin /var/www/html/admin-rann
    echo "mv install/ install- dan mv admin/ admin-user sudah dikonfigurasi!"
else
    echo "Silahkan selesaikan dulu konfigurasi PrestaShopnya terlebih dahulu."
fi
