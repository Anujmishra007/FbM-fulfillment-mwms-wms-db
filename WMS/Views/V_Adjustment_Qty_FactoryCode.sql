SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE View [dbo].[V_Adjustment_Qty_FactoryCode]
AS
SELECT DISTINCT a1.*, p.pokey, p.userdefine03 as Factorycode
FROM V_Adjustment_Qty a1, itrn i (nolock), receipt r (nolock), receiptdetail rd (nolock), 
	po p (nolock)
WHERE a1.lot = i.lot and i.sourcetype like '%ReceiptDetail%' 
and substring(i.sourcekey, 1, 10) = rd.receiptkey
and substring(i.sourcekey, 11, 15) = rd.receiptlinenumber
and rd.receiptkey = r.receiptkey
and rd.pokey *= p.pokey


GO
GRANT DELETE ON  [dbo].[V_Adjustment_Qty_FactoryCode] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Adjustment_Qty_FactoryCode] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Adjustment_Qty_FactoryCode] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Adjustment_Qty_FactoryCode] TO [NSQL]
GO
