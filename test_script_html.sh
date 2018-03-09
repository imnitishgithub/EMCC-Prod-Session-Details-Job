##Instatiate Variables
SID=$1
##### Verify sid input
if [ -z "$1" ]
then
  echo "Required parameter DBNAME is missing"
  echo " Usage is loadtest.sh dbname "
  echo "       Script is terminating!"
  exit 1
fi

sqlplus -s "sysman_read1/AYU45DW@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=emccef-scan.us.oracle.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=adcemcc.us.oracle.com)))" <<EOF  >report.html
SET echo off feed off MARKUP HTML ON SPOOL ON PREFORMAT ON ENTMAP OFF -
HEAD "<TITLE>PEO EM Monitoring Team Dashboard</TITLE>"
set pages 10000
COLUMN name HEADING "DB Name" FORMAT A10
COLUMN sessions HEADING "Sessions" FORMAT 9999
COLUMN active HEADING "Active" FORMAT 9999
COLUMN inactive HEADING "Inactive" FORMAT 9999
COLUMN instance_name HEADING "Instance" FORMAT A10
COLUMN osuser HEADING "OS User" FORMAT A10
COLUMN schemaname HEADING "DB User" FORMAT A10
COLUMN module HEADING "Module" FORMAT A45
COLUMN event HEADING "Event" FORMAT A30
COLUMN machine HEADING "Machine" FORMAT A30
COLUMN count HEADING "Count" FORMAT 9999
set lines 165

select d.name, to_char(sysdate,'DD-MON-YY HH24:MI:SS') "Date", gs.sessions, gs1.active, gs2.inactive from
(select name from v\$database) d,
(select count(1) sessions from v\$session) gs,
(select count(1) active   from v\$session where status='ACTIVE') gs1,
(select count(1) inactive   from v\$session where status='INACTIVE') gs2;

select   gi.instance_name, gs.machine, gs.osuser, gs.schemaname, count (gs.sid) count -
from v\$session gs, v\$instance gi where type<>'BACKGROUND' -
group by gi.instance_name, gs.machine, gs.osuser, gs.schemaname order by 5 desc;

EOF



cat report.html >> report_full.html