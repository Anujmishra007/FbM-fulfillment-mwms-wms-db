SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_idsStkTrfDoc]
AS
SELECT  [STDNo]
, [Facility]
, [TruckNo]
, [StorerKey]
, [DriverName]
, [Finalized]
, [DestCode]
, [WHSEID]
, [TrxType]
, [ReasonCode]
, [AddDate]
, [AddWho]
, [SourceID]
, [ArchiveCop]
FROM [idsStkTrfDoc] (NOLOCK)


GO
GRANT DELETE ON  [dbo].[V_idsStkTrfDoc] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_idsStkTrfDoc] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_idsStkTrfDoc] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_idsStkTrfDoc] TO [NSQL]
GO
