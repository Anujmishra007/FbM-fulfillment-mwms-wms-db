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
   @n_PalletQty INT

   --debug
   PRINT '@c_uom=' + @c_uom +  ', @n_uombase=' + CONVERT(NVARCHAR, @n_uombase)+ 
   ',@n_qtylefttofulfill=' + CONVERT(NVARCHAR, @n_qtylefttofulfill)+ ', @c_Facility=' + @c_Facility+
   ', @c_HostWHCode=' + @c_HostWHCode + ', @c_OtherParms=' + @c_OtherParms + ', @c_lot=' + @c_lot+ ', @n_PalletQty=' + CONVERT(NVARCHAR, @n_PalletQty)

   CREATE TABLE ##T_INV_nspALSTD08
   (
      RowID        INT NOT NULL IDENTITY(1, 1)
      , WaveKey      NVARCHAR(20)
      , Lot          NVARCHAR(10)
      , Loc          NVARCHAR(10)
      , ID           NVARCHAR(18)
      , QtyAvailable INT
      , CaseQty      INT
      , LooseQty     INT
      , Casecnt      INT
      , UsedFlag     INT DEFAULT 0
      , Lottable04   DATETIME
      , Lottable05   DATETIME
   )































   

   IF OBJECT_ID('tempdb..##TMP_PREALLOCATE_CURSOR_CANDIDATES','u') IS NOT NULL
      AND EXISTS (SELECT 1 FROM ##TMP_PREALLOCATE_CURSOR_CANDIDATES)
   BEGIN

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


      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
      SELECT 
      LOTxLOCxID.LOC, 
      LOTxLOCxID.ID,
      QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), 
      '1'
      FROM LOTxLOCxID (NOLOCK)
      JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
      JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc  
      JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot AND LOTxLOCxID.StorerKey = LOTATTRIBUTE.StorerKey AND LOTxLOCxID.Sku = LOTATTRIBUTE.Sku   
      CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   
      JOIN ##TMP_PREALLOCATE_CURSOR_CANDIDATES TPC ON TPC.LOT = LOTxLOCxID.Lot AND TPC.SKU = LOTxLOCxID.Sku 
      WHERE SKUxLOC.Locationtype ="PICK"
      AND LOC.Locationflag <>"HOLD"
      AND LOC.Locationflag <> "DAMAGE"
      AND LOC.Status <> "HOLD"
      AND LOC.Facility = @c_Facility   
      AND LOC.Facility = F.Facility   
      ORDER BY 
      (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED),
      LOTATTRIBUTE.Lottable05, 
      F.FacSort, LOC.LogicalLocation, LOC.LOC   

      --debug
      PRINT 'Cursor candidates for lot with UOM not equal to 1'
   
   END
   ELSE
   BEGIN
      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
      SELECT 
      LOTxLOCxID.LOC, 
      LOTxLOCxID.ID,
      QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), 
      '1'
      FROM LOTxLOCxID (NOLOCK)
      JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC   
      JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey AND LOTxLOCxID.Sku = SKUxLOC.Sku AND LOTxLOCxID.Loc = SKUxLOC.Loc   
      CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F   
      WHERE LOTxLOCxID.Lot = @c_lot
      AND SKUxLOC.Locationtype ="PICK"
      AND LOC.Locationflag <>"HOLD"
      AND LOC.Locationflag <> "DAMAGE"
      AND LOC.Status <> "HOLD"
      AND LOC.Facility = F.Facility   
      ORDER BY F.FacSort, LOC.LogicalLocation, LOC.LOC   
   END
END
GO
GRANT EXECUTE ON nspALSTD06 TO NSQL
GO