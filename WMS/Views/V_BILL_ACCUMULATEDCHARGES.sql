SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_BILL_ACCUMULATEDCHARGES] 
AS 
SELECT [Ident]
, [AccumulatedChargesKey]
, [Descrip]
, [Status]
, [PrintCount]
, [ServiceKey]
, [StorerKey]
, [Sku]
, [Lot]
, [ID]
, [UOMShow]
, [TariffKey]
, [TariffDetailKey]
, [TaxGroupKey]
, [Rate]
, [Base]
, [MasterUnits]
, [SystemGeneratedCharge]
, [Debit]
, [Credit]
, [BilledUnits]
, [ChargeType]
, [LineType]
, [BillFromDate]
, [BillThruDate]
, [SourceKey]
, [SourceType]
, [AccessorialDetailKey]
, [GLDistributionKey]
, [InvoiceBatch]
, [InvoiceKey]
, [CostRate]
, [CostBase]
, [CostMasterUnits]
, [CostUOMShow]
, [CostSystemGeneratedCharge]
, [Cost]
, [CostUnits]
, [TrafficCop]
, [ReferenceKey]
, [ITRNSourceKey]
, [ITRNSourceType]
, [AddWho]
FROM [BILL_ACCUMULATEDCHARGES] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
