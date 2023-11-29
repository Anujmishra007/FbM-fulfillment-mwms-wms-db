SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************/
/* Stored Procedure: nspPR_IN01                                          */
/* Creation Date: 02-Nov-2023                                            */
/* Copyright: Maersk                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: WMS-23995 - IN-Biotique - New Pre Allocation Rule - CR       */
/*                                                                       */
/* Called By:                                                            */
/*                                                                       */
/* Github Version: 1.0                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 02-Nov-2023  WLChooi  1.0  DevOps Combine Script                      */
/*************************************************************************/
CREATE OR ALTER PROC [dbo].[nspPR_IN01]
   @c_Storerkey        NVARCHAR(15)
 , @c_SKU              NVARCHAR(20)
 , @c_LOT              NVARCHAR(10)
 , @c_Lottable01       NVARCHAR(18)
 , @c_Lottable02       NVARCHAR(18)
 , @c_Lottable03       NVARCHAR(18)
 , @d_Lottable04       DATETIME
 , @d_Lottable05       DATETIME
 , @c_Lottable06       NVARCHAR(30)
 , @c_Lottable07       NVARCHAR(30)
 , @c_Lottable08       NVARCHAR(30)
 , @c_Lottable09       NVARCHAR(30)
 , @c_Lottable10       NVARCHAR(30)
 , @c_Lottable11       NVARCHAR(30)
 , @c_Lottable12       NVARCHAR(30)
 , @d_Lottable13       DATETIME
 , @d_Lottable14       DATETIME
 , @d_Lottable15       DATETIME
 , @c_UOM              NVARCHAR(10)
 , @c_Facility         NVARCHAR(10)
 , @n_UOMBase          INT
 , @n_QtyLeftToFulfill INT
 , @c_OtherParms       NVARCHAR(20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_ConsigneeMinShelfLife INT
         , @c_Condition             NVARCHAR(MAX)
         , @c_UOMBase               NVARCHAR(10)
         , @c_SQL                   NVARCHAR(MAX)

   DECLARE @c_OrderKey          NVARCHAR(10)
         , @c_OrderLineNumber   NVARCHAR(5)
         , @n_OrderMinShelfLife INT
         , @c_OrderBy           NVARCHAR(2000)
         , @c_GroupBy           NVARCHAR(2000)
         , @c_Lottable04Label   NVARCHAR(100)

   SET @c_UOMBase = TRIM(CAST(@n_UOMBase AS NVARCHAR(10)))
   SET @c_Condition = N''
   SET @c_SQL = N''

   IF LEN(@c_OtherParms) > 0
   BEGIN
      SET @c_OrderKey = LEFT(@c_OtherParms, 10)
      SET @c_OrderLineNumber = SUBSTRING(@c_OtherParms, 11, 5)

      SET @n_OrderMinShelfLife = 0

      SELECT @n_OrderMinShelfLife = ISNULL(Storer.MinShelflife, 0)
      FROM Sku (NOLOCK)
      JOIN Storer (NOLOCK) ON Sku.Storerkey = Storer.Storerkey
      WHERE Sku.Sku = @c_sku
      AND Sku.Storerkey = @c_storerkey  

      IF ISNULL(@n_OrderMinShelfLife, 0) = 0
      BEGIN
         SELECT @n_OrderMinShelfLife = IIF(ISNUMERIC(CODELKUP.UDF01) = 1, CODELKUP.UDF01, 0)
         FROM ORDERS (NOLOCK)
         JOIN CODELKUP (NOLOCK) ON CODELKUP.LISTNAME = 'ORDERTYPE'
                              AND CODELKUP.Storerkey = ORDERS.StorerKey
                              AND CODELKUP.Code = ORDERS.[Type]
         WHERE ORDERS.OrderKey = @c_OrderKey
      END

      IF ISNULL(@n_OrderMinShelfLife, 0) <> 0
      BEGIN
         SELECT @n_OrderMinShelfLife = (ISNULL(SKU.ShelfLife, 0) * ISNULL(@n_OrderMinShelfLife, 0) / 100)
              , @c_Lottable04Label = ISNULL(LOTTABLE04LABEL,'')
         FROM SKU (NOLOCK)
         WHERE SKU.StorerKey = @c_Storerkey 
         AND SKU.Sku = @c_SKU
      END
      ELSE
      BEGIN
         SELECT @n_OrderMinShelfLife = IIF(ISNUMERIC(SKU.SUSR2) = 1, SKU.SUSR2, 0)
              , @c_Lottable04Label = ISNULL(LOTTABLE04LABEL,'')
         FROM SKU (NOLOCK)
         WHERE SKU.StorerKey = @c_Storerkey 
         AND SKU.Sku = @c_SKU
      END
   END

   IF @n_OrderMinShelfLife IS NULL
      SELECT @n_OrderMinShelfLife = 0

   IF ISNULL(LTRIM(TRIM(@c_LOT)), '') <> '' AND LEFT(@c_LOT, 1) <> '*'
   BEGIN
      DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT LOT.StorerKey
           , LOT.Sku
           , LOT.Lot
           , QTYAVAILABLE = (LOT.Qty - LOT.QtyAllocated - LOT.QtyPicked - LOT.QtyPreAllocated)
      FROM LOT (NOLOCK)
         , LOTATTRIBUTE (NOLOCK)
         , LOTxLOCxID (NOLOCK)
         , LOC (NOLOCK)
      WHERE LOT.Lot = @c_LOT
      AND   LOT.Lot = LOTATTRIBUTE.Lot
      AND   LOTxLOCxID.Lot = LOT.Lot
      AND   LOTxLOCxID.Lot = LOTATTRIBUTE.Lot
      AND   LOTxLOCxID.Loc = LOC.Loc
      AND   LOC.Facility = @c_Facility
      AND   DATEDIFF(DAY, GETDATE(), LOTATTRIBUTE.Lottable04) >= @n_ConsigneeMinShelfLife
      ORDER BY LOTATTRIBUTE.Lottable04
             , LOT.Lot
   END
   ELSE
   BEGIN
      IF ISNULL(TRIM(@c_Lottable01), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND LOC.HostWhCode = N''' + TRIM(@c_Lottable01) + N''' '
      END

      IF ISNULL(TRIM(@c_Lottable02), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable02 = N''' + TRIM(@c_Lottable02) + N''' '
      END

      IF ISNULL(TRIM(@c_Lottable03), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable03 = N''' + TRIM(ISNULL(@c_Lottable03, '')) + N''' '
      END

      IF @n_OrderMinShelfLife <> 0
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) 
                             + N' AND DATEDIFF(DAY, GETDATE(), Lotattribute.Lottable04) >= ' + TRIM(CAST(@n_OrderMinShelfLife AS NVARCHAR))
      END

      --IF CONVERT(NVARCHAR(8), @d_Lottable05, 112) <> '19000101' AND @d_Lottable05 IS NOT NULL
      --BEGIN
      --   SELECT @c_Condition = TRIM(@c_Condition) + N' AND CONVERT(NVARCHAR(10),Lotattribute.Lottable05, 112) = N'''
      --                         + TRIM(CONVERT(NVARCHAR(8), @d_Lottable05, 112)) + N''' '
      --END

      IF ISNULL(TRIM(@c_Lottable06), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable06 = N''' + TRIM(@c_Lottable06) + N''' '
      END
      IF ISNULL(TRIM(@c_Lottable07), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable07 = N''' + TRIM(@c_Lottable07) + N''' '
      END
      IF ISNULL(TRIM(@c_Lottable08), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable08 = N''' + TRIM(@c_Lottable08) + N''' '
      END
      IF ISNULL(TRIM(@c_Lottable09), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable09 = N''' + TRIM(@c_Lottable09) + N''' '
      END
      IF ISNULL(TRIM(@c_Lottable10), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable10 = N''' + TRIM(@c_Lottable10) + N''' '
      END
      IF ISNULL(TRIM(@c_Lottable11), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable11 = N''' + TRIM(@c_Lottable11) + N''' '
      END
      IF ISNULL(TRIM(@c_Lottable12), '') <> ''
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND Lotattribute.Lottable12 = N''' + TRIM(@c_Lottable12) + N''' '
      END
      IF CONVERT(NVARCHAR(8), @d_Lottable13, 112) <> '19000101' AND @d_Lottable13 IS NOT NULL
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND CONVERT(NVARCHAR(10),Lotattribute.Lottable13, 112) = N'''
                               + TRIM(CONVERT(NVARCHAR(8), @d_Lottable13, 112)) + N''' '
      END
      IF CONVERT(NVARCHAR(8), @d_Lottable14, 112) <> '19000101' AND @d_Lottable14 IS NOT NULL
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND CONVERT(NVARCHAR(10),Lotattribute.Lottable14, 112) = N'''
                               + TRIM(CONVERT(NVARCHAR(8), @d_Lottable14, 112)) + N''' '
      END
      IF CONVERT(NVARCHAR(8), @d_Lottable15, 112) <> '19000101' AND @d_Lottable15 IS NOT NULL
      BEGIN
         SELECT @c_Condition = TRIM(@c_Condition) + N' AND CONVERT(NVARCHAR(10),Lotattribute.Lottable15, 112) = N'''
                               + TRIM(CONVERT(NVARCHAR(8), @d_Lottable15, 112)) + N''' '
      END

      IF @c_Lottable04Label = 'EXP_DATE'
      BEGIN
         SELECT @c_OrderBy = N' ORDER BY LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05, LOT.Lot '
      END
      ELSE
      BEGIN
         SELECT @c_OrderBy = N' ORDER BY LOTATTRIBUTE.Lottable05, LOTATTRIBUTE.Lottable04, LOT.Lot '
      END

      SELECT @c_GroupBy = N' GROUP BY LOT.StorerKey, LOT.Sku, LOT.Lot, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05 '

      SELECT @c_SQL = N' DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR '
                    + N' SELECT LOT.StorerKey, LOT.SKU, LOT.LOT, '
                    + N' QTYAVAILABLE = SUM(LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) - MIN(ISNULL(p.QTYPREALLOCATED, 0)) '
                    + N' FROM LOTxLOCxID (NOLOCK) ' + N' JOIN LOT (NOLOCK) ON LOTxLOCxID.Lot = LOT.Lot '
                    + N' JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT '
                    + N' JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.Loc '
                    + N' JOIN ID (NOLOCK) ON LOTxLOCxID.ID = ID.ID '
                    + N' JOIN SKUxLOC (NOLOCK) ON SKUxLOC.StorerKey = LOTxLOCxID.StorerKey '
                    + N' AND SKUxLOC.SKU = LOTxLOCxID.SKU ' + N' AND SKUxLOC.LOC = LOTxLOCxID.LOC '
                    + N' LEFT OUTER JOIN ( SELECT p.lot, ORDERS.facility, QtyPreallocated = SUM(p.Qty) '
                    + N'                   FROM PreallocatePickdetail p (NOLOCK), ORDERS (NOLOCK) '
                    + N'                   WHERE p.Orderkey = ORDERS.Orderkey ' 
                    + N'                   AND   p.Storerkey = @c_Storerkey '
                    + N'                   AND   p.SKU = @c_SKU '
                    + N'                   GROUP BY p.Lot, ORDERS.Facility) p ON LOTXLOCXID.Lot = p.Lot '
                    + N'                                                      AND p.Facility = LOC.Facility '
                    + N' WHERE LOT.StorerKey = @c_Storerkey ' 
                    + N' AND LOT.SKU = @c_SKU '
                    + N' AND LOT.STATUS = ''OK'' ' 
                    + N' AND ID.STATUS = ''OK'' ' 
                    + N' AND LOC.Status = ''OK'' '
                    + N' AND LOC.Facility = @c_Facility ' 
                    + N' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'') '
                    + N' AND LOC.LocationFlag = ''NONE'' '
                    + N' AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED >= @n_UOMBase '
                    + @c_Condition 
                    + @c_GroupBy
                    + N' HAVING SUM(LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) - MIN(ISNULL(p.QTYPREALLOCATED,0)) >= @n_UOMBase '
                    + TRIM(ISNULL(@c_OrderBy, ''))

      EXEC sp_executesql @c_SQL
                       , N'@c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20), @c_Facility NVARCHAR(5), @n_UOMBase INT '
                       , @c_Storerkey
                       , @c_SKU
                       , @c_Facility
                       , @n_UOMBase
   END
END
GO
GRANT EXECUTE ON [dbo].[nspPR_IN01] TO [NSQL]
GO