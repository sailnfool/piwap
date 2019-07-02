if [ -z "${__funcpathmunge}" ]
then
	export __funcpathmunge=1
	##########
	# pathmunge - add a directory to $PATH
	# This script came from stackoverflow
	# https://stackoverflow.com/questions/5012958/what-is-the-advantage-of-pathmunge-over-grep
	# 
	# pathmunge <dir> [ after ]
	#
	# The directory <dir> is added before the rest of the directories in 
	# PATH.  The optional argument "after" places the directory after all
	# other directories in PATH.  This script guarantees that links or 
	# symbolic links are decoded via "realpath(1)" and that the specified
	# directory is only placed in PATH one time.
	#
	##########
	function pathmunge() {
		USAGE="${FUNCNAME} <dir> [ after ]"
		if [ -d "$1" ]
		then
		  realpath / 2>&1 >/dev/null && path=$(realpath "$1") || path="$1"
		  # GNU bash, version 2.02.0(1)-release (sparc-sun-solaris2.6) ==> TOTAL incompatibility with [[ test ]]
		  [ -z "$PATH" ] && export PATH="$path:/bin:/usr/bin"
		  # SunOS 5.6 ==> (e)grep option "-q" not implemented !
		  /bin/echo "$PATH" | /bin/egrep -s "(^|:)$path($|:)" >/dev/null || {
		    [ "$2" == "after" ] && export PATH="$PATH:$path" || export PATH="$path:$PATH"
		  }
		else
			errecho ${LINENO} "${USAGE}"
		fi
	##########
	# End of function pathmunge
	##########
	}
fi
