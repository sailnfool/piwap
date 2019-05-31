if [ -z "${__verifychange}" ]
then
	export __verifychange=1
	##########
	# This function provides a verification of the requested change
	##########
	function verifychange {
		set -x
		echo "${0##*/}:${LINENO}:RPI_VERBOSE=${RPI_VERBOSE}"
		if [ ${RPI_VERBOSE} -gt 0 ]
		then
			if [ ${RPI_VERBOSE} -gt 1 ]
			then
				set -x
				echo "${0##*/}:${LINENO}"
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
				echo "${0##*/}:${LINENO}"
				set +x
			fi
		fi
	}
	##########
	# end of function verifychange
	##########
fi
