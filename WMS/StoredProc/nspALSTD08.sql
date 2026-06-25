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
/* Purpose:                                                             */
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
/************************************************************************/
CREATE OR ALTER PROC nspALSTD06
@c_lot NVARCHAR(10) ,
@c_uom NVARCHAR(10) ,
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase int ,
@n_qtylefttofulfill int,
@c_OtherParms       NVARCHAR(200) = ''
AS
BEGIN
   SET NOCOUNT ON

   DECLARE
   @c_WaveKey NVARCHAR(20) = @c_OtherParms, -- for wave pick, pass wavekey through otherparms
   @c_StorerKey NVARCHAR(15),
   @c_SKU NVARCHAR(20),
   @n_PalletQty INT,
   @n_QtyToAllocate INT,
   @n_IDQtyAvailable INT,
   @c_Loc NVARCHAR(50),
   @c_ID NVARCHAR(50)

   SELECT TOP 1 @c_StorerKey = o.StorerKey
   FROM ORDERS o (NOLOCK)
   JOIN WAVEDETAIL wd (NOLOCK) ON o.OrderKey = wd.OrderKey
   WHERE wd.WaveKey = @c_WaveKey
   

   --debug
   PRINT '@c_StorerKey='+ @c_StorerKey +', @c_uom=' + @c_uom +  ', @n_uombase=' + CONVERT(NVARCHAR, @n_uombase)+ 
   ',@n_qtylefttofulfill=' + CONVERT(NVARCHAR, @n_qtylefttofulfill)+ ', @c_Facility=' + @c_Facility+
   ', @c_HostWHCode=' + @c_HostWHCode + ', @c_OtherParms=' + @c_OtherParms + ', @c_lot=' + @c_lot+ ', @n_PalletQty=' + CONVERT(NVARCHAR, @n_PalletQty)


   EXEC isp_Init_Allocate_Candidates

   
   IF OBJECT_ID('tempdb..##TMP_PREALLOCATE_CURSOR_CANDIDATES','u') IS NULL
   BEGIN
      CREATE TABLE ##TMP_PREALLOCATE_CURSOR_CANDIDATES
      ( 
         StorerKey NVARCHAR(15), 
         Facility NVARCHAR(10),
         SKU NVARCHAR(20),
         LOT NVARCHAR(100)
      )
   END

   --debug
   print ''

   INSERT INTO ##TMP_PREALLOCATE_CURSOR_CANDIDATES
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
        AND NOT EXISTS(SELECT 1 FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES TPC 
          WHERE TPC.LOT = LOT.LOT AND TPC.SKU = LOTXLOCXID.SKU AND TPC.STORERKEY = LOTXLOCXID.STORERKEY AND TPC.FACILITY = LOC.FACILITY)
        GROUP BY LOT.LOT, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05, LOC.Facility
        HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked) - MIN(LOT.QtyPreAllocated)) >=  @n_uombase
        ORDER BY CASE WHEN (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) >=  @n_uombase
                            AND (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) %  @n_UOMBase   = 0 
                      THEN 1 ELSE 0 END, 
                      (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)),
                      LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05 

   --debug
   SELECT * FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES

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
   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
   JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot AND LOTxLOCxID.StorerKey = LOTATTRIBUTE.StorerKey AND LOTxLOCxID.Sku = LOTATTRIBUTE.Sku   
   CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   
   JOIN ##TMP_PREALLOCATE_CURSOR_CANDIDATES TPC ON TPC.LOT = LOTxLOCxID.Lot AND TPC.SKU = LOTxLOCxID.Sku 
   WHERE SKUxLOC.Locationtype = "PICK"
      AND LOC.Locationflag <> "HOLD"
      AND LOC.Locationflag <> "DAMAGE"
      AND LOC.Status <> "HOLD"
      AND LOC.Facility = @c_Facility   
      AND LOC.Facility = F.Facility   
      AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED > 0
   ORDER BY 
      LOTATTRIBUTE.Lottable05, 
      F.FacSort, LOC.LogicalLocation, LOC.LOC   

   --debug
   SELECT * FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES
   SELECT * FROM #T_INV
   SELECT * FROM #ALLOCATE_CANDIDATES  
   ---------
   SELECT TOP 1
   @c_StorerKey = TPC.STORERKEY,
   @c_SKU = TPC.SKU
   FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES TPC
   WHERE TPC.LOT = @c_lot
   AND TPC.FACILITY = @c_Facility

   SELECT @n_PalletQty = P.Pallet
   FROM SKU (NOLOCK) S
   JOIN PACK (NOLOCK) P ON S.Packkey = P.Packkey
   WHERE S.SKU = @c_SKU
   AND S.StorerKey = @c_StorerKey

   DECLARE CUR_INV CURSOR READ_ONLY FAST_FORWARD FOR
   SELECT 
      INV.Loc,
      INV.Lot, 
      INV.ID,
      IIF(@n_qtylefttofulfill >= (INV.QtyAvailable), INV.QtyAvailable, @n_qtylefttofulfill),
      INV.QtyAvailable
   FROM #T_INV INV (NOLOCK)
      JOIN LOTxLOCxID (NOLOCK) ON LOTxLOCxID.Loc = INV.LOC AND LOTxLOCxID.ID = INV.ID AND INV.LOT = LOTxLOCxID.LOT
      JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
      JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
      JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot AND LOTxLOCxID.StorerKey = LOTATTRIBUTE.StorerKey AND LOTxLOCxID.Sku = LOTATTRIBUTE.Sku   
   WHERE SKUxLOC.Locationtype = "PICK"
      AND LOC.Locationflag <> "HOLD"
      AND LOC.Locationflag <> "DAMAGE"
      AND LOC.Status <> "HOLD"
      AND LOC.Facility = @c_Facility   
      AND INV.QtyAvailable > 0
   ORDER BY 
      LOTATTRIBUTE.Lottable05, 
      LOC.LogicalLocation, 
      LOC.LOC   

   OPEN CUR_INV
   FETCH NEXT FROM CUR_INV INTO @c_Loc, @c_Lot, @c_ID, @n_QtyToAllocate, @n_IDQtyAvailable

   WHILE @@FETCH_STATUS = 0 AND @n_qtylefttofulfill > 0
   BEGIN
      
      SET @n_qtylefttofulfill = @n_qtylefttofulfill - @n_QtyToAllocate
      SET @n_IDQtyAvailable = @n_IDQtyAvailable - @n_QtyToAllocate

      UPDATE #T_INV
         SET QtyAvailable = @n_IDQtyAvailable
      WHERE Lot = @c_lot AND Loc = @c_Loc AND ID = @c_ID AND WaveKey = @c_WaveKey

      EXEC isp_Insert_Allocate_Candidates
            @c_Lot = @c_Lot
         ,  @c_Loc = @c_Loc
         ,  @c_ID  = @c_ID
         ,  @n_QtyAvailable = @n_QtyToAllocate
         ,  @c_OtherValue = '1'

      FETCH NEXT FROM CUR_INV INTO @c_Loc, @c_Lot, @c_ID, @n_QtyToAllocate, @n_IDQtyAvailable
   END
   CLOSE CUR_INV
   DEALLOCATE CUR_INV





























   -- IF OBJECT_ID('tempdb..##TMP_PREALLOCATE_CURSOR_CANDIDATES','u') IS NOT NULL
   --    AND EXISTS (SELECT 1 FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES)
   -- BEGIN

   --    SELECT TOP 1
   --    @c_StorerKey = TPC.STORERKEY,
   --    @c_SKU = TPC.SKU
   --    FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES TPC
   --    WHERE TPC.LOT = @c_lot
   --    AND TPC.FACILITY = @c_Facility

   --    SELECT @n_PalletQty = P.Pallet
   --    FROM SKU (NOLOCK) S
   --    JOIN PACK (NOLOCK) P ON S.Packkey = P.Packkey
   --    WHERE S.SKU = @c_SKU
   --    AND S.StorerKey = @c_StorerKey


   --    DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
   --    SELECT 
   --    LOTxLOCxID.LOC, 
   --    LOTxLOCxID.ID,
   --    QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), 
   --    '1'
   --    FROM LOTxLOCxID (NOLOCK)
   --    JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
   --    JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
   --    JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot AND LOTxLOCxID.StorerKey = LOTATTRIBUTE.StorerKey AND LOTxLOCxID.Sku = LOTATTRIBUTE.Sku   
   --    CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   
   --    JOIN ##TMP_PREALLOCATE_CURSOR_CANDIDATES TPC ON TPC.LOT = LOTxLOCxID.Lot AND TPC.SKU = LOTxLOCxID.Sku 
   --    WHERE SKUxLOC.Locationtype ="PICK"
   --    AND LOC.Locationflag <>"HOLD"
   --    AND LOC.Locationflag <> "DAMAGE"
   --    AND LOC.Status <> "HOLD"
   --    AND LOC.Facility = @c_Facility   
   --    AND LOC.Facility = F.Facility   
   --    ORDER BY 
   --    (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED),
   --    LOTATTRIBUTE.Lottable05, 
   --    F.FacSort, LOC.LogicalLocation, LOC.LOC   

   --    --debug
   --    PRINT 'Cursor candidates for lot with UOM not equal to 1'
   
   -- END
   -- ELSE
   -- BEGIN
   --    DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
   --    SELECT 
   --    LOTxLOCxID.LOC, 
   --    LOTxLOCxID.ID,
   --    QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), 
   --    '1'
   --    FROM LOTxLOCxID (NOLOCK)
   --    JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
   --    JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc   
   --    CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   
   --    WHERE LOTxLOCxID.Lot = @c_lot
   --    AND SKUxLOC.Locationtype ="PICK"
   --    AND LOC.Locationflag <>"HOLD"
   --    AND LOC.Locationflag <> "DAMAGE"
   --    AND LOC.Status <> "HOLD"
   --    AND LOC.Facility = F.Facility   
   --    ORDER BY F.FacSort, LOC.LogicalLocation, LOC.LOC   
   -- END

   --debug
   SELECT * FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES
   SELECT * FROM #T_INV
   SELECT * FROM #ALLOCATE_CANDIDATES  

   EXIT_SP:

   EXEC isp_Cursor_Allocate_Candidates
         @n_SkipPreAllocationFlag = 1    --Return Lot column

END
GO
GRANT EXECUTE ON nspALSTD06 TO NSQL
GO