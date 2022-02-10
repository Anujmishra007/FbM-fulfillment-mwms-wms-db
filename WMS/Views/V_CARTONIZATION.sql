SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_CARTONIZATION] 
AS 
SELECT [CartonizationKey]
, [CartonizationGroup]
, [CartonType]
, [CartonDescription]
, [UseSequence]
, [Cube]
, [MaxWeight]
, [MaxCount]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [Timestamp]
, [CartonWeight]
, [CartonLength]
, [CartonWidth]
, [CartonHeight]
FROM [CARTONIZATION] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_CARTONIZATION] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_CARTONIZATION] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_CARTONIZATION] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_CARTONIZATION] TO [NSQL]
GO
