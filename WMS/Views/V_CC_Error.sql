SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_CC_Error]
AS
SELECT [StorerKey]
, [Sku]
, [Lot]
, [ID]
, [Loc]
, [Qty]
, [Remark]
, [AddDate]
FROM [CC_Error] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_CC_Error] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_CC_Error] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_CC_Error] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_CC_Error] TO [NSQL]
GO
