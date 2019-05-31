#! /bin/bash
# scriptname=${0##*/}
#####################################################################
# Copyright (c) 2019 Sea2Cloud Storage, Inc., All Rights Reserved
# Modesto, CA 95356
# Author - Robert E. Novak aka REN
# sailnfool@gmail.com
# skype: sailnfool.ren
#
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#
# This is a human-readable summary of (and not a substitute for)
# the license. Disclaimer.
#
# You are free to:
# Share — copy and redistribute the material in any medium or format
# Adapt — remix, transform, and build upon the material
#         for any purpose, even commercially.
# 
# The licensor cannot revoke these freedoms as long as you follow
# the license terms.
# 
# Under the following terms:
# Attribution — You must give appropriate credit, provide a link to
#               the license, and indicate if changes were made. You
#               may do so in any reasonable manner, but not in any
#               way that suggests the licensor endorses you or your
#               use.
# 
# No additional restrictions — You may not apply legal terms or
#               technological measures that legally restrict others
#               from doing anything the license permits.
# 
# Notices:
# You do not have to comply with the license for elements of the
# material in the public domain or where your use is permitted by
# an applicable exception or limitation.
# 
# No warranties are given. The license may not give you all of
# the permissions necessary for your intended use. For
# example, other rights such as publicity, privacy, or moral
# rights may limit how you use the material.
#####################################################################
# End of Disclaimer
#####################################################################
#
# Restart - install all of the tools needed for updating Raspberry PI
#						stretch to create a wireless access point.  There are also
#           some extras to insure that the necessary tools for
#           installing and managing some packages are also included.
#           This script is based upon "How to use your Raspberry Pi
#           as a wireless access point"
# https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point
#_____________________________________________________________________
# Rev.|Auth.| Date       | Notes
#_____________________________________________________________________
# 1.1 | REN | 04/08/2019 | Added command line parameters
# 1.0 | REN | 04/06/2019 | Initial release
#_____________________________________________________________________
#
#####################################################################
# A number of functions to support BASH software development
#####################################################################
# source rpi.functions
source func.errecho
source func.verifychange


#####################################################################
# These defaults affect Step 4 (see below) but can be overridden
# on the command line.
#
# restart -h
#####################################################################
class3network="192.168.28"
numclients=30
defaultclient=10

#####################################################################
# These defaults affect Step 5 (see below) but can be overridden
# on the command line.
# if you don't change the defaults, then be sure you provide them
# on the command line.
#####################################################################
SSID=my_pi
wpa_passphrase=PASSWORD

#####################################################################
# This default affects Step 0A
#####################################################################
skip_remove=0

#####################################################################
# This affects the verbosity of the output (see -v)
#####################################################################
RPI_VERBOSE=0
export RPI_VERBOSE

USAGE="\r\n${0##*/} [-[dh]] [ -c <class3network> ] [-n <#>]\r\n
\t-c\t<class3network>\tOverride the default value of ${class3network}\r\n
\t-f\t<#>\t\toverride default server address of ${defaultclient}\r\n
\t\t\t\tE.G. ${class3network}.${defaultclient} is the server default address\r\n
\t-h\t\t\tPrint this help message and exit\r\n
\t-n\t<#>\t\twhere '#' is the number of DHCP client addresses\r\n
\t\t\t\tthat will be configured for the WiFi\r\n
\t-s\t<SSID>\t\tOverride the default value of ${SSID} for the\r\n
\t\t\t\taccess point name\r\n
\t-o\t\tEnable installation of optional packages\r\n
\t-p\t<password>\toverride the default value of the WPA Passphrase\r\n
\t-r\t\t\tdisable removal of packages before installation\r\n
\t-v\t<#>\t\tEnable verbose mode; 0=none, higher digits more verbose\r\n
\t-w\t\t\tDisable the installation of the Wireless Access Point\r\n"

if [ ${EUID} != 0 ]
then
	errecho -e "This script must run with an EUID of root(0)\r\n" ${USAGE}
	exit 1
fi

#####################################################################
# The command line options which are documented by the USAGE
# string.  Best seen by running: "restart -h"
#####################################################################
optionargs="hrowv:n:f:c:s:p:"
optionalpackages=0
installwap=1

