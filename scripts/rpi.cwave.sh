if [ -z "$__cwave" ]
then
	export __cwave=1
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
fi
