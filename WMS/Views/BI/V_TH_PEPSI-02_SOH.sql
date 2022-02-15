SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [BI].[V_TH_PEPSI-02_SOH] as 
SELECT
   X.StorerKey,
   S.SKUGROUP,
   X.Sku,
   X.Qty,
   P.PackUOM1,
   A.Lottable02,
   A.Lottable05,
   DATEDIFF ( dy, A.Lottable05, 
   (
      GETDATE()
   )
) as'Aging',
   X.QtyAllocated,
   X.QtyPicked,
   X.QtyExpected,
   (
      X.Qty
   )
   - ((X.QtyPicked) + (X.QtyAllocated)) as 'QTY Avl',
   A.Lottable01,
   X.Loc,
   A.Lottable03,
   GETDATE() as 'Date',
   X.Id,
   S.DESCR,
   A.Lottable06 
FROM
   dbo.LOTxLOCxID X with (nolock)
JOIN dbo.LOTATTRIBUTE A with (nolock) ON X.StorerKey = A.StorerKey 
      AND X.Lot = A.Lot 
      AND X.Sku = A.Sku 
JOIN dbo.SKU S with (nolock) ON X.StorerKey = S.StorerKey 
      AND X.Sku = S.Sku 
JOIN dbo.PACK P with (nolock) ON S.PACKKey = P.PackKey 
JOIN dbo.LOC L with (nolock) ON X.Loc = L.Loc
WHERE
   (
(X.StorerKey = 'PEPSI' 
      AND L.Facility = '3102' 
      AND X.Qty > 0)
   )
GO
GRANT SELECT ON  [BI].[V_TH_PEPSI-02_SOH] TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH_PEPSI-02_SOH]

REVERT;
*/