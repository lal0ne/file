## 基础环境

| centos | 7.3.1611              | cat /etc/redhat-release |
| ------ | --------------------- | ----------------------- |
| 内核   | 3.10.0-514.el7.x86_64 | uname -a                |

## 换源

```shell
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
```

## LAMP

```shell
# 安装php
yum -y install php

# 安装Apache
yum -y install httpd
systemctl start httpd.service
systemctl enable httpd.service

# 安装MariaDB
yum -y install mariadb*
systemctl start mariadb.service
systemctl enable mariadb.service
# 配置mysql
mysql_secure_installation

# 关联php和mysql
yum -y install php-mysql
```

## 开放端口

```shell
yum install iptables-services
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save
service iptables restart
```

## zabbix

```shell
setenforce 0
iptables -I INPUT -p tcp --dport 10050 -j ACCEPT
iptables -I INPUT -p tcp --dport 10051 -j ACCEPT
service iptables save
service iptables restart
```

安装官网选相应版本，[zabbix](https://www.zabbix.com/cn/download)根据该内容执行安装配置步骤。

`php_value[date.timezone] = Europe/Riga` 改为 `php_value[date.timezone] = Asia/Shanghai`

访问 `http://IP/zabbix` 进行页面安装，默认密码为 `Admin/zabbix`