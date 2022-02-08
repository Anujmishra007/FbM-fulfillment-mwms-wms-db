SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TH_CustomerLotInfo]
AS Select * from  TH_CustomerLotInfo (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TH_CustomerLotInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TH_CustomerLotInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TH_CustomerLotInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TH_CustomerLotInfo] TO [NSQL]
GO
