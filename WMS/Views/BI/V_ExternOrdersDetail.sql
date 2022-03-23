SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--https://jiralfl.atlassian.net/browse/WMS-14815
CREATE OR ALTER VIEW  [BI].[V_ExternOrdersDetail]
AS
SELECT *
FROM dbo.ExternOrdersDetail WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_ExternOrdersDetail] TO [JReportRole]
GO
