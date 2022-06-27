#!/bin/bash
#__author__ : lalone
#__data__ : 2022-06-27

# export TERM=linux

# 读取地址
read -p "请输入MySQL的地址：(127.0.0.1)" HOST
HOST=${HOST:-127.0.0.1}
# 读取账号
read -p "请输入MySQL的账号：(root)" USER
USER=${USER:-root}
# 读取密码
read -s -p "请输入MySQL的密码：" PASSWORD
PASSWORD=${PASSWORD:-}
echo ""
# 读取端口
read -p "请输入MySQL的端口：(3306)" PORT
PORT=${PORT:-3306}

while : 
do
    # 选择执行的操作
    echo '(1) 查看所有数据库'
    # mysql -uroot -p -e "show databases"
    echo '(2) 导出所有数据库'
    # mysqldump -uroot -p --all-databases --add-drop-database --set-gtid-purged=OFF > mysqldump.sql  
    echo '(3) 导出特定数据库'
    # mysqldump -uroot -p --databases {db} --add-drop-database --set-gtid-purged=OFF > mysqldump.sql
    echo '(4) 导入特定数据库'
    # mysql -uroot -p < mysqldump.sql
    echo '(5) 查看特定数据库所有数据表'
    # mysql -uroot -p -e "select table_name from information_schema.tables where table_schema='{db}'"
    echo '(6) 查看特定数据库特定数据表'
    # mysql -uroot -p -e "select * from {db}.{table}"
    echo '(7) 导出特定数据库特定数据表'
    # mysqldump -uroot -p --add-drop-table --set-gtid-purged=OFF {db} {table} > mysqldump.sql
    echo '(8) 导入特定数据库特定数据表'
    # mysql -uroot -p {db} < mysqldump.sql
    echo '(9) 执行自定义SQL语句'
    # read -p "SQL语句" -a query
    # QUERY=`echo "${query[@]}"`
    # mysql -u$USER -p$PASSWORD -P$PORT -e "$QUERY"
    echo '(10) 退出'
    read -p '选择执行的操作:(1)' aNum
    aNum=${aNum:-1}
    case $aNum in
        1)  echo ''
            echo '查看所有数据库'
            mysql -u$USER -p$PASSWORD -P$PORT -e "show databases"
            echo ''
        ;;
        2)  echo ''
            echo '导出所有数据库'
            mysqldump -u$USER -p$PASSWORD -P$PORT --all-databases --add-drop-database --set-gtid-purged=OFF > mysqldump.sql
            echo ''
        ;;
        3)  echo ''
            echo '导出特定数据库'
            read -p "数据库名称：" DATABASE
            mysqldump -u$USER -p$PASSWORD -P$PORT --databases $DATABASE --add-drop-database --set-gtid-purged=OFF > mysqldump.sql
            echo ''
        ;;
        4)  echo ''
            echo '导入特定数据库'
            read -p "数据库文件：(mysqldump.sql)" DATABASEFILENAME
            DATABASEFILENAME=${DATABASEFILENAME:-mysqldump.sql}
            mysql -u$USER -p$PASSWORD -P$PORT < $DATABASEFILENAME
            echo ''
        ;;
        5)  echo ''
            echo '查看特定数据库所有数据表'
            read -p "数据库：" DATABASE
            mysql -u$USER -p$PASSWORD -P$PORT -e "select table_name from information_schema.tables where table_schema='$DATABASE'"
            echo ''
        ;;
        6)  echo ''
            echo '查看特定数据库特定数据表'
            read -p "数据库：" DATABASE
            read -p "数据表：" TABLE
            mysql -u$USER -p$PASSWORD -P$PORT -e "select * from $DATABASE.$TABLE"
            echo ''
        ;;
        7)  echo ''
            echo '导出特定数据库特定数据表'
            read -p "数据库：" DATABASE
            read -p "数据表：" TABLE
            mysqldump -u$USER -p$PASSWORD -P$PORT --add-drop-table --set-gtid-purged=OFF $DATABASE $TABLE > mysqldump.sql
            echo ''
        ;;
        8)  echo ''
            echo '导入特定数据库特定数据表'
            read -p "数据库：" DATABASE
            read -p "数据库文件：(mysqldump.sql)" DATABASEFILENAME
            DATABASEFILENAME=${DATABASEFILENAME:-mysqldump.sql}
            mysql -u$USER -p$PASSWORD -P$PORT $DATABASE < $DATABASEFILENAME
            echo ''
        ;;
        9)  echo ''
            echo '执行自定义SQL语句'
            echo "Example: select table_name from information_schema.tables where table_schema='mysql'"
            read -p "SQL语句:" -a query
            QUERY=`echo "${query[@]}"`
            mysql -u$USER -p$PASSWORD -P$PORT -e "$QUERY"
            echo ''
        ;;
        10)  exit 1
        ;;
        *)  echo ''
            echo "请选择正确的选项"
            echo ''
        ;;
    esac

done