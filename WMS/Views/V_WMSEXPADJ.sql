SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_WMSEXPADJ] 
AS 
SELECT [Adjustmentkey]
, [CustomerRefNo]
, [AdjustmentType]
, [AdjustmentLineNumber]
, [SKU]
, [Lottable01]
, [Lottable02]
, [Lottable03]
, [Lottable04]
, [Lottable05]
, [Qty]
, [ReasonCode]
, [HOSTWHCODE]
, [TRANSFLAG]
FROM [WMSEXPADJ] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_WMSEXPADJ] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WMSEXPADJ] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WMSEXPADJ] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WMSEXPADJ] TO [NSQL]
GO
