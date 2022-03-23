SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_InvHoldSkuLog]
AS
SELECT [StorerKey]
, [Sku]
, [Facility]
, [PreHoldQty]
, [OnHoldQty]
, [TranStatus]
, [AddWho]
, [AddDate]
, [EditWho]
, [EditDate]
, [Msgtext]
FROM [InvHoldSkuLog] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_InvHoldSkuLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_InvHoldSkuLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_InvHoldSkuLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_InvHoldSkuLog] TO [NSQL]
GO
