#!/bin/bash

(( $(ps -ef | grep java | grep apache-cassandra | grep -v grep | wc -l) != 1 )) && exit 1

exit 0