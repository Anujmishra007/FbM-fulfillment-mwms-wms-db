SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Stored Procedure: nspPRIDS21                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4.2                                                       */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 19-Oct-2005  Vicky         SOS#42066 - Fix getting multiple line     */
/*                            from same lot                             */
/* 18-AUG-2015  YTWan   1.1   SOS#350432 - Project Merlion -            */
/*                            Allocation Strategy (Wan01)               */
/* 25-Jun-2025  WLChooi 1.2   UWP-36187-Support Multi Facilities(WL01)  */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[nspPRIDS21]
         @c_storerkey       NVARCHAR(15) ,
         @c_sku             NVARCHAR(20) ,
         @c_lot             NVARCHAR(10) ,
         @c_lottable01      NVARCHAR(18) ,
         @c_lottable02      NVARCHAR(18) ,
         @c_lottable03      NVARCHAR(18) ,
         @d_lottable04      DATETIME,
         @d_lottable05      DATETIME,
         @c_lottable06      NVARCHAR(30) ,  --(Wan01)
         @c_lottable07      NVARCHAR(30) ,  --(Wan01)
         @c_lottable08      NVARCHAR(30) ,  --(Wan01)
         @c_lottable09      NVARCHAR(30) ,  --(Wan01)
         @c_lottable10      NVARCHAR(30) ,  --(Wan01)
         @c_lottable11      NVARCHAR(30) ,  --(Wan01)
         @c_lottable12      NVARCHAR(30) ,  --(Wan01)
         @d_lottable13      DATETIME ,      --(Wan01)
         @d_lottable14      DATETIME ,      --(Wan01)
         @d_lottable15      DATETIME ,      --(Wan01)
         @c_uom             NVARCHAR(10) ,
         @c_Facility        NVARCHAR(5),
         @n_uombase           INT ,
         @n_qtylefttofulfill  INT
        ,@c_OtherParms NVARCHAR(200)=''     --(Wan01)
