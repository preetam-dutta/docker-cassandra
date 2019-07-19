FROM alpine:3.10.1

# adding kasndra user for Cassandra operations
RUN addgroup -g 550 kasndra && adduser -h /home/kasndra -G kasndra -S -u 550 kasndra

# Supporting sw tools installation
RUN apk add --no-cache openjdk8
RUN apk add python2
RUN apk add bash
RUN apk update && apk upgrade

# installing Cassandra in /opt/cassandra
WORKDIR /opt
RUN wget http://mirrors.estointernet.in/apache/cassandra/3.11.4/apache-cassandra-3.11.4-bin.tar.gz
RUN tar -zxvf apache-cassandra-3.11.4-bin.tar.gz \
  && rm -f apache-cassandra-3.11.4-bin.tar.gz \
  && mv apache-cassandra-3.11.4 cassandra \
  && ln -s /var/log/cassandra /opt/cassandra/logs

# setting up Cassandra scripts
WORKDIR /usr/local/bin/
COPY cassandra.sh cqlsh nodetool /usr/local/bin/
RUN chmod 755 cassandra.sh cqlsh nodetool
  
# setting up Cassandra configurations
WORKDIR /opt/cassandra/conf
RUN mv cassandra.yaml cassandra.yaml.orig && ln -s /etc/cassandra/cassandra.yaml cassandra.yaml
WORKDIR /etc/cassandra
RUN sed -e "s/^num_tokens:.*$/num_tokens: 8/" \
  -e "s/^# hints_directory:.*$/hints_directory: \/var\/lib\/cassandra\/hints/" \
  -e "s/^# data_file_directories:.*$/data_file_directories:/" \
  -e "s/^#     - \/var\/lib\/cassandra\/data.*$/  - \/var\/lib\/cassandra\/data/" \
  -e "s/^# commitlog_directory:.*$/commitlog_directory: \/var\/lib\/cassandra\/commitlog/" \
  -e "s/^# saved_caches_directory:.*$/saved_caches_directory: \/var\/lib\/cassandra\/saved_caches/" \
  -e "s/^endpoint_snitch:.*$/endpoint_snitch: GossipingPropertyFileSnitch/" < /opt/cassandra/conf/cassandra.yaml.orig > cassandra.yaml \
  && chown -R kasndra:kasndra /etc/cassandra

RUN mkdir -p /var/lib/cassandra /var/log/cassandra \
  && chown -R kasndra:kasndra /var/lib/cassandra /var/log/cassandra
VOLUME ["/var/lib/cassandra", "/var/log/cassandra"]

# 7000 Intra-node communication
# 7001 TLS intra-node communication
# 7199 JMX
# 9042 CQL
# 9160 Thrift service
EXPOSE 7000 7001 7199 9042 9160

USER kasndra:kasndra
ENV seed="CURRENT_HOST"
ENV clusterName="preet-cluster"
WORKDIR /home/kasndra
ENTRYPOINT cassandra.sh -s ${seed} -c ${clusterName}