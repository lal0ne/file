## 客户端

```shell
# 数据源
source s_sys { file("/var/log/messages"); internal(); };
# 发送目标
destination log_server { tcp("10.10.100.166" port(514)); };
# 发送数据
log { source(s_sys); destination(log_server); };

# s_sys 自定义命名
# log_server 自定义命名
# source、destination、log 固定格式
```

## 服务端

暂未用到，待补充...