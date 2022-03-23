SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_HolidayHeader]
AS SELECT * FROM dbo.HolidayHeader
GO
GRANT DELETE ON  [dbo].[V_HolidayHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_HolidayHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_HolidayHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_HolidayHeader] TO [NSQL]
GO
