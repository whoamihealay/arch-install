clear


# ------------------------------------------------------
# Set System Time
# ------------------------------------------------------
read -p "Enter TZ (America/Toronto) :  " zoneinfo
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohci

# ------------------------------------------------------
# Update reflector
# ------------------------------------------------------
echo "Start reflector..."
reflector -c "Canada," -p https -a 3 --sort rate --save /etc/pacman.d/mirrorlist

# ------------------------------------------------------
# Synchronize mirrors
# ------------------------------------------------------
pacman -Syy

# ------------------------------------------------------
# Install Packages
# ------------------------------------------------------
# Boot & System
pacman --noconfirm -S grub efibootmgr base-devel linux-headers acpi acpid grub-btrfs os-prober
# Network
pacman --noconfirm -S networkmanager network-manager-applet wpa_supplicant inetutils dnsutils reflector avahi nns-mdns
# Audio
pacman --noconfirm -S alsa-utils pipewire pipewire-alsa pipewire-pulse
# File System & Storage
pacman --noconfirm -S dosfstools mtools ntfs-3g nfs-utils
# Security
pacman --noconfirm -S firewalld
# Utilities
pacman --noconfirm -S gvfs flatpak openssh git neovim

# ------------------------------------------------------
# set lang utf8 US
# ------------------------------------------------------
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# ------------------------------------------------------
# Set Keyboard
# ------------------------------------------------------
read -p "Enter keyboard layout: " keyboardlayout
echo "FONT=ter-v18n" >> /etc/vconsole.conf
echo "KEYMAP=$keyboardlayout" >> /etc/vconsole.conf

# ------------------------------------------------------
# Set hostname and localhost
# ------------------------------------------------------
read -p "Enter hostname:" hostname
echo "$hostname" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts


# ------------------------------------------------------
# Set Root Password
# ------------------------------------------------------
read -p "Enter root password: " rootPassword
echo "Set root password"
passwd $rootPassword

# ------------------------------------------------------
# Add User
# ------------------------------------------------------
read -p "Enter username: " username
read -p "Enter password: " password
echo "Add user $username"
useradd -m -G wheel $username
passwd $password

# ------------------------------------------------------
# Add user to wheel
# ------------------------------------------------------
clear
echo "Uncomment %wheel group in sudoers (around line 85):"
echo "Before: #%wheel ALL=(ALL:ALL) ALL"
echo "After:  %wheel ALL=(ALL:ALL) ALL"
echo ""
read -p "Open sudoers now?" c
EDITOR=vim sudo -E visudo
usermod -aG wheel $username

# ------------------------------------------------------
# Enable Services
# ------------------------------------------------------
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid

# ------------------------------------------------------
# Grub installation
# ------------------------------------------------------
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg

# ------------------------------------------------------
# Add btrfs and setfont to mkinitcpio
# ------------------------------------------------------
# Before: BINARIES=()
# After:  BINARIES=(btrfs setfont)
sed -i 's/BINARIES=()/BINARIES=(btrfs setfont)/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

