SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_HOUSEAIRWAYBILLDETAIL] 
AS 
SELECT [HAWBKEY]
, [HAWBLineNumber]
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
FROM [HOUSEAIRWAYBILLDETAIL] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
