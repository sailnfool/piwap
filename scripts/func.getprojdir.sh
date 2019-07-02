if [ -z "${__getprojdir}" ]
then
	export __getprojdir=1
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
fi
