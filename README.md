[Arch linux Installation](https://wiki.archlinux.org/title/Installation_guide)

```
# Load keyboard layout (replace de with us, fr, es if needed)
loadkeys us

# Check internet connection
ping -c4 www.archlinux.org

# Check partitions
lsblk

# Create partitions
gdisk /dev/sda
# Partition 1: +512M ef00 (for EFI)
# Partition 2: Available space 8300 (for Linux filesystem)
# (Optional Partition 3 for Virtual Machines)
# Write w, Confirm Y

# Sync package
pacman -Syy

# Maybe it's required to install the current archlinux keyring
# if the installation of git fails.
pacman -S archlinux-keyring
pacman -Syy

# Install git
pacman -S git

# Clone Installation
git clone https://gitlab.com/stephan-raabe/archinstall.git
cd archinstall

# Start the script
./1-install.sh

```

