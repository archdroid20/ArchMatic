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
 useradd -m -g users -G wheel $username
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
sudo cat <<EOF > /etc/pacman.d/mirrorlist
Server = http://mirror.arizona.edu/archlinux/$repo/os/$arch
Server = https://mirror.arizona.edu/archlinux/$repo/os/$arch
Server = http://mirrors.cat.pdx.edu/archlinux/$repo/os/$arch
Server = http://mirror.cc.columbia.edu/pub/linux/archlinux/$repo/os/$arch
Server = http://repo.ialab.dsu.edu/archlinux/$repo/os/$arch
Server = https://repo.ialab.dsu.edu/archlinux/$repo/os/$arch
Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = http://mirrors.lug.mtu.edu/archlinux/$repo/os/$arch
Server = https://mirrors.lug.mtu.edu/archlinux/$repo/os/$arch
Server = http://mirror.math.princeton.edu/pub/archlinux/$repo/os/$arch
Server = http://mirrors.mit.edu/archlinux/$repo/os/$arch
Server = https://mirrors.mit.edu/archlinux/$repo/os/$arch
Server = http://mirrors.ocf.berkeley.edu/archlinux/$repo/os/$arch
Server = https://mirrors.ocf.berkeley.edu/archlinux/$repo/os/$arch
Server = http://ftp.osuosl.org/pub/archlinux/$repo/os/$arch
Server = http://dfw.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = http://iad.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = http://ord.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://dfw.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://iad.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://ord.mirror.rackspace.com/archlinux/$repo/os/$arch
Server = http://plug-mirror.rcac.purdue.edu/archlinux/$repo/os/$arch
Server = https://plug-mirror.rcac.purdue.edu/archlinux/$repo/os/$arch
Server = http://mirrors.rit.edu/archlinux/$repo/os/$arch
Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
Server = http://mirrors.rutgers.edu/archlinux/$repo/os/$arch
Server = https://mirrors.rutgers.edu/archlinux/$repo/os/$arch
Server = http://mirror.siena.edu/archlinux/$repo/os/$arch
Server = http://mirrors.sonic.net/archlinux/$repo/os/$arch
Server = https://mirrors.sonic.net/archlinux/$repo/os/$arch

EOF
echo "-------------------------------------------------"
echo "Mirror Sync - US Only"
echo "-------------------------------------------------"
pacman -Sy
nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
cat <<EOF > /etc/makepkg.conf
#!/hint/bash
#
# /etc/makepkg.conf
#

#########################################################################
# SOURCE ACQUISITION
#########################################################################
#
#-- The download utilities that makepkg should use to acquire sources
#  Format: 'protocol::agent'
DLAGENTS=('file::/usr/bin/curl -gqC - -o %o %u'
          'ftp::/usr/bin/curl -gqfC - --ftp-pasv --retry 3 --retry-delay 3 -o %o %u'
          'http::/usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o %o %u'
          'https::/usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o %o %u'
          'rsync::/usr/bin/rsync --no-motd -z %u %o'
          'scp::/usr/bin/scp -C %u %o')

# Other common tools:
# /usr/bin/snarf
# /usr/bin/lftpget -c
# /usr/bin/wget

#-- The package required by makepkg to download VCS sources
#  Format: 'protocol::package'
VCSCLIENTS=('bzr::bzr'
            'git::git'
            'hg::mercurial'
            'svn::subversion')

#########################################################################
# ARCHITECTURE, COMPILE FLAGS
#########################################################################
#
CARCH="x86_64"
CHOST="x86_64-pc-linux-gnu"

#-- Compiler and Linker Flags
CPPFLAGS="-D_FORTIFY_SOURCE=2"
CFLAGS="-march=x86-64 -mtune=corei7 -O2 -pipe -fno-plt"
CXXFLAGS="-march=x86-64 -mtune=corei7 -O2 -pipe -fno-plt"
LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
#RUSTFLAGS="-C opt-level=2"
#-- Make Flags: change this for DistCC/SMP systems
MAKEFLAGS="-j8"
#-- Debugging flags
DEBUG_CFLAGS="-g -fvar-tracking-assignments"
DEBUG_CXXFLAGS="-g -fvar-tracking-assignments"
#DEBUG_RUSTFLAGS="-C debuginfo=2"

