SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--https://jiralfl.atlassian.net/browse/WMS-14815
CREATE OR ALTER VIEW  [BI].[V_ExternOrders]
AS
SELECT *
FROM dbo.ExternOrders WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_ExternOrders] TO [JReportRole]
GO
