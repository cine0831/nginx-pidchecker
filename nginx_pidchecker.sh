#!/bin/bash
# -*-Shell-script-*-
#
#/**
# * Title    : nginx process id checker
# * Auther   : Alex, Lee
# * Created  : 07-16-2017
# * Modified : 10-16-2018
# * E-mail   : cine0831@gmail.com
#**/
#
#set -e
#set -x

_NGINX_PROC=$(ls -al /proc/$(ps aux | grep nginx | grep 'master pro' | grep root | egrep -v 'nobody|grep|bash|log|py' | awk '{print $2}') | grep 'exe' | awk 'NF>1{print $NF}')
_NGINX_HOME=$(echo $_NGINX_PROC | sed -e 's/\/sbin\/nginx//g')
_NGINX_LOG_FILE="${_NGINX_HOME}/logs"
_NGINX_PID_FILE="${_NGINX_LOG_FILE}/nginx.pid"
_NGINX_PS=$(ps -ef | grep nginx | grep 'master process' | grep root | egrep -v 'nobody|grep|bash|log|py' | awk '{if ($3 == 1) print $2'})

# log file checking
_LOG_HOME="/usr/local/nginx_pidchecker/logs"
_LOG_FILE="$_LOG_HOME/pid_checker.log-$(date '+%Y%m%d')"

if [ ! -d $_LOG_HOME ]; then
    mkdir -p $_LOG_HOME
fi

if [ ! -f $_LOG_FILE ]; then
    touch $_LOG_FILE 
    chmod 600 $_LOG_FILE 2>&1 | tee -a $_LOG_FILE
    chown root.root $_LOG_FILE 2>&1 | tee -a $_LOG_FILE
fi

# NGINX가 구동중일 때만 pid 비교 및 생성
if [ $_NGINX_PROC != "execdomains" ] || [ $_NGINX_PS ]; then
    echo -e "\n"
    echo -e "=================================================================" 2>&1 | tee -a $_LOG_FILE
    echo -e "= $(date '+%Y-%m-%d %R')                                              =" 2>&1 | tee -a $_LOG_FILE
    echo -e "=================================================================" 2>&1 | tee -a $_LOG_FILE

    # getting nginx pid from file
    if [ -s ${_NGINX_PID_FILE} ]; then
        _NGINX_PID=`cat $_NGINX_PID_FILE`
        if [ ! -n $_NGINX_PID ]; then
            _NGINX_PID=0
        fi
    else
        touch ${_NGINX_PID_FILE}
        _NGINX_PID=0
    fi

    # compare pid between nginx pid file and getting ps process
    if [ ! $_NGINX_PS -eq $_NGINX_PID ]; then
        echo -e "${_NGINX_PS}" > ${_NGINX_PID_FILE}
        echo -e "PS pid add to nginx.pid file." 2>&1 | tee -a $_LOG_FILE
    else
        echo -e "A pid already exists." 2>&1 | tee -a $_LOG_FILE
    fi
    echo -e "=================================================================" 2>&1 | tee -a $_LOG_FILE
fi
