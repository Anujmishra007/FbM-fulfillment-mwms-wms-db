SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [RDT].[V_RDT_TIMINGS_SUM] AS
select convert(char(10),starttime,120) TransDate ,substring(convert(char(13),starttime,120),12,2) Hour24,
(SUM(CASE WHEN TIMETAKEN > 1000 THEN 1 ELSE 0 END))TransOver1000ms,
count(*) TotalTrans  from rdt.rdttrace (nolock)
group by convert(char(10),starttime,120), substring(convert(char(13),starttime,120),12,2)



GO
GRANT DELETE ON  [RDT].[V_RDT_TIMINGS_SUM] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[V_RDT_TIMINGS_SUM] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[V_RDT_TIMINGS_SUM] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[V_RDT_TIMINGS_SUM] TO [NSQL]
GO
