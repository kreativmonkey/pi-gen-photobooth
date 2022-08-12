# Installing custom nginx.conf
install -m 644 files/ngnix.conf		"${ROOTFS_DIR}/etc/nginx/nginx.conf"

# Setup the correct PHP_Version to the nginx.conf file
sed -i "/fastcgi_pass unix:/s/php\([[:digit:]].*\)-fpm/php${PHP_VERSION}-fpm/g" "${ROOTFS_DIR}/etc/nginx/nginx.conf"

on_chroot << EOF
systemctl enable nginx
systemctl enable php${PHP_VERSION}-fpm.service
EOF