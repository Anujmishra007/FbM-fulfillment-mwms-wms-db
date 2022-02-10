SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_Holiday] 
AS 
SELECT [HolidayKey]
, [Holiday]
, [DayDesc]
, [DayOfWeek]
FROM [Holiday] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_Holiday] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Holiday] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Holiday] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Holiday] TO [NSQL]
GO
