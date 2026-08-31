SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspALSTD08                                         */
/* Creation Date:                                                       */
/* Copyright:                                                           */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:     replace nspRBClrPl                                      */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 24-May-2026  AYD      1.0  DevOps Combine Script                     */
/* 22-Jul-2026  AYD01    1.1  Priority of full pallet vs loose qty,FIFO */
/************************************************************************/
CREATE OR ALTER PROC nspALSTD08
-- @c_lot NVARCHAR(10) ,
-- @c_uom NVARCHAR(10) ,
-- @c_HostWHCode NVARCHAR(10),
-- @c_Facility NVARCHAR(5),
-- @n_uombase int ,
-- @n_qtylefttofulfill int,
-- @c_OtherParms       NVARCHAR(200) = ''
   @c_Orderkey   NVARCHAR(10),  
   @c_Facility   NVARCHAR(5),     
   @c_StorerKey  NVARCHAR(15),     
   @c_SKU        NVARCHAR(20),    
   @c_Lottable01 NVARCHAR(18),    
   @c_Lottable02 NVARCHAR(18),    
   @c_Lottable03 NVARCHAR(18),    
   @d_Lottable04 DATETIME,    
   @d_Lottable05 DATETIME,    
   @c_Lottable06 NVARCHAR(30),    
   @c_Lottable07 NVARCHAR(30),    
   @c_Lottable08 NVARCHAR(30),    
   @c_Lottable09 NVARCHAR(30),    
   @c_Lottable10 NVARCHAR(30),    
   @c_Lottable11 NVARCHAR(30),    
   @c_Lottable12 NVARCHAR(30),    
   @d_Lottable13 DATETIME,    
   @d_Lottable14 DATETIME,    
   @d_Lottable15 DATETIME,    
   @c_UOM        NVARCHAR(10),    
   @c_HostWHCode NVARCHAR(10),    
   @n_UOMBase    INT,    
   @n_QtyLeftToFulfill INT,
   @c_OtherParms NVARCHAR(200)=''
