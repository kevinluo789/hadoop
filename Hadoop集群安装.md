# Hadoop三节点集群安装示例

示意图:
: ![cluster setup](images/Hadoop_example.png)

## 一、集群角色规划
- NameNode角色部署在大内存机器上  

| 服务器 | IP | 运行角色 |
| --- | --- | --- |
| node1.luoxuzhong.cn | 192.168.1.3 | NameNode DataNode ResourceManager NodeManager |
| node2.luoxuzhong.cn | 192.168.1.4 | SecondaryNameNode DataNode NodeManager |
| node3.luoxuzhong.cn | 192.168.1.5 | DataNode NodeManager |

## 二、服务器基础环境准备
- 主机名（3台机器）
```bash
hostnamectl hostname node1.luoxuzhong.cn
```
- Hosts映射（3台机器）
`vim /etc/hosts`
```bash
[root@localhost ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.3 node1 node1.luoxuzhong.cn
192.168.1.4 node2 node2.luoxuzhong.cn
192.168.1.5 node3 node3.luoxuzhong.cn
```
- 防火墙关闭（3台机器）
```bash
systemctl stop firewalld
systemctl disable firewalld
```
- ssh免密登陆（node1执行->node1|node2|node3）
```bash
ssh-keygen
ssh-copy-id node1
ssh-copy-id node2
ssh-copy-id node3
```
- 集群时间同步（3台机器）
```bash
systemctl start chronyd
systemctl enable chronyd
```
- 创建统一工作目录（3台机器）
```bash
# 软件安装路径
mkdir -p /export/server/
# 数据存储路径
mkdir -p /export/data/
# 安装包存放路径
mkdir -p /export/software/
```
## 三、上传安装包、解压安装包
- JDK 1.8安装（3台机器）
    [Java下载路径](https://www.oracle.com/java/technologies/downloads/archive/)
    ```bash
    # 上传jre-8u391-linux-x64.tar.gz到/export/server/目录下
    cd /export/server/
    tar -xzvf jre-8u391-linux-x64.tar.gz
    ```
    配置java环境变量
    `vim /etc/profile.d/java.sh`
    ```bash
    export JAVA_HOME=/export/server/jre1.8.0_391
    export PATH=$PATH:$JAVA_HOME/bin
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    ```
    使环境变量生效`source /etc/profile`

- 上传、解压Hadoop安装包（3台机器）
    ```bash
    # 上传hadoop-3.3.6.tar.gz到/export/server/目录下
    cd /export/server/
    tar -xzvf hadoop-3.3.6.tar.gz
    ```
    配置hadoop系统环境变量
    `vim /etc/profile.d/hadoop.sh`
    ```bash
    export HADOOP_HOME=/export/server/hadoop-3.3.6
    export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
    ```
    使环境变量生效`source /etc/profile`
```bash
# 复制命令参考（建议在修改配置文件后复制）
rsync -e 'ssh' -a server/ node3:/export/server/
```
## 四、Hadoop安装包目录结构

| 目录 | 内容 |
| --- | --- |
| bin | Hadoop最基本的管理脚本和使用脚本的目录，这些脚本是sbin目录下管理脚本的基础实现，用户可以直接使用这些脚本管理和使用Hadoop。|
| etc | Hadoop配置文件所在的目录，包括core-site,xml、hdfs-site.xml、mapred-site.xml等从Hadoop1.0继承而来的配置文件和yarn-site.xml等Hadoop2.0新增的配置文件。|
| include | 对外提供的编程库头文件（具体动态库和静态库在lib目录中），这些头文件均是用C++定义的，通常用于C++程序访问HDFS或者编写MapReduce程序。|
| lib | 该目录包含了Hadoop对外提供的编程动态库和静态库，与include目录中的头文件结合使用。|
| libexec | 各个服务对用的shell配置文件所在的目录，可用于配置日志输出、启动参数（比如JVM参数）等基本信息。|
| sbin | Hadoop管理脚本所在的目录，主要包含HDFS和YARN中各类服务的启动/关闭脚本。|
| share | Hadoop各个模块编译后的jar包所在的目录，官方自带示例。|

## 五、配置
官网参考链接： [https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html)

配置文件（参见etc目录下）:
: 1. 环境配置：[hadoop-env.sh](./etc/hadoop-env.sh)
: 2. 用户定义的模块配置:
        : [core-site.xml](./etc/core-site.xml)
        : [hdfs-site.xml](./etc/hdfs-site.xml)
        : [yarn-site.xml](./etc/yarn-site.xml)
        : [mapred-site.xml](./etc/mapred-site.xml)
: 3. [workers](./etc/workers)

## 六、NameNode format（格式化操作）
- 首次搭建要初始化一次，只能这一次（类似磁盘格式化）
- 命令：`hdfs namenode -format`

- 如果多次format除了造成数据丢失外，还会导致hdfs集群主从角色之间互不识别。通过删除所有机器hadoop.tmp.dir目录重新format解决。

## 七、启动命令
```bash
# 单个节点启动hdfs
[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon start namenode
[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon start datanode
[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon start secondarynamenode

# 集群启动hdfs（需要配置workers文件和ssh互信）
[hdfs]$ $HADOOP_HOME/sbin/start-dfs.sh

# 单个节点启动yarn
[yarn]$ $HADOOP_HOME/bin/yarn --daemon start resourcemanager
[yarn]$ $HADOOP_HOME/bin/yarn --daemon start nodemanager
[yarn]$ $HADOOP_HOME/bin/yarn --daemon start proxyserver

# 集群启动yarn（需要配置workers文件和ssh互信）
[yarn]$ $HADOOP_HOME/sbin/start-yarn.sh

# 单个节点启动MapReduce JobHistory Server
[mapred]$ $HADOOP_HOME/bin/mapred --daemon start historyserver

# 集群启动所有（需要配置workers文件和ssh互信）
$HADOOP_HOME/sbin/start-all.sh
```

## 八、停止命令
```bash
# 单个节点停止hdfs
[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon stop namenode
[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon stop datanode
[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon stop secondarynamenode

# 集群停止hdfs（需要配置workers文件和ssh互信）
[hdfs]$ $HADOOP_HOME/sbin/stop-dfs.sh

# 单个节点停止yarn
[yarn]$ $HADOOP_HOME/bin/yarn --daemon stop resourcemanager
[yarn]$ $HADOOP_HOME/bin/yarn --daemon stop nodemanager
[yarn]$ $HADOOP_HOME/bin/yarn stop proxyserver

# 集群停止yarn（需要配置workers文件和ssh互信）
[yarn]$ $HADOOP_HOME/sbin/stop-yarn.sh

# 单个节点停止MapReduce JobHistory Server
[mapred]$ $HADOOP_HOME/bin/mapred --daemon stop historyserver

# 集群停止所有（需要配置workers文件和ssh互信）
$HADOOP_HOME/sbin/stop-all.sh
```

## 九、Web地址
| Daemon | Web Interface | Notes |
| --- | --- | --- |
| NameNode | http://nn_host:port/ | Default HTTP port is 9870. |
| ResourceManager | http://rm_host:port/ | Default HTTP port is 8088. |
| MapReduce JobHistory Server | http://jhs_host:port/ | Default HTTP port is 19888. |
