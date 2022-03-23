SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_KIT]
AS
SELECT [KITKey]
, [StorerKey]
, [ToStorerKey]
, [Type]
, [OpenQty]
, [Status]
, [EffectiveDate]
, [ReasonCode]
, [CustomerRefNo]
, [Remarks]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [Timestamp]
, [GenerateHOCharges]
, [GenerateIS_HiCharges]
, [Facility]
, [USRDEF1]
, [USRDEF2]
, [USRDEF3]
, [ActionFlag]
, [ExternKitKey]
FROM [KIT] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_KIT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_KIT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_KIT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_KIT] TO [NSQL]
GO
