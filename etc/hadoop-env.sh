# 文件最后添加
export JAVA_HOME=/export/server/jre1.8.0_391

#
# To prevent accidents, shell commands be (superficially) locked
# to only allow certain users to execute certain subcommands.
# It uses the format of (command)_(subcommand)_USER.
#
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root

# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs
# export HADOOP_PID_DIR=/tmp
# export HADOOP_HEAPSIZE_MAX=