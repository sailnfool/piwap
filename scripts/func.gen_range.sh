if [ -z "${__gen_range}" ]
then
	export __gen_range=1
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
fi
