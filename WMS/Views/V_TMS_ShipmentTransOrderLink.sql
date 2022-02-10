SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[V_TMS_ShipmentTransOrderLink]
AS
Select * from dbo.[TMS_ShipmentTransOrderLink] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TMS_ShipmentTransOrderLink] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TMS_ShipmentTransOrderLink] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TMS_ShipmentTransOrderLink] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TMS_ShipmentTransOrderLink] TO [NSQL]
GO
