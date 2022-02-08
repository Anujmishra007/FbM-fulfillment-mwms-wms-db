SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 Create VIEW [dbo].[V_rdsPODetailSize]  AS  
SELECT rdsPONo,
rdsPOLineNo,
SKU,
StorerKey,
Style,
Color,
Measurement,
Size,
UnitPrice,
Qty,
AddDate,
AddWho,
EditDate,
EditWho,
ArchiveCop,
TrafficCop
FROM rdsPODetailSize with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_rdsPODetailSize] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsPODetailSize] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsPODetailSize] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsPODetailSize] TO [NSQL]
GO
