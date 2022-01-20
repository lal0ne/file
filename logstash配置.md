## logstash配置

### 基础案例

```yaml
# 数据来源
input {
		# 文件的方式收集日志
        file{
                path => ["xx/xxx.log"]
        }
        # tcp方式收集日志
        tcp {
			port => "5044"
			#自己取的类型
			type => "log4j2"
		}
		# filebeat的方式
		beats {
			port => "5045"
		}       
}
# 数据过滤
filter {
	# grok正则捕获 [正则解析任意文本]
	grok {
		# 正则匹配
		match => {
               "message" => "\{\"%{WORD}\":\"\[%{LOGLEVEL:level}\s\]\s%{YEAR:year}-%{MONTHNUM:mouth}-%{MONTHDAY:day} %{HOUR:hour}:?%{MINUTE:minute}(?::?%{SECOND:second})\s%{JAVACLASS:project}\s%{JAVACLASS:class}\(%{JAVAFILE:file}(?::%{NUMBER:line})?\)\s-\[%{UUID:traceId}\]\s-\s(?<msg>.+)\}"
        }
        # 添加标签
        add_tag => ["myLog"]
    }
    # 将massage字段转成json
    json {
    	source => "message"
    }
    # date插件 [转换日志记录中的时间字段，变成Logstash：：timestamp对象]
    date {
    	# 正则匹配
        match => ["time", "yyyy-MM-dd HH:mm:ss.SSS"]
        # 删除字段
        remove_field => ["time"]
    }
    # mutate插件 [基础类型数据处理能力，包括重命名、删除、替换、修改日志事件中的字段]
    mutate {
    	# 字段类型转换
    	convert => []
    	# 正则替换匹配
    	gsub => []
    	# 分隔符分隔字符串为数组
    	split => []
    	# 添加标签
        add_tag => []
        # 重命名字段
        rename => {}
        # 删除字段
        remove_field => []
        # 添加字段
        add_field => []
    }
    # 归属地 [提供对应的地域信息，包括国别，省市，经纬度等等]
    geoip {
    	# 数据源
    	source => [""]
    	# 目标
    	target => ["geoip"]
    	# 显示字段
    	fields => []
    }
}
filter {
	if "_grokparsefailure" in [tags]{
		drop{}
	}
}
# 数据输出
output {
  # if "traceId" in [message]{
        elasticsearch {
                hosts => ["192.168.1.185:9200"]
                index => "application-%{+YYYY.MM.dd}"
        }
   #}
}
```

