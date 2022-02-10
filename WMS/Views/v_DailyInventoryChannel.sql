SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE VIEW [dbo].[v_DailyInventoryChannel]
AS
Select   * from dbo.DailyInventoryChannel (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[v_DailyInventoryChannel] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[v_DailyInventoryChannel] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[v_DailyInventoryChannel] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[v_DailyInventoryChannel] TO [NSQL]
GO
