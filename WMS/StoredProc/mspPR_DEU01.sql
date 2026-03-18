SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store Procedure:  mspPR_DEU01                                        */
/* Creation Date: 02/03/26                                              */
/* Copyright: MAERSK                                                    */
/* Written by:  Suryakanta Sahoo                                        */
/*                                                                      */
/* Purpose:  FCR-10743 Pre-Allocation Strategy                          */
/*                                                                      */
/* Input Parameters:  @c_storerkey char                                 */
/*                    @c_sku char                                       */
/*                    @c_lot char                                       */
/*                    @c_lottable01                                     */
/*                    @c_lottable02                                     */
/*                    @c_lottable03                                     */
/*                    @d_lottable04                                     */
/*                    @d_lottable05                                     */
/*                    @c_uom                                            */
/*                    @c_facility                                       */
/*                    @n_uombase                                        */
/*                    @n_qtylefttofulfill                               */
/*                                                                      */
/* Output Parameters:  None                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: Allocation Module                                         */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/*   Date              Author          Purposes                         */
/*   02/03/26        Suryakanta        FCR-10743                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspPR_DEU01]
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
   @n_qtylefttofulfill INT,
   @c_OtherParms NVARCHAR(200) = ''
AS
BEGIN

   DECLARE @b_success INT, @n_err INT, @c_errmsg NVARCHAR(250), @b_debug INT
   DECLARE @c_manual NVARCHAR(1)
   DECLARE @c_LimitString NVARCHAR(255)
   DECLARE @c_Limitstring1 NVARCHAR(255), @c_lottable04label NVARCHAR(20)

   SELECT @b_success = 0, @n_err = 0, @c_errmsg = '', @b_debug = 0
   SELECT @c_manual = 'N'

   DECLARE @n_shelflife INT
   DECLARE @n_continue INT
   DECLARE @c_UOMBase NVARCHAR(10)
   DECLARE @sql_query NVARCHAR(MAX)
   SELECT @c_UOMBase = @n_uombase

   IF @d_lottable04 = '1900-01-01'
   BEGIN
      SELECT @d_lottable04 = NULL
   END

   IF @d_lottable05 = '1900-01-01'
   BEGIN
      SELECT @d_lottable05 = NULL
   END

   IF @b_debug = 1
   BEGIN
      SELECT 'nspPR_CH01 : Before Lot Lookup .....'
      SELECT '@c_lot' = @c_lot, '@c_lottable01' = @c_lottable01, '@c_lottable02' = @c_lottable02, '@c_lottable03' = @c_lottable03
      SELECT '@d_lottable04' = @d_lottable04, '@d_lottable05' = @d_lottable05, '@c_manual' = @c_manual, '@c_sku' = @c_sku
      SELECT '@c_storerkey' = @c_storerkey, '@c_facility' = @c_facility
   END

   IF ((ISNULL(LTRIM(RTRIM(@c_lottable01)), '')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@c_lottable02)), '')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@c_lottable03)), '')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@d_lottable04)), '')) <> '' OR
       (ISNULL(LTRIM(RTRIM(@d_lottable05)), '')) <> '') OR
       LEFT(ISNULL(LTRIM(RTRIM(@c_lot)), ''), 1) = '*'
   BEGIN
      SELECT @c_manual = 'Y'
   END

   IF @b_debug = 1
   BEGIN
      SELECT 'nspPR_CH01 : After Lot Lookup .....'
      SELECT '@c_lot' = @c_lot, '@c_lottable01' = @c_lottable01, '@c_lottable02' = @c_lottable02, '@c_lottable03' = @c_lottable03
      SELECT '@d_lottable04' = @d_lottable04, '@d_lottable05' = @d_lottable05, '@c_manual' = @c_manual
      SELECT '@c_storerkey' = @c_storerkey
   END

   IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lot)) IS NOT NULL AND
      dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lot)) <> '' AND
      LEFT(@c_lot, 1) <> '*'
   BEGIN
      /* Lot specific candidate set */
      DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR
      SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT,
             QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
      FROM LOT (NOLOCK)
         INNER JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT
         INNER JOIN LOTXLOCXID (NOLOCK) ON LOTXLOCXID.LOT = LOT.LOT
         INNER JOIN LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC
         INNER JOIN ID (NOLOCK) ON LOTXLOCXID.ID = ID.ID
         INNER JOIN SKUxLOC (NOLOCK) ON SKUxLOC.StorerKey = LOTxLOCxID.StorerKey
            AND SKUxLOC.SKU = LOTxLOCxID.SKU
            AND SKUxLOC.LOC = LOTxLOCxID.LOC
      WHERE LOT.LOT = @c_lot
         AND LOC.Facility = @c_facility
         AND LOTXLOCXID.STORERKEY = @c_storerkey
         AND LOTXLOCXID.SKU = @c_sku
         AND ((LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED) % @n_uombase) = 0
         AND (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED) >= @n_uombase
      ORDER BY LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.LOTTABLE05

      IF @b_debug = 1
      BEGIN
         SELECT ' Lot not null'
         SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT,
                QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
         FROM LOT, LOTATTRIBUTE
         WHERE LOT.LOT = LOTATTRIBUTE.LOT
            AND LOT.LOT = @c_lot
         ORDER BY LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.LOTTABLE02
      END
   END
   ELSE
   BEGIN
      /* Everything Else when no lottable supplied */
      IF @c_manual = 'N'
      BEGIN
         IF @b_debug = 1
            SELECT 'Manual = N and Lot is NULL'

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
               SELECT @c_Limitstring1 = dbo.fnc_RTrim(@c_LimitString1) + ' AND lottable04 > N''' +
                  CONVERT(CHAR(15), DATEADD(DAY, -@n_shelflife, GETDATE()), 106) + ''''
            END
            ELSE
            BEGIN
               SELECT @c_Limitstring1 = dbo.fnc_RTrim(@c_LimitString1) + ' AND Lottable05 <= N''' +
                  CONVERT(CHAR(15), GETDATE(), 106) + ''''
            END
         END

         IF @b_debug = 1
         BEGIN
            SELECT 'Manual = N'
            SELECT 'limitstring', @c_limitstring1
         END

     SET @sql_query = 'DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR  ' +
            'SELECT MIN(LOTXLOCXID.STORERKEY) , MIN(LOTXLOCXID.SKU), LOT.LOT,   ' +
            'QTYAVAILABLE = (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated) )' +
            'FROM LOT (NOLOCK) , LOTATTRIBUTE (NOLOCK), LOTXLOCXID (NOLOCK), LOC (NOLOCK), ID (NOLOCK), SKU (NOLOCK), SKUxLOC (NOLOCK) ' +
            'WHERE LOTXLOCXID.STORERKEY = N''' + @c_storerkey + ''' ' +
            ' AND LOTXLOCXID.SKU = N''' + @c_sku + ''' ' +
            ' AND LOT.STATUS = "OK" AND LOC.STATUS = "OK" AND ID.STATUS = "OK" And LOC.LocationFlag = "NONE" ' +
            ' AND LOTXLOCXID.ID = ID.ID AND lot.lot = lotattribute.lot ' +
            ' AND LOTXLOCXID.LOT = LOT.LOT AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT ' +
            ' AND LOTXLOCXID.LOC = LOC.LOC ' +
            ' AND SKU.SKU = LOTXLOCxID.SKU ' +
            ' AND SKU.STORERKEY = LOTXLOCXID.STORERKEY ' +
            ' AND LOTATTRIBUTE.SKU = SKU.SKU AND LOTATTRIBUTE.STORERKEY = SKU.STORERKEY ' +
            ' AND LOC.FACILITY = N''' + @c_facility + ''' ' + @c_LimitString1 + ' ' +
            ' AND SKUxLOC.StorerKey = LOTxLOCxID.StorerKey ' +
            ' AND SKUxLOC.SKU = LOTxLOCxID.SKU ' +
            ' AND SKUxLOC.LOC = LOTxLOCxID.LOC ' +
            ' AND ID.QTY >= ' + CAST(@n_uombase AS NVARCHAR) + ' ' +
            ' GROUP BY LOT.LOT ' +
            ' HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked)- MIN(LOT.QtyPreAllocated) )>= ' + CAST(@n_uombase AS NVARCHAR) + ' ' +
            'AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreAllocated)) % ' + CAST(@n_uombase AS NVARCHAR) + ') = 0 ' +
            ' ORDER BY lotATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE05 '

    EXEC (@sql_query)
         IF @b_debug = 1
         BEGIN
            SELECT 'AND LOC.FACILITY = N''' + @c_facility + '''' + @c_LimitString1 + '"'
         END
      END
      ELSE
      BEGIN
         IF @b_debug = 1
            SELECT 'Manual = Y and Lot is NULL'

         SELECT @c_LimitString = ''

         IF ISNULL(RTRIM(@c_lottable01), '') <> ''
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + ' AND Lottable01= N''' +
               dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lottable01)) + ''''

         IF ISNULL(RTRIM(@c_lottable02), '') <> ''
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + ' AND lottable02= N''' +
               dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lottable02)) + ''''

         IF ISNULL(RTRIM(@c_lottable03), '') <> ''
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + ' AND lottable03= N''' +
               dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lottable03)) + ''''

         IF ISNULL(RTRIM(@d_lottable04), '') <> '' AND
            ISNULL(RTRIM(@d_lottable04), '') <> '1900-01-01'
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + ' AND lottable04 = N''' +
               dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(CHAR(20), @d_lottable04))) + ''''

         IF ISNULL(RTRIM(@d_lottable05), '') <> '' AND
            ISNULL(RTRIM(@d_lottable05), '') <> '1900-01-01'
            SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + ' AND lottable05= N''' +
               dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(CHAR(20), @d_lottable05))) + ''''

         IF LEFT(@c_lot, 1) = '*'
         BEGIN
            SELECT @n_shelflife = CONVERT(INT, SUBSTRING(@c_lot, 2, 9))

            IF @n_shelflife < 13
            BEGIN
               SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString) + ' AND lottable04 > N''' +
                  CONVERT(CHAR(15), DATEADD(MONTH, @n_shelflife, GETDATE()), 106) + ''''
            END
            ELSE
            BEGIN
               SELECT @c_Limitstring = dbo.fnc_RTrim(@c_LimitString) + ' AND lottable04 > N''' +
                  CONVERT(CHAR(15), DATEADD(DAY, @n_shelflife, GETDATE()), 106) + ''''
            END
         END

         IF @b_debug = 1
         BEGIN
            SELECT '@c_limitstring', @c_limitstring
         END

         IF @b_debug = 1
         BEGIN
            PRINT ('DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR ' +
               ' SELECT MIN(LOTXLOCXID.STORERKEY) , MIN(LOTXLOCXID.SKU), LOT.LOT, ' +
               ' QTYAVAILABLE = (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated) ) ' +
               ' FROM LOT (NOLOCK) ' +
               ' JOIN LOTATTRIBUTE (NOLOCK) ON (lot.lot = lotattribute.lot) ' +
               ' JOIN LOTXLOCXID (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT) ' +
               ' JOIN LOC (NOLOCK) ON (LOTXLOCXID.LOC = LOC.LOC) ' +
               ' JOIN ID (NOLOCK) ON (LOTXLOCXID.ID = ID.ID) ' +
               ' JOIN SKUxLOC (NOLOCK) ON (SKUxLOC.SKU = LOTxLOCxID.SKU AND SKUxLOC.LOC = LOTxLOCxID.LOC AND SKUxLOC.StorerKey = LOTxLOCxID.StorerKey) ' +
               ' LEFT OUTER JOIN (SELECT P.lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) ' +
               ' FROM PreallocatePickdetail P (NOLOCK), ORDERS (NOLOCK) ' +
               ' WHERE P.Orderkey = ORDERS.Orderkey ' +
               ' AND P.Storerkey = N''' + @c_storerkey + ''' ' +
               ' AND P.SKU = N''' + @c_sku + ''' ' +
               ' AND ORDERS.FACILITY = N''' + @c_facility + ''' ' +
               ' AND P.qty > 0 ' +
               ' GROUP BY p.Lot, ORDERS.Facility) P ON LOTXLOCXID.Lot = P.Lot AND P.Facility = LOC.Facility ' +
               ' WHERE LOTXLOCXID.STORERKEY = N''' + @c_storerkey + ''' ' +
               ' AND LOTXLOCXID.SKU = N''' + @c_sku + ''' ' +
               ' AND LOT.STATUS = "OK" AND LOC.STATUS = "OK" AND ID.STATUS = "OK" And LOC.LocationFlag = "NONE" ' +
               ' AND LOC.FACILITY = N''' + @c_facility + ''' ' + @c_LimitString + ' ' +
               ' AND (SKUxLOC.LocationType NOT IN ("PICK", "CASE") OR SKUxLOC.LocationType IN ("PICK", "CASE")) ' +
               ' AND ID.QTY >= ' + CAST(@n_uombase AS NVARCHAR) + ' ' +
               ' GROUP BY LOT.LOT, SKUxLOC.LocationType, LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE02, LOTATTRIBUTE.LOTTABLE05 ' +
               ' HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked)- MIN(LOT.QtyPreAllocated) ) >= ' + CAST(@n_uombase AS NVARCHAR) + ' ' +
               ' AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreAllocated)) % ' + CAST(@n_uombase AS NVARCHAR) + ') = 0 ' +
               ' ORDER BY SKUxLOC.LocationType, LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE02, LOTATTRIBUTE.LOTTABLE05 ')
         END

      SELECT @c_StorerKey = dbo.fnc_RTrim(@c_StorerKey)
      SELECT @c_Sku = dbo.fnc_RTrim(@c_SKU)

      SET @sql_query = 'DECLARE PREALLOCATE_CURSOR_CANDIDATES SCROLL CURSOR FOR ' +
            ' SELECT MIN(LOTXLOCXID.STORERKEY) , MIN(LOTXLOCXID.SKU), LOT.LOT, ' +
            ' QTYAVAILABLE = (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreallocated) ) ' +
            ' FROM LOT (NOLOCK) ' +
            ' JOIN LOTATTRIBUTE (NOLOCK) ON (lot.lot = lotattribute.lot) ' +
            ' JOIN LOTXLOCXID (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT) ' +
            ' JOIN LOC (NOLOCK) ON (LOTXLOCXID.LOC = LOC.LOC) ' +
            ' JOIN ID (NOLOCK) ON (LOTXLOCXID.ID = ID.ID) ' +
            ' JOIN SKUxLOC (NOLOCK) ON (SKUxLOC.SKU = LOTxLOCxID.SKU AND SKUxLOC.LOC = LOTxLOCxID.LOC AND SKUxLOC.StorerKey = LOTxLOCxID.StorerKey) ' +
            ' LEFT OUTER JOIN (SELECT P.lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) ' +
            ' FROM PreallocatePickdetail P (NOLOCK), ORDERS (NOLOCK) ' +
            ' WHERE P.Orderkey = ORDERS.Orderkey ' +
            ' AND P.Storerkey = N''' + @c_storerkey + ''' ' +
            ' AND P.SKU = N''' + @c_sku + ''' ' +
            ' AND ORDERS.FACILITY = N''' + @c_facility + ''' ' +
            ' AND P.qty > 0 ' +
            ' GROUP BY p.Lot, ORDERS.Facility) P ON LOTXLOCXID.Lot = P.Lot AND P.Facility = LOC.Facility ' +
            ' WHERE LOTXLOCXID.STORERKEY = N''' + @c_storerkey + ''' ' +
            ' AND LOTXLOCXID.SKU = N''' + @c_sku + ''' ' +
            ' AND LOT.STATUS = "OK" AND LOC.STATUS = "OK" AND ID.STATUS = "OK" And LOC.LocationFlag = "NONE" ' +
            ' AND LOC.FACILITY = N''' + @c_facility + ''' ' + @c_LimitString + ' ' +
            ' AND (SKUxLOC.LocationType NOT IN ("PICK", "CASE") OR SKUxLOC.LocationType IN ("PICK", "CASE")) ' +
            ' AND ID.QTY >= ' + CAST(@n_uombase AS NVARCHAR) + ' ' +
            ' GROUP BY LOT.LOT, SKUxLOC.LocationType, LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE02, LOTATTRIBUTE.LOTTABLE05 ' +
            ' HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked)- MIN(LOT.QtyPreAllocated) )>= ' + CAST(@n_uombase AS NVARCHAR) + ' ' +
            ' AND ((SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(LOT.QtyPreAllocated)) % ' + CAST(@n_uombase AS NVARCHAR) + ') = 0 ' +
            ' ORDER BY SKUxLOC.LocationType, LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE02, LOTATTRIBUTE.LOTTABLE05 '
     EXEC (@sql_query)
     END
   END
END
GO
GRANT EXECUTE ON mspPR_DEU01 TO nSQL
GO
