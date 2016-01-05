FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer
ADD vendor/atlassian-bamboo-5.9.7.tar.gz /
VOLUME /bamboo-home
RUN mkdir -p /bamboo-home && \
    echo "bamboo.home=/bamboo-home" > /atlassian-bamboo-5.9.7/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
WORKDIR /atlassian-bamboo-5.9.7
ENTRYPOINT ["bin/start-bamboo.sh"]
CMD ["-fg"]
