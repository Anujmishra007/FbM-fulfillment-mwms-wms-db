SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE VIEW [RDT].[V_RDT_TOTAL_TIMINGS] AS
select convert(char(10),starttime,120) TransDate, count(*) TotalTrans, sum(timetaken)/count(*) AVGTime
 from rdt.rdttrace (nolock)
group by convert(char(10),starttime,120)




GO
GRANT DELETE ON  [RDT].[V_RDT_TOTAL_TIMINGS] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[V_RDT_TOTAL_TIMINGS] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[V_RDT_TOTAL_TIMINGS] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[V_RDT_TOTAL_TIMINGS] TO [NSQL]
GO