AS
BEGIN

      DECLARE @n_StorerMinShelfLife INT,
              @c_Condition NVARCHAR(4000)     --(Wan01)
            , @c_SQL       NVARCHAR(MAX)      --WL01

      IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lot)) IS NOT NULL
      BEGIN
            /* Get Storer Minimum Shelf Life */

            SELECT @n_StorerMinShelfLife = ((Sku.Shelflife * Storer.MinShelflife/100) * -1)
            FROM  SKU (NOLOCK), STORER (NOLOCK), LOT (NOLOCK)
            WHERE Lot.Lot = @c_lot
            AND   Lot.Sku = Sku.Sku
            AND   Sku.Storerkey = Storer.Storerkey

            DECLARE  PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
               SELECT LOT.STORERKEY,LOT.SKU,LOT.LOT ,
                      QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
               FROM  LOT (NOLOCK), LOTATTRIBUTE (NOLOCK), LOTXLOCXID (NOLOCK), LOC (NOLOCK)
               WHERE LOT.LOT = @c_lot
               AND LOT.LOT = LOTATTRIBUTE.LOT
               AND LOTXLOCXID.Lot = LOT.LOT
               AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT
               AND LOTXLOCXID.LOC = LOC.LOC
               AND LOC.Facility = @c_facility
               -- AND DateAdd(Day, @n_StorerMinShelfLife, Lotattribute.Lottable04) > GetDate()
               ORDER BY Lotattribute.Lottable04, Lotattribute.Lottable05
      END
      ELSE
      BEGIN
            /* Get Storer Minimum Shelf Life */
            --    SELECT @n_StorerMinShelfLife = ((Sku.Shelflife * Storer.MinShelflife/100) * -1)
            --    FROM Sku (nolock), Storer (nolock)
            --    WHERE Sku.Sku = @c_sku
            --    AND Sku.Storerkey = @c_storerkey
            --    AND Sku.Storerkey = Storer.Storerkey
            --
            --    IF @n_StorerMinShelfLife IS NULL
            --       SELECT @n_StorerMinShelfLife = 0


            IF dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable01)) <> '' AND @c_Lottable01 IS NOT NULL
            BEGIN
               SELECT @c_Condition = " AND LOTTABLE01 = N'" + dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable01)) + "' "
            END
            IF dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable02)) <> '' AND @c_Lottable02 IS NOT NULL
            BEGIN
               SELECT @c_Condition = dbo.fnc_RTrim(@c_Condition) + " AND LOTTABLE02 = N'" + dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable02)) + "' "
            END
            IF dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable03)) <> '' AND @c_Lottable03 IS NOT NULL
            BEGIN
               SELECT @c_Condition = dbo.fnc_RTrim(@c_Condition) + " AND LOTTABLE03 = N'" + dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable03)) + "' "
            END
            IF CONVERT(CHAR(10), @d_Lottable04, 103) <> "01/01/1900"
            BEGIN
               SELECT @c_Condition = dbo.fnc_RTrim(@c_Condition) + " AND LOTTABLE04 = N'" + dbo.fnc_RTrim(CONVERT( NVARCHAR(20), @d_Lottable04, 106)) + "' "
            END
            IF CONVERT(CHAR(10), @d_Lottable05, 103) <> "01/01/1900"
            BEGIN
               SELECT @c_Condition = dbo.fnc_RTrim(@c_Condition) + " AND LOTTABLE05 = N'" + dbo.fnc_RTrim(CONVERT( NVARCHAR(20), @d_Lottable05, 106)) + "' "
            END

            --(Wan01) - START
            IF RTRIM(@c_Lottable06) <> '' AND @c_Lottable06 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable06 = N''' + RTRIM(@c_Lottable06) + ''''
            END

            IF RTRIM(@c_Lottable07) <> '' AND @c_Lottable07 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable07 = N''' + RTRIM(@c_Lottable07) + ''''
            END

            IF RTRIM(@c_Lottable08) <> '' AND @c_Lottable08 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable08 = N''' + RTRIM(@c_Lottable08) + ''''
            END

            IF RTRIM(@c_Lottable09) <> '' AND @c_Lottable09 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable09 = N''' + RTRIM(@c_Lottable09) + ''''
            END

            IF RTRIM(@c_Lottable10) <> '' AND @c_Lottable10 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable10 = N''' + RTRIM(@c_Lottable10) + ''''
            END

            IF RTRIM(@c_Lottable11) <> '' AND @c_Lottable11 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable11 = N''' + RTRIM(@c_Lottable11) + ''''
            END

            IF RTRIM(@c_Lottable12) <> '' AND @c_Lottable12 IS NOT NULL
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable12 = N''' + RTRIM(@c_Lottable12) + ''''
            END

            IF CONVERT(CHAR(10), @d_Lottable13, 103) <> '01/01/1900'
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable13 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) + ''''
            END

     IF CONVERT(CHAR(10), @d_Lottable14, 103) <> '01/01/1900'
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable14 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) + ''''
            END

            IF CONVERT(CHAR(10), @d_Lottable15, 103) <> '01/01/1900'
            BEGIN
               SET @c_Condition = @c_Condition + ' AND LOTATTRIBUTE.Lottable15 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) + ''''
            END
            --(Wan01) - END

            --  Added By Vicky on 19th Oct 2005 for SOS#42066 - Start
            SELECT @c_Condition = dbo.fnc_RTrim(@c_Condition) + " GROUP BY LOT.STORERKEY, LOT.SKU, LOT.LOT, LOT.QTY, LOT.QTYALLOCATED, LOT.QTYPICKED, LOT.QTYPREALLOCATED, QTYONHOLD, " +
            "LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE05 "         -- End Vicky
            SELECT @c_Condition = dbo.fnc_RTrim(@c_Condition) + " ORDER BY LOTATTRIBUTE.LOTTABLE04, LOTATTRIBUTE.LOTTABLE05 "

            --WL01 S
            --EXEC ('DECLARE  PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR  '
            --   + 'SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT, '
            --   + 'QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED - QTYONHOLD) '
            --   + 'FROM LOT (NOLOCK), LOTATTRIBUTE (NOLOCK), LOTXLOCXID (NOLOCK), LOC (NOLOCK) '
            --   + 'WHERE LOT.STORERKEY = N''' + @c_storerkey  + ''' '
            --   + 'AND LOT.SKU = N''' + @c_sku + ''' '
            --   + 'AND LOT.STATUS = "OK" '
            --   + 'AND LOT.Lot = LOTATTRIBUTE.Lot '
            --   + 'AND LOTXLOCXID.Lot = LOT.LOT '
            --   + 'AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT '
            --   + 'AND LOTXLOCXID.LOC = LOC.LOC '
            --   + 'AND LOC.Facility = N''' + @c_facility + ''' '
            --   + 'AND (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED - QTYONHOLD) > 0 '
            --   + @c_Condition )
            -- AND DateAdd(Day, @n_StorerMinShelfLife, Lotattribute.Lottable04) > GetDate()

            SET @c_SQL = N' DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR '
                       + N' SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT, '
                       + N'        QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED - QTYONHOLD) '
                       + N' FROM LOT (NOLOCK) '
                       + N' JOIN LOTATTRIBUTE (NOLOCK) ON LOT.Lot = LOTATTRIBUTE.Lot '
                       + N' JOIN LOTXLOCXID (NOLOCK) ON LOTXLOCXID.Lot = LOT.LOT '
                       + N'                         AND LOTXLOCXID.LOT = LOTATTRIBUTE.LOT '
                       + N' JOIN LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC '
                       + N' JOIN ( SELECT Facility, FacSort FROM dbo.fnc_GetFacilitiesByStorer(@c_Storerkey, @c_Facility)) F ON LOC.Facility = F.Facility '   --WL01
                       + N' WHERE LOT.STORERKEY = @c_storerkey '
                       + N' AND LOT.SKU = @c_sku '
                       + N' AND LOT.STATUS = ''OK'' '
                       + N' AND (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED - QTYONHOLD) > 0 '
                       + @c_Condition
            EXEC sp_ExecuteSQL @c_SQL
               , N'@c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20), @c_Facility NVARCHAR(5)'
               , @c_Storerkey
               , @c_Sku
               , @c_Facility
            --WL01 E
END
END
GO
GRANT EXECUTE ON  [dbo].[nspPRIDS21] TO [NSQL]
GO