#########################################################################
# BUILD ENVIRONMENT
#########################################################################
#
# Defaults: BUILDENV=(!distcc !color !ccache check !sign)
#  A negated environment option will do the opposite of the comments below.
#
#-- distcc:   Use the Distributed C/C++/ObjC compiler
#-- color:    Colorize output messages
#-- ccache:   Use ccache to cache compilation
#-- check:    Run the check() function if present in the PKGBUILD
#-- sign:     Generate PGP signature file
#
BUILDENV=(!distcc color !ccache check !sign)
#
#-- If using DistCC, your MAKEFLAGS will also need modification. In addition,
#-- specify a space-delimited list of hosts running in the DistCC cluster.
#DISTCC_HOSTS=""
#
#-- Specify a directory for package building.
#BUILDDIR=/tmp/makepkg

#########################################################################
# GLOBAL PACKAGE OPTIONS
#   These are default values for the options=() settings
#########################################################################
#
# Default: OPTIONS=(!strip docs libtool staticlibs emptydirs !zipman !purge !debug)
#  A negated option will do the opposite of the comments below.
#
#-- strip:      Strip symbols from binaries/libraries
#-- docs:       Save doc directories specified by DOC_DIRS
#-- libtool:    Leave libtool (.la) files in packages
#-- staticlibs: Leave static library (.a) files in packages
#-- emptydirs:  Leave empty directories in packages
#-- zipman:     Compress manual (man and info) pages in MAN_DIRS with gzip
#-- purge:      Remove files specified by PURGE_TARGETS
#-- debug:      Add debugging flags as specified in DEBUG_* variables
#
OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug)

