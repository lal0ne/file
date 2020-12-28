说明：

​	使用ssh 登录A机器（IP：1.1.1.1） 的 2333 端口，可以自动跳转到 B机器（IP：2.2.2.2）上，其中B机器的 ssh 登录端口就是默认的 22。

1. iptables 端口转发打开

   ```sh
   vi /etc/sysctl.conf
   
   # 修改如下内容，如果不存在就创建该内容
   net.ipv4.ip_forward=1
   
   # 保存退出后，运行一下命令使其生效
   sysctl -p
   ```

2. 两台机器可以联通

3. iptables 的 filter 下面的 FORWARD 默认策略要是 ACCEPT

   ```sh
   iptables -P FORWARD ACCEPT
   ```

4. iptables 转发

   ```sh
   iptables -t nat -A PREROUTING -d 1.1.1.1 -p tcp --dport 2333 -j DNAT --to-destination 2.2.2.2:22
   iptables -t nat -A POSTROUTING -d 2.2.2.2 -p tcp --dport 22 -j SNAT --to 1.1.1.1
   service iptables save
   service iptables restart
   ```

注意，在A机器上配置时把本机IP写成实际的 IPv4 地址就行。