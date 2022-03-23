SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_WMSOrderQTY]
AS
select externorderkey, externlineno, sku,
CASE UOM WHEN Packuom1 THEN (qtyallocated+qtypicked+shippedqty) / casecnt
         WHEN Packuom2 Then (qtyallocated+qtypicked+shippedqty) / innerpack
         WHEN Packuom3 Then (qtyallocated+qtypicked+shippedqty)
         WHEN Packuom4 Then (qtyallocated+qtypicked+shippedqty) / pallet
END AS 'Qty'
from orderdetail (nolock)
   JOIN PACK (NOLOCK) ON (PACK.PackKey = OrderDetail.PackKey)
   JOIN TransmitLog (NOLOCK) ON (TransmitLog.Key1 = OrderDetail.OrderKey AND
                                 TransmitLog.TransmitFlag = '9' AND
                                 TransmitLog.TableName = 'OWORDALLOC')






GO
GRANT DELETE ON  [dbo].[V_WMSOrderQTY] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WMSOrderQTY] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WMSOrderQTY] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WMSOrderQTY] TO [NSQL]
GO
