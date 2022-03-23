SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_UPLOADORDERDETAIL]
AS
SELECT [Orderkey]
, [Orderlinenumber]
, [ExternOrderkey]
, [OrderGroup]
, [SKU]
, [Storerkey]
, [Openqty]
, [Packkey]
, [UOM]
, [ExternLineno]
, [ExtendedPrice]
, [UnitPrice]
, [Facility]
, [Mode]
, [status]
, [remarks]
, [adddate]
, [Lottable01]
, [Lottable02]
, [Lottable03]
, [Lottable04]
, [Lottable05]
FROM [UPLOADORDERDETAIL] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_UPLOADORDERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_UPLOADORDERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_UPLOADORDERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_UPLOADORDERDETAIL] TO [NSQL]
GO
