if [ -z "${__stderrecho}" ]
then
	export __stderrecho=1
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
	
fi
