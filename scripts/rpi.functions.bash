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
#_____________________________________________________________________
# Rev.|Auth.| Date       | Notes
# 1.6 | REN | 04/10/2019 | Stripped out functions not used in Raspberry
#                        | Pi uses, renamed to pi.functions
#                        | used __pifunctions to prevent duplicate
#                        | 'source' inclusions.  Changed STC_VERBOSE to
#                        | RPI_VERBOSE
# 1.5 | REN | 03/10/2019 | Incorporated ren.functions and uos.functions
# 1.4 | REN | 03/05/2019 | eliminated errvecho, incorporated stc.conf
# 1.3 | REN | 03/04/2019 | Fixed errvecho to be STC_VERBOSE triggered
# 1.2 | REN | 02/28/2019 | Added getprojdir to find the directory
#                        | under which a project is located.
# 1.1 | REN | 02/27/2019 | Added onefilereformat that will process
#                        | an asciidoc file (.adoc) to insure that
#                        | lines are not excessively long and that
#                        | sentences begin on a new line.
# 1.0 | REN | 10/02/2018 | Initial Release
#_____________________________________________________________________

##########
# The overall objective of this source is to be obvious for reasons
# of maintenance.  There may be shorter ways to accomplish the same
# functions with fewer characters.  Suggested implementations with
# thorough testing and documentation are welcome.
##########

