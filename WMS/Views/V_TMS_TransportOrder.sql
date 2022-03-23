SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TMS_TransportOrder]
AS
Select * from dbo.[TMS_TransportOrder] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TMS_TransportOrder] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TMS_TransportOrder] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TMS_TransportOrder] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TMS_TransportOrder] TO [NSQL]
GO
