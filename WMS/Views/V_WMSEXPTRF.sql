SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_WMSEXPTRF]
AS
SELECT [Transferkey]
, [ReasonCode]
, [CustomerRefNo]
, [TransferLineNumber]
, [FROMSKU]
, [FROMQty]
, [FROMWHCODE]
, [FROMLottable01]
, [FROMLottable02]
, [FromLottable03]
, [FROMLottable04]
, [FromLottable05]
, [TOSKU]
, [TOQty]
, [TOWHCODE]
, [ToLottable01]
, [ToLottable02]
, [ToLottable03]
, [ToLottable04]
, [ToLottable05]
, [TRANSFLAG]
FROM [WMSEXPTRF] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_WMSEXPTRF] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WMSEXPTRF] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WMSEXPTRF] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WMSEXPTRF] TO [NSQL]
GO
