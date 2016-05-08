#!/bin/bash
#
# Copyright (C) 2016 by Lele Long <longlele@jiemo.me>
# This file is free software, distributed under the GPL License.
#
# <BRIEF DESCRIPTION HERE>
#
cd "$(dirname "$0")"

usage() {
    cat <<EOF
EOF
}

declare -r VM=win10-32
declare -r OSTYPE=Windows10
declare -r VMHOME="$HOME/VirtualBox VMs/$VM/"
declare -r ISOFILE="$HOME/Downloads/Win10_English_x32.iso"
# VBoxMange list ostypes

main() {
    # https://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html
    # http://nakkaya.com/2012/08/30/create-manage-virtualBox-vms-from-the-command-line/

    curl --connect-timeout 3 --continue-at - --location --remote-name \
        http://download.virtualbox.org/virtualbox/5.0.20/virtualbox-5.0_5.0.20-106931~Ubuntu~trusty_amd64.deb
    curl --connect-timeout 3 --continue-at - --location --remote-name \
        http://download.virtualbox.org/virtualbox/5.0.20/Oracle_VM_VirtualBox_Extension_Pack-5.0.20-106931.vbox-extpack
    if [[ ! -e /usr/bin/VBoxManage ]]; then
        sudo gdebi virtualbox-5.0_5.0.20-106931~Ubuntu~trusty_amd64.deb
    fi

    mkdir -p "$VMHOME"
    if [[ ! -e $ISOFILE ]]; then
        echo "iso file not found $ISOFILE"
        exit 1
    fi
    #VBoxManage list vms/hdds
    VBoxManage createhd --filename "$VMHOME/$VM.vdi" --size 51200
    VBoxManage createvm --name $VM --ostype "$OSTYPE" --register
    VBoxManage storagectl $VM --name "SATA Controller" --add sata  --controller IntelAHCI
    VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VMHOME/$VM.vdi"
    VBoxManage storagectl $VM --name "IDE Controller" --add ide
    VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISOFILE"
    VBoxManage modifyvm $VM --ioapic on
    VBoxManage modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
    #LC_ALL=C lspci -v | grep -EA10 "3D|VGA" | grep 'prefetchable'
    VBoxManage modifyvm $VM --memory 2048 --vram 128
    VBoxManage modifyvm $VM --nic1 nat --nictype1 82540EM --cableconnected1 on
    VBoxManage modifyvm $VM --nic1 bridged --bridgeadapter1 e1000g0
    VBoxManage modifyvm $VM --natpf1 "guestsqlserver,tcp,,1433,,1433"
    VBoxManage modifyvm $VM --natpf1 "guestssh,tcp,,2222,,22"
    ## VBoxManage modifyvm $VM --vrde on
    VBoxManage sharedfolder add $VM --name Downloads --hostpath "$HOME/Downloads" --automount
    # VBoxManage list extpacks
    sudo VBoxManage extpack install "Oracle_VM_VirtualBox_Extension_Pack-5.0.20-106931.vbox-extpack"
    #VBoxManage startvm $VM --type headless

    # install guest addon
    # add chinese language
    # windows feature: .net 3.5, telnet
    # sqlserver hybrid, sa/test
}

main "$@"

exit 0
