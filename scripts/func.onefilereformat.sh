if [ -z "${__onefilereformat}" ]
then
	export __onefilereformat=1
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
#		scriptname=${0##*/}
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
fi

