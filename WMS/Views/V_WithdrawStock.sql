SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
  
  
 CREATE VIEW [dbo].[V_WithdrawStock]   
AS   
SELECT [StorerKey]  
, [SKU]  
, [LOT]  
, [ID]  
, [Loc]  
, [Qty]  
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
, [RowId]  
, [Sourcekey]  
, [Sourcetype]  
FROM [WithdrawStock] (NOLOCK)   
  
GO
GRANT DELETE ON  [dbo].[V_WithdrawStock] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WithdrawStock] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WithdrawStock] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WithdrawStock] TO [NSQL]
GO
