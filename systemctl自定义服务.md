# systemctl自定义服务

## 示例

```shell
[Unit]
Description=<描述>
# 弱依赖关系
Wants=network.target network-online.target
# 在该服务启动后执行
After=network.target network-online.target

[Service]
# Type
#		simple		ExecStart字段启动的进程为主进程
#		forking		ExecStart字段将以fork()方式启动，此时父进程将会退出，子进程将成为主进程
#		oneshot		类似于simple，但只执行一次，Systemd 会等它执行完，才启动其他服务
#		dbus		类似于simple，但会等待 D-Bus 信号后启动
#		notify		类似于simple，启动结束后会发出通知信号，然后 Systemd 再启动其他服务
#		idle		类似于simple，但是要等到其他任务都执行完，才会启动该服务。一种使用场合是为让该服务的输出，不与其他服务的输出相混合
Type=simple
# 启动进程时执行的命令
ExecStart=/usr/bin/python3 /usr/local/timer_tasks/timer_tasks.py
# 停止服务时执行的命令
ExecStop=ps -aux | grep "timer_tasks.py" | grep -v "grep" | awk '{print $2}' | xargs kill -9
#RestartSec=2
#UMask=0066
#StandardOutput=null
#Restart=on-failure
# ps -aux | grep "timer_tasks.py" | grep -v "grep" | awk '{print $2}' | xargs kill -9
# Increase the default a bit in order to allow many simultaneous
# files to be monitored, we might need a lot of fds.
# LimitNOFILE=16384

[Install]
# 示该服务所在的 Target
WantedBy=multi-user.target
# 进行一个链接的别名的意思
Alias=py-tasks.service

```

