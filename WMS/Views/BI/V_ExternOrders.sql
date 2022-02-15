SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--https://jiralfl.atlassian.net/browse/WMS-14815

CREATE  VIEW  [BI].[V_ExternOrders]
AS
SELECT * 
FROM dbo.ExternOrders WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_ExternOrders] TO [JReportRole]
GO
