## 监控内容

### history

```shell
# 新建history日志文件
touch /var/log/history.log
# 将一下内容添加进 `/etc/profile`

# 定义个方法/函数
function log2file
{
# 设置history文件的格式
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] [`who am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`] "
# 设置后的history文件
# 1027  [2020-01-08 15:48:12] [10.10.10.3] cat /etc/profile
# 第几行 时间 来源ip 命令

export PROMPT_COMMAND='\
  #  if [ -z "$OLD_PWD" ]
  # 判断字符串$OLD_PWD长度是否为零
  if [ -z "$OLD_PWD" ];then
        export OLD_PWD=$(pwd);
  fi;
  if [ ! -z "$LAST_CMD" ] && [ "$(history 1)" != "$LAST_CMD" ]; then
        # 写入到指定路径的文件中
        # >> 追加到文件中
        echo  `whoami` "[$OLD_PWD]$(history 1)" >>/var/log/history.log;
  fi ;
  # 设置指代变量
  export LAST_CMD="$(history 1)";
  export OLD_PWD=$(pwd);'
}
# trap command [EXIT，ERR，DEBUG]
# 简单来说就是调用方法/函数
# 调试所用，具体可以看看trap用法
trap log2file DEBUG
```

重启

```shell
source /etc/profile
```

### ssh

```shell
# 日志位置
/var/log/secure
```

## syslog转发

```shell
# 将一下内容添加进 `/etc/rsyslog.conf`

module(load="imfile" PollingInterval="10")
input(type="imfile"
       File="/var/log/secure"
       Tag="ssh: "
       PersistStateInterval="1"
       reopenOnTruncate="on"
       Severity="info"
       Facility="local5"
)
input(type="imfile"
       File="/var/log/history.log"
       Tag="history: "
       PersistStateInterval="1"
       reopenOnTruncate="on"
       Severity="info"
       Facility="local5"
)
local5.* @@10.10.100.166:514
```

重启

```shell
# centos
systemctl restart rsyslog
systemctl enable rsyslog

# ubuntu
service rsyslog restart

# kali
/etc/init.d/rsyslog restart
```

## syslog服务端

```shell
# 将一下内容添加进 `/etc/rsyslog.conf`

# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# Provides TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514

# Use default timestamp format
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
$EscapeControlCharactersOnReceive off
template( name="jsonformat"
          type="string"
          string="{%timegenerated:::date-rfc3339,jsonf:@timestamp%,\"source\":\"1\",%fromhost-ip:::jsonf:host%,%syslogseverity:::jsonf:severity%,%hostname:::jsonf:hostname%,%rawmsg:::jsonf:message%}"
)

# Turn off message reception via local log socket;
# local messages are retrieved through imjournal now.
$OmitLocalLogging on

# File to store the position in the journal
$IMJournalStateFile imjournal.state

if($fromhost-ip != "127.0.0.1") then{
        *.*  stop
}

```

重启

```shell
# centos
systemctl restart rsyslog
systemctl enable rsyslog

# ubuntu
service rsyslog restart
```

