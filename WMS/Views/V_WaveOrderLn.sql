SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_WaveOrderLn]
AS
SELECT [Facility]
, [WaveKey]
, [OrderKey]
, [OrderLineNumber]
, [Sku]
, [StorerKey]
, [OpenQty]
, [QtyAllocated]
, [QtyPicked]
, [QtyReplenish]
, [UOM]
, [PackKey]
, [Status]
, [Lottable01]
, [Lottable02]
, [Lottable03]
, [Lottable04]
, [Lottable05]
, [Lottable06]
, [Lottable07]
, [Lottable08]
, [Lottable09]
, [Lottable10]
, [Lottable11]
, [Lottable12]
, [Lottable13]
, [Lottable14]
, [Lottable15]
, [LoadKey]
FROM [WaveOrderLn] (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_WaveOrderLn] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WaveOrderLn] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WaveOrderLn] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WaveOrderLn] TO [NSQL]
GO
