#!/usr/bin/env bash
#该脚本为Linux下启动java程序的通用脚本。即可以作为开机自启动service脚本被调用，
#也可以作为启动java程序的独立脚本来使用。
#
#
###################################
#参数说明
#$1：操作标示，可选的值有：start, stop, status, info等
#$2：端口
#$3：日志目录
###################################
#环境变量及程序执行参数
#需要根据实际环境以及Java程序名称来修改这些参数
###################################
#JDK所在路径
JAVA_HOME=/usr/local/jdk1.8.0_111

#日志目录
APP_LOG_DIR=/opt/scheduleJoblogs
 
#执行程序启动所使用的系统用户，考虑到安全，推荐不使用root帐号
RUNNING_USER=root

#应用名称
APP_NAME="scheduleJob"
 
#应用所在的目录
export APP_HOME=$(cd `dirname $0`; cd ../; pwd)
 
#需要启动的Java主程序（main方法类）
APP_MAIN_CLASS=wonder.App

#java虚拟机启动参数
JAVA_OPTS="-server -Xms1024M -Xmx2048M -Duser.timezone=Asia/Shanghai -XX:+DisableExplicitGC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${APP_HOME}"

OVERRIDE_LOG_DIR=$3
LOG_DIR=${APP_HOME}/logs
CONF_DIR=${APP_HOME}/conf
WORK_DIR=${APP_HOME}/work
PID_FILE=${WORK_DIR}/scheduleJob.pid
START_WAIT_TIMEOUT=60

 
#拼凑完整的classpath参数，包括指定lib目录下所有的jar
CLASSPATH=${CONF_DIR}
for i in "$APP_HOME"/lib/*.jar;do
   CLASSPATH="$CLASSPATH":"$i"
done
 
#端口，如果有传入端口，则使用传入的端口
PORT=$2
if [ ${#PORT} -le 2 ]; then
	PORT=9012
fi
SERVER_PORT="-Dserver.port=${PORT}"

#日志目录，如果有传入，则使用传入的日志目录
if [ ${#OVERRIDE_LOG_DIR} -gt 4 ]; then
	APP_LOG_DIR=$OVERRIDE_LOG_DIR
fi

 
###################################
#(函数)判断程序是否已启动
###################################
#初始化psid变量（全局）
psid=0
 
checkpid() {
   if [ -f "${PID_FILE}" ];then
      psid=`cat ${PID_FILE}`
      kill -0 ${psid} 2>/dev/null
      if [ $? == 1 ];then
      	rm -rf ${PID_FILE}
      	psid=0
      fi
   else
      psid=0
   fi
}

is_started() {
	netstat -ntpl|grep ${PORT} > /dev/null
	echo "$?"
}
 
###################################
#(函数)启动程序
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则提示程序已启动
#3. 如果程序没有被启动，则执行启动命令行
#4. 启动命令执行后，再次调用checkpid函数
#5. 如果步骤4的结果能够确认程序的pid,则打印[OK]，否则打印[Failed]
#注意：echo -n 表示打印字符后，不换行
#注意: "nohup 某命令 >/dev/null 2>&1 &" 的用法
###################################
start() {
   checkpid
 
   if [ ${psid} -ne 0 ];then
      echo "================================"
      echo "warn: $APP_NAME already started! (pid=$psid)"
      echo "================================"
   else
      echo -n "Starting $APP_MAIN_CLASS ..."
      JAVA_CMD="nohup $JAVA_HOME/bin/java ${SERVER_PORT} -DAPP_LOG_DIR=${APP_LOG_DIR} -DAPP_HOME=${APP_HOME} $JAVA_OPTS -cp $CLASSPATH $APP_MAIN_CLASS >${LOG_DIR}/server.log 2>&1 &"
      echo $JAVA_CMD
      su - ${RUNNING_USER} -c "$JAVA_CMD"
      starttime=0
      while  [ "`is_started`" == "1" ]; do
         if [[ "$starttime" -lt ${START_WAIT_TIMEOUT} ]]; then
            sleep 1
            ((starttime++))
            tail -n 10 ${APP_LOG_DIR}/trade.log
         else
            echo "$APP_NAME failed to start"
            echo "The $APP_NAME doesn't start in ${START_WAIT_TIMEOUT} seconds!"
            echo "check ${LOG_DIR}/server.log or ${APP_LOG_DIR}/trade.log to see the details"
            exit -1
         fi
      done
	  echo ""
	  echo "Starting $APP_MAIN_CLASS OK ... in ${starttime} seconds"
   fi
}
 
###################################
#(函数)强制停止程序
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则开始执行停止，否则，提示程序未运行
#3. 使用kill -9 pid命令进行强制杀死进程
#4. 执行kill命令行紧接其后，马上查看上一句命令的返回值: $?
#5. 如果步骤4的结果$?等于0,则打印[OK]，否则打印[Failed]
#6. 为了防止java程序被启动多次，这里增加反复检查进程，反复杀死的处理（递归调用stop）。
#注意：echo -n 表示打印字符后，不换行
#注意: 在shell编程中，"$?" 表示上一句命令或者一个函数的返回值
###################################
killapp() {
   checkpid
 
   if [ ${psid} -ne 0 ];then
      echo -n "Stopping $APP_NAME ...(pid=$psid) "
      su - ${RUNNING_USER} -c "kill -9 $psid"
      if [ $? -eq 0 ];then
      	 rm -rf ${PID_FILE}
         echo "[OK]"
      else
         echo "[Failed]"
      fi
 
      checkpid
      if [ ${psid} -ne 0 ];then
         killapp
      fi
   else
      echo "================================"
      echo "warn: $APP_NAME is not running"
      echo "================================"
   fi
}

#正常停止程序
stop() {
   checkpid
 
   if [ ${psid} -ne 0 ];then
      echo "Stopping $APP_NAME ...(pid=$psid) "
      kill `cat ${PID_FILE}`
   else
      echo "================================"
      echo "warn: $APP_NAME is not running"
      echo "================================"
   fi
}

###################################
#(函数)检查程序运行状态
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则提示正在运行并表示出pid
#3. 否则，提示程序未运行
###################################
status() {
   checkpid
 
   if [ ${psid} -ne 0 ]; then
      echo "$APP_NAME is running! (pid=$psid)"
   else
      echo "$APP_NAME is not running"
   fi
}
 
###################################
#(函数)打印系统环境参数
###################################
info() {
   echo "System Information:"
   echo "****************************"
   echo 'head -n 1 /etc/issue'
   echo 'uname -a'
   echo
   echo "JAVA_HOME=$JAVA_HOME"
   echo '$JAVA_HOME/bin/java -version'
   echo
   echo "APP_HOME=$APP_HOME"
   echo "APP_MAINCLASS=$APP_MAIN_CLASS"
   echo "****************************"
}
 
###################################
#读取脚本的第一个参数($1)，进行判断
#参数取值范围：{start|stop|restart|status|info}
#如参数不在指定范围之内，则打印帮助信息
###################################
case "$1" in
   'start')
      start
      ;;
   'stop')
     stop
     ;;
   'killapp')
     killapp
     ;;
   'restart')
     stop
     start
     ;;
   'status')
     status
     ;;
   'info')
     info
     ;;
  *)
     echo "Usage: $0 {start|stop|killapp|restart|status|info}"
     exit 1
esac

