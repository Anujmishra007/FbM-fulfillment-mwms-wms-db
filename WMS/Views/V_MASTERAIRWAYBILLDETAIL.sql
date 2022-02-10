SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_MASTERAIRWAYBILLDETAIL] 
AS 
SELECT [MAWBKEY]
, [MAWBLineNumber]
, [HAWBKEY]
, [NumberOfPieces]
, [GrossWeight]
, [UOMWeight]
, [RateClass]
, [Sku]
, [SkuDescription]
, [ChargeableWeight]
, [Rate]
, [Extension]
, [UOMVolume]
, [Length]
, [Width]
, [Height]
, [Notes]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [TimeStamp]
FROM [MASTERAIRWAYBILLDETAIL] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_MASTERAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_MASTERAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_MASTERAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_MASTERAIRWAYBILLDETAIL] TO [NSQL]
GO
