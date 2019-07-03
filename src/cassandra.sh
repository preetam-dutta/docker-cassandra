#!/bin/bash

cassandra_home="/opt/cassandra"
cassandra_yml="/etc/cassandra/cassandra.yaml"
cassandra_yml_tmp="/tmp/cassandra_yml.$$.tmp"

node_ip=$(hostname -i)
listen_address=$node_ip
rpc_address=$node_ip
seeds_address="CURRENT_HOST"
cluster_name="NOT_SET"

usage() {
  echo "Usage: $0 -s <mandatory first node IP, second node onwards optional, no space> [-c <cluster_name>]"
  echo ""
  echo "Example: $0 -s \"172.31.82.6,172.31.83.4\" -c my-cluster"
  echo ""
}

while getopts "s:c:h" opt; do
  case "${opt}" in
    s)
      seeds_address=${OPTARG}
      ;;
    c)
      cluster_name=${OPTARG}
      ;;
    h)
      usage
      ;;
  esac
done

[[ $seeds_address == "CURRENT_HOST" ]] && {
  seeds_address=$(hostname -i)
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