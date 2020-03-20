if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspExportInventory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspExportInventory]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Stored Procedure: nspExportInventory                                 */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/

/****** Object:  Stored Procedure dbo.nspExportInventory    Script Date: 8/31/99 3:37:47 PM ******/
CREATE PROCEDURE nspExportInventory
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   SELECT LOT.StorerKey,
   SKU = UPPER(LOT.sku),
   LOTATTRIBUTE.lottable03,
   LOTATTRIBUTE.lottable02,
   ExpiryDate = RIGHT(dbo.fnc_RTrim("0" + CONVERT(char(2), DATEPART(month, lottable04))),2) + "/"
   + RIGHT(dbo.fnc_RTrim("0" + CONVERT(char(2), DATEPART(day, lottable04))),2) + "/"
   + RIGHT(dbo.fnc_RTrim("00" + CONVERT(char(4), DATEPART(year, lottable04))),4),
   LOT.lot,
   qty = LOT.qty - LOT.qtyallocated,
   qtyonhold = CASE
   WHEN (Lot.Status = 'HOLD') THEN lot.qty
ELSE Lot.QtyOnHold
END
INTO #Temp
FROM LOT, LOTATTRIBUTE
WHERE LOT.lot = LOTATTRIBUTE.lot
AND LEFT(lottable03,2) <> 'SK'
UPDATE #Temp
SET ExpiryDate = NULL
WHERE ExpiryDate = '0/0/00'
OR lottable02 = ''
--  DELETE #Temp WHERE qty = 0
SELECT storerkey, sku, lottable03, lottable02, expirydate, qty, qtyonhold
FROM #Temp order by storerkey, sku
DROP TABLE #Temp
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspExportInventory to nSQL
GO
