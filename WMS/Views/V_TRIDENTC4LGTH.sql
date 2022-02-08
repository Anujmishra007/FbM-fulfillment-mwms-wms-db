SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TRIDENTC4LGTH] 
AS 
SELECT [TridentSchedulerKey]
, [Hikey]
, [HiImpExp]
, [NextRunDate]
, [LastRunDate]
, [Frequency]
, [StartWindow]
, [StartString]
, [EnableFlag]
, [SkipDays]
, [SkipTime]
, [AddDate]
, [AddWho]
FROM [TRIDENTC4LGTH] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_TRIDENTC4LGTH] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TRIDENTC4LGTH] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TRIDENTC4LGTH] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TRIDENTC4LGTH] TO [NSQL]
GO
