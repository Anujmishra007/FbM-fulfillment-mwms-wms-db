SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 Create VIEW [dbo].[V_rdsOrderDetailSize]  AS  
SELECT rdsOrderNo,
rdsOrderLineNo,
SKU,
StorerKey,
Style,
Color,
Measurement,
Size,
Qty,
AddDate,
AddWho,
EditDate,
EditWho,
ArchiveCop,
TrafficCop
FROM rdsOrderDetailSize with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_rdsOrderDetailSize] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsOrderDetailSize] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsOrderDetailSize] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsOrderDetailSize] TO [NSQL]
GO
