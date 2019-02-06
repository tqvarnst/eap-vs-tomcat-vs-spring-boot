#!/bin/bash

while [ true ] ; do
	curl http://127.0.0.1:8080/ >& /dev/null
	if [ $? = 0 ] ; then
		echo "got request at `python -c'import datetime; print(datetime.datetime.now().time())'`"
		exit 0
	fi
	sleep .05
done