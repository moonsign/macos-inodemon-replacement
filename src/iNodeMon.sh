#!/bin/bash
PIDOFCMD="/usr/bin/pgrep"
AUTHMNGSERVICE="AuthenMngService"
INODEMON="iNodeMon"
MONPROC="iNodeMon"
PSCMD="/bin/ps"
CMDARG="-eopid,command"
CPUARG="-o%cpu -p"
PKILLCMD="/usr/bin/pkill"
THRESHOLD=80
VERBOSE=false
DEBUG=false
LOGFILE="/Library/Logs/iNode/iNodeMon.log"
INTERVAL=60
MYSELF="$$"
DAYOFMONTH=

_start_auth()
{
	IfExist="$(ps -Ac -o command|grep -x ${AUTHMNGSERVICE})"
	if [[ ! -z "${IfExist}" ]]; then
		_log -i "${AUTHMNGSERVICE} was already running"
	else
		_log -i "Starting ${AUTHMNGSERVICE} ..."
		/Applications/iNodeClient/${AUTHMNGSERVICE} >& /dev/null &
	fi
	_get_pid "${AUTHMNGSERVICE}"
	if [[ -z ${pid} ]]; then
		_log -e "Failed to start ${AUTHMNGSERVICE}."
	else
		_log -i "${AUTHMNGSERVICE} started, pid:${pid}."
	fi
}

_chk_uniq(){
	process=$1
	_get_pid "${process}"
	if [[ ! -z "${pid}" ]]; then
		_log -w "Process \"${process}\" already running."
		_exit 1
	fi
}

_kill(){
	process=$1
	_get_pid "${process}"
	if [[ -z "${pid}" ]]; then
		_log -i "${process} is not running."
		return
	fi

	_log -i "Stopping ${process} ..."
	KCMD="${PKILLCMD} ${process}"
	eval "${KCMD}"
	_get_pid "${process}"
	if [[ ! -z "${pid}" ]]; then
		_log -e "Failed to kill ${process}, you can mannually kill by using \"sudo ${KCMD}\""
	else
		_log -i "${process} stopped."
	fi
}

_log(){
	verbose=${VERBOSE}
	case $1 in
		"-e"|"-w"|"-i")
		verbose=true
		if [[ $1 = "-e" ]]; then
			level="[ERROR]"
		elif [[ $1 = "-w" ]]; then
			level="[WARN]"
		elif [[ $1 = "-i" ]]; then
			level="[INFO]"
		fi
		shift 1
		;;
		*)
		level="[PROMPT]"
		;;
	esac

	date="[$(date "+%Y-%m-%d %H:%M:%S")]"
	content="${date} ${level} $@"

	if ${verbose} || ${DEBUG}; then
		if ${DEBUG}; then
			echo -e "${content}"
		else
			echo -e "${content}" | tee -a "${LOGFILE}"
		fi
	fi
}

# _get_script_pid(){
# 	mepid="${MYSELF}"
# 	mecmd="$(basename $1)"
# 	echo ${mepid} ${mecmd}
# 	echo "==="
# 	pidstr=`${PSCMD} ${CMDARG} | egrep -o "[0-9][0-9]*.*(bash|sh).*${mecmd}" | grep -v "${mepid}" | grep -v "$$"`
# 	echo "====${pidstr}"
# 	pid="$(echo "${pidstr}" | awk -v mecmd="${mecmd}" '{pid=$1;split($2,b,"/");sh=b[length(b)];split($NF,a,"/"); me=a[length(a)];print pid,sh,me; if(sh ~ /bash|sh/ && me == mecmd){print pid}}')"
# 	echo "${pid}"
# }

_get_pid(){
	process=$1
	# if [[ "${process}" =~ ^.*\.sh$ ]]; then
	# 	_get_script_pid "${process}"
	# 	return
	# fi
	me="${MYSELF}"
	pid="$(${PIDOFCMD} ${process} | grep -v "${me}")"
}

_get_cpu(){
	cpu_usage="$(${PSCMD} ${CPUARG} ${pid}|\grep -o "[0-9.][0-9.]*")"
	if [[ -z ${cpu_usage} ]]; then
		_log -e "Failed to get CPU usage of ${pid}."
	else
		_log "CPU usage of ${AUTHMNGSERVICE}: ${cpu_usage}%"
	fi
}

_bak_log(){
	today="$(date +"%d")"
	if [[ ! -z "${DAYOFMONTH}" && "${DAYOFMONTH}" != "${today}" ]]; then
		if [[ -f "${LOGFILE}" ]]; then
			mv -f "${LOGFILE}" "${LOGFILE/%.log/.old}"
		fi
	fi
	DAYOFMONTH="${today}"
}

_exit(){
	exit $1
}

#main begin
logdir="$(dirname "${LOGFILE}")"
if [[ ! -d "${logdir}" ]]; then
	mkdir -p "${logdir}"
fi

while [[ $1 ]]; do
	VERBOSE=true
	case $1 in
		"-v")
		shift 1
		;;
		"-d")
		DEBUG=true
		INTERVAL=2
		shift 1
		;;
		"-k")
		_kill "${INODEMON}"
		_exit 0
		;;
		*)
		_log -e "Unsupported argument \"$1\", exit."
		_exit 1
		;;
	esac
done

_chk_uniq "${INODEMON}"
_log -i "${INODEMON} is in service."
while true; do
	_bak_log
	_get_pid "${AUTHMNGSERVICE}"
	if [[ -z "${pid}" ]]; then
		_log -i "${AUTHMNGSERVICE} is not running."
		_start_auth
	else
		_get_cpu
		if [[ ! -z "${cpu_usage}" ]]; then
			if [[ $(echo "${cpu_usage} >= ${THRESHOLD}"| bc) -eq 1 ]]; then
				_log -w "CPU usage of ${AUTHMNGSERVICE} is ${cpu_usage}%, overload."
				_kill "${AUTHMNGSERVICE}"
				_start_auth
			fi
		fi
	fi
	if ${DEBUG}; then
		_log "Sleep for ${INTERVAL} secs."
	fi
	sleep ${INTERVAL}
done

_exit 0
