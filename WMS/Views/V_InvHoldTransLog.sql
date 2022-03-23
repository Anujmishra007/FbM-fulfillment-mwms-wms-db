SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_InvHoldTransLog]
AS
SELECT [StorerKey]
, [Sku]
, [Facility]
, [SourceKey]
, [SourceType]
, [UserID]
, [RowID]
, [Status]
, [AddWho]
, [AddDate]
, [EditWho]
, [EditDate]
, [Msgtext]
FROM [InvHoldTransLog] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_InvHoldTransLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_InvHoldTransLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_InvHoldTransLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_InvHoldTransLog] TO [NSQL]
GO
