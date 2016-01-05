Bamboo Server Dockerfile
========================

Simple Ubuntu 14.04-based Dockerfile for bringing a base Atlassian Bamboo
container online

Usage
-----

```
docker build .
docker run \
  -p 8085:8085 \
  -d \
  -v <path to persistent data>:/bamboo-home \
  <container id>
```

Note: `vendor/atlassian-bamboo-5.9.7.tar.gz` exceeds to 100 MB file size limit
imposed by GitHub.  You will need [git-lfs](https://git-lfs.github.com/) in
order to fully retrieve the contents of this repository.  Alternatively, you
may download the file directly from Atlassian.
