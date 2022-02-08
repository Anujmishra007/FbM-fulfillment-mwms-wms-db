SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_ChartOfAccounts] 
AS 
SELECT [ChartofAccountsKey]
, [Descrip]
, [SupportFlag]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
FROM [ChartOfAccounts] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_ChartOfAccounts] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ChartOfAccounts] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ChartOfAccounts] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ChartOfAccounts] TO [NSQL]
GO
