SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PalletMaster] 
AS 
SELECT [Pallet_type]
, [Descr]
, [Maxcube]
, [Maxwgt]
, [Maxunit]
, [AddWho]
, [AddDate]
, [EditWho]
, [EditDate]
FROM [PalletMaster] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PalletMaster] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PalletMaster] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PalletMaster] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PalletMaster] TO [NSQL]
GO
