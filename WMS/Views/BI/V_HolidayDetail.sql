SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--https://jiralfl.atlassian.net/browse/JPPGLS-69
CREATE OR ALTER VIEW [BI].[V_HolidayDetail]
AS
SELECT * FROM dbo.HolidayDetail
GO
GRANT SELECT ON  [BI].[V_HolidayDetail] TO [JReportRole]
GO
