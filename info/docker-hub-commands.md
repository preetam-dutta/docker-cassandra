

Docker Hub Notes
================

Docker Build
------------
Execute the below command to build Cassandra container
- docker build -t cassandra:latest .
  ```bash
  $ cd cloud-lab/docker/preet-cassandra
  $ docker build -t cassandra .
  Sending build context to Docker daemon  8.192kB
  ...
  Successfully tagged cassandra:latest
  $
  ```

Docker image listing
--------------------
Ensure that you able to see the recently built image 
- docker image ls
  ```bash
  $ docker image ls
  REPOSITORY                                 TAG                 IMAGE ID            CREATED             SIZE
  cassandra                               latest              a2c3f6dbcda2        22 minutes ago      337MB
  ...
  $
  ```

Docker Login
------------
Login to Docker as prep for pushing the image
- docker login
  ```bash
  $ docker login
  ...
  Username: preetamdutta
  Password:
  ...
  Login Succeeded
  $
  ```

Docker Tag & Push
-----------------
- docker tag cassandra:latest preetamdutta/cassandra:v1.0.0
- docker push preetamdutta/cassandra:v1.0.0




