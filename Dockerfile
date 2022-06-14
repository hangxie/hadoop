FROM debian:11-slim

ENV HADOOP_VERSION=3.3.3
ENV HADOOP_HOME /opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_COMMON_HOME ${HADOOP_HOME}
ENV HADOOP_HDFS_HOME ${HADOOP_HOME}
ENV HADOOP_MAPRED_HOME ${HADOOP_HOME}
ENV HADOOP_YARN_HOME ${HADOOP_HOME}
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV YARN_CONF_DIR ${HADOOP_HOME}/etc/hadoop

ARG DEBIAN_FRONTEND=noninteractive

RUN echo install packages \
 && apt-get update \
 && apt-get -y install ca-certificates curl tar sudo openssh-server rsync openjdk-11-jdk \
 && echo configure ssh \
 && ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa \
 && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
 && chmod 0600 /root/.ssh/authorized_keys \
 && echo install Hapdoop \
 && cd /opt \
 && curl -sLO https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
 && tar zxf hadoop-${HADOOP_VERSION}.tar.gz \
 && rm hadoop-${HADOOP_VERSION}.tar.gz \
 && rm -rf ${HADOOP_HOME}/share/doc ${HADOOP_HOME}/lib/native \
 && echo configure Hadoop \
 && java -XshowSettings:properties -version 2>&1 | grep java.home | awk '{print "export JAVA_HOME="$3}' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export HADOOP_HOME=${HADOOP_HOME}" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export HADOOP_MAPRED_HOME=${HADOOP_HOME}" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
 && rm -rf /var/lib/apt/lists/*

ADD core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
ADD hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
ADD yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
ADD ssh_config /root/.ssh/config
ADD startup.sh /

ENV PATH ${HADOOP_HOME}/bin:$PATH
WORKDIR /opt/hadoop-${HADOOP_VERSION}
ENTRYPOINT ["/startup.sh"]
