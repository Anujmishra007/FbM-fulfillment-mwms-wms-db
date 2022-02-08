SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_UploadPODetail] 
AS 
SELECT [POkey]
, [PoLineNumber]
, [Storerkey]
, [ExternPOkey]
, [POGroup]
, [ExternLinenumber]
, [SKU]
, [QtyOrdered]
, [UOM]
, [MODE]
, [STATUS]
, [REMARKS]
, [adddate]
, [Best_bf_Date]
, [ExpiryDate]
, [SerialLot]
FROM [UploadPODetail] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_UploadPODetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_UploadPODetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_UploadPODetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_UploadPODetail] TO [NSQL]
GO