while getopts ${optionargs} name
do
	case ${name} in
		h)
			echo -e ${USAGE}
			exit 0
			;;
		n)
			numclients="${OPTARG}"
			;;
		o)
			optionalpackages=1
			;;
		f)
			defaultclient="${OPTARG}"
			;;
		v)
			RPI_VERBOSE="${OPTARG}"
			# echo "${0##*/}:${LINENO}:RPI_VERBOSE=${RPI_VERBOSE}"
			export RPI_VERBOSE
			;;
		c)
			class3network="${OPTARG}"
			;;
		s)
			SSID="${OPTARG}"
			;;
		p)
			wpa_passphrase="${OPTARG}"
			;;
		r)
			skip_remove=1
			;;
		w)
			installwap=0
			;;
		\?)
			errecho "-e" ${LINENO} "invalid option: -${OPTARG}"
			errecho "-e" ${LINENO} ${USAGE}
			exit 0
			;;
	esac
done

#####################################################################
# Set up the ranges for the DHCP clients in Step 4
#####################################################################
lowclient=$(expr ${defaultclient} \+ 1)
topclient=$(expr ${lowclient} \+ ${numclients} \- 1)

#####################################################################
# A Brief set of notes on the packages that follow:
# These notes were moved to the end for clarity
#####################################################################
# This is the list of packages I find generally useful.
# only the last set of packages are needed for the WiFi setup
#####################################################################
if [ ${installwap} -eq 1 ]
then
	PLIST="${PLIST} hostapd dnsmasq bridge-utils"
fi
if [ ${optionalpackages} -eq 1 ]
then
	PLIST="${PLIST} dos2unix synaptic vim-gtk3 clang autoconf gdebi"
	PLIST="${PLIST} doxygen asciidoc asciidoctor ps2eps ghostscript"
	PLIST="${PLIST} indent libtool automake autoconf gfortran"
	PLIST="${PLIST} git git-cola filezilla"
fi
	
	
#####################################################################
# STEP 0-A - not explicitly in the article
#
# First we remove all of the packages in the list
# Start with a clean slate
#####################################################################
if [ \( ${installwap} -eq 0 \) -a \( ${optionalpackages} -eq 0 \) ]
then
	errecho ${LINENO} "installwap=${installwap} and optionalpackages=${optionalpackages}, nothing to do"
	exit 0
fi
if [ "${skip_remove}" = "0" ]
then
	sudo apt-get remove -y ${PLIST}
fi

#####################################################################
# STEP 0-B - not explicitly in the article
#
# After removing all of the packages, we will have
# to autoremove a number of orphan packages
#####################################################################
sudo apt-get -y autoremove

#####################################################################
# STEP 1 - Install and Update Raspbian
#
# Now we update and upgrade apt-get to make sure
# that the automatic repositories are up to date
#####################################################################
sudo apt-get -y update
sudo apt-get -y upgrade

#####################################################################
# STEP 2 - Unlike the article, we are insatlling all of the 
#          packages in one step
#
# Now we install all of the packages
#####################################################################
if [ $RPI_VERBOSE -gt 0 ]
then
	echo sudo apt-get install -y ${PLIST}
fi
sudo apt-get install -y ${PLIST}
if [ ${installwap} -eq 1 ]
then
	sudo systemctl stop hostapd
	sudo systemctl stop dnsmasq
fi

#####################################################################
# Briefly here is the pattern for all of the updates
# 1) If there is no copy of the original base line files
#    for the packages, then make a copy in a file suffixed
#    with ".orig"
# 2) Perform any editing changes necessary by applying to
#    a copy of ".orig"
# 3) Move the copy into the place for the destination file
# 4) Perform an ls -l on the original and on the replaced copy
# 5) diff the two copies.
#####################################################################
# STEP 3 - Configure a static IP for the wlan0 interface
#          Note that the options to this step are included
#          in the command line options:
# restart -h
#          to see the options
# Configure DHCP
#####################################################################
if [ ${installwap} -eq 1 ]
then
	DHCPCONFIG="/etc/dhcpcd.conf"
	DHCPORIG=${DHCPCONFIG}.orig
	DHCPNEW="/tmp/$(basename ${DHCPCONFIG}).$$.new"
	DHCPCOPY="/tmp/$(basename ${DHCPCONFIG}).$$.copy"
	DHCPGROUP="netdev"