AS
BEGIN
   SET NOCOUNT ON

   DECLARE
   @c_lot NVARCHAR(10),
   @c_WaveKey NVARCHAR(20) = @c_OtherParms, -- for wave pick, pass wavekey through otherparms
   -- @c_StorerKey NVARCHAR(15),
   -- @c_SKU NVARCHAR(20),
   @n_PalletQty INT,
   @n_QtyToAllocate INT,
   @n_IDQtyAvailable INT,
   @c_Loc NVARCHAR(50),
   @c_ID NVARCHAR(50),
   @n_CNT INT = 0

   IF @n_QtyLeftToFulfill <= 0
   BEGIN
      GOTO EXIT_SP
   END

   SELECT TOP 1 @c_StorerKey = o.StorerKey
   FROM ORDERS o (NOLOCK)
   JOIN WAVEDETAIL wd (NOLOCK) ON o.OrderKey = wd.OrderKey
   WHERE wd.WaveKey = @c_WaveKey
   
   SELECT @n_PalletQty = P.Pallet
      FROM SKU (NOLOCK) S
      JOIN PACK (NOLOCK) P ON (S.Packkey = P.Packkey)
   WHERE S.SKU = @c_sku
     AND S.StorerKey = @c_storerkey

   

   --debug
   PRINT '@c_StorerKey='+ @c_StorerKey +', @c_uom=' + @c_uom +  ', @n_uombase=' + CONVERT(NVARCHAR, @n_uombase)+ 
   ',@n_qtylefttofulfill=' + CONVERT(NVARCHAR, @n_qtylefttofulfill)+ ', @c_Facility=' + @c_Facility+
   ', @c_HostWHCode=' + @c_HostWHCode + ', @c_OtherParms=' + @c_OtherParms + ', @c_lot=' + @c_lot+ ', @n_PalletQty=' + CONVERT(NVARCHAR, @n_PalletQty)


   EXEC isp_Init_Allocate_Candidates

   
   IF OBJECT_ID('tempdb..#TMP_PREALLOCATE_CURSOR_CANDIDATES','U') IS NOT NULL
      DROP TABLE #TMP_PREALLOCATE_CURSOR_CANDIDATES

   CREATE TABLE #TMP_PREALLOCATE_CURSOR_CANDIDATES
   (
      StorerKey NVARCHAR(15),
      Facility NVARCHAR(10),
      SKU NVARCHAR(20),
      LOT NVARCHAR(100)
   )

   INSERT INTO #TMP_PREALLOCATE_CURSOR_CANDIDATES
      SELECT 
      STORERKEY = MIN(LOTXLOCXID.STORERKEY), 
      FACILITY = LOC.FACILITY,
      SKU = MIN(LOTXLOCXID.SKU), 
      LOT = LOT.LOT     
      FROM LOT (NOLOCK), LOTATTRIBUTE (NOLOCK), LOTXLOCXID (NOLOCK), LOC (NOLOCK), ID (NOLOCK), SKU (NOLOCK), SKUxLOC (NOLOCK) 
      WHERE LOTXLOCXID.STORERKEY =  @c_storerkey 
        AND LOTXLOCXID.SKU = @c_sku 
        AND LOT.STATUS = 'OK' AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' And LOC.LocationFlag = 'NONE' 
        AND LOTXLOCXID.ID = ID.ID AND lot.lot = lotattribute.lot 
        AND LOTXLOCXID.LOT = LOT.LOT AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT 
        AND LOTXLOCXID.LOC = LOC.LOC 
        AND SKU.SKU = LOTXLOCxID.SKU 
        AND SKU.STORERKEY = LOTXLOCXID.STORERKEY 
        AND LOTATTRIBUTE.SKU = SKU.SKU AND LOTATTRIBUTE.STORERKEY = SKU.STORERKEY 
        AND LOC.FACILITY = @c_Facility 
        AND SKUxLOC.StorerKey = LOTxLOCxID.StorerKey 
        AND SKUxLOC.SKU = LOTxLOCxID.SKU 
        AND SKUxLOC.LOC = LOTxLOCxID.LOC 
        AND NOT EXISTS(SELECT 1 FROM #TMP_PREALLOCATE_CURSOR_CANDIDATES TPC 
          WHERE TPC.LOT = LOT.LOT AND TPC.SKU = LOTXLOCXID.SKU AND TPC.STORERKEY = LOTXLOCXID.STORERKEY AND TPC.FACILITY = LOC.FACILITY)
        GROUP BY LOT.LOT, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05, LOC.Facility
        HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked) - MIN(LOT.QtyPreAllocated)) > 0
      --   HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked) - MIN(LOT.QtyPreAllocated)) >=  @n_uombase
      --   ORDER BY CASE WHEN (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) >=  @n_uombase
      --                       AND (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) %  @n_UOMBase   = 0 
      --                 THEN 1 ELSE 0 END, 
      --                 (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)),
      --                 LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05 

   CREATE TABLE #T_INV
   (
      RowID        INT NOT NULL IDENTITY(1, 1)
      , WaveKey      NVARCHAR(20)
      , Lot          NVARCHAR(10)
      , Loc          NVARCHAR(10)
      , ID           NVARCHAR(18)
      , QtyAvailable INT
      -- , CaseQty      INT
      -- , LooseQty     INT
      -- , Casecnt      INT
      -- , UsedFlag     INT DEFAULT 0
      -- , Lottable04   DATETIME
      , Lottable05   DATETIME
   )

   INSERT INTO #T_INV (WaveKey, Lot, Loc, ID, QtyAvailable, Lottable05)
   SELECT @c_WaveKey, 
      LOTxLOCxID.Lot, 
      LOTxLOCxID.Loc, 
      LOTxLOCxID.ID, 
      (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED),
      LOTATTRIBUTE.Lottable05
   FROM LOTxLOCxID (NOLOCK)
   JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
   JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
   JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot AND LOTxLOCxID.StorerKey = LOTATTRIBUTE.StorerKey AND LOTxLOCxID.Sku = LOTATTRIBUTE.Sku   
   WHERE LOC.LocationFlag <> 'HOLD'
      AND LOC.LocationFlag <> 'DAMAGE'
      AND LOC.Status <> 'HOLD'
      AND LOT.Status <> 'HOLD'
      AND ID.Status <> 'HOLD'
      AND LOC.Facility = @c_Facility   
      AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED > 0
      AND EXISTS (SELECT 1 FROM #TMP_PREALLOCATE_CURSOR_CANDIDATES TPC 
         WHERE TPC.LOT = LOTxLOCxID.Lot AND TPC.SKU = LOTxLOCxID.SKU AND TPC.STORERKEY = LOTxLOCxID.STORERKEY AND TPC.FACILITY = LOC.FACILITY)
   ORDER BY 
      LOTATTRIBUTE.Lottable05, 
      LOC.LogicalLocation, LOC.LOC   

   -- NOTE: @c_lot is never initialized in this procedure; removed ineffective lookup by lot.
   SELECT @n_PalletQty = P.Pallet
   FROM SKU (NOLOCK) S
   JOIN PACK (NOLOCK) P ON S.Packkey = P.Packkey
   WHERE S.SKU = @c_SKU
   AND S.StorerKey = @c_StorerKey

   WHILE @n_qtylefttofulfill > 0 
      AND EXISTS (SELECT 1 FROM #T_INV WHERE QtyAvailable > 0)
   BEGIN 
      SET @n_CNT = 0
      IF @n_qtylefttofulfill < @n_PalletQty
      BEGIN
         --debug 
         print 'Loose allocate: @n_qtylefttofulfill=' + CONVERT(NVARCHAR, @n_qtylefttofulfill)

         SELECT TOP 1
            @n_CNT = 1,
            @c_Loc = INV.Loc,
            @c_Lot = INV.Lot, 
            @c_ID = INV.ID,
            @n_QtyToAllocate = IIF(@n_qtylefttofulfill >= (INV.QtyAvailable % @n_PalletQty), 
               INV.QtyAvailable % @n_PalletQty, @n_qtylefttofulfill),
            @n_IDQtyAvailable = INV.QtyAvailable
         FROM #T_INV INV (NOLOCK)
            JOIN LOTxLOCxID (NOLOCK) ON LOTxLOCxID.Loc = INV.LOC AND LOTxLOCxID.ID = INV.ID AND INV.LOT = LOTxLOCxID.LOT
            JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
            JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
            JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
            JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
         WHERE LOC.LocationFlag <> 'HOLD'
            AND LOC.LocationFlag <> 'DAMAGE'
            AND LOC.Status <> 'HOLD'
            AND LOT.Status <> 'HOLD'
            AND ID.Status <> 'HOLD'
            AND LOC.Facility = @c_Facility   
            AND (INV.QtyAvailable % @n_PalletQty) > 0 --1st Priority: prioritize loose qty with loose pallet first
         ORDER BY 
            INV.Lottable05,   --AYD01 2nd Priority: FIFO
            INV.QtyAvailable,
            LOC.LogicalLocation, 
            LOC.LOC   

         --debug 
         print 'Loose allocate: @n_qtylefttofulfill=' + CONVERT(NVARCHAR, @n_qtylefttofulfill) + ', @n_QtyToAllocate=' + CONVERT(NVARCHAR, @n_QtyToAllocate) + ', @n_IDQtyAvailable=' + CONVERT(NVARCHAR, @n_IDQtyAvailable) + ', @c_Loc=' + @c_Loc + ', @c_Lot=' + @c_Lot + ', @c_ID=' + @c_ID
      END
      IF @n_CNT = 0 
      BEGIN
         SELECT TOP 1
            @c_Loc = INV.Loc,
            @c_Lot = INV.Lot, 
            @c_ID = INV.ID,
            @n_QtyToAllocate = IIF(@n_qtylefttofulfill >= (INV.QtyAvailable), INV.QtyAvailable, @n_qtylefttofulfill),
            @n_IDQtyAvailable = INV.QtyAvailable
         FROM #T_INV INV (NOLOCK)
            JOIN LOTxLOCxID (NOLOCK) ON LOTxLOCxID.Loc = INV.LOC AND LOTxLOCxID.ID = INV.ID AND INV.LOT = LOTxLOCxID.LOT
            JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
            JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
            JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
            JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
         WHERE LOC.LocationFlag <> 'HOLD'
            AND LOC.LocationFlag <> 'DAMAGE'
            AND LOC.Status <> 'HOLD'
            AND LOT.Status <> 'HOLD'
            AND ID.Status <> 'HOLD'
            AND LOC.Facility = @c_Facility   
            AND INV.QtyAvailable > 0
         ORDER BY 
            IIF(INV.QtyAvailable % @n_PalletQty = 0, 0, 1), --AYD01 1st Priority: prioritize full pallet first
            INV.Lottable05,   --AYD01 2nd Priority: FIFO
            INV.QtyAvailable,
            LOC.LogicalLocation, 
            LOC.LOC
      END
      
      SET @n_qtylefttofulfill = @n_qtylefttofulfill - @n_QtyToAllocate
      SET @n_IDQtyAvailable = @n_IDQtyAvailable - @n_QtyToAllocate

      -----------------------------
      UPDATE #T_INV
         SET QtyAvailable = @n_IDQtyAvailable
      WHERE Lot = @c_lot AND Loc = @c_Loc AND ID = @c_ID AND WaveKey = @c_WaveKey

      EXEC isp_Insert_Allocate_Candidates
            @c_Lot = @c_Lot
         ,  @c_Loc = @c_Loc
         ,  @c_ID  = @c_ID
         ,  @n_QtyAvailable = @n_QtyToAllocate
         ,  @c_OtherValue = '1'

      -- Debug output removed to avoid extra result sets during allocation
   END

   --debug
   select * from #ALLOCATE_CANDIDATES order by id

   EXIT_SP:

   EXEC isp_Cursor_Allocate_Candidates
         @n_SkipPreAllocationFlag = 1    --Return Lot column

END
GO
GRANT EXECUTE ON nspALSTD08 TO NSQL
GO