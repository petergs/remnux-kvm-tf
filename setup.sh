#!/bin/bash
# color escape codes
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NONE='\033[0m'

echo -e "${GREEN}https://github.com/petergs/remnux-kvm-tf${NONE}"

# download the ova
read -p "Would you like to open the download page for the REMnux ova? [Y/n] " reply 
if [[ "$reply" =~ ^[Yy]$ ]]; then
    xdg-open https://docs.remnux.org/install-distro/get-virtual-appliance#download-virtual-appliance 1> /dev/null 2> /dev/null
fi
echo -e "${ORANGE}Enter an absolute path to the ova:${NONE}"
read downloadpath
mv $downloadpath "${PWD}/remnux.ova"

# unarchive the ova and convert to qcow2
echo -e "${BLUE}Unarchiving the ova...${NONE}"
tar xvf "${PWD}/remnux.ova"
vmdk=*.vmdk.gz
gunzip $vmdk
vmdk=*.vmdk
echo -e "${BLUE}Converting the vmdk to qcow2 which may take a while...${NONE}"
qemu-img convert -O qcow2 $vmdk remnux.qcow2

# lazy globbing
rm -i *.vmdk *.mf *.ovf remnux.ova

# move the qcow2 to the desired pool
echo -e "${ORANGE}Enter the desired pool name (leave blank to use the default pool):${NONE}"
read poolname
if [[ -z "$poolname" ]]; then
    poolname="default"
fi
echo -e "${BLUE}Getting the path for pool ${poolname}...${NONE}"
poolpath=`virsh pool-dumpxml "$poolname" | grep path | awk '{gsub(/<[^>]*>/,"",$0);print}' | awk '{gsub(" ", "", $0);print}'`

echo -e "${BLUE}Moving the remnux.qcow2 to ${poolpath}/...${NONE}"
mv "${PWD}/remnux.qcow2" "${poolpath}/remnux-base.qcow2"
if [[ $? -ne 0 ]]; then
    echo "Trying mv with sudo..."
    sudo mv "${PWD}/remnux.qcow2" "${poolpath}/remnux-base.qcow2"
fi

echo -e "${GREEN}Setup complete!${NONE}"
