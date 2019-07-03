
Build the image and upload to Docker Hub
========================================

Docker Build
------------
Execute the below command to build Cassandra container
- Command:
  ```bash
  docker build -t cassandra:latest .
  ```
- Example:
  ```bash
  $ cd <project-path>
  $ docker build -t cassandra .
  Sending build context to Docker daemon  8.192kB
  ...
  Successfully tagged cassandra:latest
  $
  ```

Docker image listing
--------------------
Ensure that you able to see the recently built image
- Command:
  ```bash
  docker image ls
  ``` 
- Example:
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
- Command:
  ```bash
  docker login
  ```
- Example:
  ```bash
  $ docker login
  ...
  Username: pre***
  Password:
  ...
  Login Succeeded
  $
  ```

Tag the local build
-------------------
- Command:
  ```bash
  docker tag cassandra:latest preetamdutta/cassandra:latest
  ```
Push the build on Docker Hub
----------------------------
- Command:
  ```bash
  docker push preetamdutta/cassandra:latest
  ```