#-- File integrity checks to use. Valid: md5, sha1, sha224, sha256, sha384, sha512, b2
INTEGRITY_CHECK=(md5)
#-- Options to be used when stripping binaries. See `man strip' for details.
STRIP_BINARIES="--strip-all"
#-- Options to be used when stripping shared libraries. See `man strip' for details.
STRIP_SHARED="--strip-unneeded"
#-- Options to be used when stripping static libraries. See `man strip' for details.
STRIP_STATIC="--strip-debug"
#-- Manual (man and info) directories to compress (if zipman is specified)
MAN_DIRS=({usr{,/local}{,/share},opt/*}/{man,info})
#-- Doc directories to remove (if !docs is specified)
DOC_DIRS=(usr/{,local/}{,share/}{doc,gtk-doc} opt/*/{doc,gtk-doc})
#-- Files to be removed from all packages (if purge is specified)
PURGE_TARGETS=(usr/{,share}/info/dir .packlist *.pod)
#-- Directory to store source code in for debug packages
DBGSRCDIR="/usr/src/debug"

#########################################################################
# PACKAGE OUTPUT
#########################################################################
#
# Default: put built package and cached source in build directory
#
#-- Destination: specify a fixed directory where all packages will be placed
#PKGDEST=/home/packages
#-- Source cache: specify a fixed directory where source files will be cached
#SRCDEST=/home/sources
#-- Source packages: specify a fixed directory where all src packages will be placed
#SRCPKGDEST=/home/srcpackages
#-- Log files: specify a fixed directory where all log files will be placed
#LOGDEST=/home/makepkglogs
#-- Packager: name/email of the person or organization building packages
#PACKAGER="John Doe <john@doe.com>"
#-- Specify a key to use for package signing
#GPGKEY=""

#########################################################################
# COMPRESSION DEFAULTS
#########################################################################
#
COMPRESSGZ=(gzip -c -f -n)
COMPRESSBZ2=(bzip2 -c -f)
COMPRESSXZ=(xz -c -z -)
COMPRESSZST=(zstd -c -z -q -)
COMPRESSLRZ=(lrzip -q)
COMPRESSLZO=(lzop -q)
COMPRESSZ=(compress -c -f)
COMPRESSLZ4=(lz4 -q)
COMPRESSLZ=(lzip -c -f)

#########################################################################
# EXTENSION DEFAULTS
#########################################################################
#
PKGEXT='.pkg.tar.zst'
SRCEXT='.src.tar.gz'

EOF

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
cat <<EOF > /etc/bluetooth/main.Conf

[General]

# Default adapter name
# Defaults to 'BlueZ X.YZ'
#Name = BlueZ

# Default device class. Only the major and minor device class bits are
# considered. Defaults to '0x000000'.
#Class = 0x000100

# How long to stay in discoverable mode before going back to non-discoverable
# The value is in seconds. Default is 180, i.e. 3 minutes.
# 0 = disable timer, i.e. stay discoverable forever
#DiscoverableTimeout = 0
Discoverable=true
# Always allow pairing even if there are no agent registered
# Possible values: true, false
# Default: false
#AlwaysPairable = false

# How long to stay in pairable mode before going back to non-discoverable
# The value is in seconds. Default is 0.
# 0 = disable timer, i.e. stay pairable forever
#PairableTimeout = 0

# Use vendor id source (assigner), vendor, product and version information for
# DID profile support. The values are separated by ":" and assigner, VID, PID
# and version.
# Possible vendor id source values: bluetooth, usb (defaults to usb)
#DeviceID = bluetooth:1234:5678:abcd

# Do reverse service discovery for previously unknown devices that connect to
# us. For BR/EDR this option is really only needed for qualification since the
# BITE tester doesn't like us doing reverse SDP for some test cases, for LE
# this disables the GATT client functionally so it can be used in system which
# can only operate as peripheral.
# Defaults to 'true'.
#ReverseServiceDiscovery = true

# Enable name resolving after inquiry. Set it to 'false' if you don't need
# remote devices name and want shorter discovery cycle. Defaults to 'true'.
#NameResolving = true

# Enable runtime persistency of debug link keys. Default is false which
# makes debug link keys valid only for the duration of the connection
# that they were created for.
#DebugKeys = false

# Restricts all controllers to the specified transport. Default value
# is "dual", i.e. both BR/EDR and LE enabled (when supported by the HW).
# Possible values: "dual", "bredr", "le"
#ControllerMode = dual

# Enables Multi Profile Specification support. This allows to specify if
# system supports only Multiple Profiles Single Device (MPSD) configuration
# or both Multiple Profiles Single Device (MPSD) and Multiple Profiles Multiple
# Devices (MPMD) configurations.
# Possible values: "off", "single", "multiple"
#MultiProfile = off

# Permanently enables the Fast Connectable setting for adapters that
# support it. When enabled other devices can connect faster to us,
# however the tradeoff is increased power consumptions. This feature
# will fully work only on kernel version 4.1 and newer. Defaults to
# 'false'.
#FastConnectable = false

# Default privacy setting.
# Enables use of private address.
# Possible values: "off", "device", "network"
# "network" option not supported currently
# Defaults to "off"
# Privacy = off

# Specify the policy to the JUST-WORKS repairing initiated by peer
# Possible values: "never", "confirm", "always"
# Defaults to "never"
#JustWorksRepairing = never

# How long to keep temporary devices around
# The value is in seconds. Default is 30.
# 0 = disable timer, i.e. never keep temporary devices
#TemporaryTimeout = 30

# Enables the device to issue an SDP request to update known services when
# profile is connected. Defaults to true.
#RefreshDiscovery = true

[Controller]
# The following values are used to load default adapter parameters.  BlueZ loads
# the values into the kernel before the adapter is powered if the kernel
# supports the MGMT_LOAD_DEFAULT_PARAMETERS command. If a value isn't provided,
# the kernel will be initialized to it's default value.  The actual value will
# vary based on the kernel version and thus aren't provided here.
# The Bluetooth Core Specification should be consulted for the meaning and valid
# domain of each of these values.

# BR/EDR Page scan activity configuration
#BRPageScanType=
#BRPageScanInterval=
#BRPageScanWindow=

# BR/EDR Inquiry scan activity configuration
#BRInquiryScanType=
#BRInquiryScanInterval=
#BRInquiryScanWindow=

# BR/EDR Link supervision timeout
#BRLinkSupervisionTimeout=

# BR/EDR Page Timeout
#BRPageTimeout=

# BR/EDR Sniff Intervals
#BRMinSniffInterval=
#BRMaxSniffInterval=

# LE advertisement interval (used for legacy advertisement interface only)
#LEMinAdvertisementInterval=
#LEMaxAdvertisementInterval=
#LEMultiAdvertisementRotationInterval=

# LE scanning parameters used for passive scanning supporting auto connect
# scenarios
#LEScanIntervalAutoConnect=
#LEScanWindowAutoConnect=

# LE scanning parameters used for passive scanning supporting wake from suspend
# scenarios
#LEScanIntervalSuspend=
#LEScanWindowSuspend=

# LE scanning parameters used for active scanning supporting discovery
# proceedure
#LEScanIntervalDiscovery=
#LEScanWindowDiscovery=

# LE scanning parameters used for passive scanning supporting the advertisement
# monitor Apis
#LEScanIntervalAdvMonitor=
#LEScanWindowAdvMonitor=

# LE scanning parameters used for connection establishment.
#LEScanIntervalConnect=
#LEScanWindowConnect=

# LE default connection parameters.  These values are superceeded by any
# specific values provided via the Load Connection Parameters interface
#LEMinConnectionInterval=
#LEMaxConnectionInterval=
#LEConnectionLatency=
#LEConnectionSupervisionTimeout=
#LEAutoconnecttimeout=

[GATT]
# GATT attribute cache.
# Possible values:
# always: Always cache attributes even for devices not paired, this is
# recommended as it is best for interoperability, with more consistent
# reconnection times and enables proper tracking of notifications for all
# devices.
# yes: Only cache attributes of paired devices.
# no: Never cache attributes
# Default: always
#Cache = always

# Minimum required Encryption Key Size for accessing secured characteristics.
# Possible values: 0 and 7-16. 0 means don't care.
# Defaults to 0
#KeySize = 0

# Exchange MTU size.
# Possible values: 23-517
# Defaults to 517
#ExchangeMTU = 517

# Number of ATT channels
# Possible values: 1-5 (1 disables EATT)
# Default to 3
#Channels = 3

[Policy]
#
# The ReconnectUUIDs defines the set of remote services that should try
# to be reconnected to in case of a link loss (link supervision
# timeout). The policy plugin should contain a sane set of values by
# default, but this list can be overridden here. By setting the list to
# empty the reconnection feature gets disabled.
#ReconnectUUIDs=00001112-0000-1000-8000-00805f9b34fb,0000111f-0000-1000-8000-00805f9b34fb,0000110a-0000-1000-8000-00805f9b34fb

# ReconnectAttempts define the number of attempts to reconnect after a link
# lost. Setting the value to 0 disables reconnecting feature.
#ReconnectAttempts=7

# ReconnectIntervals define the set of intervals in seconds to use in between
# attempts.
# If the number of attempts defined in ReconnectAttempts is bigger than the
# set of intervals the last interval is repeated until the last attempt.
#ReconnectIntervals=1,2,4,8,16,32,64

# AutoEnable defines option to enable all controllers when they are found.
# This includes adapters present on start as well as adapters that are plugged
# in later on. Defaults to 'false'.
AutoEnable=true
EOF
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
uuid=$(lsblk -nr -o UUID,MOUNTPOINT | grep -Po '.*(?= /$)')

bootctl --boot-path=/boot install
cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux.
version linux-5.9
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd  /initramfs-linux.img
options root=$uuid rw
EOF
echo "--------------------------------------"
echo "-- Installing the intel ucode  --"
echo "--------------------------------------"
pacman -S intel-ucode
