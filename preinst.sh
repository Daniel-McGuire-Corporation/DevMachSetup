#!/bin/bash

# Define variables
DISK="/dev/sda"
ROOT_PARTITION="${DISK}1"

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
echo g     # Create a new GPT partition table
echo n     # New partition
echo 1     # Partition number 1
echo       # Default - first sector
echo       # Default - last sector
echo w     # Write changes
) | fdisk $DISK

echo "Formatting the partition..."
mkfs.ext4 $ROOT_PARTITION

echo "Mounting the partition..."
mount $ROOT_PARTITION /mnt

# Install Arch Linux base system with Linux Zen kernel
echo "Installing base system with Linux Zen kernel..."
pacstrap /mnt base linux-zen linux-firmware

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Save hostname to a temporary file for later use
echo "$HOSTNAME" > /mnt/etc/hostname

# Ensure the script ends with no errors
if [ $? -ne 0 ]; then
    echo "An error occurred during pre-installation. Please check the logs." 1>&2
    exit 1
fi
clear
echo "Installation Complete! Run the Post Install script after reboot."
echo
echo "Press any key to reboot."
read -n 1 -s
reboot