[logstash过滤器插件filter详解及实例](https://www.cnblogs.com/FengGeBlog/p/10305318.html)

## 1. 基础知识

### 1.1 配置语法

Logstash 设计了自己的 DSL —— 有点像 Puppet 的 DSL，或许因为都是用 Ruby 语言写的吧 —— 包括有区域，注释，数据类型(布尔值，字符串，数值，数组，哈希)，条件判断，字段引用等。

#### 区段(section)

Logstash 用 `{}` 来定义区域。区域内可以包括插件区域定义，你可以在一个区域内定义多个插件。插件区域内则可以定义键值对设置。示例如下：

```yaml
input {
    stdin {}
    syslog {}
}
```

#### 数据类型

Logstash 支持少量的数据值类型：

- bool

```yaml
debug => true
```

- string

```yaml
host => "hostname"
```

- number

```yaml
port => 514
```

- array

```yaml
match => ["datetime", "UNIX", "ISO8601"]
```

- hash

```yaml
options => {
    key1 => "value1",
    key2 => "value2"
}
```

**注意**：如果你用的版本低于 1.2.0，*哈希*的语法跟*数组*是一样的，像下面这样写：

```yaml
match => [ "field1", "pattern1", "field2", "pattern2" ]
```

#### 字段引用(field reference)

字段是 `Logstash::Event` 对象的属性。我们之前提过事件就像一个哈希一样，所以你可以想象字段就像一个键值对。

*小贴士：我们叫它字段，因为 Elasticsearch 里是这么叫的。*

如果你想在 Logstash 配置中使用字段的值，只需要把字段的名字写在中括号 `[]` 里就行了，这就叫**字段引用**。

对于 **嵌套字段**(也就是多维哈希表，或者叫哈希的哈希)，每层的字段名都写在 `[]` 里就可以了。比如，你可以从 geoip 里这样获取 *longitude* 值(是的，这是个笨办法，实际上有单独的字段专门存这个数据的)：

```yaml
[geoip][location][0]
```

*小贴士：logstash 的数组也支持倒序下标，即 `[geoip][location][-1]` 可以获取数组最后一个元素的值。*

Logstash 还支持变量内插，在字符串里使用字段引用的方法是这样：

```yaml
"the longitude is %{[geoip][location][0]}"
```

#### 条件判断(condition)

Logstash从 1.3.0 版开始支持条件判断和表达式。

表达式支持下面这些操作符：

- equality, etc: ==, !=, <, >, <=, >=
- regexp: =~, !~
- inclusion: in, not in
- boolean: and, or, nand, xor
- unary: !()

通常来说，你都会在表达式里用到字段引用。比如：

```yaml
if "_grokparsefailure" not in [tags] {
} else if [status] !~ /^2\d\d/ and [url] == "/noc.gif" {
} else {
}
```

#### 命令行参数

Logstash 提供了一个 shell 脚本叫 `logstash` 方便快速运行。它支持一下参数：

- -e

意即*执行*。我们在 "Hello World" 的时候已经用过这个参数了。事实上你可以不写任何具体配置，直接运行 `bin/logstash -e ''` 达到相同效果。这个参数的默认值是下面这样：

```yaml
input {
    stdin { }
}
output {
    stdout { }
}
```

- --config 或 -f

意即*文件*。真实运用中，我们会写很长的配置，甚至可能超过 shell 所能支持的 1024 个字符长度。所以我们必把配置固化到文件里，然后通过 `bin/logstash -f agent.conf` 这样的形式来运行。

此外，logstash 还提供一个方便我们规划和书写配置的小功能。你可以直接用 `bin/logstash -f /etc/logstash.d/` 来运行。logstash 会自动读取 `/etc/logstash.d/` 目录下所有的文本文件，然后在自己内存里拼接成一个完整的大配置文件，再去执行。

- --configtest 或 -t

意即*测试*。用来测试 Logstash 读取到的配置文件语法是否能正常解析。Logstash 配置语法是用 grammar.treetop 定义的。尤其是使用了上一条提到的读取目录方式的读者，尤其要提前测试。

- --log 或 -l

意即*日志*。Logstash 默认输出日志到标准错误。生产环境下你可以通过 `bin/logstash -l logs/logstash.log` 命令来统一存储日志。

- --filterworkers 或 -w

意即*工作线程*。Logstash 会运行多个线程。你可以用 `bin/logstash -w 5` 这样的方式强制 Logstash 为**过滤**插件运行 5 个线程。

*注意：Logstash目前还不支持输入插件的多线程。而输出插件的多线程需要在配置内部设置，这个命令行参数只是用来设置过滤插件的！*

**提示：Logstash 目前不支持对过滤器线程的监测管理。如果 filterworker 挂掉，Logstash 会处于一个无 filter 的僵死状态。这种情况在使用 filter/ruby 自己写代码时非常需要注意，很容易碰上 `NoMethodError: undefined method '\*' for nil:NilClass` 错误。需要妥善处理，提前判断。**

- --pluginpath 或 -P

可以写自己的插件，然后用 `bin/logstash --pluginpath /path/to/own/plugins` 加载它们。

- --verbose

输出一定的调试日志。

*小贴士：如果你使用的 Logstash 版本低于 1.3.0，你只能用 `bin/logstash -v` 来代替。*

- --debug

输出更多的调试日志。

*小贴士：如果你使用的 Logstash 版本低于 1.3.0，你只能用 `bin/logstash -vv` 来代替。*

------

## 2. 输入插件

[标准插件](https://www.elastic.co/guide/en/logstash/current/input-plugins.html)

参考：[数据输入配置](https://blog.csdn.net/qq330983778/article/details/105644835)

**重点介绍**

------

### 2.1 标准输入

[Stdin input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-stdin.html)

#### 配置示例

```yaml
input {
    stdin {
        add_field => {"key" => "value"}
        codec => "plain"
        tags => ["add"]
        type => "std"
    }
}
```

#### 解释

*type* 和 *tags* 是 logstash 事件中两个特殊的字段。通常来说我们会在*输入区段*中通过 *type* 来标记事件类型 —— 我们肯定是提前能知道这个事件属于什么类型的。而 *tags* 则是在数据处理过程中，由具体的插件来添加或者删除的。

### 2.2 文件

[File input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html)

*sincedb 文件中记录了每个被监听的文件的 inode, major number, minor number 和 pos。*

#### 配置示例

```yaml
input
    file {
        path => ["/var/log/*.log", "/var/log/message"]
        type => "system"
        start_position => "beginning"
    }
}
```

#### 解释

有一些比较有用的配置项，可以用来指定 *FileWatch* 库的行为：

- discover_interval

logstash 每隔多久去检查一次被监听的 `path` 下是否有新文件。默认值是 15 秒。

- exclude

不想被监听的文件可以排除出去，这里跟 `path` 一样支持 glob 展开。

- sincedb_path

如果你不想用默认的 `$HOME/.sincedb`(Windows 平台上在 `C:\Windows\System32\config\systemprofile\.sincedb`)，可以通过这个配置定义 sincedb 文件到其他位置。

- sincedb_write_interval

logstash 每隔多久写一次 sincedb 文件，默认是 15 秒。

- stat_interval

logstash 每隔多久检查一次被监听文件状态（是否有更新），默认是 1 秒。

- start_position

logstash 从什么位置开始读取文件数据，默认是结束位置，也就是说 logstash 进程会以类似 `tail -F` 的形式运行。如果你是要导入原有数据，把这个设定改成 "beginning"，logstash 进程就从头开始读取，有点类似 `cat`，但是读到最后一行不会终止，而是继续变成 `tail -F`。

### 2.3 beats

[Beats input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-beats.html)

#### 配置示例

```yaml
input {
  beats {
    port => "514"
  }
}
```

#### 解释

通过该端口接收`filebeat`发送的信息。

### 2.4 syslog

[Syslog input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-syslog.html)

#### 配置示例

```yaml
input {
  syslog {
    port => "514"
  }
}
```

#### 解释

Logstash 是用 `UDPSocket`, `TCPServer` 和 `LogStash::Filters::Grok` 来实现 `LogStash::Inputs::Syslog` 的。

### 2.5 http

[Http input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-http.html)

#### 配置示例

```yaml
http {
	# 启动端口
	port => 8080
	# 编码
	codec => plain {
		charset => "GB2312"
	}
	# 关闭SSL
	ssl => false
}
```



### 2.6 tcp

[Tcp input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-tcp.html)

#### 配置示例

```yaml
input {
    tcp {
        port => 8888
        mode => "server"
        ssl_enable => false
    }
}
```

参数											默认值					说明
port											必填						监听的端口或连接的端口
host											“0.0.0.0”				监听的地址或要连接的地址
mode										“server”/“client”		server监听的地址:端口;client连接的地址:端口
proxy_protocol							false						haproxy支持代理协议
ssl_cert		
ssl_certificate_authorities		
ssl_enable		
ssl_extra_chain_certs		
ssl_key		
ssl_key_passphrase		
ssl_verify		
tcp_keep_alive							false					是否使用使用系统的设置
dns_reverse_lookup_enabled		true					是否开启IP解析成hostname

### 2.7 udp

[Udp input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-udp.html)

#### 配置示例

```yaml
udp {
	port => 12346
}
```



------

## 3. 编码插件

### 3.1  JSON编码

#### 配置示例

httpd.conf 示例：

```
LogFormat "{ \
	\"@timestamp\": \"%{%Y-%m-%dT%H:%M:%S%z}t\", \
	\"@version\": \"1\", \
	\"tags\":[\"apache\"], \
	\"message\": \"%h %l %u %t \\\"%r\\\" %>s %b\", \
	\"clientip\": \"%a\", \
	\"status\": %>s, \
	\"request\": \"%U%q\", \
	\"urlpath\": \"%U\", \
	\"urlquery\": \"%q\", \
	\"bytes\": %B, \
	\"method\": \"%m\", \
	\"site\": \"%{Host}i\", \
	\"referer\": \"%{Referer}i\", \
	\"useragent\": \"%{User-agent}i\" \
}" ls_apache_json
```

nginx.conf 示例：

```
logformat json '{"@timestamp":"$time_iso8601",'
               '"@version":"1",'
               '"host":"$server_addr",'
               '"client":"$remote_addr",'
               '"size":$body_bytes_sent,'
               '"responsetime":$request_time,'
               '"domain":"$host",'
               '"url":"$uri",'
               '"status":"$status"}';
access_log /var/log/nginx/access.log_json json;
```

*注意：在 `$request_time` 和 `$body_bytes_sent` 变量两头没有双引号 `"`，这两个数据在 JSON 里应该是数值类型！*

重启 nginx 应用，然后修改你的 input/file 区段配置成下面这样：

```yaml
input {
    file {
        path => "/var/log/nginx/access.log_json""
        codec => "json"
    }
}
```

### 3.2 合并多行数据

#### 配置示例

```yaml
input {
    stdin {
        codec => multiline {
            pattern => "^\["
            negate => true
            what => "previous"
        }
    }
}
```

#### 解释

其实这个插件的原理很简单，就是把当前行的数据添加到前面一行后面，，直到新进的当前行匹配 `^\[` 正则为止。

## 4. 过滤器插件

[过滤器库](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html)

------

### 4.1 date

[Date filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-date.html)

#### 配置示例

*filters/date* 插件支持五种时间格式：

##### ISO8601

类似 "2011-04-19T03:44:01.103Z" 这样的格式。具体Z后面可以有 "08:00"也可以没有，".103"这个也可以没有。常用场景里来说，Nginx 的 *log_format* 配置里就可以使用 `$time_iso8601` 变量来记录请求时间成这种格式。

##### UNIX

UNIX 时间戳格式，记录的是从 1970 年起始至今的总秒数。Squid 的默认日志格式中就使用了这种格式。

##### UNIX_MS

这个时间戳则是从 1970 年起始至今的总毫秒数。据我所知，JavaScript 里经常使用这个时间格式。

##### TAI64N

TAI64N 格式比较少见，是这个样子的：`@4000000052f88ea32489532c`。我目前只知道常见应用中， qmail 会用这个格式。

##### Joda-Time 库

Logstash 内部使用了 Java 的 Joda 时间库来作时间处理。所以我们可以使用 Joda 库所支持的时间格式来作具体定义。Joda 时间格式定义见下表：

##### 时间格式

| Symbol | Meaning                     | Presentation | Examples                           |
| ------ | --------------------------- | ------------ | ---------------------------------- |
| G      | era                         | text         | AD                                 |
| C      | century of era (>=0)        | number       | 20                                 |
| Y      | year of era (>=0)           | year         | 1996                               |
| x      | weekyear                    | year         | 1996                               |
| w      | week of weekyear            | number       | 27                                 |
| e      | day of week                 | number       | 2                                  |
| E      | day of week                 | text         | Tuesday; Tue                       |
| y      | year                        | year         | 1996                               |
| D      | day of year                 | number       | 189                                |
| M      | month of year               | month        | July; Jul; 07                      |
| d      | day of month                | number       | 10                                 |
| a      | halfday of day              | text         | PM                                 |
| K      | hour of halfday (0~11)      | number       | 0                                  |
| h      | clockhour of halfday (1~12) | number       | 12                                 |
| H      | hour of day (0~23)          | number       | 0                                  |
| k      | clockhour of day (1~24)     | number       | 24                                 |
| m      | minute of hour              | number       | 30                                 |
| s      | second of minute            | number       | 55                                 |
| S      | fraction of second          | number       | 978                                |
| z      | time zone                   | text         | Pacific Standard Time; PST         |
| Z      | time zone offset/id         | zone         | -0800; -08:00; America/Los_Angeles |
| '      | escape for text             | delimiter    |                                    |
| ''     | single quote                | literal      | '                                  |

http://joda-time.sourceforge.net/apidocs/org/joda/time/format/DateTimeFormat.html

下面我们写一个 Joda 时间格式的配置作为示例：

```yaml
filter {
    grok {
        match => ["message", "%{HTTPDATE:logdate}"]
    }
    date {
        match => ["logdate", "dd/MMM/yyyy:HH:mm:ss Z"]
    }
}
```

**注意：时区偏移量只需要用一个字母 `Z` 即可。**



### 4.2 elasticsearch

[Elasticsearch filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-elasticsearch.html)

#### 配置示例

```yaml
elasticsearch {
	hosts => ["es-server"]
	query => "type:start AND operation:%{[opid]}"
	fields => { "@timestamp" => "started" }
}
```



### 4.3 geoip

[Geoip filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-geoip.html)

#### 配置示例

```yaml
filter {
    geoip {
        source => "message"
    }
}
```

#### 配置说明

GeoIP 库数据较多，如果你不需要这么多内容，可以通过 `fields` 选项指定自己所需要的。下例为全部可选内容：

```
filter {
    geoip {
        fields => ["city_name", "continent_code", "country_code2", "country_code3", "country_name", "dma_code", "ip", "latitude", "longitude", "postal_code", "region_name", "timezone"]
    }
}
```

需要注意的是：`geoip.location` 是 logstash 通过 `latitude` 和 `longitude` 额外生成的数据。所以，如果你是想要经纬度又不想重复数据的话，应该像下面这样做：

filter { geoip { fields => ["city_name", "country_code2", "country_name", "latitude", "longitude", "region_name"] remove_field => ["[geoip][latitude]", "[geoip][longitude]"] } } ```

### 4.4 grok

[Grok filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html)

#### Grok 表达式语法

Grok 支持把预定义的 *grok 表达式* 写入到文件中，官方提供的预定义 grok 表达式见：https://github.com/logstash/logstash/tree/v1.4.2/patterns。

**注意：在新版本的logstash里面，pattern目录已经为空，最后一个commit提示core patterns将会由logstash-patterns-core gem来提供，该目录可供用户存放自定义patterns**

下面是从官方文件中摘抄的最简单但是足够说明用法的示例：

```
USERNAME [a-zA-Z0-9._-]+
USER %{USERNAME}
```

**第一行，用普通的正则表达式来定义一个 grok 表达式；第二行，通过打印赋值格式，用前面定义好的 grok 表达式来定义另一个 grok 表达式。**

grok 表达式的打印复制格式的完整语法是下面这样的：

```
%{PATTERN_NAME:capture_name:data_type}
```

*小贴士：data_type 目前只支持两个值：`int` 和 `float`。*

所以我们可以改进我们的配置成下面这样：

```yaml
filter {
    grok {
        match => {
            "message" => "%{WORD} %{NUMBER:request_time:float} %{WORD}"
        }
    }
}
```

重新运行进程然后可以得到如下结果：

```
{
         "message" => "begin 123.456 end",
        "@version" => "1",
      "@timestamp" => "2014-08-09T12:23:36.634Z",
            "host" => "raochenlindeMacBook-Air.local",
    "request_time" => 123.456
}
```

这次 *request_time* 变成数值类型了。

#### 最佳实践

实际运用中，我们需要处理各种各样的日志文件，如果你都是在配置文件里各自写一行自己的表达式，就完全不可管理了。所以，我们建议是把所有的 grok 表达式统一写入到一个地方。然后用 *filter/grok* 的 `patterns_dir` 选项来指明。

如果你把 "message" 里所有的信息都 grok 到不同的字段了，数据实质上就相当于是重复存储了两份。所以你可以用 `remove_field` 参数来删除掉 *message* 字段，或者用 `overwrite` 参数来重写默认的 *message* 字段，只保留最重要的部分。

重写参数的示例如下：

```yaml
filter {
    grok {
        patterns_dir => "/path/to/your/own/patterns"
        match => {
            "message" => "%{SYSLOGBASE} %{DATA:message}"
        }
        overwrite => ["message"]
    }
}
```



### 4.5 http

[HTTP filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-http.html)

#### 配置示例

```yaml
http {
	url => ""
}
```



### 4.6 json

[JSON filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-json.html)

#### 配置示例

```yaml
filter {
    json {
        source => "message"
        target => "jsoncontent"
    }
}
```



### 4.7 json_encode

[Json_encode filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-json_encode.html)

#### 配置示例

```yaml
json_encode {
	source => "foo"
	target => "bar"
}
```



### 4.8 mutate

[Mutate filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html)

#### 类型转换

类型转换是 *filters/mutate* 插件最初诞生时的唯一功能。

可以设置的转换类型包括："integer"，"float" 和 "string"。示例如下：

```yaml
filter {
    mutate {
        convert => ["request_time", "float"]
    }
}
```

**注意：mutate 除了转换简单的字符值，还支持对数组类型的字段进行转换，即将 `["1","2"]` 转换成 `[1,2]`。但不支持对哈希类型的字段做类似处理。有这方面需求的可以采用稍后讲述的 filters/ruby 插件完成。**

#### 字符串处理

- gsub

仅对字符串类型字段有效

```yaml
    gsub => ["urlparams", "[\\?#]", "_"]
```

- split

```yaml
filter {
    mutate {
        split => ["message", "|"]
    }
}
```

随意输入一串以`|`分割的字符，比如 "123|321|adfd|dfjld*=123"，可以看到如下输出：

```ruby
{
    "message" => [
        [0] "123",
        [1] "321",
        [2] "adfd",
        [3] "dfjld*=123"
    ],
    "@version" => "1",
    "@timestamp" => "2014-08-20T15:58:23.120Z",
    "host" => "raochenlindeMacBook-Air.local"
}
```

- join

仅对数组类型字段有效

我们在之前已经用 `split` 割切的基础再 `join` 回去。配置改成：

```yaml
filter {
    mutate {
        split => ["message", "|"]
    }
    mutate {
        join => ["message", ","]
    }
}
```

filter 区段之内，是顺序执行的。所以我们最后看到的输出结果是：

```ruby
{
    "message" => "123,321,adfd,dfjld*=123",
    "@version" => "1",
    "@timestamp" => "2014-08-20T16:01:33.972Z",
    "host" => "raochenlindeMacBook-Air.local"
}
```

- merge

合并两个数组或者哈希字段。依然在之前 split 的基础上继续：

```yaml
filter {
    mutate {
        split => ["message", "|"]
    }
    mutate {
        merge => ["message", "message"]
    }
}
```

我们会看到输出：

```ruby
{
       "message" => [
        [0] "123",
        [1] "321",
        [2] "adfd",
        [3] "dfjld*=123",
        [4] "123",
        [5] "321",
        [6] "adfd",
        [7] "dfjld*=123"
    ],
      "@version" => "1",
    "@timestamp" => "2014-08-20T16:05:53.711Z",
          "host" => "raochenlindeMacBook-Air.local"
}
```

如果 src 字段是字符串，会自动先转换成一个单元素的数组再合并。把上一示例中的来源字段改成 "host"：

```yaml
filter {
    mutate {
        split => ["message", "|"]
    }
    mutate {
        merge => ["message", "host"]
    }
}
```

结果变成：

```ruby
{
       "message" => [
        [0] "123",
        [1] "321",
        [2] "adfd",
        [3] "dfjld*=123",
        [4] "raochenlindeMacBook-Air.local"
    ],
      "@version" => "1",
    "@timestamp" => "2014-08-20T16:07:53.533Z",
          "host" => [
        [0] "raochenlindeMacBook-Air.local"
    ]
}
```

看，目的字段 "message" 确实多了一个元素，但是来源字段 "host" 本身也由字符串类型变成数组类型了！

下面你猜，如果来源位置写的不是字段名而是直接一个字符串，会产生什么奇特的效果呢？

- strip
- lowercase
- uppercase

#### 字段处理

- rename

重命名某个字段，如果目的字段已经存在，会被覆盖掉：

```yaml
filter {
    mutate {
        rename => ["syslog_host", "host"]
    }
}
```

- update

更新某个字段的内容。如果字段不存在，不会新建。

- replace

作用和 update 类似，但是当字段不存在的时候，它会起到 `add_field` 参数一样的效果，自动添加新的字段。

#### 执行次序

需要注意的是，filter/mutate 内部是有执行次序的。其次序如下：

```yaml
    rename(event) if @rename
    update(event) if @update
    replace(event) if @replace
    convert(event) if @convert
    gsub(event) if @gsub
    uppercase(event) if @uppercase
    lowercase(event) if @lowercase
    strip(event) if @strip
    remove(event) if @remove
    split(event) if @split
    join(event) if @join
    merge(event) if @merge

    filter_matched(event)
```

而 `filter_matched` 这个 filters/base.rb 里继承的方法也是有次序的。

```yaml
  @add_field.each do |field, value|
  end
  @remove_field.each do |field|
  end
  @add_tag.each do |tag|
  end
  @remove_tag.each do |tag|
  end
```



### 4.9 range

[Range filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-range.html)

#### 配置示例

```yaml
range {
	ranges => [ "message", 0, 10, "tag:short",
				"message", 11, 100, "tag:medium",
                    "message", 101, 1000, "tag:long",
                    "message", 1001, 1e1000, "drop",
                    "duration", 0, 100, "field:latency:fast",
                    "duration", 101, 200, "field:latency:normal",
                    "duration", 201, 1000, "field:latency:slow",
                    "duration", 1001, 1e1000, "field:latency:outlier",
                    "requests", 0, 10, "tag:too_few_%{host}_requests" ]
	}
}
```



### 4.10 split

[Split filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-split.html)

#### 配置示例

```yaml
filter {
    split {
        field => "message"
        terminator => "#"
    }
}
```

#### 重要提示

split 插件中使用的是 yield 功能，其结果是 split 出来的新事件，会直接结束其在 filter 阶段的历程，也就是说写在 split 后面的其他 filter 插件都不起作用，进入到 output 阶段。所以，一定要保证 **split 配置写在全部 filter 配置的最后**。

使用了类似功能的还有 clone 插件。

*注：从 logstash-1.5.0beta1 版本以后修复该问题。*

### 4.11 urldecode

[Urldecode filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-urldecode.html)

```yaml
urldecode {
	charset => "UTF-8"
}
```



------

## 5. 输出插件

[输出选择](https://www.elastic.co/guide/en/logstash/current/output-plugins.html)

------

### 5.1 elasticsearch

[Elasticsearch output plugin](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html)

#### 配置示例

```
output {
    elasticsearch {
        host => "192.168.0.2"
        protocol => "http"
        index => "logstash-%{type}-%{+YYYY.MM.dd}"
        index_type => "%{type}"
        workers => 5
        template_overwrite => true
    }
}
```

#### 解释

##### 协议

现在，新插件支持三种协议： *node*，*http* 和 *transport*。

一个小集群里，使用 *node* 协议最方便了。Logstash 以 elasticsearch 的 client 节点身份(即不存数据不参加选举)运行。如果你运行下面这行命令，你就可以看到自己的 logstash 进程名，对应的 `node.role` 值是 **c**：

```
# curl 127.0.0.1:9200/_cat/nodes?v
host       ip      heap.percent ram.percent load node.role master name
local 192.168.0.102  7      c         -      logstash-local-1036-2012
local 192.168.0.2    7      d         *      Sunstreak
```

特别的，作为一个快速运行示例的需要，你还可以在 logstash 进程内部运行一个**内嵌**的 elasticsearch 服务器。内嵌服务器默认会在 `$PWD/data` 目录里存储索引。如果你想变更这些配置，在 `$PWD/elasticsearch.yml` 文件里写自定义配置即可，logstash 会尝试自动加载这个文件。

对于拥有很多索引的大集群，你可以用 *transport* 协议。logstash 进程会转发所有数据到你指定的某台主机上。这种协议跟上面的 *node* 协议是不同的。*node* 协议下的进程是可以接收到整个 Elasticsearch 集群状态信息的，当进程收到一个事件时，它就知道这个事件应该存在集群内哪个机器的分片里，所以它就会直接连接该机器发送这条数据。而 *transport* 协议下的进程不会保存这个信息，在集群状态更新(节点变化，索引变化都会发送全量更新)时，就不会对所有的 logstash 进程也发送这种信息。更多 Elasticsearch 集群状态的细节，参阅http://www.elasticsearch.org/guide。

如果你已经有现成的 Elasticsearch 集群，但是版本跟 logstash 自带的又不太一样，建议你使用 *http* 协议。Logstash 会使用 POST 方式发送数据。

##### 小贴士

- Logstash 1.4.2 在 transport 和 http 协议的情况下是固定连接指定 host 发送数据。从 1.5.0 开始，host 可以设置数组，它会从节点列表中选取不同的节点发送数据，达到 Round-Robin 负载均衡的效果。
- Kibana4 强制要求 ES 全集群所有 node 版本在 1.4 以上，所以采用 node 方式发送数据的 logstash-1.4(携带的 Elasticsearch.jar 库是 1.1.1 版本) 会导致 Kibana4 无法运行，采用 Kibana4 的读者务必改用 http 方式。
- 开发者在 IRC freenode#logstash 频道里表示："高于 1.0 版本的 Elasticsearch 应该都能跟最新版 logstash 的 node 协议一起正常工作"。此信息仅供参考，请认真测试后再上线。

##### 性能问题

Logstash 1.4.2 在 http 协议下默认使用作者自己的 ftw 库，随同分发的是 0.0.39 版。该版本有[内存泄露问题](https://github.com/elasticsearch/logstash/issues/1604)，长期运行下输出性能越来越差！

解决办法：

1. 对性能要求不高的，可以在启动 logstash 进程时，配置环境变量ENV["BULK"]，强制采用 elasticsearch 官方 Ruby 库。命令如下：

    export BULK="esruby"

2. 对性能要求高的，可以尝试采用 logstash-1.5.0RC2 。新版的 outputs/elasticsearch 放弃了 ftw 库，改用了一个 JRuby 平台专有的 [Manticore 库](https://github.com/cheald/manticore/wiki/Performance)。根据测试，性能跟 ftw 比[相当接近](https://github.com/elasticsearch/logstash/pull/1777)。

3. 对性能要求极高的，可以手动更新 ftw 库版本，目前最新版是 0.0.42 版，据称内存问题在 0.0.40 版即解决。

#### 模板

Elasticsearch 支持给索引预定义设置和 mapping(前提是你用的 elasticsearch 版本支持这个 API，不过估计应该都支持)。Logstash 自带有一个优化好的模板，内容如下:

```json
{
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "5s"
  },
  "mappings" : {
    "_default_" : {
       "_all" : {"enabled" : true},
       "dynamic_templates" : [ {
         "string_fields" : {
           "match" : "*",
           "match_mapping_type" : "string",
           "mapping" : {
             "type" : "string", "index" : "analyzed", "omit_norms" : true,
               "fields" : {
                 "raw" : {"type": "string", "index" : "not_analyzed", "ignore_above" : 256}
               }
           }
         }
       } ],
       "properties" : {
         "@version": { "type": "string", "index": "not_analyzed" },
         "geoip"  : {
           "type" : "object",
             "dynamic": true,
             "path": "full",
             "properties" : {
               "location" : { "type" : "geo_point" }
             }
         }
       }
    }
  }
}
```

这其中的关键设置包括：

- template for index-pattern

只有匹配 `logstash-*` 的索引才会应用这个模板。有时候我们会变更 Logstash 的默认索引名称，记住你也得通过 PUT 方法上传可以匹配你自定义索引名的模板。当然，我更建议的做法是，把你自定义的名字放在 "logstash-" 后面，变成 `index => "logstash-custom-%{+yyyy.MM.dd}"` 这样。

- refresh_interval for indexing

Elasticsearch 是一个*近*实时搜索引擎。它实际上是每 1 秒钟刷新一次数据。对于日志分析应用，我们用不着这么实时，所以 logstash 自带的模板修改成了 5 秒钟。你还可以根据需要继续放大这个刷新间隔以提高数据写入性能。

- multi-field with not_analyzed

Elasticsearch 会自动使用自己的默认分词器(空格，点，斜线等分割)来分析字段。分词器对于搜索和评分是非常重要的，但是大大降低了索引写入和聚合请求的性能。所以 logstash 模板定义了一种叫"多字段"(multi-field)类型的字段。这种类型会自动添加一个 ".raw" 结尾的字段，并给这个字段设置为不启用分词器。简单说，你想获取 url 字段的聚合结果的时候，不要直接用 "url" ，而是用 "url.raw" 作为字段名。

- geo_point

Elasticsearch 支持 *geo_point* 类型， *geo distance* 聚合等等。比如说，你可以请求某个 *geo_point* 点方圆 10 千米内数据点的总数。在 Kibana 的 bettermap 类型面板里，就会用到这个类型的数据。

#### 其他模板配置建议

- doc_values

doc_values 是 Elasticsearch 1.3 版本引入的新特性。启用该特性的字段，索引写入的时候会在磁盘上构建 fielddata。而过去，fielddata 是固定只能使用内存的。在请求范围加大的时候，很容易触发 OOM 报错：

> ElasticsearchException[org.elasticsearch.common.breaker.CircuitBreakingException: Data too large, data for field [@timestamp] would be larger than limit of [639015321/609.4mb]]

doc_values 只能给不分词(对于字符串字段就是设置了 `"index":"not_analyzed"`，数值和时间字段默认就没有分词) 的字段配置生效。

doc_values 虽然用的是磁盘，但是系统本身也有自带 VFS 的 cache 效果并不会太差。据官方测试，经过 1.4 的优化后，只比使用内存的 fielddata 慢 15% 。所以，在数据量较大的情况下，**强烈建议开启**该配置：

```json
{
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "5s"
  },
  "mappings" : {
    "_default_" : {
       "_all" : {"enabled" : true},
       "dynamic_templates" : [ {
         "string_fields" : {
           "match" : "*",
           "match_mapping_type" : "string",
           "mapping" : {
             "type" : "string", "index" : "analyzed", "omit_norms" : true,
               "fields" : {
                 "raw" : { "type": "string", "index" : "not_analyzed", "ignore_above" : 256, "doc_values": true }
               }
           }
         }
       } ],
       "properties" : {
         "@version": { "type": "string", "index": "not_analyzed" },
         "@timestamp": { "type": "date", "index": "not_analyzed", "doc_values": true, "format": "dateOptionalTime" },
         "geoip"  : {
           "type" : "object",
             "dynamic": true,
             "path": "full",
             "properties" : {
               "location" : { "type" : "geo_point" }
             }
         }
       }
    }
  }
}
```

- order

如果你有自己单独定制 template 的想法，很好。这时候有几种选择：

1. 在 logstash/outputs/elasticsearch 配置中开启 `manage_template => false` 选项，然后一切自己动手；
2. 在 logstash/outputs/elasticsearch 配置中开启 `template => "/path/to/your/tmpl.json"` 选项，让 logstash 来发送你自己写的 template 文件；
3. 避免变更 logstash 里的配置，而是另外发送一个 template ，利用 elasticsearch 的 templates order 功能。

这个 order 功能，就是 elasticsearch 在创建一个索引的时候，如果发现这个索引同时匹配上了多个 template ，那么就会先应用 order 数值小的 template 设置，然后再应用一遍 order 数值高的作为覆盖，最终达到一个 merge 的效果。

比如，对上面这个模板已经很满意，只想修改一下 `refresh_interval` ，那么只需要新写一个：

```json
{
  "order" : 1,
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "20s"
  }
}
```

然后运行 `curl -XPUT http://localhost:9200/_template/template_newid -d '@/path/to/your/tmpl.json'` 即可。

logstash 默认的模板， order 是 0，id 是 logstash，通过 logstash/outputs/elasticsearch 的配置选项 `template_name` 修改。你的新模板就不要跟这个名字冲突了。

------

## 条件判断

[条件](https://www.elastic.co/guide/en/logstash/6.7/event-dependent-configuration.html#conditionals)

参考：[配置语法中的条件判断](https://windcoder.com/logstash6peizhiyufazhongdetiaojianpanduan)

### 条件语法

```
if EXPRESSION {
  ...
} else if EXPRESSION {
  ...
} else {
  ...
}
```

### 比较操作

- 相等: `==`, `!=`, `<`, `>`, `<=`, `>=`

- 正则: `=~`(匹配正则), `!~`(不匹配正则)

- 包含: `in`(包含), `not in`(不包含)

### 布尔操作

  - and(与), or(或), nand(非与), xor(非或)

### 一元运算符

- `!`(取反)

- `()`(复合表达式), `!()`(对复合表达式结果取反)


## 相关网站

[规则测试](http://grokdebug.herokuapp.com/)

[Logstash 最佳实践](https://doc.yonyoucloud.com/doc/logstash-best-practice-cn/index.html)

