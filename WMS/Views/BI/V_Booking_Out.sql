SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--https://jiralfl.atlassian.net/browse/JPPGLS-37
CREATE OR ALTER VIEW  [BI].[V_Booking_Out] AS
SELECT *
FROM dbo.Booking_Out WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_Booking_Out] TO [JReportRole]
GO
