#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update the system
echo "Updating the system..."
pacman -Syu --noconfirm

# Install base-devel and Git (necessary for building packages)
echo "Installing base-devel and git..."
pacman -S --noconfirm base-devel git

# Install QEMU, KVM, Virt-Manager
echo "Installing virtualization tools..."
pacman -S --noconfirm qemu qemu-arch-extra virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs

# Enable libvirtd service
echo "Enabling libvirtd service..."
systemctl enable --now libvirtd

# Add user to libvirt group (replace 'your_username' with your actual username)
echo "Adding user to libvirt group..."
usermod -aG libvirt your_username

# Install .NET SDKs
echo "Installing .NET 6, 7, and 8 SDKs..."
pacman -S --noconfirm dotnet-sdk-6.0 dotnet-sdk-7.0 dotnet-sdk

# Install Xorg and Video Drivers
echo "Installing Xorg and video drivers..."
pacman -S --noconfirm xorg-server xorg-apps xorg-xinit

# Detect GPU and install appropriate driver
echo "Detecting GPU and installing appropriate driver..."
if lspci | grep -E "VGA|3D" | grep -i intel; then
    pacman -S --noconfirm xf86-video-intel
elif lspci | grep -E "VGA|3D" | grep -i amd; then
    pacman -S --noconfirm xf86-video-amdgpu
elif lspci | grep -E "VGA|3D" | grep -i nvidia; then
    pacman -S --noconfirm nvidia nvidia-utils
else
    echo "No supported GPU detected or already configured."
fi

# Install KDE Plasma Desktop Environment
echo "Installing KDE Plasma Desktop Environment..."
pacman -S --noconfirm plasma kde-applications

# Install SDDM (Login Manager)
echo "Installing and enabling SDDM..."
pacman -S --noconfirm sddm
systemctl enable sddm

# Install NetworkManager
echo "Installing and enabling NetworkManager..."
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Install Firefox
echo "Installing Firefox..."
pacman -S --noconfirm firefox

# Install Sound and Media tools
echo "Installing sound and media tools..."
pacman -S --noconfirm pulseaudio pulseaudio-alsa vlc

# Install File Management and Utilities
echo "Installing file management and utilities..."
pacman -S --noconfirm dolphin konsole ark kate

# Install Office and Productivity tools
echo "Installing office and productivity tools..."
pacman -S --noconfirm libreoffice-fresh okular

# Install Fonts and Themes
echo "Installing fonts and themes..."
pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji

# Install Development Tools
echo "Installing development tools..."
pacman -S --noconfirm git code gcc g++ make base-devel

# Install System Utilities
echo "Installing system utilities..."
pacman -S --noconfirm htop neofetch gparted

# Install yay AUR helper
echo "Installing yay AUR helper..."
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm

# Cleanup
echo "Cleaning up..."
cd /
rm -rf /tmp/yay

echo "Post-installation script completed! Rebooting system..."
reboot
