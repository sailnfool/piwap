
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
