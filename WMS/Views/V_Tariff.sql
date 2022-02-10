SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_Tariff] 
AS 
SELECT [TariffKey]
, [Descrip]
, [SupportFlag]
, [InitialStoragePeriod]
, [RecurringStoragePeriod]
, [SplitMonthDay]
, [SplitMonthPercent]
, [PeriodType]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [CalendarGroup]
, [RSPeriodType]
, [SplitMonthPercentBefore]
, [CaptureEndOfMonth]
FROM [Tariff] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_Tariff] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Tariff] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Tariff] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Tariff] TO [NSQL]
GO
