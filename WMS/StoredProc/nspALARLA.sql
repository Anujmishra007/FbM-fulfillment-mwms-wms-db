
/****** Object:  StoredProcedure [dbo].[nspALARLA]    Script Date: 6/23/2026 5:13:50 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: nspALARLA                   */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : ARLA Allocation Logic Based on Last Picked Best Before Date based on Consigneekey    UWP-59498                          */
/*                                                                           */
/* Called By:  nspALARLA                 */
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
ALTER       PROC [dbo].[nspALARLA]
         @c_lot NVARCHAR(10) ,  
         @c_uom NVARCHAR(10) ,  
         @c_HostWHCode NVARCHAR(10),  
         @c_Facility NVARCHAR(5),  
         @n_uombase int ,  
         @n_qtylefttofulfill int,    
         @c_OtherParms NVARCHAR(200) = ''   
AS
BEGIN   
   SET NOCOUNT ON 
   
   DECLARE @cOrderKey NVARCHAR(10),
@cOrderLineNumber NVARCHAR(10),
@cConsigneeKey NVARCHAR(15)

SET @cOrderKey=left(@c_OtherParms,10) 
SET @cOrderLineNumber=right(left(@c_OtherParms,15),5)
SELECT @cConsigneeKey=ConsigneeKey
        FROM ORDERS WITH (NOLOCK)
        WHERE ORDERKEY =  left(@c_OtherParms,10) 

DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
/*SELECT LOC,ID,QTYAVAILABLE,'1' FROM
(SELECT LLI.Loc,LLI.ID,--(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) AS QTYAVAILABLE
(LLI.QTY ) AS QTYAVAILABLE
   FROM LOTXLOCXID (NOLOCK) LLI
   JOIN LOC (NOLOCK) ON LLI.LOC = LOC.LOC 
   JOIN ID  (NOLOCK) ON LLI.ID = ID.ID
   JOIN LOT (NOLOCK) ON LLI.LOT = LOT.LOT
   JOIN LOTATTRIBUTE LA    ON  LA.Lot       = LLI.Lot    AND LA.StorerKey = LLI.StorerKey    AND LA.Lottable10 IS NOT NULL
   LEFT JOIN CUSTOMERDATETRACKER CDT    ON  ATR.STORERKEY    = LLI.STORERKEY    AND ATR.SKU          = LLI.SKU
  AND ATR.ConsigneeKey =(select CONSIGNEEKEY from ORDERS (NOLOCK) where OrderKey = left(@c_OtherParms,10) )
   WHERE LOC.Facility = @c_facility
   AND ISNULL(LOC.LocationFlag,'') in ('','NONE')
   AND LLI.ID NOT IN (select ID from INVENTORYHOLD (NOLOCK) where hold = 1 and ID <>'')
   AND LOC.Loc NOT IN (select LOC from INVENTORYHOLD (NOLOCK) where hold = 1 and LOC <>'')
   AND LOC.Status = 'OK'
   AND ID.Status = 'OK'
   AND LOT.Status = 'OK'
   --AND LOT.LOT = @c_lot
   AND (        ATR.LastBestBeforeDate IS NULL OR TRY_CONVERT(DATETIME2(3), LA.Lottable04) >= ATR.LastBestBeforeDate    )
   AND LA.Lottable04 <=(select LOTTABLE02 from ORDERDETAIL (NOLOCK) where OrderKey = left(@c_OtherParms,10) and orderlinenumber = right(left(@c_OtherParms,15),5))
   AND (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked) > 0
   --AND LLI.ID =(select ID from ORDERDETAIL (NOLOCK) where OrderKey = left(@c_OtherParms,10) and orderlinenumber = right(left(@c_OtherParms,15),5))
)P*/
/*SELECT LOC,ID,QTYAVAILABLE,'1' FROM
(SELECT LLI.Loc,LLI.ID,(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) AS QTYAVAILABLE
--(LLI.QTY ) AS QTYAVAILABLE
   FROM LOTXLOCXID (NOLOCK) LLI
   JOIN LOC (NOLOCK) ON LLI.LOC = LOC.LOC 
   JOIN ID  (NOLOCK) ON LLI.ID = ID.ID
   JOIN LOT (NOLOCK) ON LLI.LOT = LOT.LOT
   JOIN LOTATTRIBUTE LA    ON  LA.Lot       = LLI.Lot    AND LA.StorerKey = LLI.StorerKey    AND LA.Lottable10 IS NOT NULL

   JOIN SKU S ON S.SKU=LLI.SKU AND S.STORERKEY=LLI.STORERKEY
   LEFT JOIN CUSTOMERDATETRACKER CDT    ON  ATR.STORERKEY    = LLI.STORERKEY    AND ATR.SKU          = LLI.SKU
  AND ATR.ConsigneeKey =(select TOP 1  CONSIGNEEKEY from ORDERS (NOLOCK) where OrderKey = left(@c_OtherParms,10) )
   WHERE LOC.Facility = 'DK001' AND  S.PutawayZone = LOC.PutawayZone
   AND ISNULL(LOC.LocationFlag,'') in ('','NONE')
   AND LLI.ID NOT IN (select ID from INVENTORYHOLD (NOLOCK) where hold = 1 and ID <>'')
   AND LOC.Loc NOT IN (select LOC from INVENTORYHOLD (NOLOCK) where hold = 1 and LOC <>'')
   AND LOC.Status = 'OK'
   AND ID.Status = 'OK'
   AND LOT.Status = 'OK'
   --AND LOT.LOT = @c_lot
   AND LLI.SKU =(select TOP 1 SKU from ORDERDETAIL (NOLOCK)where OrderKey = left(@c_OtherParms,10) and orderlinenumber = right(left(@c_OtherParms,15),5))

    AND (
        ATR.LastBestBeforeDate IS NULL
        OR TRY_CONVERT(DATETIME2(3), LA.Lottable04) >= ATR.LastBestBeforeDate  
		--AND TRY_CONVERT(DATETIME2(3), LA.Lottable04) <=(select LOTTABLE02 from ORDERDETAIL (NOLOCK) where OrderKey = left('000035915600001',10) and orderlinenumber = right(left('000035915600001',15),5)))
		
    )
   --
    -- Only consider rows where net available > 0
    AND (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked- LLI.QtyReplen) > 0
)P*/



