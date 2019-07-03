About
=====

Cassandra Docker image for Kubernetes Deployment.
The container start cassandra and the sleeps infinitely 


Build image
-----------

```bash
docker build -t preet/k8/cassandra .
```

Create Volume
-------------

```bash
docker volume create cassandra-node1-data
docker volume create cassandra-node1-logs

docker volume create cassandra-node2-data
docker volume create cassandra-node2-logs

docker volume create cassandra-node3-data
docker volume create cassandra-node3-logs
```

Run Container
-------------

For the first node, execute command without the seed node
```bash
docker run -i \
    -v cassandra-node1-data:/var/lib/cassandra \
    -v cassandra-node1-logs:/var/log/cassandra \
    --env clusterName=preet-cluster2 \
    -t preet/k8/cassandra:latest
    
```

For second node onwards execute below command, updating the volume details
```bash
docker run \
    -v cassandra-node2-data:/var/lib/cassandra \
    -v cassandra-node2-logs:/var/log/cassandra \
    --env seed=172.17.0.2 \
    --env clusterName=preet-cluster2 \
    -t preet/k8/cassandra:latest
```
