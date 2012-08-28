#!/bin/sh

echo "Install Ruby 1.9.3"

mkdir -p /tmp

echo "Installing YAML"
cd /tmp
wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar xzvf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure --prefix=/usr/local
make
make install
echo "Successfully installed YAML"

# Quick review of what’s going on: download and untar the source code, change to the directory and install the package. You may need to sudo the make install command. Your mileage may vary.

# Installing Ruby 1.9.3-p0
echo "Installing Ruby"
cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p0.tar.gz
tar xzvf ruby-1.9.3-p0.tar.gz
cd ruby-1.9.3-p0
./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib
make
make install
echo "Successfully installed Ruby"
