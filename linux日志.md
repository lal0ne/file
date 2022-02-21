# 底层日志

## 系统账号

```shell
# 查询特权用户
awk -F: '$3==0{print $1}' /etc/passwd

# 查询可以远程登录
awk '/\$1|\$6/{print $1}' /etc/shadow

# 除root帐号外，其他帐号是否存在sudo权限
more /etc/sudoers | grep -v "^#\|^$" | grep "ALL=(ALL)"

# 当前登录当前系统的用户信息
who     # 查看当前登录用户（tty本地登陆  pts远程登录）
w       # 查看系统信息，想知道某一时刻用户的行为
uptime  # 查看登陆多久、多少用户，负载
```

## secure日志

```shell
# 1、定位有多少IP在爆破主机的root帐号：
grep "Failed password for root" /var/log/secure | awk '{print $11}' | sort | uniq -c | sort -nr | more

# 定位有哪些IP在爆破：
grep "Failed password" /var/log/secure|grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"|uniq -c

# 爆破用户名字典是什么？
 grep "Failed password" /var/log/secure|perl -e 'while($_=<>){ /for(.*?) from/; print "$1\n";}'|uniq -c|sort -nr

# 2、登录成功的IP有哪些：
grep "Accepted " /var/log/secure | awk '{print $11}' | sort | uniq -c | sort -nr | more

# 登录成功的日期、用户名、IP：
grep "Accepted " /var/log/secure | awk '{print $1,$2,$3,$9,$11}'
```

## lastlog日志

```shell
# 成功登陆的事件和最后一次不成功的登陆事件
lastlog
```

## wtmp日志

```shell
# 创建以来登陆过的用户
last

# 所有用户的连接时间
ac -dp
```

## apache日志

```shell
# 当前WEB服务器中联接次数最多的ip地址
netstat -ntu |awk '{print $5}' |sort | uniq -c| sort -nr

# 查看日志中访问次数最多的前10个IP
cat access_log |cut -d ' ' -f 1 | sort |uniq -c | sort -nr | awk '{print $0 }' | head -n 10 | less

# 查看日志中出现100次以上的IP
cat access_log |cut -d ' ' -f 1 | sort |uniq -c | awk '{if ($1 > 100) print $0}'｜sort -nr | less

# 查看最近访问量最高的文件
cat access_log | tail -10000 | awk '{print $7}' | sort | uniq -c | sort -nr | less

# 查看日志中访问超过100次的页面
cat access_log | cut -d ' ' -f 7 | sort |uniq -c | awk '{if ($1 > 100) print $0}' | less

# 统计某url，一天的访问次数
cat access_log | grep '12/Aug/2009' | grep '/images/index/e1.gif' | wc | awk '{print $1}'

# 前五天的访问次数最多的网页
cat access_log | awk '{print $7}' | uniq -c | sort -n -r | head -20

# 从日志里查看该ip在干嘛
cat access_log | grep 218.66.36.119 | awk '{print $1"\t"$7}' | sort | uniq -c | sort -nr | less

# 列出传输时间超过 30 秒的文件
cat access_log | awk '($NF > 30){print $7}' | sort -n | uniq -c | sort -nr | head -20

# 列出最最耗时的页面(超过60秒的)
cat access_log | awk '($NF > 60 && $7~/\.php/){print $7}' | sort -n | uniq -c | sort -nr | head -100
```

## apache排除资源访问记录

```shell
# 修改 httpd.conf
vim /usr/local/httpd/conf/httpd.conf
---
<IfModule log_config_module>
	# 日志格式
	# %{X-FORWARDED-FOR}i ==> X-FORWARDED-FOR的地址
	# %{REMOTE_PORT}e ==> 请求源的端口
	LogFormat "%h %{X-FORWARDED-FOR}i \"%{REMOTE_PORT}e\" %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
	<IfModule logio_module>
        # You need to enable mod_logio.c to use %I and %O
        #LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
	</IfModule>
	# 设置排除日志
	# [SetEnvIf说明](https://www.cnblogs.com/bigcome/p/6811497.html)
	SetEnvIf Request_URI ".*\.gif$" TAG
	SetEnvIf Request_URI ".*\.jpg$" TAG
	SetEnvIf Request_URI ".*\.png$" TAG
	SetEnvIf Request_URI ".*\.bmp$" TAG
	SetEnvIf Request_URI ".*\.swf$" TAG
	# ajax提交
	#SetEnvIf Request_URI ".*\.js$" TAG
	SetEnvIf Request_URI ".*\.css$" TAG
    
	# 写入日志
	CustomLog "logs/access_log" combined env=!TAG
</IfModule>
---

# 重启服务
/usr/local/httpd/bin/apachectl restart
```

## apache记录post数据

```shell
# 将 mod_dumpio.so 放在 /usr/local/httpd/modules 下
# 附加执行权限
chmod 755 /usr/local/httpd/modules/mod_dumpio.so

# 修改 httpd.conf
vim /usr/local/httpd/conf/httpd.conf
---
LoadModule dumpio_module modules/mod_dumpio.so
# apache 2.4
LogLevel dumpio:trace7
# apache 2.2
# LogLevel debug
DumpIOInput On
DumpIOOutput On
---

# 重启服务
/usr/local/httpd/bin/apachectl restart

# 产生日志在error中
```

## 执行命令记录

```shell
# 修改 /etc/profile
vim /etc/profile
---
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
        if [ ! -w "$HISTORY_LOG" ]; then
              touch "$HISTORY_LOG";
              chmod 666 "$HISTORY_LOG";
        fi;
        # 写入到指定路径的文件中
        # >> 追加到文件中
        echo  `whoami` "[$OLD_PWD]$(history 1)" >>"$HISTORY_LOG";
  fi;
  # 设置指代变量
  export HISTORY_LOG="/var/log/history.log";
  export LAST_CMD="$(history 1)";
  export OLD_PWD=$(pwd);'
}
# trap command [EXIT，ERR，DEBUG]
# 简单来说就是调用方法/函数
# 调试所用，具体可以看看trap用法
trap log2file DEBUG
---

# 重启服务
source /etc/profile
```

## messages日志

```shell
# 系统日志信息
# 字段描述：
# 　　1. 事件的日期和时间
# 　　2. 事件的来源主机
# 　　3. 产生这个事件的程序[进程号] 
# 　　4. 实际的日志信息
```

## ~~ssh日志~~

## ~~rdp日志~~

## ~~ftp日志~~

## ~~telnet日志~~

