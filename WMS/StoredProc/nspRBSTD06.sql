SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspRBSTD06 (Enhanced)                              */
/* Creation Date:                                                       */
/* Copyright:                                                           */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Order-Driven Allocation with FIFO + Pallet Priority         */
/* Note : The proc nspRBSTD06 is enhanced frm nspALSTD06 to support     */
/* order-driven allocation strategy with FIFO and pallet priority.      */
/* The cursor is modified to sort the candidate locations based on      */
/* allocation phase (full pallet requirement first),                    */
/* FIFO (oldest LOT first), pallet type (full before partial),          */
/* facility sort, and location ordering. This enhancement ensures       */
/* that the allocation process prioritizes full pallets,                */
/* minimizes picks, and supports multi-facility operations effectively. */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Github Version: 2.0                                                  */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver. Purposes                                  */
/* 20-Nov-2024  WLChooi  1.1  DevOps Combine Script                     */
/* 20-Nov-2024  WLChooi  1.1  WMS-26556-Support Multi Facilities(WL01)  */
/* 11-MAR-2026  surya    1.2  Reverse the earlier changes               */
/* 25-MAR-2026  surya    2.0  Order-Driven Allocation + FIFO + Fulpalet */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[nspRBSTD06]
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

   -- =====================================================================
   -- STEP 1: CALCULATE ORDER STRUCTURE
   -- =====================================================================
   DECLARE @n_fullPalletRequirement INT;
   DECLARE @n_remainingRequirement INT;

   SET @n_fullPalletRequirement = (@n_qtylefttofulfill / @n_uombase) * @n_uombase;
   SET @n_remainingRequirement = @n_qtylefttofulfill % @n_uombase;

   -- =====================================================================
   -- STEP 2: DECLARE CURSOR - ORDER-DRIVEN ALLOCATION
   -- =====================================================================
   DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY
   FOR SELECT
          LOTxLOCxID.LOC,
          LOTxLOCxID.ID,
          QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED),'1'

       FROM LOTxLOCxID (NOLOCK)
           JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC
           JOIN SKUxLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUxLOC.Storerkey
                                AND LOTxLOCxID.Sku = SKUxLOC.Sku
                                AND LOTxLOCxID.Loc = SKUxLOC.Loc
           CROSS APPLY (SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(LOTxLOCxID.StorerKey, @c_Facility)) F

           -- Optional: Add LOT join for CreateDate if LOT table has it
           LEFT JOIN LOT (NOLOCK) ON LOTxLOCxID.LOT = LOT.LOT

       WHERE LOTxLOCxID.Lot = @c_lot
         AND SKUxLOC.Locationtype = 'PICK'
         AND LOC.Locationflag <> 'HOLD'
         AND LOC.Locationflag <> 'DAMAGE'
         AND LOC.Status <> 'HOLD'
         --AND LOC.Facility = @c_Facility   --WL01
         AND LOC.Facility = F.Facility --WL01
         AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) > 0

         -- Changed by June 17.Jul.03 SOS12446, sort by Logicalloc first

       -- =====================================================================
       -- ORDER BY: Phase + FIFO + Pallet Type + Location
       -- =====================================================================
       -- Priority 1: Allocation Phase (FULL_REQ first, PARTIAL_REM second)
       -- Priority 2: FIFO (oldest LOT.CreateDate first)
       -- Priority 3: Pallet Type (Full before Partial within phase)
       -- Priority 4: Facility Sort
       -- Priority 5: Location ordering
       -- Priority 6: Highest quantity first
       ORDER BY
              -- Priority 1: Phase (FULL_REQ=0 sorts first)
              CASE
                 WHEN @n_fullPalletRequirement > 0
                      AND ((LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) % @n_uombase = 0)
                      AND ((LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase)
                 THEN 0  -- Phase 1: Full Pallets
                 ELSE 1  -- Phase 2: Partial Pallets
              END,

              -- Priority 2: FIFO (oldest LOT.CreateDate first)
              ISNULL(LOT.EditDate, GETDATE()) ASC,

              -- Priority 3: Pallet Type within phase
              CASE
                 WHEN ((LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) % @n_uombase = 0)
                      AND ((LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase)
                 THEN 0  -- Full pallet
                 ELSE 1  -- Partial pallet
              END,

              -- Priority 4: Facility Sort (maintain multi-facility support)
              F.FacSort ASC,

              -- Priority 5: Location ordering
              LOC.LogicalLocation ASC,
              LOC.LOC ASC,

              -- Priority 6: Highest quantity first (minimize picks)
              (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) DESC

       OPTION (OPTIMIZE FOR UNKNOWN);

END
GO
GRANT EXECUTE ON nspRBSTD06 TO nSQL
GO
