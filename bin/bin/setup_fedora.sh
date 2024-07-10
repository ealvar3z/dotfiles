#!/bin/bash

source common.sh

dnf_pkgs="pcsc-lite pcsc-perl pcsc-tools nss-tools p11-kit opensc openconnect"
opensc_module="/usr/lib64/pkcs11/opensc-pkcs11.so"
opensc_p11mod="/etc/pkcs11/modules/opensc.module"

if [ $(id -u) != "0" ]; then
    error "Must be run as root" 1
fi

echo -e "\n[Installing packages...]"
dnf install -y $dnf_pkgs || exit $?
echo "done."

echo -e "\n[Enabling pcscd...]"
systemctl enable pcscd || exit $?
systemctl start  pcscd || exit $?
echo "done."

echo -e "\n[Enabling opensc-pcks11 module...]"
test -f $opensc_module || error "$opensc_module missing"
test -f $opensc_p11mod && error "$opensc_p11mod already exists. Please remove and try again."
echo "module:$opensc_module" > $opensc_p11mod || exit $?

pushd "$HOME"
echo -e "\n[Configuring Chrome...]"
modutil -dbdir sql:.pki/nssdb/ -add "CAC Module" -libfile /usr/lib64/opensc-pkcs11.so

echo -e "\n[Checking if CAC Module loaded...]"
modutil -dbdir sql:.pki/nssdb/ -list | grep CAC || error "CAC Module not found"
echo "[DONE]."
