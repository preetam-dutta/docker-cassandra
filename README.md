Description
===========
This is a Cassandra Docker image for bringing up Cassandra cluster(preferably to be used in Kubernetes Stateful Set). The container starts cassandra and the sleeps infinitely.

You could use this for starting a single node or multiple nodes cluster for development purpose. 

This leverages Docker Volumes to persist data across Cassandra Nodes

Docker Hub Project Link
=======================
- https://hub.docker.com/r/preetamdutta/cassandra 

Prerequisite
============
You should have Docker installed, preferably Docker Desktop


Pull the Docker Image
=====================
Pull the docker image from DockerHub
- Command:
  ```bash
  docker pull preetamdutta/cassandra:latest
  ```

Create Docker Volume
====================
You need to create docker volumes to persist data across container restarts. Create two set of volumes per node, one for the data and another for the logs

- Command:
  ```bash
  docker volume create cassandra-node<sequence-number>-data
  docker volume create cassandra-node<sequence-number>-logs
  ```

- Example showing volumes creation for 3 nodes cluster:
  ```bash
  docker volume create cassandra-node1-data
  docker volume create cassandra-node1-logs
  
  docker volume create cassandra-node2-data
  docker volume create cassandra-node2-logs
  
  docker volume create cassandra-node3-data
  docker volume create cassandra-node3-logs
  ```

Running the first node
======================
The first node you bring up is going to be the seed node for the rest of the cluster. For the first node, execute the below command
- Command:
  ```bash
  docker run -i -v cassandra-node<sequence-number>-data:/var/lib/cassandra -v cassandra-node<sequence-number>-logs:/var/log/cassandra --env clusterName=<cluster-name> -t preetamdutta/cassandra:latest
  ```
- Example:
  ```bash
  docker run -i \
      -v cassandra-node1-data:/var/lib/cassandra \
      -v cassandra-node1-logs:/var/log/cassandra \
      --env clusterName=preet-cluster \
      --env maxHeapSize=768 \
      --env heapNewSize=100 \
      -t preetamdutta/cassandra:latest
      
  ```
  
  *Parameters:*
  - *-v cassandra-node1-data:/var/lib/cassandra*: volume for data
  - *-v cassandra-node1-logs:/var/lib/cassandra*: volume for log
  - *--env clusterName=preet-cluster*: the cluster name, feel free to choose a cluster name of your liking
  - *-t preetamdutta/cassandra:latest*: the image tag


Verifying the first node & take a note of the seed IP for subsequent nodes
==========================================================================

List the container to identify the CONTAINER ID
- Command: 
  ```bash
  docker container ls
  ```
  
- Example:
  ```bash
  $ docker container ls
  CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                                         NAMES
  94e1a467e3ac        preet-cassandra:latest   "/bin/sh -c 'cassand…"   3 minutes ago       Up 3 minutes        7000-7001/tcp, 7199/tcp, 9042/tcp, 9160/tcp   hopeful_mendel
  $
  ```

Note the CONAINER_ID from previous command and verify node status via the **nodetool** command
The status should be **UN**
- Command:
  ```bash
  docker exec -it <container id> nodetool status
  ```
- Example:
  ```bash
  $ docker exec -it 94e1a467e3ac nodetool status
  Datacenter: dc1
  ===============
  Status=Up/Down
  |/ State=Normal/Leaving/Joining/Moving
  --  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
  UN  172.17.0.2  140.07 KiB  8            100.0%            fa2895a0-7ae8-423a-b5a9-80979abccaf8  rack1
  
  $
  ```

The above nodetool state should show that the single node is up and running.

If you intend to start further nodes of the cluster then note the IP of this node, this IP will be used as the seed IP for the subsequent nodes.
If you only wish to use single node then skip the below section and go straight to **Starting CQLSH** section and bring up the CQLSH to play with the cassandra cluster


Running the second and subsequent nodes
=======================================
For second node onwards execute below command, updating the volume details. And for the **seed** provide the IP of the first cluster.
And ensure the cluster-name also remains the same as first node

For the below command keep changing the *<sequence-number>* to bring up more nodes as you may desire
- Command:
  ```bash
  docker run -v cassandra-node<sequence-number>-data:/var/lib/cassandra -v cassandra-node<sequence-number>-logs:/var/log/cassandra --env seed=172.17.0.2 --env clusterName=preet-cluster -t preetamdutta/cassandra:latest
  ```
- Example:
  ```bash
  docker run \
      -v cassandra-node2-data:/var/lib/cassandra \
      -v cassandra-node2-logs:/var/log/cassandra \
      --env seed=172.17.0.2 \
      --env clusterName=preet-cluster \
      -t preetamdutta/cassandra:latest
  ```

Verify the subsequent nodes are coming up via **nodetool** command
- Example:
  ```bash
  $ docker exec -it 5fed44c4d5ba nodetool status
  Datacenter: dc1
  ===============
  Status=Up/Down
  |/ State=Normal/Leaving/Joining/Moving
  --  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
  UJ  172.17.0.3  65.22 KiB  8            ?                 06d35de5-f16b-4db9-8ecf-682f95044714  rack1
  UN  172.17.0.2  215.58 KiB  8            100.0%            fa2895a0-7ae8-423a-b5a9-80979abccaf8  rack1
  ```

Starting CQLSH
==============
List running containers
- Example:
  ```bash
  $ docker container ls
  CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                                         NAMES
  94e1a467e3ac        preet-cassandra:latest   "/bin/sh -c 'cassand…"   3 minutes ago       Up 3 minutes        7000-7001/tcp, 7199/tcp, 9042/tcp, 9160/tcp   hopeful_mendel
  $

Note the CONAINER_ID from previous command and start **cqlsh**
- Command:
  ```bash
  docker exec -it <container id> cqlsh
  ```
- Example:
  ```bash
  $ docker exec -it 94e1a467e3ac cqlsh
  Connected to preet-cluster at 172.17.0.2:9042.
  [cqlsh 5.0.1 | Cassandra 3.11.4 | CQL spec 3.4.4 | Native protocol v4]
  Use HELP for help.
  cqlsh>
  ```