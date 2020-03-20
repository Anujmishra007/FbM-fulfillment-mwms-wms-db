if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspPRLOR02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspPRLOR02]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/  
/* Stored Procedure: nspPRLOR02                                          */  
/* Creation Date:                                                        */  
/* Copyright: LF                                                         */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose:  324093-Loreal PH Strategy - Preallocate from Pick           */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/* PVCS Version: 1.0                                                     */  
/*                                                                       */  
/* Version: 5.4                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author   Ver  Purposes                                   */ 
/* 26-Feb-2015  NJOW01   1.0  324093-skip shelflife checking if          */
/*                            lottable04 no value                        */
/*************************************************************************/

CREATE PROC nspPRLOR02 
  	@c_StorerKey NVARCHAR(15) ,
  	@c_SKU NVARCHAR(20) ,
  	@c_LOT NVARCHAR(10) ,
  	@c_LOTtable01 NVARCHAR(18) ,
  	@c_LOTtable02 NVARCHAR(18) ,
  	@c_LOTtable03 NVARCHAR(18) ,
  	@d_Lottable04 datetime,
  	@d_Lottable05 datetime,
  	@c_UOM NVARCHAR(10),
    @c_Facility NVARCHAR(10)  ,
  	@n_UOMBase int ,
  	@n_QtyLeftToFulfill int,
    @c_OtherParms NVARCHAR(200)
