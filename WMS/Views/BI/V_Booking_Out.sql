SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--https://jiralfl.atlassian.net/browse/JPPGLS-37
CREATE  VIEW  [BI].[V_Booking_Out] AS 
SELECT * 
FROM dbo.Booking_Out WITH (NOLOCK)  
GO
GRANT SELECT ON  [BI].[V_Booking_Out] TO [JReportRole]
GO
