#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2019-12-10
# @Author  : Xiong Bin (i@xbdba.com)
# @Link    : http://www.xbdba.com
# @Name    : sendsms.py

import pymysql
import pymssql

mysql_conn = pymysql.connect("127.0.0.1","zabbix","zabbix","zabbix" )
mycursor = mysql_conn.cursor()

ms_conn = pymssql.connect(IP, USERNAME, PASSWORD, DATABASENAME)
mscursor = ms_conn.cursor()

mycursor.callproc('resize_alerts')
QurySql ="""select sendto,subject from all_alerts order by sendto,eventtime"""
mycursor.execute(QurySql)
data = mycursor.fetchall()

sql = "insert into 短信TABLE values (%s, %s, 'Zabbix', 0)"
for row in data:
        mscursor.execute(sql, (row[0], unicode(row[1], 'utf-8')))
ms_conn.commit()