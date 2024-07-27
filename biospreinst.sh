#!/bin/bash

# Define variables
DISK="/dev/sda"
ROOT_PARTITION="${DISK}1"
BOOT_PARTITION="${DISK}2"  # Optional, if you want a separate boot partition

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Prompt for hostname
read -p "Enter your desired hostname: " HOSTNAME

# Setup Disk
echo "Partitioning the disk..."
(
echo o     # Create a new MBR partition table
echo n     # New partition
echo p     # Primary partition
echo 1     # Partition number 1
echo       # Default - first sector
echo       # Default - last sector
echo w     # Write changes
) | fdisk $DISK

echo "Formatting the partition..."
mkfs.ext4 $ROOT_PARTITION

# Optional: Create a separate boot partition
# Uncomment the following lines if you want a separate boot partition
# echo "Creating a boot partition..."
# (
# echo n     # New partition
# echo p     # Primary partition
# echo 2     # Partition number 2
# echo       # Default - first sector
# echo       # Default - last sector
# echo w     # Write changes
# ) | fdisk $DISK
# mkfs.ext4 ${DISK}2
# BOOT_PARTITION="${DISK}2"

echo "Mounting the partition..."
mount $ROOT_PARTITION /mnt

# Install Arch Linux base system with Linux Zen kernel
echo "Installing base system with Linux Zen kernel..."
pacstrap /mnt base linux-zen linux-firmware

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system to install and configure GRUB
echo "Chrooting into the new system..."
arch-chroot /mnt /bin/bash <<EOF
echo "Installing GRUB..."
pacman -S --noconfirm grub

# Optional: Install GRUB to the MBR of the disk
echo "Installing GRUB to the MBR of $DISK..."
grub-install --target=i386-pc $DISK

# Generate GRUB configuration file
echo "Generating GRUB configuration file..."
grub-mkconfig -o /boot/grub/grub.cfg

# Set hostname
echo "$HOSTNAME" > /etc/hostname

# Exit chroot environment
exit
EOF

# Ensure the script ends with no errors
if [ $? -ne 0 ]; then
    echo "An error occurred during installation. Please check the logs." 1>&2
    exit 1
fi

clear
echo "Installation Complete! Run the Post Install script after reboot."
echo
echo "Press any key to reboot."
read -n 1 -s
reboot
