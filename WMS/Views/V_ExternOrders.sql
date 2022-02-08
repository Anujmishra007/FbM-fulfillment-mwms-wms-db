SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[V_ExternOrders]
as
Select * 
from DBO.ExternOrders (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ExternOrders] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ExternOrders] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ExternOrders] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ExternOrders] TO [NSQL]
GO
