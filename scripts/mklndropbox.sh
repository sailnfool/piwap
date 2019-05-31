#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2019 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#
# This is a human-readable summary of (and not a substitute for) the license. Disclaimer.
# You are free to:
# Share — copy and redistribute the material in any medium or format
# Adapt — remix, transform, and build upon the material
# for any purpose, even commercially.
# 
# The licensor cannot revoke these freedoms as long as you follow
# the license terms.
# 
# Under the following terms:
# Attribution — You must give appropriate credit, provide a link to
# the license, and indicate if changes were made. You may do so in
# any reasonable manner, but not in any way that suggests the licensor
# endorses you or your use.
# 
# No additional restrictions — You may not apply legal terms or
# technological measures that legally restrict others from doing
# anything the license permits.
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
#
# mklndropbox - link each of the text files in the directory to a name
#               prefixed by the current date and time of the most recent
#               timestamp for the directory
#_____________________________________________________________________
# Rev.|Auth.| Date       | Notes
#_____________________________________________________________________
# 1.0 | REN | 04/12/2019 | Initial Release
#_____________________________________________________________________
#

source rpi.functions

USAGE="\r\n${scriptname} [-[hn]] [ -v <#> ] [-i <ignoredir> ] ... ] <dirname>\r\n
\t\tlinks each of the text files in the directory to a name prefixed\r\n
\t\tby the current date and time of the most recent timestamp for\r\n
\t\tthe directory.  This is a poor man's replacement for lack of\r\n
\t\tdropbox support on Raspbian\r\n
\t\tin the format \"+%Y%m%d.%H%M%S\"\r\n
\t\tsee 'man date' for syntax\r\n
\t-h\tPrint this message\r\n
\t-v\tturn on verbose mode for this script\r\n
\t\tdefault=0 - none, higher integers more verbose\r\n"

optionargs="hnfv:i:"
NUMARGS=1
RPI_DEBUG="0"
export RPI_DEBUG

while getopts ${optionargs} name
do
	case ${name} in
	h) 
#		errecho "-e" ${LINENO} ${USAGE}
		echo -e ${USAGE}
		exit 0
		;;
	d) 
		RPI_DEBUG=${OPTARG}
		export RPI_DEBUG
		;;
	\?)
		errecho "-e" ${LINENO} "invalid option: -$OPTARG"
		errecho "-e" ${LINENO} ${USAGE}
		exit 0
		;;
	esac
done

if [ $# -lt ${NUMARGS} ]
then
	errecho ${LINENO} "Insufficient Parameters: ${NUMARGS} required, $# supplied"
	errecho "-e" ${LINENO} ${USAGE}
	exit -2
fi
dirname=${@:${OPTIND}:1}

# 2018-10-14 10:33:55.990652503 -0700 --./sourcedate.bash
rm -f /tmp/sourcedate.newest.$$*
timestamp=$(sourcedate -t ${dirname})
for filename in $(find ${dirname} -type f -exec file {} ';'| fgrep text | sed "s/:.*//")
do
	filename2=$(basename ${filename})
	echo ln ${filename2} ${timestamp}.${filename2}
	ln ${filename2} ${timestamp}.${filename2}
done
