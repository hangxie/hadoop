FROM debian:11-slim

ENV HADOOP_VERSION=3.3.1
ADD startup.sh /

RUN echo fixing arm build \
    && for U in dpkg-split dpkg-deb tar rm; do \
           ln -fs `which $U` /usr/sbin/; \
           ln -fs `which $U` /usr/local/sbin/; \
       done \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install nscd ca-certificates sssd-tools python3-minimal \
    && ls -asl /etc/ssl/certs/ \
    && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install ssh pdsh openjdk-11-jdk curl \
    && cd /opt \
    && curl -O https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}-aarch64.tar.gz \
    && tar zxf hadoop-${HADOOP_VERSION}-aarch64.tar.gz \
    && rm hadoop-${HADOOP_VERSION}-aarch64.tar.gz \
    && cd /opt/hadoop-${HADOOP_VERSION} \
    && mkdir /run/ssh \
    && rm -rf /var/lib/apt/lists/* \
    && for U in dpkg-split dpkg-deb tar rm; do \
           rm /usr/sbin/$U /usr/local/sbin/$U; \
       done \
    && chmod +x /startup.sh


WORKDIR /opt/hadoop-${HADOOP_VERSION}
ENTRYPOINT ["/startup.sh"]
