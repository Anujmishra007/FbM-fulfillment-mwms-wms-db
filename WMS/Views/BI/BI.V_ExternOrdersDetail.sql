SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--https://jiralfl.atlassian.net/browse/WMS-14815

CREATE  VIEW  [BI].[V_ExternOrdersDetail]
AS
SELECT * 
FROM dbo.ExternOrdersDetail WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_ExternOrdersDetail] TO [JReportRole]
GO
