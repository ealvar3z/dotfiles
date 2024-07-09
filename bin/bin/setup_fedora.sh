#!/bin/bash

source common.sh

apt_pkgs="pcsc-tools p11-kit coolkey openconnect"
libcoolkey="/usr/lib/pkcs11/libcoolkeypk11.so"
coolkey_p11mod="/etc/pkcs11/modules/libcoolkey.module"

if [ $(id -u) != "0" ]; then
    error "Must be run as root" 1
fi

echo -e "\nInstalling packages..."
apt install -y $apt_pkgs || exit $?
echo "done."

echo -e "\nEnabling pcscd..."
systemctl enable pcscd || exit $?
systemctl start  pcscd || exit $?
echo "done."

echo -e "\nEnabling libcoolkey pcks11 module..."
test -f $libcoolkey || error "$libcoolkey missing"
test -f $coolkey_p11mod && error \
    "$coolkey_p11mod already exists. Please remove and try again."
echo "module:$libcoolkey" > $coolkey_p11mod || exit $?
echo "done."