AS
BEGIN
   SET NOCOUNT ON 
   SET CONCAT_NULL_YIELDS_NULL OFF 
   
   IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_LOT)) IS NOT NULL
   BEGIN
      DECLARE  PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
      SELECT LOT.STORERKEY,LOT.SKU,LOT.LOT ,
             QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
      FROM LOT (NOLOCK), LOTATTRIBUTE (NOLOCK), LOTxLOCxID (NOLOCK), LOC (NOLOCK) 
      WHERE LOT.LOT = LOTATTRIBUTE.LOT  
      AND LOTxLOCxID.Lot = LOT.LOT
      AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT
      AND LOTxLOCxID.LOC = LOC.LOC
      AND LOC.Facility = @c_Facility
      AND LOT.LOT = @c_LOT
      ORDER BY LOTATTRIBUTE.LOTTABLE04
   END
   ELSE
   BEGIN
      -- Get OrderKey and line Number
      DECLARE @c_OrderKey        NVARCHAR(10),
              @c_OrderLineNumber NVARCHAR(5), 
              @n_SKU_OutGoingShelfLife int,
              @n_SkuShelfLife int
      
      IF ISNULL(@c_OtherParms,'') <> ''  --when storerconfig 'Orderinfo4PreAllocation' is turned on 
      BEGIN
         SELECT @c_OrderKey = LEFT(dbo.fnc_LTrim(@c_OtherParms), 10)
         SELECT @c_OrderLineNumber = SUBSTRING(dbo.fnc_LTrim(@c_OtherParms), 11, 5)
      END
   
       DECLARE @n_ConsigneeMinShelfLife int,
               @c_LimitString           NVARCHAR(2000)

      DECLARE @c_SQLStatement NVARCHAR(2048), 
              @n_Pallet       int,
              @n_CaseCnt      int 
    
       IF dbo.fnc_RTrim(@c_OrderKey) IS NOT NULL AND dbo.fnc_RTrim(@c_OrderKey) <> '' AND @c_Lottable03 = 'P01'
       BEGIN
          SELECT @n_ConsigneeMinShelfLife = ISNULL(STORER.MinShelfLife,0) 
          FROM   ORDERS (NOLOCK) 
          JOIN STORER (NOLOCK) ON (ORDERS.ConsigneeKey = STORER.StorerKey)
          WHERE ORDERS.OrderKey = @c_OrderKey
   
          SELECT @n_SKU_OutGoingShelfLife = CAST(CASE WHEN ISNUMERIC(SKU.BUSR2) = 1 THEN SKU.BUSR2 ELSE '0' END AS Integer), 
                 @n_Pallet = PACK.Pallet, 
                 @n_CaseCnt = PACK.CaseCnt,
                 @n_SkuShelfLife = ISNULL(SKU.Shelflife,0)  
          FROM   SKU WITH (NOLOCK)
          JOIN PACK WITH (NOLOCK) ON SKU.PackKey = Pack.PackKey 
          WHERE  STORERKEY = @c_StorerKey 
          AND    SKU = @c_SKU 
             
          IF @n_SKU_OutGoingShelfLife > 0 
          BEGIN
             SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString) + " AND (DATEDIFF(day, Lottable04, GETDATE()) > " + CAST(@n_SKU_OutGoingShelfLife as NVARCHAR(10)) + " OR Lottable04 IS NULL OR CONVERT(NVARCHAR, Lottable04, 112)='20000101') "
          END 
          IF @n_ConsigneeMinShelfLife > 0 
          BEGIN 
             SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString) + " AND (DATEDIFF(day, Lottable04, GETDATE()) <= " + CAST(@n_ConsigneeMinShelfLife as NVARCHAR(10))  + " OR Lottable04 IS NULL OR CONVERT(NVARCHAR, Lottable04, 112)='20000101') "
          END 
          IF @n_SkuShelfLife > 0
          BEGIN
             SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString) + " AND (DATEDIFF(day, Lottable04, GETDATE()) <= " + CAST(@n_SkuShelfLife as NVARCHAR(10))  + " OR Lottable04 IS NULL OR CONVERT(NVARCHAR, Lottable04, 112)='20000101') "
          END 
      END
                     
      SELECT @c_SQLStatement = "DECLARE  PREALLOCATE_CURSOR_CANDIDATES  CURSOR FAST_FORWARD READ_ONLY FOR " +
      " SELECT LOT.STORERKEY,LOT.SKU,LOT.LOT," +
      " QTYAVAILABLE = SUM(LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) - MIN(LOT.QTYPREALLOCATED) " +
      " FROM LOTxLOCxID WITH (NOLOCK) " + 
      " JOIN LOT WITH (NOLOCK) ON LOTxLOCxID.Lot = LOT.LOT AND LOT.STATUS = 'OK' " +
      " JOIN LOC WITH (NOLOCK) ON LOTxLOCxID.LOC = LOC.LOC AND LOC.Status <> 'HOLD' AND LOC.LocationFlag NOT IN ('DAMAGE','HOLD') " + 
      " JOIN ID WITH (NOLOCK) ON LOTxLOCxID.ID = ID.ID AND ID.Status <> 'HOLD' " +    
      " JOIN LOTATTRIBUTE WITH (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT " + 
      " JOIN SKUxLOC WITH (NOLOCK) ON SKUxLOC.StorerKey = LOTxLOCxID.StorerKey AND SKUxLOC.SKU = LOTxLOCxID.SKU " + 
      " AND SKUxLOC.LOC = LOTxLOCxID.LOC " + 
      " WHERE LOC.Facility = '" + dbo.fnc_RTrim(@c_Facility) + "' " + 
      " AND LOT.STORERKEY = '" + dbo.fnc_RTrim(@c_StorerKey) + "' " +
      " AND LOT.SKU = '" + dbo.fnc_RTrim(@c_SKU) + "' " +
      " AND LOC.HostWHCode = '" + dbo.fnc_RTrim(@c_Lottable03) + "' " +                 
      " AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED >= " + CAST(@n_UOMBase AS NVARCHAR(10)) +
      " AND SKUXLOC.LocationType IN('PICK','CASE') " +
      dbo.fnc_RTrim(@c_Limitstring) +
   	  " GROUP BY LOT.STORERKEY,LOT.SKU,LOT.LOT, LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE05 " +
      " HAVING SUM(LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) - MIN(LOT.QTYPREALLOCATED) - MIN(QTYONHOLD) >= " + CAST(@n_UOMBase AS NVARCHAR(10)) + 
      " ORDER BY CASE WHEN LOTATTRIBUTE.LOTTABLE04 IS NULL THEN LOTATTRIBUTE.LOTTABLE05 ELSE LOTATTRIBUTE.LOTTABLE04 END, LOTATTRIBUTE.LOTTABLE05 "
      
      EXECUTE(@c_SQLStatement)

   END
END
GO
 
SET ANSI_NULLS OFF 
GO


GRANT EXECUTE ON nspPRLOR02 to nSQL
GO
