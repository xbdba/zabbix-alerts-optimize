CREATE DEFINER=`zabbix`@`%` PROCEDURE `resize_alerts`( )
BEGIN   

start transaction;

-- 清空临时表
TRUNCATE TABLE tmp_alerts;
truncate table all_alerts;
  
-- 初始化要处理的告警数据
INSERT INTO tmp_alerts
select eventid,clock,sendto,triggername,hostname,itemvalue,eventtime,esc_step,p_eventid,STATUS from (
SELECT a.eventid,
       a.clock,
       a.sendto,
       substring_index(SUBJECT, '#', 1) triggername,
       substring_index(substring_index(SUBJECT, '#', 2), '#', -1) hostname,
       substring_index(substring_index(SUBJECT, '#', 4), '#', -1) itemvalue,
       substring_index(message, '：', -1) eventtime,
       a.esc_step,
       a.p_eventid,
       CASE
       
         WHEN a.p_eventid IS NULL THEN
          1
         ELSE
          0
       END STATUS,@row_num :=
IF
  ( @pre_value = concat_ws('', a.eventid, a.sendto ), @row_num + 1, 1 ) as rownumber,
  @pre_value := concat_ws( '', a.eventid, a.sendto )
  FROM alerts a, events b,( SELECT @row_num := 1 ) x,
  ( SELECT @prev_value := '' ) y 
 WHERE a.clock > UNIX_TIMESTAMP(date_add(now(), INTERVAL - 4 MINUTE))
   -- AND a.eventid > (SELECT max(eventid) FROM his_alerts)
   AND (a.eventid, a.esc_step) not in(SELECT eventid,esc_step FROM his_alerts)
   AND STATUS = 1
   AND mediatypeid = 3
   AND a.eventid = b.eventid
 ORDER BY eventid,
  sendto) aa
where rownumber=1
order by 1;

-- 归档告警数据 
INSERT INTO his_alerts
  SELECT * FROM tmp_alerts;

-- 删除周期内已经恢复的告警 
DELETE FROM tmp_alerts
 WHERE eventid IN
       (SELECT eventid
          FROM (SELECT a.eventid
                  FROM tmp_alerts a
                 WHERE eventid IN (SELECT p_eventid FROM tmp_alerts)
                UNION ALL
                SELECT a.eventid
                  FROM tmp_alerts a
                 WHERE p_eventid IN (SELECT eventid FROM tmp_alerts)) aa);

-- 合并相同主机多个告警 
insert into all_alerts(sendto, subject, eventtime)
  select sendto,
         subject,
         substr(subject, instr(subject, '告警时间:') + 5) eventtime
    from (select sendto,
                 concat(case
                          when status = '0' then
                           '【恢复OK】: '
                          else
                           '【故障PROBLEM】: '
                        end,
                        triggername,
                        ' 主机:',
                        hostname,
                        case
                          when triggername in
                               ('Oracle日志报错！', '表空间使用率超过90%','ogg日志报错') and status = '1' then
                           concat(' 问题详情:', itemvalue)
                          else
                           ''
                        end,
                        ' 告警时间:',
                        eventtime) subject
            from (select sendto,
                         group_concat(triggername order by eventtime) triggername,
                         hostname,
                         min(itemvalue) itemvalue,
                         min(eventtime) eventtime,
                         status
                    from tmp_alerts
                   group by sendto, hostname, status
                  having count(1) > 1
                   order by eventtime) aa) bb;

-- 删除已经合并的相同主机多个告警

delete from tmp_alerts
 where eventid in
       (select eventid
          from (select eventid
                  from tmp_alerts a
                 where EXISTS (select 1
                          from (select group_concat(eventid) eventid,
                                       sendto,
                                       group_concat(triggername) triggername,
                                       hostname,
                                       min(itemvalue) itemvalue,
                                       min(eventtime) eventtime,
                                       status
                                  from tmp_alerts a
                                 group by sendto, hostname, status
                                having count(1) > 1
                                 order by eventtime) aa
                         where a.sendto = aa.sendto
                           and a.status = aa.status
                           and instr(aa.eventid, a.eventid) > 0)) mm);

-- 合并剩余的多个主机相同告警

insert into all_alerts
  (sendto, subject, eventtime)
  select sendto,
         subject,
         substr(subject, instr(subject, '告警时间:') + 5) eventtime
    from (select sendto,
                 concat(case
                          when status = '0' then
                           '【恢复OK】: '
                          else
                           '【故障PROBLEM】: '
                        end,
                        triggername,
                        ' 主机:',
                        hostname,
                        case
                          when cnt = '1' then
                           ''
                          else
                           concat(' 等', cnt, '台主机')
                        end,
                        case
                          when triggername in
                               ('Oracle日志报错！', '表空间使用率超过90%','ogg日志报错') and status = '1' then
                           concat(' 问题详情:', itemvalue)
                          else
                           ''
                        end,
                        ' 告警时间:',
                        eventtime) subject
            from (select sendto,
                         triggername,
                         max(hostname) hostname,
                         min(itemvalue) itemvalue,
                         min(eventtime) eventtime,
                         status,
                         count(1) cnt
                    from tmp_alerts a
                   group by sendto, triggername, status
                   order by eventtime) aa) bb;

-- 归档已发送短信数据 
insert into all_alerts_history
  (sendto, subject, eventtime)
  select * from all_alerts;

commit;

END
