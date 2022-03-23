SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [BI].[V_PackTask]
AS SELECT RowRef
, Orderkey
, TaskBatchNo
, DevicePosition
, LogicalName
, OrderMode
, UDF01
, UDF02
, UDF03
, UDF04
, UDF05
, AddWho
, AddDate
, EditWho
, EditDate
, CAST (TrafficCop AS NVARCHAR) AS [TrafficCop]
, CAST( ArchiveCop AS NVARCHAR) AS [ArchiveCop]
, ReplenishmentGroup

FROM dbo.PackTask (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_PackTask] TO [JReportRole]
GO
