#!/bin/sh

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
col=80

BASEDIR=$(dirname $0)
NUM_OF_KILO_CALLS=10
NUM_OF_USERS=10
NUM_OF_CALLS=$((NUM_OF_KILO_CALLS*1000))
URL=http://localhost:8080/
 
function mvn_build_project {
	local __project_dir=${1:-"$BASEDIR/projects/helloworld-rest-spring-boot"}
	mvn -q -f ${__project_dir}/pom.xml clean package -DskipTests

}

function start_spring_app {
	 local __app_path=${1:-"$BASEDIR/projects/helloworld-rest-spring-boot/target/helloworld-rs-0.1.0.jar"}
	 local __max_memory=${2:-"1g"}
	 java -Xmx${__max_memory} -Xms64m -jar $__app_path > $BASEDIR/spring.log &
}

function open_jconsole {
	local __app_name=${1:-"helloworld-rs"}
	jconsole $(ps -ef | grep ${__app_name} | grep -v grep | awk '{ print $2 }') > /dev/null &
}

printf "Building the project"
mvn_build_project
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"

printf "Waiting for Spring Boot to start."
start_spring_app
until $(curl -s $URL > /dev/null 2>&1) 
do
	printf "."
	sleep 1
done
printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"


open_jconsole

echo "Warmup"
ab -k -n $NUM_OF_KILO_CALLS -c $NUM_OF_USERS -s 120 $URL > warmup.txt

sleep 10

echo "Start performance test"
ab -k -n $NUM_OF_CALLS -c $NUM_OF_USERS -s 120 $URL > performance.txt

sleep 30

kill $(ps -ef | grep helloworld-rs | grep -v grep | awk '{ print $2 }') > /dev/null
