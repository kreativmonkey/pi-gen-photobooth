#!/bin/bash -e

# Modify /usr/lib/os-release
sed -i "s/Raspbian/photobooth-os/gI" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^HOME_URL=.*$/HOME_URL=\"https:\/\/github.com\/andi34\/photobooth\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^SUPPORT_URL=.*$/SUPPORT_URL=\"https:\/\/github.com\/andi34\/photobooth\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^BUG_REPORT_URL=.*$/BUG_REPORT_URL=\"https:\/\/github.com\/andi34\/photobooth\/\"/g" ${ROOTFS_DIR}/usr/lib/os-release

# Custom motd
# Replace message of the day (ssh greeting text)
rm "${ROOTFS_DIR}"/etc/motd
rm "${ROOTFS_DIR}"/etc/update-motd.d/10-uname
install -m 755 files/motd-photobooth "${ROOTFS_DIR}"/etc/update-motd.d/10-photobooth

# Installing yarn
echo "deb https://dl.yarnpkg.com/debian/ stable main" > ${ROOTFS_DIR}/etc/apt/sources.list.d/yarn.list
wget -O https://dl.yarnpkg.com/debian/pubkey.gpg -O files/yarnkey.gpg
cat files/yarnkey.gpg | gpg --dearmor "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/raspberrypi-archive-stable.gpg"

on_chroot << EOF
apt-get update
apt-get install -y yarn
EOF

# Installing NodeJS
wget -O - https://raw.githubusercontent.com/audstanley/NodeJs-Raspberry-Pi/master/Install-Node.sh -O files/Install-Node.sh
install -m 755 files/Install-Node.sh "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/Install-Node.sh

on_chroot << EOF
echo '---> call nodejs installer script'
cd /home/$FIRST_USER_NAME}
./Install-Node.sh node-install -v 12.22.12 
EOF

# Installing the newest version of gphoto2
wget -O - https://raw.githubusercontent.com/gonzalo/gphoto2-updater/master/gphoto2-updater.sh -O files/gphoto2-updater.sh
wget -O - https://raw.githubusercontent.com/gonzalo/gphoto2-updater/master/.env -O files/.env
install -m 755 files/gphoto2-updater.sh "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/gphoto2-updater.sh
install -m 655 files/.env "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/.env

on_chroot << EOF
echo '---> call gphoto2 update script'
cd /home/${FIRST_USER_NAME}
./gphoto2-updater.sh
rm gphoto2-updater.sh .env
EOF

# Installing Photobooth
on_chroot << EOF
echo '---> installing photobooth'
cd /var/www/
git clone https://github.com/andi34/photobooth html
cd html
git fetch origin main
git checkout origin/main

git submodule update --init

echo '---> installing via yarn'
yarn install
yarn build
EOF
