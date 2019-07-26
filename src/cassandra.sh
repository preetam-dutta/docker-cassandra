#!/bin/bash

cassandra_home="/opt/cassandra"
cassandra_yml="/etc/cassandra/cassandra.yaml"
cassandra_yml_tmp="/tmp/cassandra_yml.$$.tmp"

node_ip=$(hostname -i)
listen_address=$node_ip
rpc_address=$node_ip
seeds_address="CURRENT_HOST"
cluster_name="NOT_SET"
max_heap_size="NOT_SET"
heap_new_size="NOT_SET"

usage() {
  echo "Usage: $0 -s <mandatory first node IP, second node onwards optional, no space> [-c <cluster_name>] [-m <MAX_HEAP_SIZE in MB> -n <HEAP_NEWSIZE in MB>]"
  echo ""
  echo "Example: $0 -s \"172.31.82.6,172.31.83.4\" -c my-cluster -m 512 -n 100"
  echo ""
  echo "if default heap needs to be changed, provide both -m and -n, otherwise if only one of them is provided, then its ignored"
  echo ""
}

while getopts "m:n:s:c:h" opt; do
  case "${opt}" in
    s)
      seeds_address=${OPTARG}
      ;;
    c)
      cluster_name=${OPTARG}
      ;;
    m)
      max_heap_size=${OPTARG}
      ;;
    n)
      heap_new_size=${OPTARG}
      ;;
    h)
      usage
      ;;
  esac
done

[[ $seeds_address == "CURRENT_HOST" ]] && {
  seeds_address=$(hostname -i)
}

isNumber='^[1-9][0-9]+$'
[[ $max_heap_size != "NOT_SET" ]] && [[ $heap_new_size != "NOT_SET" ]] && [[ $max_heap_size =~ $isNumber ]] && [[ $heap_new_size =~  $isNumber ]] && {
sed -e "s/^#MAX_HEAP_SIZE.*$/MAX_HEAP_SIZE=\"${max_heap_size}M\"/" \
  -e "s/^#HEAP_NEWSIZE.*$/HEAP_NEWSIZE=\"${heap_new_size}M\"/" < ${cassandra_home}/conf/cassandra-env.sh.orig > /etc/cassandra/cassandra-env.sh
}


sed "s/^listen_address:.*$/listen_address: $listen_address/
s/^rpc_address:.*$/rpc_address: $rpc_address/
s/seeds:.*$/seeds: \"$seeds_address\"/" < $cassandra_yml > $cassandra_yml_tmp

[[ $cluster_name != "NOT_SET" ]] && {
  mv $cassandra_yml_tmp ${cassandra_yml_tmp}_2
  sed "s/^cluster_name:.*$/cluster_name: '${cluster_name}'/" < ${cassandra_yml_tmp}_2 > $cassandra_yml_tmp
  rm ${cassandra_yml_tmp}_2
}

mv -f  $cassandra_yml_tmp $cassandra_yml

${cassandra_home}/bin/cassandra

sleep 60
while ( true ); do
  if (( $(ps -ef | grep java | grep -c cassandra) == 1 )); then
    sleep 40
  else
    exit
  fi
done
exit