#!/bin/bash

case "$1" in
"php52")
  PHP_VERSION='52' ;;
"php53")
  PHP_VERSION='53' ;;
"php54")
  PHP_VERSION='54' ;;
"php55")
  PHP_VERSION='55' ;;
*)
  PHP_VERSION='55' ;;
"php56")
  PHP_VERSION='56' ;;
*)
  PHP_VERSION='56' ;;
esac

echo "Your install PHP 56!"
echo "----- ✄ -----------------------"

echo '✩✩✩✩ Add Repositories ✩✩✩✩'
brew tap homebrew/dupes
brew tap josegonzalez/homebrew-php
brew update

echo '✩✩✩✩ MYSQL (mariadb) ✩✩✩✩'
brew install mariadb
#mysql_install_db --verbose --user=`root` --basedir="$(brew --prefix mariadb)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

echo '✩✩✩✩ NGINX ✩✩✩✩'
brew install --with-passenger nginx

echo '-> Download configs'
mkdir /usr/local/etc/nginx/{common,sites-available,sites-enabled}

curl -Lo /usr/local/etc/nginx/nginx.conf https://raw.github.com/mrded/brew-emp/master/conf/nginx/nginx.conf

curl -Lo /usr/local/etc/nginx/common/php https://raw.github.com/mrded/brew-emp/master/conf/nginx/common/php
curl -Lo /usr/local/etc/nginx/common/drupal https://raw.github.com/mrded/brew-emp/master/conf/nginx/common/drupal

# Download Virtual Hosts.
curl -Lo /usr/local/etc/nginx/sites-available/default https://raw.github.com/mrded/brew-emp/master/conf/nginx/sites-available/default
curl -Lo /usr/local/etc/nginx/sites-available/drupal.dev https://raw.github.com/mrded/brew-emp/master/conf/nginx/sites-available/drupal.dev

ln -s /usr/local/etc/nginx/sites-available/default /usr/local/etc/nginx/sites-enabled/default

# Create folder for logs.
rm -rf /usr/local/var/log/{fpm,nginx}
mkdir -p /usr/local/var/log/{fpm,nginx}

echo '✩✩✩✩ PHP + FPM ✩✩✩✩'
brew install freetype jpeg libpng gd
brew install php${PHP_VERSION} --without-apache --with-mysql --with-fpm --without-snmp
brew link --overwrite php${PHP_VERSION}

echo '✩✩✩✩ Redis ✩✩✩✩'
brew install redis php${PHP_VERSION}-redis

echo '✩✩✩✩ Xdebug ✩✩✩✩'
brew install php${PHP_VERSION}-xdebug

case "${PHP_VERSION}" in
"52")
  DOT_VERSION='5.2' ;;
"53")
  DOT_VERSION='5.3' ;;
"54")
  DOT_VERSION='5.4' ;;
"55")
  DOT_VERSION='5.5' ;;
"56")
  DOT_VERSION='5.6' ;;
esac

echo 'xdebug.remote_enable=On' >>  /usr/local/etc/php/${DOT_VERSION}/conf.d/ext-xdebug.ini
echo 'xdebug.remote_host="localhost"' >>  /usr/local/etc/php/${DOT_VERSION}/conf.d/ext-xdebug.ini
echo 'xdebug.remote_port=9002' >>  /usr/local/etc/php/${DOT_VERSION}/conf.d/ext-xdebug.ini
echo 'xdebug.remote_handler="dbgp"' >>  /usr/local/etc/php/${DOT_VERSION}/conf.d/ext-xdebug.ini

echo '✩✩✩✩ Xhprof ✩✩✩✩'
brew install graphviz php${PHP_VERSION}-xhprof
mkdir /tmp/xhprof
chmod 777 /tmp/xhprof
echo 'xhprof.output_dir=/tmp/xhprof' >>  /usr/local/etc/php/${DOT_VERSION}/conf.d/ext-xhprof.ini

curl -Lo /usr/local/etc/nginx/sites-available/xhprof.dev https://raw.github.com/mrded/brew-emp/master/conf/nginx/sites-available/xhprof.dev
ln -s /usr/local/etc/nginx/sites-available/xhprof.dev /usr/local/etc/nginx/sites-enabled/xhprof.dev
sudo echo '127.0.0.1 xhprof.dev' >>  /etc/hosts

echo '✩✩✩✩ Drush ✩✩✩✩'
brew install drush

echo '✩✩✩✩ Brew-emp ✩✩✩✩'
curl -Lo /usr/local/bin/getlooky https://raw.github.com/mrded/brew-emp/master/bin/getlooky
chmod 755 /usr/local/bin/getlooky