#	if [ "${skip_remove}" = "0" ]
#	then
#		sudo rm -rf ${DHCPORIG}
#	fi
	
	if [ ! -r ${DHCPORIG} ]
	then
		sudo mv ${DHCPCONFIG} ${DHCPORIG}
	fi
	#####################################################################
	# I had challenges with "here" documents, so I did the following
	#####################################################################
	sudo echo "interface wlan0" > ${DHCPNEW}
	sudo echo "static ip_address=${class3network}.${defaultclient}/24" >> ${DHCPNEW}
	sudo echo "denyinterfaces eth0" >> ${DHCPNEW}
	sudo echo "denyinterfaces wlan0" >> ${DHCPNEW}
	
	#####################################################################
	# Add the above lines to the end of the original file
	#####################################################################
	sudo cat ${DHCPORIG} ${DHCPNEW} > ${DHCPCOPY}
	
	#####################################################################
	# Put the copy as an overwrite on the file.
	#####################################################################
	sudo mv ${DHCPCOPY} ${DHCPCONFIG}
	
	#####################################################################
	# Make sure the permissions match and cleanup
	#####################################################################
	sudo chgrp ${DHCPGROUP} ${DHCPCONFIG}
	sudo chmod g+w ${DHCPCONFIG}
	sudo rm ${DHCPNEW}
	
	verifychange "DHCP" ${DHCPORIG} ${DHCPCONFIG} "01"
	
	#####################################################################
	# Step - 4 Configure the DHCP server (dnsmasq)
	#
	# Configure DNS MASQ
	# Note the use fo the command line arguments.  Note that this script
	# only handles class 3 networks.  A potential future bug
	#####################################################################
	DNSMASQ="/etc/dnsmasq.conf"
	DNSMASQNEW="/tmp/$(basename ${DHCPCONFIG}).$$.new"
	DNSMASQCOPY="/tmp/$(basename ${DHCPCONFIG}).$$.copy"
	if [ "${skip_remove}" = "0" ]
	then
		sudo rm -rf ${DNSMASQ}.orig
	fi
	if [ ! -r ${DNSMASQ}.orig ]
	then
		sudo cp ${DNSMASQ} ${DNSMASQ}.orig
	fi
	sudo chmod 644 ${DNSMASQ}
	sudo echo "# set up 24 hour leases for dhcp clients" > ${DNSMASQNEW}
	sudo echo "interface=wlan0" >> ${DNSMASQNEW}
	sudo echo "	dhcp-range=${class3network}.${lowclient},${class3network}.${topclient},255.255.255.0,24h" >> ${DNSMASQNEW}
	sudo cat ${DNSMASQ}.orig ${DNSMASQNEW} > ${DNSMASQCOPY}
	sudo mv ${DNSMASQCOPY} ${DNSMASQ}
	sudo chown root ${DNSMASQ}
	sudo chgrp root ${DNSMASQ}
	
	verifychange "DNSMASQ" ${DNSMASQ}.orig ${DNSMASQ} "02"
	
	#####################################################################
	# STEP - 5 Configure the access point host software (hostapd)
	#
	# Configure the access point software
	#####################################################################
	HOSTAPD="/etc/default/hostapd"
	HOSTAPDCONF="/etc/hostapd/hostapd.conf"
	HOSTNEW="/tmp/hostapd.conf.new"
	sudo rm -rf ${HOSTNEW}
	sudo echo "interface=wlan0" >> ${HOSTNEW}
	sudo echo "bridge=br0" >> ${HOSTNEW}
	sudo echo "hw_mode=g" >> ${HOSTNEW}
	sudo echo "channel=7" >> ${HOSTNEW}
	sudo echo "wmm_enabled=0" >> ${HOSTNEW}
	sudo echo "macaddr_acl=0" >> ${HOSTNEW}
	sudo echo "auth_algs=1" >> ${HOSTNEW}
	sudo echo "ignore_broadcast_ssid=0" >> ${HOSTNEW}
	sudo echo "wpa=2" >> ${HOSTNEW}
	sudo echo "wpa_key_mgmt=WPA-PSK" >> ${HOSTNEW}
	sudo echo "wpa_pairwise=TKIP" >> ${HOSTNEW}
	sudo echo "rsn_pairwise=CCMP" >> ${HOSTNEW}
	sudo echo "ssid=${SSID}" >> ${HOSTNEW}
	sudo echo "wpa_passphrase=${wpa_passphrase}" >> ${HOSTNEW}
	
	sudo mv ${HOSTNEW} ${HOSTAPDCONF}
	sudo chmod 644 ${HOSTAPDCONF}
	
	if [ "${skip_remove}" = "0" ]
	then
		sudo rm -rf ${HOSTAPD}.orig
		sudo rm -rf ${HOSTAPDCONF}.orig
	fi
	if [ ! -r ${HOSTAPD}.orig ]
	then
		sudo cp ${HOSTAPD} ${HOSTAPD}.orig
	fi
	if [ ! -r ${HOSTAPDCONF}.orig ]
	then
		sudo cp ${HOSTAPDCONF} ${HOSTAPDCONF}.orig
	fi
	sudo sed -e "s,^#DAEMON_CONF.*,DAEMON_CONF=${HOSTAPDCONF}," < ${HOSTAPD}.orig > ${HOSTAPD}.copy
	sudo mv ${HOSTAPD}.copy ${HOSTAPD}
	verifychange "HOSTAPD" ${HOSTAPD}.orig ${HOSTAPD} "03"
	verifychange "HOSTAPDCONF" "${HOSTAPDCONF}.orig" "${HOSTAPDCONF}" "03A"
	
	#####################################################################
	# STEP 6 - Set up traffic forwarding
	#
	# Set up Traffic Forwarding
	#####################################################################
	SYSCTLCONF="/etc/sysctl.conf"
	SYSCTLCONFORIG="${SYSCTLCONF}.orig"
	SYSCTLCONFNEW="${SYSCTLCONF}.new"
	if [ "${skip_remove}" = "0" ]
	then
		sudo rm -rf ${SYSCTLCONFORIG}
	fi
	if [ ! -r ${SYSCTLCONFORIG} ]
	then
		sudo cp ${SYSCTLCONF} ${SYSCTLCONFORIG}
	fi
	sudo sed -e "s,#\(net\.ipv4\.ip_forward=1\),\1," < ${SYSCTLCONFORIG} > ${SYSCTLCONF}.new
	sudo mv ${SYSCTLCONF}.new ${SYSCTLCONF}
	sudo chown root ${SYSCTLCONF}
	sudo chgrp root ${SYSCTLCONF}
	sudo chmod 755 ${SYSCTLCONF}
	verifychange "SYSCTL" ${SYSCTLCONFORIG} ${SYSCTLCONF} "04"
	
	#####################################################################
	# STEP 7 - Add a new iptables rule
	#####################################################################
	IP4TABLES="/etc/iptables.ipv4.nat"
	RCLOCAL="/etc/rc.local"
	RCLOCALNEW=/tmp/$(basename ${RCLOCAL}).new
	RCLOCALORIG="${RCLOCAL}.orig"
	if [ "${skip_remove}" = "0" ]
	then
		sudo rm -rf ${RCLOCALORIG}
		sudo rm -rf ${IP4TABLES}.orig
	fi
	if [ ! -r ${IP4TABLES}.orig ]
	then
		sudo sh -c "iptables-save > ${IP4TABLES}.orig"
	fi
	sudo iptables-restore < ${IP4TABLES}.orig
	if [ ! -r ${RCLOCALORIG} ]
	then
		sudo mv ${RCLOCAL} ${RCLOCALORIG}
	fi
	sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	sudo sh -c "iptables-save > ${IP4TABLES}"
	sed -e "/^exit 0$/d" < ${RCLOCALORIG} > ${RCLOCALNEW}
	sudo echo "iptables-restore < ${IP4TABLES}" >> ${RCLOCALNEW}
	sudo echo "exit 0" >> ${RCLOCALNEW}
	sudo mv ${RCLOCALNEW} ${RCLOCAL}
	sudo chown root ${RCLOCAL}
	sudo chgrp root ${RCLOCAL}
	
	#####################################################################
	# Make sure that the execute bits are turned on for rc.local or it
	# will never be run.
	#####################################################################
	sudo chmod 744 ${RCLOCAL}
	
	verifychange "RCLOCAL" ${RCLOCALORIG} ${RCLOCAL} "05"
	
	verifychange "IP4TABLES" ${IP4TABLES}.orig ${IP4TABLES} "06"
	
	#####################################################################
	# STEP 8 -nHandle Bridging
	# The following code which sends output to /dev/null is only
	# run if a prior run left a bridge up and open.  Note the steps
	# with systemctl below to get the hostapd and dnsmasq restarted.
	# With those additions, you may not need to reboot.
	#####################################################################
	
	sudo brctl delif br0 eth0 2>&1 > /dev/null
	sudo ip link set br0 down 2>&1 > /dev/null
	sudo brctl delbr br0 2>&1 > /dev/null
	
	
	sudo brctl addbr br0
	sudo brctl addif br0 eth0
	
	#####################################################################
	# Set up the network interfaces for bridging
	#####################################################################
	NETINTER="/etc/network/interfaces"
	NETINTERORIG="${NETINTER}.orig"
	if [ "${skip_remove}" = "0" ]
	then
		sudo rm -rf ${NETINTERORIG}
	fi
	if [ ! -r ${NETINTERORIG} ]
	then
		sudo mv ${NETINTER} ${NETINTERORIG}
	fi
	
	sudo echo "auto br0" > ${NETINTER}.new
	sudo echo "iface br0 inet manual" >> ${NETINTER}.new
	sudo echo "bridge_ports eth0 wlan0" >> ${NETINTER}.new
	sudo echo "$0##*/:$LINENO"
	sudo cat ${NETINTERORIG} ${NETINTER}.new > ${NETINTER}.copy
	sudo mv ${NETINTER}.copy ${NETINTER}
	sudo chown root ${NETINTER}
	sudo chgrp root ${NETINTER}
	
	#####################################################################
	# I found this solution in:
	# https://www.raspberrypi.org/forums/viewtopic.php?t=235598
	# This solved a problem that I had been having for days!
	#####################################################################
	sudo systemctl unmask hostapd
	sudo systemctl enable hostapd
	sudo systemctl start hostapd
	sudo systemctl start dnsmasq
	
	verifychange "NETINTER" ${NETINTERORIG} ${NETINTER} "07"
