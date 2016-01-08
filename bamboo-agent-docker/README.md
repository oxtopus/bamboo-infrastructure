Bamboo Agent Dockerfile
=======================

Simple Ubuntu 14.04-based Dockerfile for building an image based on the base
Atlassian Bamboo Agent, and with docker utilities installed so that the agent
may run docker containers.


Usage
-----

```
docker build .
docker run \
  -e HOME=/root/ \
  -e BAMBOO_SERVER=<bamboo server http url> \ 
  -d \
  <container id>
```
