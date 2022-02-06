#!/bin/bash

cat >> etc/hadoop/hadoop-env.sh <<EOF
export JAVA_HOME=$(/usr/bin/java -XshowSettings all 2>&1 | grep java.home | awk '{print $3}')
export HDFS_DATANODE_USER=root
export HDFS_DATANODE_SECURE_USER=root
export HDFS_NAMENODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export PDSH_RCMD_TYPE=ssh
EOF

mkdir input
cp etc/hadoop/*.xml input
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar grep input output 'dfs[a-z.]+'

cat > etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

cat > etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>
EOF

bin/hdfs namenode -format

ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
echo "StrictHostKeyChecking no" > /root/.ssh/config
mkdir /run/sshd

/usr/sbin/sshd
sbin/start-dfs.sh
/usr/bin/tail -F logs/hadoop-root-namenode-*.log
