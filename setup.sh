#!/usr/bin/env bash

# references:
# https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html
# https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5
set -euo pipefail

usage() {
    name=$(basename -s .sh $0)
    bold=$(tput bold)
    normal=$(tput sgr0)
    under=$(tput smul)
    cat <<EOF
${bold}NAME${normal}
  $name - setup disk encrypted with Luks and with btrfs inside lvm to install nixos.
  It will stop in mount pounts part with default config generated by nixos-generate-config --root /mnt
  After that you need to apply a configuration.

${bold}SYNOPSIS${normal}
  $name [OPTION]... [DISK]...

${bold}DESCRIPTION${normal}
  Setups ${bold}nixos${normal} initial system based on ${bold}configuration.nix${normal} and ${bold}disk${normal} setted.

  It will overwrite all previus partition on disk chosed

  With No ${bold}DISK${normal} it will open to user chose one based on finded disks.

  With No ${bold}size${normal} setted it will use full disk

  ${bold}-h, -?, --help, --usage${normal}
    display this help and exit


  ${bold}-d, --disk${normal} ${under}DISK${normal}
    disk as arg

  ${bold}-s, --size${normal} ${under}SIZE${normal}
    size in used by disk chosed for instalation of nixos, NUMBER[GB,MB,..], eg: 120GB

EOF
    exit 1
}

error() {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    echo -e "${RED}${1}${NC}"
    exit 1
}

is_disk() {
    disk=$1
    blkid $disk
}

is_usb() {
    usb=$1
    value="$(udevadm info --query=property --name=$usb --property=ID_BUS --value)"
    [ "$value" == "usb" ]
}

list_disks() {
    all_disks=$(lsblk -d -e7 -o name -n -p)
    declare -a disks
    for disk in $all_disks; do
        ! is_usb $disk && disks+=($disk)
    done

    echo -e "Disks Founded:\n${disks[*]}"
}

chose_disk() {
    read -r -e disk
    is_disk $disk || echo "invalid disk: $disk" && exit 1
    echo -n $disk
}

declare disk="-"
declare configuration="-"
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -h | --help | --usage | -\?) usage ;;
    -d | --disk)
        disk="$2"
        shift
        ;;
    -s | --size)
        size="$2"
        shift
        ;;
    -c | --configuration)
        configuration="$2"
        shift
        ;;
    *)
        echo "Unknow parameter: $1"
        exit 1
        ;;
    esac
    shift
done

[[ "$disk" == "-" ]] &&
    list_disks &&
    echo -ne "\ndisk: " &&
    set disk $(chose_disk)

sgdisk --clear \
    --new 1::+1M --typecode=1:ef02 --change-name=1:'BIOS boot' \
    --new 2::+1G --typecode=2:ef00 --change-name=2:'EFI boot' \
    --new 3::${size:--0} --typecode=3:8e00 --change-name=3:'LVM' \
    $disk

mapfile -t parts < <(lsblk -l $disk -p -o NAME -n | grep -v ^$disk$)

mkfs.fat -n BOOT ${parts[1]}

cryptsetup -q luksFormat ${parts[2]} || error "can't format to luks"
cryptsetup luksOpen ${parts[2]} pv

pvcreate /dev/mapper/pv
vgcreate vg /dev/mapper/pv

lvcreate -C y -L 26G -n swap vg
lvcreate -l '100%FREE' -n root vg

mkswap -L swap /dev/vg/swap
mkfs.btrfs -L root /dev/vg/root

swapon /dev/vg/swap

mount -t btrfs /dev/vg/root /mnt

btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log

btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

umount /mnt

mount -o subvol=root,compress=zstd,noatime /dev/vg/root /mnt

mkdir /mnt/home
mount -o subvol=home,compress=zstd,noatime /dev/vg/root /mnt/home

mkdir /mnt/nix
mount -o subvol=nix,compress=zstd,noatime /dev/vg/root /mnt/nix

mkdir /mnt/persist
mount -o subvol=persist,compress=zstd,noatime /dev/vg/root /mnt/persist

mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime /dev/vg/root /mnt/var/log

mkdir /mnt/boot
mount ${parts[1]} /mnt/boot

nixos-generate-config --root /mnt
