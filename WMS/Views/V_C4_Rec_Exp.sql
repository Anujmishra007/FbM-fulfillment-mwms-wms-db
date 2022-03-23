SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_C4_Rec_Exp]
AS
SELECT [Messageh]
, [MessageDate]
, [Rev_Date]
, [PO_Number]
, [Buyer]
, [SupplyCode]
, [Head]
, [Line]
, [SKU]
, [Qty]
, [Best_Before_Date]
, [Status]
, [Documentkey]
, [Adddate]
, [EditDate]
FROM [C4_Rec_Exp] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_C4_Rec_Exp] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_C4_Rec_Exp] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_C4_Rec_Exp] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_C4_Rec_Exp] TO [NSQL]
GO
