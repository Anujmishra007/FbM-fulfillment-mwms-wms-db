SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 

CREATE VIEW [dbo].[V_TMS_Shipment]
AS
Select * from dbo.[TMS_Shipment] (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_TMS_Shipment] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TMS_Shipment] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TMS_Shipment] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TMS_Shipment] TO [NSQL]
GO
