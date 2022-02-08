SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TaxGroup] 
AS 
SELECT [TaxGroupKey]
, [SupportFlag]
, [Descrip]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [TaxGroup] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_TaxGroup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TaxGroup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TaxGroup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TaxGroup] TO [NSQL]
GO
