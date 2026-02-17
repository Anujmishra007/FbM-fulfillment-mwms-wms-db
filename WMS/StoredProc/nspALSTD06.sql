SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspALstd06                                         */
/* Creation Date:                                                       */
/* Copyright:                                                           */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Order-driven FIFO allocation with full/partial pallet       */
/*          differentiation (v1.1 - WMS-26556, v1.2 - Pallet FIFO)     */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Github Version: 1.2                                                  */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 20-Nov-2024  WLChooi  1.1  DevOps Combine Script                     */
/* 20-Nov-2024  WLChooi  1.1  WMS-26556-Support Multi Facilities(WL01)  */
/* 16-FEB-2026  Surya    1.2  Order-driven FIFO with Pallet Logic      */
/************************************************************************/
CREATE OR ALTER PROC nspALSTD06
@c_lot NVARCHAR(10),
@c_uom NVARCHAR(10),
@c_HostWHCode NVARCHAR(10),
@c_Facility NVARCHAR(5),
@n_uombase INT,
@n_qtylefttofulfill INT,
@c_OtherParms NVARCHAR(200) = ''
AS
BEGIN
   SET NOCOUNT ON

   -- Determine if order contains full pallet quantity
   DECLARE @n_FullPalletQty INT
   DECLARE @n_IsFullPalletOrder INT = 0

   -- Get full pallet quantity from UOM configuration
SELECT @n_FullPalletQty = COALESCE(FullPalletQty, 0)
FROM dbo.UOM
WHERE UOM = @c_uom

      -- Check if order quantity is multiple of full pallet quantity
    IF @n_FullPalletQty > 0 AND (@n_qtylefttofulfill % @n_FullPalletQty = 0)
BEGIN
      SET @n_IsFullPalletOrder = 1
END

   -- Scenario 1 & 2: Order contains full pallet quantities
   -- Allocate from full pallets only, apply FIFO
   IF @n_IsFullPalletOrder = 1
BEGIN
      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
      FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
                 QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED),
                 PALLETTYPE = CASE WHEN LOTxLOCxID.QTY = @n_FullPalletQty THEN 'FULL' ELSE 'PARTIAL' END,
                 '1'
          FROM LOTxLOCxID (NOLOCK)
                   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC
                   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey
              AND LOTxLOCxID.Sku = SKUxLOC.Sku
              AND LOTxLOCxID.Loc = SKUxLOC.Loc
                            CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F
          WHERE LOTxLOCxID.Lot = @c_lot
            AND SKUxLOC.Locationtype = 'PICK'
            AND LOC.Locationflag <> 'HOLD'
            AND LOC.Locationflag <> 'DAMAGE'
            AND LOC.Status <> 'HOLD'
            AND LOC.Facility = F.Facility
              -- Only consider full pallets for full pallet orders
            AND LOTxLOCxID.QTY = @n_FullPalletQty
          -- FIFO within full pallets: Order by creation date/sequence
          ORDER BY F.FacSort, LOTxLOCxID.CreateDate ASC, LOC.LogicalLocation, LOC.LOC
END
   -- Scenario 3: Order contains no full pallets or partial allocation needed
   -- Standard FIFO across all available partial pallets
ELSE
BEGIN
      DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
      FOR SELECT LOTxLOCxID.LOC, LOTxLOCxID.ID,
                 QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED), '1'
          FROM LOTxLOCxID (NOLOCK)
                   JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC
                   JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey
              AND LOTxLOCxID.Sku = SKUxLOC.Sku
              AND LOTxLOCxID.Loc = SKUxLOC.Loc
                            CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F
          WHERE LOTxLOCxID.Lot = @c_lot
            AND SKUxLOC.Locationtype = 'PICK'
            AND LOC.Locationflag <> 'HOLD'
            AND LOC.Locationflag <> 'DAMAGE'
            AND LOC.Status <> 'HOLD'
            AND LOC.Facility = F.Facility
          -- FIFO across partial pallets: Order by creation date
          ORDER BY F.FacSort, LOTxLOCxID.CreateDate ASC, LOC.LogicalLocation, LOC.LOC
END
END
GO
GRANT EXECUTE ON nspALSTD06 TO NSQL
GO