else
	##########
	# At this point we will NOT be installing the Wireless Access Point(WAP)
	##########
	DHCPCONFIG="/etc/dhcpcd.conf"
	DHCPORIG=${DHCPCONFIG}.orig
#	if [ "${skip_remove}" = "0" ]
#	then
#		sudo rm -rf ${DHCPORIG}
#	fi
	
	if [ -r ${DHCPORIG} ]
	then
		##########
		# restore the config file from the ".orig"
		##########
		sudo cp ${DHCPORIG} ${DHCPCONFIG}
		DHCPGROUP="netdev"
		sudo chmod g+w ${DHCPCONFIG}
		sudo chgrp ${DHCPGROUP} ${DHCPCONFIG}
	fi
	verifychange "DHCP" ${DHCPORIG} ${DHCPCONFIG} "01"
	
	#####################################################################
	# Step - 4 Configure the DHCP server (dnsmasq)
	#
	# Configure DNS MASQ
	# Note the use fo the command line arguments.  Note that this script
	# only handles class 3 networks.  A potential future bug
	#####################################################################
	DNSMASQ="/etc/dnsmasq.conf"
	if [ ! -r ${DNSMASQ}.orig ]
	then
		sudo cp ${DNSMASQ}.orig ${DNSMASQ}
		sudo chmod 644 ${DNSMASQ}
		sudo chown root ${DNSMASQ}
		sudo chgrp root ${DNSMASQ}
	fi
	verifychange "DNSMASQ" ${DNSMASQ}.orig ${DNSMASQ} "02"
	
	#####################################################################
	# STEP - 5 Configure the access point host software (hostapd)
	#
	# Configure the access point software
	#####################################################################
	HOSTAPD="/etc/default/hostapd"
	HOSTAPDCONF="/etc/hostapd/hostapd.conf"
	
	if [ -r ${HOSTAPD}.orig ]
	then
		sudo cp ${HOSTAPD}.orig ${HOSTAPD}
	fi
	if [ -r ${HOSTAPDCONF}.orig ]
	then
		sudo cp ${HOSTAPDCONF}.orig ${HOSTAPDCONF}
		sudo chmod 644 ${HOSTAPDCONF}
	fi
	verifychange "HOSTAPD" "${HOSTAPD}.orig" "${HOSTAPD}" "03"
	verifychange "HOSTAPDCONF" "${HOSTAPDCONF}.orig" "${HOSTAPDCONF}" "03A"
	
	#####################################################################
	# STEP 6 - Set up traffic forwarding
	#
	# Set up Traffic Forwarding
	#####################################################################
	SYSCTLCONF="/etc/sysctl.conf"
	SYSCTLCONFORIG="${SYSCTLCONF}.orig"
	if [ -r ${SYSCTLCONFORIG} ]
	then
		sudo cp ${SYSCTLCONFORIG} ${SYSCTLCONF}
		sudo chown root ${SYSCTLCONF}
		sudo chgrp root ${SYSCTLCONF}
		sudo chmod 755 ${SYSCTLCONF}
	fi
	verifychange "SYSCTL" ${SYSCTLCONFORIG} ${SYSCTLCONF} "04"
	
	#####################################################################
	# STEP 7 - Add a new iptables rule
	#####################################################################
	IP4TABLES="/etc/iptables.ipv4.nat"
	RCLOCAL="/etc/rc.local"
	RCLOCALNEW=/tmp/$(basename ${RCLOCAL}).new
	RCLOCALORIG="${RCLOCAL}.orig"
	if [ -r ${IP4TABLES}.orig ]
	then
		sudo iptables-restore < ${IP4TABLES}.orig
	fi
	if [ -r ${RCLOCALORIG} ]
	then
		sudo cp ${RCLOCALORIG} ${RCLOCAL}
		sudo chown root ${RCLOCAL}
		sudo chgrp root ${RCLOCAL}
	
		#####################################################################
		# Make sure that the execute bits are turned on for rc.local or it
		# will never be run.
		#####################################################################
		sudo chmod 744 ${RCLOCAL}
	fi
	
	verifychange "RCLOCAL" ${RCLOCALORIG} ${RCLOCAL} "05"
	
	verifychange "IP4TABLES" ${IP4TABLES}.orig ${IP4TABLES} "06"
	
	#####################################################################
	# restore the network interfaces for bridging
	#####################################################################
	NETINTER="/etc/network/interfaces"
	NETINTERORIG="${NETINTER}.orig"
	if [ -r ${NETINTERORIG} ]
	then
		sudo cp ${NETINTERORIG} ${NETINTER}
		sudo chown root ${NETINTER}
		sudo chgrp root ${NETINTER}
	fi
	
	#####################################################################
	# I found this solution in:
	# https://www.raspberrypi.org/forums/viewtopic.php?t=235598
	# This solved a problem that I had been having for days!
	#####################################################################