##########
# Make sure we are only sourced once
##########
if [ -z "${__pifunctions}" ]
then
	__pifunctions=1
	export __pifunctions
	##########
	# This function is invoked as in the example below:
	# errecho $LINENO "some error message " "with more text"
	# the LINENO has to be on the invoking line to get the correct
	# line number from the point of invocation
	# The output is only generated if the gloval variable $RPI_VERBOSE
	# is defined and greater than 0
	##########
	function errecho {>&2
		scriptname=${0##*/}
		processbackslash=""
		if [ $1 = "-e" ]
		then
			processbackslash="-e"
			shift
		fi
		line=$1
		shift
		RPI_VERBOSE=${RPI_VERBOSE:-1}
		if [ ${RPI_VERBOSE} -gt 0 ]
		then
			if [ "$1" = "-e" ]
			then
				stdbuf -o 0 -e 0 /bin/echo "${processbackslash} ${scriptname}:${line}: \r\n"$@
			else
				stdbuf -o 0 -e 0 /bin/echo "${processbackslash}" ${scriptname}:${line}: $@
			fi
		fi
	} 
	##########
	# End of function errecho
	##########

	##########
	# This function is used to warn of insufficient parameters passed
	# to a function.
	# insufficient $LINENO <funcname> <#>
	##########
	function insufficient() {
		lineno="$1"
		funcname="$2"
		numparms="$3"
		shift; shift; shift;
		errecho "${lineno} $funcname: Insufficient parameters $@, need ${numparms}"
		exit -1
	}

	##########
	# This function is used to warn that the nth parameter to a function
	# is null rather than containing an expected value.
	# nullparm $LINENO <funcname> <#>
	##########
	function nullparm {
		lineno="$1"
		funcname="$2"
		parmnum="$3"
		errecho "${lineno}: ${funcname}: Parameter #${parmnum} is null"
		exit -1
	}
	source func.pathmunge
	
	##################
	# The following are the environment variables created/modified
	##################
	#	rpibindir=/usr/local/rpi/bin
	#	rpitmp=/tmp/rpi
	#	rpifix="fix.sh"
	#	rpidebugtxt="debug.txt"
	##################
	# Set the BIN environment variable
	##################
	rpidir=${rpidir:-"/usr/var/rpi"}
	rpibindir=${rpibindir:-"${rpidir}/bin"}
	export rpidir rpibindir
	sudo mkdir -p ${rpidir} ${rpibindir}
	
	##################
	# add the rpibindir to $PATH
	##################
	fgrep -q "pathmunge ${rpibindir} after" $HOME/.bashrc
	if [ $? -eq 1 ]
	then
		echo pathmunge ${rpibindir} after >> $HOME/.bashrc
	fi
	source $HOME/.bashrc
	##################
	# This is the directory where rpi commands will put 
	# temporary or diagnostic information.
	##################
	if [ -z "${rpitmp}" ]
	then
		rpitmp=/tmp/rpi
	fi
	export rpitmp
	mkdir -p ${rpitmp}
	
	##################
	# The general usage of these next two variables is to use
	# them as suffixes for the files produced by an executing
	# command.  The files are usually placed in rpitmp and
	# the command name is a prefix to the suffix.  There may
	# be other reasons to use the process ID (AKA $$) as part
	# of the name to avoid conflicts between multiple instances
	# of the utilities running on a single machine.
	##################
	# This is the suffix for scripts generated by rpi utilities
	# Generally these utilities will unwind the actions of the 
	# parent script that ran the command - hence the "fix" in
	# the name
	##################
	rpifix=${rpifix:-"fix.sh"}
	export rpifix
	##################
	# This is the suffix for any debug or diagnostic information
	# generated by an rpi utility
	##################
	rpidebugtxt=${rpidebugtxt:-"debug.txt"}
	export rpidebugtxt
	
	
	##########
	# The following functions (see list) are used by the "cwave"
	# macro/functions to trace the entry and exit from nested scripts
	# to show the indentation.  The same mechanisms are used in 
	# my C Language programs.  Cwave is the chosen name to illustrate 
	# that the pattern of nested calls generated dynamically during
	# execution resembles a wave on the water.
	# stderrecho
	# stderrnecho
	# errindentdir
	# indentdir
	##########
	##########
	# Send diagnostic output to stderr with a newline
	##########
	function stderrecho {>&2 echo $@;}
	
	##########
	# Send diagnostic output to stderr without a newline
	##########
	function stderrnecho {>&2 echo -n $@;}
	
	##########
	# Send N indented space ($1) then print a directory name ($2)
	# to stderr
	##########
	function errindentdir () {
		stderrecho ""
		xx=$(printf "%$1c%s" " " $2)
		stderrnecho $xx
	}
	
	##########
	# Send N indented space ($1) then print a directory name ($2)
	##########
	function indentdir () {
		echo ""
		xx=$(printf "%$1c%s" " " $2)
		echo -n $xx
	}
	##########
	# End of cwave functions
	##########
	
	##########
	# gen_range - generate a range of integers
	#
	# Since it is impossible to simply evaluate variables within a
	# range expression expansion, I wrote this function to generate
	# the integer numbers in a range.  If either the lower bound or
	# the upper bound are not numbers, a value of zero is substituted
	# for the # positional parameter
	# instead of: "for i in {${low}..${high}}"
	# use:        "for i in $(gen_range ${low} ${high})"
	#
	# See:
	# https://unix.stackexchange.com/questions/340440/bash-test-what-does-do
	##########
	gen_range ()
	{
	re='^[0-9]+$'
	if [ $# -ge 2 ]
		then
			lower=$1
			upper=$2
			if [ ! "${lower}" =~ $re ]
			then
				lower=0
			fi
			if [ ! "${upper}" =~ $re ]
			then
				upper=0
			fi
			i=${lower}
			while [ $i -le ${upper} ]
			do
				echo "$i"
				i=$[$i+1]
			done
		fi
	}
	##########
	# This function reformats a single file to wrap lines and make
	# sure that sentences start after a newline character
	# 
	# This is useful for maintaining asciidoc files.
	#
	# onfilereformat <file> <sourcedir> <targetdir>
	#
	# A rewrite of this would use the syntax of:
	#	onefilereformat <sourcedir>/<file> <targetdir>
	##########
	function onefilereformat() {
		numparms=3
		sourcefile="$1"
		sourcedir="$2"
		destdir="$3"
		scriptname=${0##*/}
		if [ $# -lt ${numparms} ]
		then
			insufficient ${LINENO} ${FUNCNAME} ${numparms} $@
		fi
		if [ -z "${sourcefile}" ]
		then
			nullparm ${LINENO} ${FUNCNAME} "1"
		fi
		if [ -z "${sourcedir}" ]
		then
			nullparm ${LINENO} ${FUNCNAME} "2"
		fi
		if [ -z "${destdir}" ]
		then
			nullparm ${LINENO} ${FUNCNAME} "3"
		fi
	
		if [ ! -d ${destdir} ]
		then
			mkdir -p ${destdir}
		fi
		if [ ! -d ${sourcedir} ]
		then
			errecho ${LINENO} "${FUNCNAME}: Source ${sourcedir} directory not present"
			exit -1
		fi
		if [  ! -f ${sourcedir}/${sourcefile} ]
		then
			errecho ${LINENO} "${FUNCNAME}: Source file ${sourecedir}/${souecefile} file not present"
			exit -1
		fi
		cp ${sourcedir}/${sourcefile} /tmp/${sourcefile}$$
	
		##########
		# in case the source file did not include a \n at the end of the 
		# file we do this to avoid having "fmt" or asciidoctor-pdf throw
		# an error message.
		##########
		echo "" >> /tmp/${sourcefile}$$
	
		##########
		# We tell "fmt" to generate "standard output which includes
		# two spaces after a sentence.  When we find a "." or "?" followed
		# by two spaces, we replace that with a \r\n to insure that any
		# new sentences start on a new line.  Then we do a cleanup since
		# text copied from email messages sometimes have a \r but no \n
		# so we detect those instances and fix them.  We also delete
		# spaces that may occur at the end of a line.
		##########
	
		fmt -s -u /tmp/${sourcefile}$$ | \
			sed -e 's/\([\.\?]\)[ ]{2,2}/\1\r\n/g' \
				-e 's/\r[^\n]/\r\n/' \
				-e 's/\r\n/\n/g'  \
				-e 's/ \n/\n/g' \
				-e 's/ \r/\r/g' > ${destdir}/${sourcefile}
	#			tr -d '\r' > ${destdir}/${sourcefile}
		rm /tmp/${sourcefile}$$
	}
	##########
	# This function returns the parent directory of a project within the 
	# "projectbase" tree
	##########
	function getprojdir() {
		numparms=2
		project="$1"
		projectbase="$2"
		if [ $# -lt ${numparms} ]
		then
			insufficient ${LINENO} ${FUNCNAME} ${numparms} $@
			exit -1
		fi
		if [ -z ${project} ]
		then
			nullparm ${LINENO} ${FUNCNAME} "1"
		fi
		if [ -z ${projectbase} ]
		then
			nullparm ${LINENO} ${FUNCNAME} "2"
			exit -1
		fi
		if [ ! -d ${projectbase} ]
		then
			nullparm ${LINENO} ${FUNCNAME} "3"
			exit -1
		fi
		$(find ${projectbase} \( -name ${project} -a type d \) -a -print | sed -e "/\.archive/d")
	}

	##########
	# end of getprojdir
	##########

	##########
	# This function provides a verification of the requested change
	##########
	function verifychange {
		set -x
		echo "${scriptname}:${LINENO}:RPI_VERBOSE=${RPI_VERBOSE}"
		if [ ${RPI_VERBOSE} -gt 0 ]
		then
			if [ ${RPI_VERBOSE} -gt 1 ]
			then
				set -x
				echo "${scriptname}:${LINENO}"
			fi
			numparms=4
			if [ $# -lt ${numparms} ]
			then
				insufficient ${FUNCNAME} $LINENO ${FUNCNAME} ${numparms}
			fi
			changename=$1
			if [ "${changename}" = "" ]
			then
				nullparm ${FUNCNAME} ${LINENO} 1
			fi
			origfile=$2
			if [ "${origfile}" = "" ]
			then
				nullparm ${FUNCNAME} ${LINENO} 1
			fi
			destfile=$3
			if [ "${destfile}" = "" ]
			then
				nullparm ${FUNCNAME} ${LINENO} 1
			fi
			sequence=$4
			if [ "${sequence}" = "" ]
			then
				nullparm ${FUNCNAME} ${LINENO} 1
			fi
		
			echo "Verify ${changename}" | tee /tmp/${sequence}.${changename}.$$.debug.txt
			ls -l ${origfile} ${destfile} | tee -a /tmp/${sequence}.${changename}.$$.debug.txt
			diff -s ${origfile} ${destfile} | tee -a /tmp/${sequence}.${changename}.$$.debug.txt
			if [ ${RPI_VERBOSE} -gt 1 ]
			then
				echo "${scriptname}:${LINENO}"
				set +x
			fi
		fi
	}
	##########
	# end of function verifychange
	##########

	##########
	# This bit of magic allows us to process filenames with blanks in them
	##########
	# SAVEIFS=$IFS
	# IFS=$(echo -en "\n\b")
	
fi

# vim: set syntax=bash
