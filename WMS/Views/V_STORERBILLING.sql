SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_STORERBILLING] 
AS 
SELECT [StorerKey]
, [RSMinimumInvoiceCharge]
, [RSMinimumInvoiceTaxGroup]
, [RSMinimumInvoiceGLDist]
, [ISMinimumInvoiceCharge]
, [ISMinimumInvoiceTaxGroup]
, [ISMinimumInvoiceGLDist]
, [HIMinimumInvoiceCharge]
, [HIMinimumInvoiceTaxGroup]
, [HIMinimumInvoiceGLDist]
, [HOMinimumShipmentCharge]
, [HOMinimumShipmentTaxGroup]
, [HOMinimumShipmentGLDist]
, [ISMinimumReceiptCharge]
, [ISMinimumReceiptTaxGroup]
, [ISMinimumReceiptGLDist]
, [HIMinimumReceiptCharge]
, [HIMinimumReceiptTaxGroup]
, [HIMinimumReceiptGLDist]
, [InvoiceNumberStrategy]
, [BillingGroup]
, [LockBatch]
, [LockWho]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [STORERBILLING] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_STORERBILLING] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_STORERBILLING] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_STORERBILLING] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_STORERBILLING] TO [NSQL]
GO
