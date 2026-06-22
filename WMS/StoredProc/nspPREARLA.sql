USE [GLOWMS]
GO
/****** Object:  StoredProcedure [dbo].[nspPREARLA]    Script Date: 6/21/2026 3:44:23 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: nspPREARLA                   */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : ARLA PRE Allocation Logic Based on Last Picked Best Before Date based on Consigneekey UWP-59498                             */
/*                                                                           */
/* Called By:  nspPREARLA                 */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043,SYO054   1.0  Initial version created                        */
/*****************************************************************************/
CREATE OR ALTER     PROC    [dbo].[nspPREARLA]
@c_storerkey NVARCHAR(15) ,
@c_sku NVARCHAR(20) ,
@c_uom NVARCHAR(10), 
@c_facility NVARCHAR(10)  ,  
@n_uombase int ,
@n_qtylefttofulfill int,
@c_OtherParms NVARCHAR(20) = ''    
AS
BEGIN


BEGIN
DECLARE  PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR  
/*SELECT LOTXLOCXID.STORERKEY,LOTXLOCXID.SKU,LOTXLOCXID.LOT ,
QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
FROM  LOTXLOCXID (NOLOCK), LOC (NOLOCK),LOT (NOLOCK)
WHERE LOTXLOCXID.Lot = LOT.LOT
AND LOTXLOCXID.StorerKey=@c_storerkey
AND LOC.FACILITY=@c_facility
AND LOTXLOCXID.SKU=LOT.SKU
AND LOC.LOC=LOTXLOCXID.LOC
--AND LOTXLOCXID.ID =(select ID from ORDERDETAIL (NOLOCK) where OrderKey = left(@c_OtherParms,10) and orderlinenumber = right(left(@c_OtherParms,15),5))
--AND LOTXLOCXID.SKU =(select SKU from ORDERDETAIL (NOLOCK) where OrderKey = left(@c_OtherParms,10) and orderlinenumber = right(left(@c_OtherParms,15),5))
ORDER BY LOTXLOCXID.ID */

SELECT
    LLI.STORERKEY,LLI.SKU,LLI.LOT,
    --LLI.ID,
 QTYAVAILABLE= (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen)  
    --'1'
    
FROM LOTXLOCXID LLI WITH (NOLOCK)

INNER JOIN LOC  WITH  (NOLOCK) 
    ON LLI.LOC = LOC.LOC

INNER JOIN ID   WITH (NOLOCK) 
    ON LLI.ID = ID.ID

INNER JOIN LOT  WITH  (NOLOCK) 
    ON LLI.LOT = LOT.LOT

INNER JOIN LOTATTRIBUTE LA  WITH  (NOLOCK) 
    ON LA.LOT = LLI.LOT 
    AND LA.STORERKEY = LLI.STORERKEY
    AND LA.LOTTABLE10 IS NOT NULL

INNER JOIN SKU S  WITH  (NOLOCK) 
    ON S.SKU = LLI.SKU 
    AND S.STORERKEY = LLI.STORERKEY

LEFT JOIN CUSTOMERDATETRACKER CDT  WITH  (NOLOCK) 
    ON CDT.STORERKEY = LLI.STORERKEY
    AND CDT.SKU = LLI.SKU
    AND CDT.CONSIGNEEKEY = (
        SELECT TOP 1 CONSIGNEEKEY
        FROM ORDERS (NOLOCK)
        WHERE ORDERKEY = (select ORDERKEY from ORDERS WITH (NOLOCK) where OrderKey = left(@c_OtherParms,10))
    )

WHERE 
    LOC.Facility = @c_facility

    AND LLI.SKU = (
        SELECT TOP 1 SKU 
        FROM ORDERDETAIL 
        WHERE ORDERKEY =(select ORDERKEY from ORDERS (NOLOCK) where OrderKey = left(@c_OtherParms,10))
		AND ORDERLINENUMBER =(select OrderLineNumber from ORDERDETAIL (NOLOCK) where OrderKey = left(@c_OtherParms,10) and orderlinenumber = right(left(@c_OtherParms,15),5))
        ORDER BY ADDDATE DESC
    )

    AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
	AND LOC.LocationCategory <> 'STAGE'
    AND LOC.Status = 'OK'
    AND ID.Status = 'OK'
    AND LOT.Status = 'OK'

    AND NOT EXISTS (
        SELECT 1 FROM INVENTORYHOLD IH
        WHERE IH.ID = LLI.ID 
          AND IH.HOLD = 1 
          AND IH.ID <> ''
    )

    AND NOT EXISTS (
        SELECT 1 FROM INVENTORYHOLD IH
        WHERE IH.LOC = LLI.LOC 
          AND IH.HOLD = 1 
          AND IH.LOC <> ''
    )

    AND (
        CDT.LastBestBeforeDate IS NULL
        OR TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105) >= CDT.LastBestBeforeDate
    )

    AND (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) > 0
	--AND( LA.LOTTABLE03 IS NULL OR LA.Lottable03 ='')
    AND EXISTS (
        SELECT 1
        FROM LOTXLOCXID L2
        WHERE L2.ID = LLI.ID
          AND L2.LOC = LLI.LOC
          AND L2.LOT = LLI.LOT
          AND L2.STORERKEY = LLI.STORERKEY
    )

ORDER BY 
    CASE 
        WHEN TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105) IS NULL THEN 1 
        ELSE 0 
    END,
    TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105),
    LA.Lottable05;
END

END

