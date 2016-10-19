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
	mvn -q -f ${__project_dir}/pom.xml -DskipTests clean package

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

function run_springboot {
	printf "Building the project"
	mvn_build_project $BASEDIR/projects/helloworld-rest-spring-boot
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
}

function install_eap {
  if [ ! -d $BASEDIR/target ]
  then 
    mkdir -p target
    unzip -q $BASEDIR/installs/jboss-eap-7.0.2-full-build.zip -d target
    pushd target/jboss-eap-7* > /dev/null
    sh bin/add-user.sh -s -u admin -p admin-123
    popd > /dev/null
  fi
}

function start_eap {
  pushd target/jboss-eap-7* > /dev/null
  sh bin/standalone.sh > /dev/null 2>&1 & 
  printf "Start JBoss EAP."
  until $(curl -s $URL > /dev/null 2>&1) 
	do
		printf "."
		sleep 1
	done
  printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"
  popd > /dev/null
}

function deploy_war {
	local __warfile=${1:-"$BASEDIR/projects/helloworld-rest-war/target/helloworld-rs-0.1.0.war"}
  local __fullpath_warfile="$(cd $(dirname $__warfile) && pwd)/$(basename $__warfile)"
	pushd target/jboss-eap-7* > /dev/null
  bin/jboss-cli.sh -c --command="deploy $__fullpath_warfile"
  popd
}

function run_eap {
  mvn_build_project $BASEDIR/projects/helloworld-rest-war
  install_eap
  start_eap
  open_jconsole jboss-eap
  deploy_war $BASEDIR/projects/helloworld-rest-war/target/helloworld-rs-0.1.0.war

}

function help {
		local command_name="run.sh"
        echo "Valid commands:"
        echo "$command_name spring [project-dir] [max-memory]"
        echo "$command_name jws"
        echo "$command_name eap"
        echo "$command_name kill-all"
}

function not_implemented_yet {
	echo "This feature has not been implemented yet"
}

if [[ $# -gt 0 ]]
then
   key="$1"
   case $key in
      spring)
        shift # past argument
        run_springboot "$@"
        ;;
      jws)
        shift # past argument
        not_implemented_yet
        ;;
      eap)
        shift # past argument
        run_eap "$@"
        ;;
	  kill-all)
        shift # past argument
        not_implemented_yet
        ;;
      *)
        # unknown option
        echo "Unknown option. Show help"
        help
        ;;
   esac
else
   help
fi