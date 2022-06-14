#!/bin/bash

service ssh start
source ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
${HADOOP_HOME}/bin/hdfs namenode -format
${HADOOP_HOME}/sbin/start-dfs.sh
${HADOOP_HOME}/sbin/start-yarn.sh
# ${HADOOP_HOME}/bin/mapred historyserver > ${HADOOP_HOME}/logs/hadoop-root-historyserver-$(hostname).log 2>&1 &

tail -F ${HADOOP_HOME}/logs/*.log
