#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo -e "\nFINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------



# ------------------------------------------------------------------------

# ------------------------------------------------------------------------

#echo -e "\nConfiguring LTS Kernel as a secondary boot option"

#cat <<EOF > /boot/loader/entries/arch.conf
#title Arch Linux
#linux /vmlinuz-linux
#initrd /intel-ucode.img
#initrd /initramfs-linux.img
#options root="uuid" rw
#EOF

# ------------------------------------------------------------------------

echo -e "\nConfiguring vconsole.conf to set a larger font for login shell"

cat <<EOF > /etc/vconsole.conf
KEYMAP=us
FONT=ter-v32b
EOF

# ------------------------------------------------------------------------


# ------------------------------------------------------------------------

#sudo systemctl enable --now lightdm.service

# ------------------------------------------------------------------------

echo -e "\nEnabling bluetooth daemon and setting it to auto-start"

cat <<EOF > /etc/bluetooth/main.conf
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
DiscoverableTimeout = 0
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

# Do reverse service discovery for previously unknblkid /dev/sda1 -s UUID -o)own devices that connect to
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
# The following values are useblkid /dev/sda1 -s UUID -o)d to load default adapter parameters.  BlueZ loads
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
#LEScanIntervalSuspend=sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g'
#LEScanWindowSuspend=

# LE scanning parameters used for active scanning supporting discovery
# proceedure
#LEScanIntervalDiscovery=
#LEScanWindowDiscovery=blkid /dev/sda1 -s UUID -o)

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

#systemctl enable --now org.cups.cupsd.service
#ntpd -qg
#systemctl enable --now ntpd.service
#systemctl disable dhcpcd.service
#systemctl stop dhcpcd.service
#systemctl enable --now NetworkManager.service
#systemctl enable sddm.service
echo "
###############################################################################
# Cleaning
###############################################################################
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
cat <<EOF > /etc/sudoers
## sudoers file.
##
## This file MUST be edited with the 'visudo' command as root.
## Failure to use 'visudo' may result in syntax or file permission errors
## that prevent sudo from running.
##
## See the sudoers man page for the details on how to write a sudoers file.
##

##
## Host alias specification
##
## Groups of machines. These may include host names (optionally with wildcards),
## IP addresses, network numbers or netgroups.
# Host_Alias	WEBSERVERS = www1, www2, www3

##
## User alias specification
##
## Groups of users.  These may consist of user names, uids, Unix groups,
## or netgroups.
# User_Alias	ADMINS = millert, dowdy, mikef

##
## Cmnd alias specification
##
## Groups of commands.  Often used to group related commands together.
# Cmnd_Alias	PROCESSES = /usr/bin/nice, /bin/kill, /usr/bin/renice, \
# 			    /usr/bin/pkill, /usr/bin/top
# Cmnd_Alias	REBOOT = /sbin/halt, /sbin/reboot, /sbin/poweroff

##
## Defaults specification
##
## You may wish to keep some of the following environment variables
## when running commands via sudo.
##
## Locale settings
# Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET"
##
## Run X applications through sudo; HOME is used to find the
## .Xauthority file.  Note that other programs use HOME to find
## configuration files and this may lead to privilege escalation!
# Defaults env_keep += "HOME"
##
## X11 resource path settings
# Defaults env_keep += "XAPPLRESDIR XFILESEARCHPATH XUSERFILESEARCHPATH"
##
## Desktop path settings
# Defaults env_keep += "QTDIR KDEDIR"
##
## Allow sudo-run commands to inherit the callers' ConsoleKit session
# Defaults env_keep += "XDG_SESSION_COOKIE"
##
## Uncomment to enable special input methods.  Care should be taken as
## this may allow users to subvert the command being run via sudo.
# Defaults env_keep += "XMODIFIERS GTK_IM_MODULE QT_IM_MODULE QT_IM_SWITCHER"
##
## Uncomment to use a hard-coded PATH instead of the user's to find commands
# Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
##
## Uncomment to send mail if the user does not enter the correct password.
# Defaults mail_badpass
##
## Uncomment to enable logging of a command's output, except for
## sudoreplay and reboot.  Use sudoreplay to play back logged sessions.
# Defaults log_output
# Defaults!/usr/bin/sudoreplay !log_output
# Defaults!/usr/local/bin/sudoreplay !log_output
# Defaults!REBOOT !log_output

##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL) ALL

## Uncomment to allow members of group wheel to execute any command
 %wheel ALL=(ALL) ALL

## Same thing without a password
#%wheel ALL=(ALL) NOPASSWD: ALL

## Uncomment to allow members of group sudo to execute any command
#%sudo	ALL=(ALL) NOPASSWD: ALL

## Uncomment to allow any user to run sudo if they know the password
## of the user they are running the command as (root by default).
# Defaults targetpw  # Ask for the password of the target user
# ALL ALL=(ALL) ALL  # WARNING: only use this together with 'Defaults targetpw'

## Read drop-in files from /etc/sudoers.d
## (the '#' here does not indicate a comment)
#includedir /etc/sudoers.d
EOF
# Clean orphans pkg
if [[ ! -n $(pacman -Qdt) ]]; then
	echo "No orphans to remove."
else
	pacman -Rns $(pacman -Qdtq)
fi

# Replace in the same state
cd $pwd
echo "
###############################################################################
# Done
###############################################################################
"
