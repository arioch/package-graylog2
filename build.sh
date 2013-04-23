#!/bin/sh

set -e

PKG_VERSION=$1

if [ ! -f graylog2-server-${PKG_VERSION}.tar.gz ]
then
  wget http://download.graylog2.org/graylog2-server/graylog2-server-${PKG_VERSION}.tar.gz
fi

if [ ! -f graylog2-web-interface-${PKG_VERSION}.tar.gz ]
then
  wget http://download.graylog2.org/graylog2-web-interface/graylog2-web-interface-${PKG_VERSION}.tar.gz
fi

if [ ! -f graylog2-server_${PKG_VERSION}_all.deb ]
then
  tar xvzf graylog2-server-${PKG_VERSION}.tar.gz

  [ -d build ] && rm -rf build
  mkdir -p build/etc/graylog2
  mkdir -p build/etc/init.d
  mkdir -p build/usr/share
  mv graylog2-server-${PKG_VERSION} build/usr/share/graylog2-server
  cp config/elasticsearch.yml build/etc/graylog2/
  cp config/graylog2.conf build/etc/graylog2/
  cp init build/etc/init.d/graylog2
  chmod 755 build/etc/init.d/graylog2

  fpm -s dir -t deb \
    --architecture all \
    -n graylog2-server \
    -v ${PKG_VERSION} \
    --prefix / \
    --after-install post-install-server \
    -C build etc usr

  rm -rf graylog2-server
  rm -rf graylog2-server-${PKG_VERSION}.tar.gz
  rm -rf build
fi

if [ ! -f graylog2-web_${PKG_VERSION}_all.deb ]
then
  tar xvzf graylog2-web-interface-${PKG_VERSION}.tar.gz

  [ -d build ] && rm -rf build
  mkdir -p build/usr/share
  mv graylog2-web-interface-${PKG_VERSION} build/usr/share/graylog2-web

  fpm -s dir -t deb \
    --architecture all \
    -n graylog2-web \
    -v ${PKG_VERSION} \
    --prefix / \
    --after-install post-install-web \
    -C build usr

  rm -rf graylog2-web
  rm -rf graylog2-web-interface-${PKG_VERSION}.tar.gz
  rm -rf build
fi

