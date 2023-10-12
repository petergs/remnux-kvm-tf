#!/bin/bash
# color escape codes
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NONE='\033[0m'

echo -e "${GREEN}https://github.com/petergs/remnux-kvm-tf${NONE}"


# current direct link for the REMnux general ova hosted on Box
# valid as of 2023-10-11
BOX_DOWNLOAD_URL='https://public.boxcloud.com/d/1/b1!izH-U_gcCYKTyb2nWUolev1kTYr9mAzKOqzPaXUBk3vYuFMS-5SCieYpP4pnahpB6Pnq2gTPM5ftsquKAy2zGJkipHPrURyHTbPRdeiCf990MuH_OBawQC3z11jVnEWHf40xWPLej2sjFizd_W9WMnZaToOSum2fJn1vsMXSUe4OFNtwgt0dZLq0bkr2bdLN8nH2y3DuelkMYnJxx3EqKIJLX-euhpio4dCMf-RxREdolUJnBgunqC81NJbLvsFcaNgwzsAeFsOoPIA83iX4lgFFdFPW2CG9e2tVpN8KEqQaMWDWQtj-l7kJr87FJ58QbKAORZOFXIYD_0QVC3VQeathniKBahSsRm3OKNLICTy9-zJv_hhdOQtqioXxeS1BKmZYPbaX1juSX6ywfEVLWRfvXQ6Moq_QNtQm9ruNN4XxZI6TOx9VYkpQeTOIErxVZDQW9bvaVrGqsIjsQr9mp8To3ApAg_qejr17gmSnpGrbMA5ecd7SFN71XRodmdmjkm9GUE5BGeOk6qBGh3hUNM3cHIe3uyfC9a04BCOdp65XMXDy1jlHZfJ_ybrX7apY_-pjlDftI4x2x_KX0mWMY6QduNPSXLJozmM35OJuN-c116jLz1M087H5g-BpmRbWsWL1aDgG3Y4MpHXYatDHZIwrPFQGwsKa4l9yuSzsy3O3Xmde0hfqUpsxpaXrsO_zNaUth21UmZbqA8Lwyil2kf2AyhIB1l8hQiRpUVhelzn4BQx0Vg3k9z4O7Z-V-QPMauV48oobxFDWBkmVNsZfNDpVU9dNshfoz1Uz_BzX9SSfaBLQ7lx7FqK7AHHhWToDKLbFchcMotzpHfqlTchi7hL2N3WJRRJimMdk6WKPUiubM61A1WxI9PveDi3Ytm_XoAepUW1MsKo6R46BYwrlnjxmDGMem8-_tv3XZyTAINuEgkqdvpc5oW4RWeGrIfPXOyhp9vG-fC-rxbyWaeuqvXIzTukYWrkrwLAWHwvr0TBP_3pjF2R2WCigNJFgO-Nz9BHFnBfI7vak4N_J5iouPN6Vwaj2zmbTJVGLS_6avorgTJOxNwrZCHrm09_pe8kF3LcbePiQ6X6ekxTidRTJ_gGhepro12GqaoyCpdMplm6dcNs8TK5jGjHWSgW553dEX3JZiVsVkcL3dEjKzv1MEsqskAHmLGtzaYknn5cXW2mOkjCZ2lz4tlj7wPEDL1y7SIi6LLGu7W7Vabzave8CBjk1sWAMzrGY9fq34HYnU6-PEr1cDQDyFaIbC6wKGoV-jxjqHj0V5Ys./download'

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
