#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

if ! source install.conf; then
	read -p "Please enter hostname:" hostname

	read -p "Please enter username:" username

	read -sp "Please enter password:" password

	read -sp "Please repeat password:" password2

	# Check both passwords match
	if [ "$password" != "$password2" ]; then
	    echo "Passwords do not match"
	    exit 1
	fi
  printf "hostname="$hostname"\n" >> "install.conf"
  printf "username="$username"\n" >> "install.conf"
  printf "password="$password"\n" >> "install.conf"
fi

echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "--------------------------------------"
echo "--          installing grub         --"
echo "--------------------------------------"
pacman -S grub efibootmgr dosfstools os-prober mtools
echo "--------------------------------------"
echo "--      Set Password for Root       --"
echo "--------------------------------------"
echo "Enter password for root user: "
passwd root

echo "--------------------------------------"
echo "--     Setup a new user             --"
echo "-- and add password for user        --"
echo "--------------------------------------"
echo "Enter password for new user"
 useradd -m -g users -G wheel audio $username
 passwd $username
echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone America/Los_Angeles
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_COLLATE="" LC_TIME="en_US.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap us

# Hostname
hostnamectl --no-ask-password set-hostname $hostname

# Add user to wheel group
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download - US Only"
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

echo -e "\nConfiguring vconsole.conf to set a larger font for login shell"

cat <<EOF > /etc/vconsole.conf
KEYMAP=us
FONT=ter-v32b
EOF

# ------------------------------------------------------------------------

echo -e "\nEnabling Login Display Manager"

#sudo systemctl enable --now sddm.service

# ------------------------------------------------------------------------

echo -e "\nEnabling bluetooth daemon and setting it to auto-start"

sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
sudo systemctl enable --now bluetooth.service

# ------------------------------------------------------------------------

echo -e "\nEnabling the cups service daemon so we can print"

systemctl enable --now org.cups.cupsd.service
sudo ntpd -qg
sudo systemctl enable --now ntpd.service
sudo systemctl enable dhcpcd.service
sudo systemctl start dhcpcd.service
sudo systemctl enable --now NetworkManager.service
echo -e "\nAdding users to the wheel group"
# Add users to the wheel group
 useradd -m -g users -G wheel audio $username
# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#echo "--------------------------------------"
#echo "--------------------------------------"
#mkdir /boot/efi
#grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
#cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
#

echo "--------------------------------------"
echo "-- Bootloader Systemd Installation  --"
echo "--------------------------------------"

bootctl --boot-path=/boot install
cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux.
version linux-5.9
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd  /initramfs-linux.img
options root=uuid rw
EOF
echo "--------------------------------------"
echo "-- Installing the intel ucode  --"
echo "--------------------------------------"
pacman -S intel-ucode
