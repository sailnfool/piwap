#!/bin/bash
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
# pkginstall - install my favorite packages
# 	    There are also
#           some extras to insure that the necessary tools for
#           installing and managing some packages are also included.
#           This script is based upon "How to use your Raspberry Pi
#           as a wireless access point"
# https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point
#_____________________________________________________________________
# Rev.|Aut| Date       | Notes
#_____________________________________________________________________
# 1.2 |REN| 06/23/2019 | changed from Piwap to pkginstall to 
#                        | install my favorite packges on a new
#                        | new machine
# 1.1 |REN| 04/08/2019 | Added command line parameters
# 1.0 |REN| 04/06/2019 | Initial release
#_____________________________________________________________________
#
#####################################################################
# A number of functions to support BASH software development
#####################################################################
# source rpi.functions
source func.errecho
source func.verifychange

#####################################################################
# This default affects Step 0A
#####################################################################
skip_remove=0

#####################################################################
# This affects the verbosity of the output (see -v)
#####################################################################
RPI_VERBOSE=0
export RPI_VERBOSE

USAGE="\r\n${0##*/} [-[hor]] [-v <#>]\r\n
\t-h\t\t\tPrint this help message and exit\r\n
\t-o\t\tEnable installation of optional packages\r\n
\t-r\t\t\tdisable removal of packages before installation\r\n
\t-v\t<#>\t\tEnable verbose mode; 0=none, higher digits more verbose\r\n"

# if [ ${EUID} != 0 ]
# then
# 	errecho -e "This script must run with an EUID of root(0)\r\n" ${USAGE}
# 	exit 1
# fi

#####################################################################
# The command line options which are documented by the USAGE
# string.  Best seen by running: "pkginstall -h"
#####################################################################
optionargs="hrov:"
optionalpackages=0
installwap=1

while getopts ${optionargs} name
do
	case ${name} in
		h)
			echo -e ${USAGE}
			exit 0
			;;
		o)
			optionalpackages=1
			;;
		v)
			RPI_VERBOSE="${OPTARG}"
			# echo "${0##*/}:${LINENO}:RPI_VERBOSE=${RPI_VERBOSE}"
			export RPI_VERBOSE
			;;
		r)
			skip_remove=1
			;;
		\?)
			errecho "-e" ${LINENO} "invalid option: -${OPTARG}"
			errecho "-e" ${LINENO} ${USAGE}
			exit 0
			;;
	esac
done

if [ ${optionalpackages} -eq 1 ]
then
	PLIST="${PLIST} dos2unix synaptic vim-gtk3 clang autoconf gdebi"
	PLIST="${PLIST} doxygen asciidoc asciidoctor ps2eps ghostscript"
	PLIST="${PLIST} indent libtool automake autoconf gfortran"
	PLIST="${PLIST} git git-cola filezilla make"
fi
	
#####################################################################
# STEP 0-A - not explicitly in the article
#
# First we remove all of the packages in the list
# Start with a clean slate
#####################################################################
if [ ${optionalpackages} -eq 0 ]
then
	errecho ${LINENO} "optionalpackages=${optionalpackages}, nothing to do"
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
# STEP 1 - Install and Update Operating system
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