SELECT
    LLI.LOC,
    LLI.ID,
    (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) AS QTYAVAILABLE,
    '1'
    
FROM LOTXLOCXID LLI  WITH (NOLOCK) 

INNER JOIN LOC WITH (NOLOCK) 
    ON LLI.LOC = LOC.LOC

INNER JOIN ID WITH (NOLOCK) 
    ON LLI.ID = ID.ID 

INNER JOIN LOT WITH (NOLOCK) 
    ON LLI.LOT = LOT.LOT AND LOT.SKU=LLI.SKU

INNER JOIN LOTATTRIBUTE LA WITH (NOLOCK) 
    ON LA.LOT = LLI.LOT 
    AND LA.STORERKEY = LLI.STORERKEY
    AND LA.LOTTABLE10 IS NOT NULL
	AND LA.SKU=LLI.SKU

INNER JOIN SKU S WITH (NOLOCK) 
    ON S.SKU = LLI.SKU 
    AND S.STORERKEY = LLI.STORERKEY

LEFT JOIN AllocationTrackARLA ATR WITH (NOLOCK) 
    ON ATR.STORERKEY = LLI.STORERKEY
    AND ATR.SKU = LLI.SKU
    AND ATR.CONSIGNEEKEY =@cConsigneeKey
	/*(
        SELECT CONSIGNEEKEY
        FROM ORDERS WITH (NOLOCK)
        WHERE ORDERKEY =  left(@c_OtherParms,10)
    )*/

WHERE 
    LOC.Facility = @c_facility AND 
	LLI.LOT=@c_lot

   /* AND LLI.SKU = (
        SELECT SKU 
        FROM ORDERDETAIL WITH (NOLOCK) 
        WHERE ORDERKEY = @cOrderKey
		--AND ORDERLINENUMBER =(select OrderLineNumber from ORDERDETAIL WITH (NOLOCK) where OrderKey = left(@c_OtherParms,10) 
		AND ORDERLINENUMBER =@cOrderLineNumber
        --ORDER BY ADDDATE DESC
    )*/

    AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
    AND LOC.LocationCategory <> 'STAGE'
    AND LOC.Status = 'OK'
    AND ID.Status = 'OK'
    AND LOT.Status = 'OK'

   /* AND NOT EXISTS (
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
    )*/

    AND (
        ATR.LastBestBeforeDate IS NULL
        OR 
		CAST(TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105) AS DATE) >= CAST(ATR.LastBestBeforeDate AS DATE)
 
		--OR TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105) >= ATR.LastBestBeforeDate
    )

    AND (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) > 0
	--AND( LA.LOTTABLE03 IS NULL OR LA.Lottable03 ='')
 /*   AND EXISTS (
        SELECT 1
        FROM LOTXLOCXID L2
        WHERE L2.ID = LLI.ID
          AND L2.LOC = LLI.LOC
          AND L2.LOT = LLI.LOT
          AND L2.STORERKEY = LLI.STORERKEY
    )*/

ORDER BY 
    CASE 
        WHEN TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105) IS NULL THEN 1 ELSE 0 
    END,
    TRY_CONVERT(DATETIME2(3), LA.Lottable04, 105),    LA.Lottable05;
END
