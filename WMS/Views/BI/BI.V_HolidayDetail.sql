SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--https://jiralfl.atlassian.net/browse/JPPGLS-69
CREATE VIEW [BI].[V_HolidayDetail]  
AS 
SELECT * FROM dbo.HolidayDetail  
GO
GRANT SELECT ON  [BI].[V_HolidayDetail] TO [JReportRole]
GO
