SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[v_wms_perftrace]
as
select t.currenttime,
t.spid as Blocked_ID, t.eventinfo as Blocked_SQL, b.Blocking_ID, b.eventinfo as Blocking_SQL,
p.hostname as Blocked_Host, p.program_name as Blocked_Program,
b.hostname as Blocking_host, b.program_name as Blocking_Program,
p.waittype, p.waittime, p.lastwaittype, p.waitresource, DB_NAME(P.dbid)  AS [DB_Name]  
, Blocked_sql_handle_text = t.sql_handle_text
, Blocking_sql_handle_text = b.sql_handle_text
from wms_process p (nolock), wms_trace t (nolock), wms_blocking b (nolock)
where t.currenttime = p.currenttime and p.currenttime = b.currenttime
and p.spid = t.spid and p.spid = b.spid and p.blocked = b.blocking_id



GO

GRANT SELECT ON  [dbo].[v_wms_perftrace] TO [NSQL]
GO

