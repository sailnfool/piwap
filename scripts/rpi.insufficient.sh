if [ -z "${__insufficient}" ]
then
	export __insufficient=1
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
fi
