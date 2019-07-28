#!/bin/bash

(( $(ps -ef | grep -i cassandra | grep -v grep | grep -v cassandra.sh | wc -l) != 1 )) && exit 1

exit 0