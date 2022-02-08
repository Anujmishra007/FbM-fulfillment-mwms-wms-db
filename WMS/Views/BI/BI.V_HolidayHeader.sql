SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--https://jiralfl.atlassian.net/browse/JPPGLS-69
CREATE VIEW [BI].[V_HolidayHeader]  
AS 
SELECT * FROM dbo.HolidayHeader  
GO
GRANT SELECT ON  [BI].[V_HolidayHeader] TO [JReportRole]
GO
