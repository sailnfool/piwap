#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2019 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# sourcedate - find date/time/name of newest file in tree
#							 ignore directories and contents of ".ignore" 
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
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
#_____________________________________________________________________
# Rev.	| Auth.	| Date		| Notes
#_____________________________________________________________________
# 2.1	|	REN	|	03/21/2019	| fixed the ignoredir to handle a list
#													| of directories to ignore.
#	2.0	|	REN	|	10/14/2018	| Combined sourcedatetime into one script
#	1.2	|	REN	|	09/06/2018	| Updated prolog
# 1.1	| REN	| 11/18/2017	| Changed SEACS to s2c
# 1.0	| REN	| 08/28/2011	| Initial Release
#_____________________________________________________________________
#
##########
# This script checks the last modified date (and time) of each file
# in a directory tree and extracts the date (and time) of the newest
# file in the hierarchy.
#
# Default behavior is to return the date only
# as a numeric string in the format: "+%Y%m%d" (see the date
# command documentation for an explanation.
#
# the optional parameter -t adds a period followed by the Time in 
# "+%H%M%S" format.
# the optional parameter -o outputs only the time without the date.
# the optional parameter -n Don't suppress directories in the date
#							calculations. Directories are normally suppressed because
#							a clone of a source tree will not have accurate directory
#							timestamps
# the optional parameter -d turns on diagnostics.
# all of the times are emitted in Universal Time (UCT) format.
#	see 'man stat'
#

#source rpi.functions
source func.errecho

USAGE="\r\n${scriptname} [-[hotn]] [ -v <#> ] [ [-i <ignoredir> ] ... ] <dirname>\r\n
\t\treturn the date of the newest file in the tree\r\n
\t\tin the format \"+%Y%m%d\"\r\n
\t\tsee 'man date' for syntax\r\n
\t-h\tPrint this message\r\n
\t-t\tadd a period followd by the time in \"+%H%M%S\" format\r\n
\t-o\treturn only the time stamp of the newest file\r\n
\t-n\tinclude the time stamps of directories\r\n
\t\tdirectory timestamps are ignored because you may be\r\n
\t\tlooking at a clone tree\r\n
\t-f\treport the name of the newest file\r\n
\t-i\t<ignoredir>\tignore everything under <ignoredir>\r\n
\t\tE.G.:\r\n
\t\t${scriptname} -i .ignore .\r\n
\t\t\twill ignore any directories named '.ignore'\r\n
\t\t\tand the files in the directory '.ignore'\r\n
\t\t${scriptname} -i .ignore -i .archive .\r\n
\t\t\twill ignore any directories named '.ignore' or '.archive'\r\n
\t\t\tand the files in the directories '.ignore' or '.archive'\r\n
\t-v\tturn on verbose mode for this script\r\n
\t\tdefault=0 - none, higher integers more verbose\r\n"

optionargs="hotnfd:i:"
NUMARGS=1
RPI_DEBUG="0"
export RPI_DEBUG
nodirs="-not -type d -a"
onlytime="0"
addtime="0"
filetell="0"
datetell="1"
ignoredir=""
ignorelist=".archive"

while getopts ${optionargs} name
do
	case ${name} in
	h) 
#		errecho "-e" ${LINENO} ${USAGE}
		echo -e ${USAGE}
		exit 0
		;;
	o) 
		onlytime=1
		datetell=0
		;;
	t) 
		addtime=1
		datetell=0
		;;
	n) 
		nodirs=""
		;;
	f)
		filetell="1"
		;;
	i)
		ignorelist="${ignorelist} ${OPTARG}"
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
dirname=${@:$OPTIND:1}

##########
# This is where we prune any specified directories from the list
# of directories that should be searched for a project
##########
ignoreprefix="-name "
ignoresuffix="-prune -o"
ignoredir=""
# ignoredir="-name '.ignore' -prune -o"
for i in ${ignorelist}
do
		ignoredir="${ignoredir} ${ignoreprefix} ${i} ${ignoresuffix}"
done
if [ "$RPI_DEBUG" -gt 0 ]
then
	errecho ${LINENO} "${ignoredir}"
fi

# 2018-10-14 10:33:55.990652503 -0700 --./sourcedate.bash
rm -f /tmp/sourcedate.newest.$$*
find ${dirname} ${ignoredir} ${nodirs} -exec stat \{\} --printf="%y --%n\n" \; | sort -n -r | head -1 > /tmp/sourcedate.newest.$$.txt
newestfile=$(sed -e s/.*--// < /tmp/sourcedate.newest.$$.txt)
dateonly=$(sed -e 's/ .*//' -e 's/-//g' < /tmp/sourcedate.newest.$$.txt)
datetime=$(sed -e 's/\..*//' -e 's/ /./' -e 's/-//g' -e 's/://g' < /tmp/sourcedate.newest.$$.txt)
# datetime2=$(sed -e 's/\..*--.*//' -e 's/ /./' -e 's/-//g' -e 's/://g' </tmp/sourcedate.newest.$$.txt)
timeonly=$(sed -e 's/\..*//' -e 's/.* //' -e 's/://g' < /tmp/sourcedate.newest.$$.txt)
if [ "$RPI_DEBUG" -gt 0 ]
then
	ls -l /tmp/sourcedate*$$.txt
	more /tmp/sourcedate*$$.txt
	errecho ${LINENO} "Newest file is ${newestfile}"
	errecho ${LINENO} "Date only is ${dateonly}"
	errecho ${LINENO} "Date time is ${datetime}"
	errecho ${LINENO} "Date2 time is ${datetime2}"
	errecho ${LINENO} "Time only is ${timeonly}"
fi
if [ "${onlytime}" = "1" ]
then
	echo -n ${timeonly} " "
fi
if [ "${addtime}" = "1" ]
then
	echo -n ${datetime}
fi
if [ "${datetell}" = "1" ]
then
	echo -n ${dateonly} " "
fi
if [ "${filetell}" = "1" ]
then
	echo ${newestfile}
else
	echo ""
fi
rm -f /tmp/sourcedate.newest.$$*

# vim: set syntax=bash
