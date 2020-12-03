## Docker安装数据库

### Oracle

```shell
docker run -d --restart=always --name myoracle11g -p 1521:1521 -p 8080:8080 -e ORACLE_ALLOW_REMOTE=true -e ORACLE_PWD=oracle oracleinanutshell/oracle-xe-11g
```

### MSSQL

```shell
docker run --restart=always --name MSSQL -m 512m -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=mssql@2020' -p 1433:1433 -d microsoft/mssql-server-linux
```

### MYSQL

```shell
docker run -itd --restart=always --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=mP4lN0qY9gK3jK4b mysql:5.6
```

