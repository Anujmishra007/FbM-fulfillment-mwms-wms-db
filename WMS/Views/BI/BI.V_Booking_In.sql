SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--https://jiralfl.atlassian.net/browse/JPPGLS-37
CREATE  VIEW  [BI].[V_Booking_In] AS 
SELECT * 
FROM dbo.Booking_In WITH (NOLOCK)  
GO
GRANT SELECT ON  [BI].[V_Booking_In] TO [JReportRole]
GO