#	sudo systemctl unmask hostapd
	sudo systemctl disable hostapd
	sudo systemctl stop hostapd
	sudo systemctl stop dnsmasq
	
	verifychange "NETINTER" ${NETINTERORIG} ${NETINTER} "07"
fi
echo "Enter 'sudo reboot now' if you are happy with the changes so far."
#####################################################################
#
# dos2unix
#
# We need the dos2unix command if we have been editing in windows and
# try to use the files here.  The Raspberry BASH shell gets confused
# by the \r\n instead of \n at the end of lines.  After installing
# run "man dos2unix" for how to convert the files.
#####################################################################
#
# synaptic
#
# If you are a Linux newcomer or even an experienced hand, synaptic
# eliminates the guesswork from the apt-get vs. apt methods of 
# installing packages.  Getting this script to work required
# making sure that the script was owned by root and that the
# setuid bit was set:
#
# sudo chown root restart.bash
# sudo chmod 4777 restart.bash  # Note that this is DANGEROUS!
#
# If you install synaptic you can use it to perform the other
# installations (albeit by hand) rather then worrying about the
# proper setuid bits to get permission to use sudo inside a
# script.
#####################################################################
#
# GUI Editor
#
# install the editor of your choice: gedit, nano, vim, emacs, etc.
#####################################################################
#
# clang
#
# install the more modern C compiler to build packages
# autoconf is also a package building tool.
#####################################################################
#
# gdebi
#
# gdebi will install debian packages from the command line or
# GUI interface in a user friendly way.
#####################################################################
#
# doxygen
#
# doxygen is a way of installing documentation in-line in your
# source code and then automatically extracting the documentation 
# like the "man" pages instead of keeping separate but related 
# files grouped together.
#####################################################################
#
# asciidoc & asciidoctor
#
# IMHO asciidoc and asciidoctor represent the modern descendent of
# nroff to generate human readable text in PDF or Kindle ".mob" files
# to make documentation easily accessible.
#####################################################################
#
# ps2eps & ghostscript
#
# ps2eps and ghostscript are the simple tools that enable asciidoctor
# to generate PDF and .mob files.
#####################################################################
# configure the access point and DHCP servers
#####################################################################
# The folllowing may be an artifact of an early state of the
# stretch release.  You may be able to eliminate the following
# if the above installs work correctly.
#####################################################################
# sudo apt-get update
# sudo apt-get upgrade
# sudo apt-get --fix-broken install
# sudo apt-get update --fix-missing
# sudo dpkg --configure -a
# sudo apt-get install -f
# sudo apt-get install ps2eps

# sudo apt-get install hostapd
# sudo apt-get install dnsmasq

