SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_FxRATE] 
AS 
SELECT [CurrencyKey]
, [Descrip]
, [BaseCurrency]
, [TargetCurrency]
, [ConversionRate]
, [FxDate]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [FxRATE] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_FxRATE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_FxRATE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_FxRATE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_FxRATE] TO [NSQL]
GO
