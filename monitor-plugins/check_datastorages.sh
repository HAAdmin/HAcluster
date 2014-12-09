#!/bin/sh
# --
# Check NKSCE's datastores usage.
#
# @author: Cai Liuqing <liuqing.cai@cs2c.com.cn>
# @version: 0.1
# @date: Tue 10 28 2014
# --


# --------------------------------------------------------------------
# functions
# --------------------------------------------------------------------

function usage() {
	echo "Usage:"

}

function print_help() {
	echo ""
	usage
	echo ""
}


# --------------------------------------------------------------------
# startup checks
# --------------------------------------------------------------------
if [ $# -eq 0 ];then
	usage
	exit $STATE_CRITICAL 
fi

while getopts "p:w:c:h" OPT;
do
	case "$OPT" in
		"h") print_help; exit $STATE_OK;;
		"p") PATH=$OPTARG;;
		"w") WARNING=$OPTARG;;
		"c") CRITICAL=$OPTARG;;
		*) usage; exit $STATE_UNKNOWN;;
	esac
done

if [ "$WARNING" -ge "$CRITICAL" ];then
	echo "Warning must be less than crirical. Please change arguments."
	exit
fi

if [ ! -d ${PATH} ];then
	echo "service_datastores_warn_no_exist#${PATH}"
	exit $STATE_WARN
fi

# get the Max
function getMax(){
	arr=$1
	len=${#arr[@]}
	for (( i=1; i<=len-1; i++ ))
	do
		for (( j=0;j<=len-i;j++ ))
		do
			if [[ ${arr[j]} < ${arr[j+1]} ]]
			then
				t=${arr[j]}
				arr[j]=${arr[j+1]}
				arr[j+1]=$t
			fi
		done
	done
	return arr[0]
}
#name=($(/bin/df -h | /bin/grep "${usages[0]}% $PATH" | /bin/awk '{print $1}'))
#if [ "${usages[0]}" -ge "$CRITICAL" ];then
#	echo "service_datastores_critical#$name,${usages[0]}"
#elif [ "${usages[0]}" -ge "$WARNING" ];then
#	echo "service_datastores_warnint#$name,${usages[0]}"
#fi

# get localstores' usage
#datastores=($(/bin/ls $PATH))
#len=${#datastroes[@]}
#for ds in ${datastores[@]}
#do
#	echo $ds
	
#done


# get / 's usage
`/bin/cat /dev/null >./check_datastores_Nlocal_size.out`
`/bin/cat /dev/null >./check_datastores_size.out`
`/bin/cat /dev/null >./check_datastores.out`
us=($(/bin/df -h / | /bin/sed '1d' | /bin/awk '{print $5}' | /bin/cut -d "%" -f1))
if [ "$us" -ge "$WARNING" ];then
	# get all datastores' name
	file=($(/bin/ls $PATH))
	for f1 in ${file[@]}
	do
        echo $PATH$f1
	    #echo `/bin/df -h | /bin/awk 'BEGIN {if ("$6"=="$PATH$f1") fi} END {print $0}' | /bin/awk '{print $1 " " $5 }'`
	    #echo `df -h | awk 'BEGIN {if ("$6"=="$PATH$f1") fi} END {print $0}' | awk '{print $1 " " $5 }'` >> ./check_datastores_Nlocal_size.out
		echo `/usr/bin/du $PATH$f1 | /usr/bin/tail -1 | /bin/awk '{print $1 " " $2}'` >> ./check_datastores_size.out
		echo `/usr/bin/du -h $PATH$f1 | /usr/bin/tail -1 | /bin/awk '{print $1 " " $2}'` >> ./check_datastores.out
			#sizeH$i=(/usr/bin/du -h $PATH$f1 | /usr/bin/tail -1 | /bin/awk '{print $1}')
			#name$i=(/usr/bin/du -h $PATH$f1 | /usr/bin/tail -1 | /bin/awk '{print $2}')
	done
	MaxSize=`/bin/cat ./check_datastores_size.out| /bin/awk 'BEGIN {max = 0} {if ($1>max) max=$1 fi} END {print $2 "#" max}'`
	#echo $MaxSize
	#echo "service_datastores_warnint#"/",$us"
elif [ "${us[0]}" -ge "$CRITICAL" ];then
	echo "service_datastores_critical#"/",${us[0]}"
fi

#`/bin/rm -f ./check_datastores_size.out`
#`/bin/rm -f ./check_datastores.out`
