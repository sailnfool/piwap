#! /bin/bash
if [ -z "${__errecho_sh}" ]
then
	export __errecho_sh=1
	##########
	# This function is invoked as in the example below:
	# errecho $LINENO "some error message " "with more text"
	# the LINENO has to be on the invoking line to get the correct
	# line number from the point of invocation
	# The output is only generated if the gloval variable $RPI_VERBOSE
	# is defined and greater than 0
	##########
	function errecho {>&2
		# scriptname=${0##*/}
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
				stdbuf -o 0 -e 0 /bin/echo "${processbackslash} ${0##*/}:${line}: \r\n"$@
			else
				stdbuf -o 0 -e 0 /bin/echo "${processbackslash}" ${0##*/}:${line}: $@
			fi
		fi
	} 
	##########
	# End of function errecho
	##########
fi
