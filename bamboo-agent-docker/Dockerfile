FROM atlassian/bamboo-base-agent:latest 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y curl
RUN curl -sSL https://get.docker.com/ | sh

