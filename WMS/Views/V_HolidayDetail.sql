SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_HolidayDetail]
AS SELECT * FROM dbo.HolidayDetail
GO
GRANT DELETE ON  [dbo].[V_HolidayDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_HolidayDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_HolidayDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_HolidayDetail] TO [NSQL]
GO
