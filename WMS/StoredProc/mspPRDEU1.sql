GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store Procedure:  mspPRDEU1 (Order-Driven Allocation Enhanced)             */
/* Creation Date:                                                             */
/* Copyright: MAERSK                                                          */
/* Written by: Surya                                                          */
/*                                                                            */
/* Purpose:  Pre-Allocation Strategy of IDSCN - NIKE with Order-Driven        */
/*           Allocation Logic (Scenario 1, 2, 3)                              */
/*                                                                            */
/* Input Parameters: [Same as before +]                                       */
/*                   @n_uombase (Case Size)                                   */
/*                   @n_qtylefttofulfill (ORDER QUANTITY - NEW LOGIC)         */
/*                                                                            */
/* Enhancement: 25-MAR-2026 - Surya - Order-Driven Allocation                 */
/*                                                                            */
/* Order-Driven Allocation Rules:                                             */
/* Scenario 1: Order contains full pallet quantities                          */
/*   - Phase 1: Allocate FULL pallets only (FIFO)                             */
/*   - Phase 2: Allocate PARTIAL pallets (FIFO) for remaining qty             */
/*                                                                            */
/* Scenario 3: Order contains NO full pallets                                 */
/*   - Single phase: Allocate PARTIAL pallets (FIFO)                          */
/*                                                                            */
/* Key Rule: Partial pallets CANNOT fulfill full pallet quantities            */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspPRDEU1]
-- for NIKE CN with Order-Driven Allocation
@c_storerkey NVARCHAR(15),
@c_sku NVARCHAR(20),
@c_lot NVARCHAR(10),
@c_lottable01 NVARCHAR(18),
@c_lottable02 NVARCHAR(18),
@c_lottable03 NVARCHAR(18),
@d_lottable04 DATETIME,
@d_lottable05 DATETIME,
@c_uom NVARCHAR(10),
@c_facility NVARCHAR(10),
@n_uombase INT,
@n_qtylefttofulfill INT,           -- Order Qty (for order-driven logic)
@c_OtherParms NVARCHAR(200) = ''   -- Order info for pre-allocation
AS
BEGIN
   -- =========================================================================
   -- DECLARATIONS
   -- =========================================================================
   DECLARE @b_success INT, @n_err INT, @c_errmsg NVARCHAR(250), @b_debug INT
   DECLARE @c_manual NVARCHAR(1)
   DECLARE @c_LimitString NVARCHAR(255)
   DECLARE @c_Limitstring1 NVARCHAR(255), @c_lottable04label NVARCHAR(20)
   DECLARE @n_shelflife INT
   DECLARE @c_UOMBase NVARCHAR(10)

   -- =========================================================================
   -- NEW: ORDER-DRIVEN ALLOCATION VARIABLES
   -- =========================================================================
   DECLARE @n_fullPalletRequirement INT
   DECLARE @n_remainingRequirement INT
   DECLARE @c_allocationScenario NVARCHAR(20)

   -- Initialize variables
   SELECT @b_success = 0, @n_err = 0, @c_errmsg = '', @b_debug = 1
   SELECT @c_manual = 'N'
   SELECT @c_UOMBase = @n_uombase

   -- =========================================================================
   -- NEW: CALCULATE ORDER STRUCTURE (Order-Driven Logic)
   -- =========================================================================
   SET @n_fullPalletRequirement = (@n_qtylefttofulfill / @n_uombase) * @n_uombase
   SET @n_remainingRequirement = @n_qtylefttofulfill % @n_uombase

   -- Handle null/default dates
   IF @d_lottable04 = '1900-01-01'
      SELECT @d_lottable04 = NULL

   IF @d_lottable05 = '1900-01-01'
      SELECT @d_lottable05 = NULL

   -- Determine if manual mode based on supplied lottables
   IF ((ISNULL(LTRIM(RTRIM(@c_lottable01)),'')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@c_lottable02)),'')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@c_lottable03)),'')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@d_lottable04)),'')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@d_lottable05)),'')) <> '') OR
       LEFT(ISNULL(LTRIM(RTRIM(@c_lot)),''),1) = '*'
   BEGIN
      SELECT @c_manual = 'Y'
   END

   -- =========================================================================
   -- ORIGINAL LOGIC - BRANCH 1: SPECIFIC LOT PROVIDED
   -- =========================================================================
   IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lot)) IS NOT NULL
      AND dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lot)) <> ''
      AND LEFT(@c_lot, 1) <> '*'
   BEGIN
      -- Lot specific candidate set
      DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR
      SELECT
         LOT.STORERKEY,
         LOT.SKU,
         LOT.LOT,
         QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
      FROM LOT (NOLOCK)
         JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT
         JOIN LOTXLOCXID (NOLOCK) ON LOTXLOCXID.Lot = LOT.LOT
            AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT
         JOIN LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC
         JOIN SKUxLOC (NOLOCK) ON SKUxLOC.StorerKey = LOTxLOCxID.StorerKey
            AND SKUxLOC.SKU = LOTxLOCxID.SKU
            AND SKUxLOC.LOC = LOTxLOCxID.LOC

      WHERE LOT.LOT = @c_lot
         AND LOC.Facility = @c_facility
         AND (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED) > 0

      -- NEW: ORDER BY with Phase + FIFO + Pallet Type
      ORDER BY
         -- Priority 1: Allocation Phase (FULL_REQ first)
         CASE
            WHEN @c_allocationScenario = 'SCENARIO_1'
                 AND ((LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED) % @n_uombase = 0)
                 AND ((LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED) >= @n_uombase)
            THEN 0  -- Phase 1: Full Pallets
            ELSE 1  -- Phase 2: Partial Pallets
         END,

         -- Priority 2: FIFO (oldest LOT.CreateDate first)
         LOT.EditDate ASC,

         -- Priority 3: Original ordering (Lottable04, Lottable05)
         LOTATTRIBUTE.Lottable04,
         LOTATTRIBUTE.LOTTABLE05

      IF @b_debug = 1
      BEGIN
         PRINT 'BRANCH 1: Specific LOT provided'
         PRINT '  LOT: ' + @c_lot
         PRINT '  Query by exact LOT number'
      END
   END

   -- =========================================================================
   -- ORIGINAL LOGIC - BRANCH 2: LOT NOT PROVIDED
   -- =========================================================================
   ELSE
   BEGIN
      IF @c_manual = 'N'
      BEGIN
         -- Auto mode: Get shelf life from SKU
         IF @b_debug = 1 SELECT 'BRANCH 2A: Manual = N (Auto mode), LOT is NULL'

         SELECT @n_shelflife = CONVERT(INT, SKU.SUSR2)
         FROM SKU (NOLOCK)
         WHERE SKU = @c_sku
            AND STORERKEY = @c_storerkey

         SELECT @c_lottable04label = SKU.Lottable04label
         FROM SKU (NOLOCK)
         WHERE SKU = @c_sku
            AND STORERKEY = @c_storerkey

         SELECT @c_Limitstring1 = ''

         IF @c_lottable04label = 'MANDATE'
         BEGIN
            IF @n_shelflife > 0
            BEGIN
               SELECT @c_Limitstring1 = dbo.fnc_RTrim(@c_LimitString1)
                  + " AND lottable04 > N'"
                  + CONVERT(CHAR(15), DATEADD(DAY, -@n_shelflife, GETDATE()), 106) + "'"
            END
            ELSE
            BEGIN
               SELECT @c_Limitstring1 = dbo.fnc_RTrim(@c_LimitString1)
                  + " AND Lottable05 <= N'"
                  + CONVERT(CHAR(15), GETDATE(), 106) + "'"
            END
         END

         -- NEW: Dynamic SQL with Order-Driven Logic
         EXEC ('DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR  ' +
               'SELECT MIN(LOTXLOCXID.STORERKEY), MIN(LOTXLOCXID.SKU), LOT.LOT, ' +
               'QTYAVAILABLE = (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) ' +
               'FROM LOT (NOLOCK) ' +
               'JOIN LOTATTRIBUTE (NOLOCK) ON lot.lot = lotattribute.lot ' +
               'JOIN LOTXLOCXID (NOLOCK) ON LOTXLOCXID.LOT = LOT.LOT AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT ' +
               'JOIN LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC ' +
               'JOIN ID (NOLOCK) ON LOTXLOCXID.ID = ID.ID ' +
               'JOIN SKU (NOLOCK) ON SKU.SKU = LOTXLOCXID.SKU ' +
               'JOIN SKUxLOC (NOLOCK) ON SKUxLOC.StorerKey = LOTXLOCXID.StorerKey ' +
               '   AND SKUxLOC.SKU = LOTXLOCXID.SKU AND SKUxLOC.LOC = LOTXLOCXID.LOC ' +
               'WHERE LOTXLOCXID.STORERKEY = N''' + @c_storerkey + ''' ' +
               'AND LOTXLOCXID.SKU = N''' + @c_sku + ''' ' +
               'AND LOT.STATUS = ''OK'' AND LOC.STATUS = ''OK'' AND ID.STATUS = ''OK'' AND LOC.LocationFlag = ''NONE'' ' +
               'AND LOC.FACILITY = N''' + @c_facility + ''' ' + @c_Limitstring1 + ' ' +
               'GROUP BY LOT.LOT, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.LOTTABLE05, LOTATTRIBUTE.Lottable02, LOT.CreateDate ' +
               'HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked)- MIN(LOT.QtyPreAllocated)) > 0 ' +
               'ORDER BY ' +
               '   CASE ' +
               '      WHEN ' + CAST(@n_fullPalletRequirement AS VARCHAR(10)) + ' > 0 ' +
               '           AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) % ' + CAST(@n_uombase AS VARCHAR(10)) + ' = 0) ' +
               '           AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) >= ' + CAST(@n_uombase AS VARCHAR(10)) + ') ' +
               '      THEN 0 ' +
               '      ELSE 1 ' +
               '   END, ' +
               '   LOT.EditDate ASC, ' +
               '   LOTATTRIBUTE.Lottable04, ' +
               '   LOTATTRIBUTE.LOTTABLE05 ')
      END

      ELSE
      BEGIN
         -- Manual mode: Build WHERE from lottables
         IF @b_debug = 1 SELECT 'BRANCH 2B: Manual = Y, LOT is NULL'

         SELECT @c_LimitString = ''

         IF ISNULL(RTRIM(@c_lottable01),'') <> ''
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND Lottable01= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lottable01)) + "'"

         IF ISNULL(RTRIM(@c_lottable02),'') <> ''
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND lottable02= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lottable02)) + "'"

         IF ISNULL(RTRIM(@c_lottable03),'') <> ''
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND lottable03= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lottable03)) + "'"

         IF ISNULL(RTRIM(@d_lottable04),'') <> '' AND ISNULL(RTRIM(@d_lottable04),'') <> '1900-01-01'
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND lottable04 = N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(CHAR(20), @d_lottable04))) + "'"

         IF ISNULL(RTRIM(@d_lottable05),'') <> '' AND ISNULL(RTRIM(@d_lottable05),'') <> '1900-01-01'
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND lottable05= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(CHAR(20), @d_lottable05))) + "'"

         IF LEFT(@c_lot,1) = '*'
         BEGIN
            SELECT @n_shelflife = CONVERT(INT, SUBSTRING(@c_lot, 2, 9))

            IF @n_shelflife < 13
            BEGIN
               SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString)
                  + " AND lottable04 > N'"
                  + CONVERT(CHAR(15), DATEADD(MONTH, @n_shelflife, GETDATE()), 106) + "'"
            END
            ELSE
            BEGIN
               SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString)
                  + " AND lottable04 > N'"
                  + CONVERT(CHAR(15), DATEADD(DAY, @n_shelflife, GETDATE()), 106) + "'"
            END
         END

         -- NEW: Dynamic SQL with Order-Driven Logic for Manual Mode
         SELECT @c_StorerKey = dbo.fnc_RTrim(@c_StorerKey)
         SELECT @c_Sku = dbo.fnc_RTrim(@c_SKU)

         EXEC ('DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR ' +
               'SELECT MIN(LOTXLOCXID.STORERKEY), MIN(LOTXLOCXID.SKU), LOT.LOT, ' +
               'QTYAVAILABLE = (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) ' +
               'FROM LOT (NOLOCK) ' +
               'JOIN LOTATTRIBUTE (NOLOCK) ON lot.lot = lotattribute.lot ' +
               'JOIN LOTXLOCXID (NOLOCK) ON LOTXLOCXID.LOT = LOT.LOT AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT ' +
               'JOIN LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC ' +
               'JOIN ID (NOLOCK) ON LOTXLOCXID.ID = ID.ID ' +
               'JOIN SKUxLOC (NOLOCK) ON SKUxLOC.StorerKey = LOTXLOCXID.StorerKey ' +
               '   AND SKUxLOC.SKU = LOTXLOCXID.SKU AND SKUxLOC.LOC = LOTXLOCXID.LOC ' +
               'WHERE LOTXLOCXID.STORERKEY = N''' + @c_storerkey + ''' ' +
               'AND LOTXLOCXID.SKU = N''' + @c_sku + ''' ' +
               'AND LOT.STATUS = ''OK'' AND LOC.STATUS = ''OK'' AND ID.STATUS = ''OK'' AND LOC.LocationFlag = ''NONE'' ' +
               'AND LOC.FACILITY = N''' + @c_facility + ''' ' + @c_LimitString + ' ' +
               'AND (SKUxLOC.LocationType NOT IN (''PICK'', ''CASE'') OR SKUxLOC.LocationType IN (''PICK'', ''CASE'')) ' +
               'GROUP BY LOT.LOT, SKUxLOC.LocationType, LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE02, LOTATTRIBUTE.LOTTABLE05, LOT.CreateDate ' +
               'HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked)- MIN(LOT.QtyPreAllocated) ) > 0 ' +
               'ORDER BY ' +
               '   CASE ' +
               '      WHEN ' + CAST(@n_fullPalletRequirement AS VARCHAR(10)) + ' > 0 ' +
               '           AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) % ' + CAST(@n_uombase AS VARCHAR(10)) + ' = 0) ' +
               '           AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated)) >= ' + CAST(@n_uombase AS VARCHAR(10)) + ') ' +
               '      THEN 0 ' +
               '      ELSE 1 ' +
               '   END, ' +
               '   LOT.EditDate ASC, ' +
               '   SKUxLOC.LocationType, ' +
               '   LOTATTRIBUTE.LOTTABLE04, ' +
               '   LOTATTRIBUTE.LOTTABLE02, ' +
               '   LOTATTRIBUTE.LOTTABLE05 ')
      END
   END
END
GO

GRANT EXECUTE ON mspPRDEU1 TO nSQL
GO
