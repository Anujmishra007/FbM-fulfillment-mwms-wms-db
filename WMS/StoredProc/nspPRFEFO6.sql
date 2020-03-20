if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspPRFEFO6]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspPRFEFO6]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/  
/* Stored Procedure: nspPRFEFO6                                          */  
/* Creation Date: 25-Sep-2014                                            */  
/* Copyright: LFL                                                        */  
/* Written by: Chee Jun Yan                                              */  
/*                                                                       */  
/* Purpose: SOS#315963 - FEFO, UOMBase, Minimum ShelfLife                */  
/*                                                                       */  
/* Called By: Exceed Allocate Orders                                     */  
/*                                                                       */  
/* PVCS Version: 1.2                                                     */  
/*                                                                       */  
/* Version: 5.4                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author     Ver   Purposes                                */  
/* 2014-11-28   ChewKP     1.1   Change condition of ShelfLife Checking  */
/* 18-AUG-2015  YTWan      1.2   SOS#350432 - Project Merlion -          */
/*                               AllocationStrategy (Wan01)              */     
/*************************************************************************/  
  
CREATE PROC [dbo].[nspPRFEFO6]  
   @c_StorerKey        NVARCHAR(15),  
   @c_sku              NVARCHAR(20),  
   @c_lot              NVARCHAR(10),  
   @c_lottable01       NVARCHAR(18),  
   @c_lottable02       NVARCHAR(18),  
   @c_lottable03       NVARCHAR(18),  
   @d_lottable04       DATETIME,  
   @d_lottable05       DATETIME,  
   @c_lottable06       NVARCHAR(30) ,  --(Wan01)  
   @c_lottable07       NVARCHAR(30) ,  --(Wan01)  
   @c_lottable08       NVARCHAR(30) ,  --(Wan01)
   @c_lottable09       NVARCHAR(30) ,  --(Wan01)
   @c_lottable10       NVARCHAR(30) ,  --(Wan01)
   @c_lottable11       NVARCHAR(30) ,  --(Wan01)
   @c_lottable12       NVARCHAR(30) ,  --(Wan01)
   @d_lottable13       DATETIME ,      --(Wan01)
   @d_lottable14       DATETIME ,      --(Wan01)   
   @d_lottable15       DATETIME ,      --(Wan01) 
   @c_uom              NVARCHAR(10),  
   @c_facility         NVARCHAR(10),  
   @n_uombase          INT,  
   @n_qtylefttofulfill INT  -- new column 
   ,@c_OtherParms NVARCHAR(200)=''     --(Wan01) 
AS  
BEGIN  
  
   DECLARE @n_StorerMinShelfLife INT,  
           @c_Condition          NVARCHAR(MAX), --(Wan01)  
           @c_SQLStatement       NVARCHAR(4000),  
           @c_Lottable04Label    NVARCHAR(20),  
           @c_UOMBase            NVARCHAR(10)  
  
   SELECT @c_Lottable04Label = ISNULL(LOTTABLE04LABEL, '')  
   FROM  dbo.SKU WITH (NOLOCK)  
   WHERE Sku = @c_SKU  
   AND   StorerKey = @c_StorerKey  
  
   IF ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_lot)),'') <> ''  
   BEGIN  
      /* Get Storer Minimum Shelf Life */        
      SELECT @n_StorerMinShelfLife = ISNULL(((SKU.Shelflife * STORER.MinShelflife/100) * -1), 0)  
      FROM dbo.SKU WITH (NOLOCK)   
      JOIN dbo.STORER WITH (NOLOCK) ON (SKU.Storerkey = STORER.Storerkey)   
      JOIN dbo.LOT WITH (NOLOCK) ON (LOT.Sku = SKU.Sku AND LOT.Storerkey = SKU.Storerkey)  
      WHERE LOT.Lot = @c_lot  
        AND SKU.Facility = @c_facility    
        
      DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR  
      SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT,  
         QTYAVAILABLE = CASE WHEN  SUM(LOTXLOCXID.QTY - LOTXLOCXID.QTYALLOCATED - LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0)) <  @n_UOMBase  
                              THEN SUM(LOTXLOCXID.QTY - LOTXLOCXID.QTYALLOCATED - LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0))  
                              WHEN SUM(LOTXLOCXID.QTY - LOTXLOCXID.QTYALLOCATED - LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0)) % @n_UOMBase = 0  
                              THEN SUM(LOTXLOCXID.QTY - LOTXLOCXID.QTYALLOCATED - LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0))  
                        ELSE  
                           SUM(LOTXLOCXID.QTY - LOTXLOCXID.QTYALLOCATED - LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0))  
                           -  SUM(LOTXLOCXID.QTY - LOTXLOCXID.QTYALLOCATED - LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0)) % @n_UOMBase  
                        END  
      FROM  dbo.LOT  
      INNER JOIN dbo.LOTXLOCXID (NOLOCK) ON LOT.LOT = LOTXLOCXID.LOT  
INNER JOIN dbo.LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC  
      INNER JOIN dbo.LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT  
      LEFT OUTER JOIN (SELECT p.Lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty)  
                       FROM   dbo.PreallocatePickdetail p WITH (NOLOCK), dbo.ORDERS WITH (NOLOCK)  
                       WHERE  p.Orderkey = ORDERS.Orderkey  
                       GROUP BY p.Lot, ORDERS.Facility) As P ON LOTXLOCXID.Lot = P.Lot AND LOC.Facility = P.Facility  
      WHERE LOC.Facility = @c_facility  
      AND   LOT.LOT = @c_lot  
      AND   1 = CASE   
                   WHEN ISNULL(@c_Lottable04Label, '') <> '' AND @n_StorerMinShelfLife > 0 AND   
                        DATEADD(Day, @n_StorerMinShelfLife, LOTATTRIBUTE.Lottable04) <= GETDATE() THEN 0   
                   ELSE 1   
                END  
      GROUP BY LOT.STORERKEY, LOT.SKU, LOT.LOT, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.LOTTABLE02, LOTATTRIBUTE.Lottable05  
      ORDER BY LOTATTRIBUTE.Lottable04, LOT.Lot  
   END  
   ELSE  
   BEGIN  
    /* Get Storer Minimum Shelf Life */  
    SELECT @n_StorerMinShelfLife = ISNULL(((SKU.Shelflife * STORER.MinShelflife/100) * -1), 0)  
    FROM dbo.SKU WITH (NOLOCK)   
      JOIN dbo.STORER WITH (NOLOCK) ON (SKU.Storerkey = STORER.Storerkey)   
    WHERE SKU.Sku = @c_sku  
     AND SKU.Storerkey = @c_storerkey     
     AND SKU.Facility = @c_facility   

  
      IF ISNULL(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable01)),'') <> ''   
      BEGIN  
         SELECT @c_Condition = ' AND LOTTABLE01 = N''' + dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable01)) + ''' '   
      END  
      IF ISNULL(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable02)),'') <> ''   
      BEGIN  
         SELECT @c_Condition = ISNULL(dbo.fnc_RTrim(@c_Condition),'') + ' AND LOTTABLE02 = N''' +   
                               ISNULL(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable02)),'') + ''' '   
      END  
      IF ISNULL(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable03)),'') <> ''   
      BEGIN  
         SELECT @c_Condition = ISNULL(dbo.fnc_RTrim(@c_Condition),'') + ' AND LOTTABLE03 = N''' +   
                               ISNULL(dbo.fnc_RTrim(dbo.fnc_LTrim(@c_Lottable03)),'') + ''' '   
      END  
  
      IF @d_Lottable04 IS NOT NULL AND CONVERT(char(10), @d_Lottable04, 103) <> '01/01/1900'  
      BEGIN  
         SELECT @c_Condition = ISNULL(dbo.fnc_RTrim(@c_Condition),'') + ' AND LOTTABLE04 = N''' +   
                               ISNULL(dbo.fnc_RTrim(CONVERT(char(20), @d_Lottable04, 106)),'') + ''' '  
      END  
      IF @d_Lottable05 IS NOT NULL AND CONVERT(char(10), @d_Lottable05, 103) <> '01/01/1900'  
      BEGIN  
         SELECT @c_Condition = ISNULL(dbo.fnc_RTrim(@c_Condition),'') + ' AND LOTTABLE05 = N''' +   
                               ISNULL(dbo.fnc_RTrim(CONVERT(char(20), @d_Lottable05, 106)),'') + ''' '   
      END  
  
      --(Wan01) - START
      IF RTRIM(@c_Lottable06) <> '' AND @c_Lottable06 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable06 = N''' + RTRIM(@c_Lottable06) + '''' 
      END   

      IF RTRIM(@c_Lottable07) <> '' AND @c_Lottable07 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable07 = N''' + RTRIM(@c_Lottable07) + '''' 
      END   

      IF RTRIM(@c_Lottable08) <> '' AND @c_Lottable08 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable08 = N''' + RTRIM(@c_Lottable08) + '''' 
      END   

      IF RTRIM(@c_Lottable09) <> '' AND @c_Lottable09 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable09 = N''' + RTRIM(@c_Lottable09) + '''' 
      END   

      IF RTRIM(@c_Lottable10) <> '' AND @c_Lottable10 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable10 = N''' + RTRIM(@c_Lottable10) + '''' 
      END   

      IF RTRIM(@c_Lottable11) <> '' AND @c_Lottable11 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable11 = N''' + RTRIM(@c_Lottable11) + '''' 
      END   

      IF RTRIM(@c_Lottable12) <> '' AND @c_Lottable12 IS NOT NULL
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable12 = N''' + RTRIM(@c_Lottable12) + '''' 
      END  

      IF @d_Lottable13 IS NOT NULL AND CONVERT(char(10), @d_Lottable13, 103) <> '01/01/1900'
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable13 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) + ''''
      END

      IF @d_Lottable14 IS NOT NULL AND CONVERT(char(10), @d_Lottable14, 103) <> '01/01/1900'
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable14 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) + ''''
      END

      IF @d_Lottable15 IS NOT NULL AND CONVERT(char(10), @d_Lottable15, 103) <> '01/01/1900'
      BEGIN
         SET @c_Condition = @c_Condition + ' AND Lottable15 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) + ''''
      END
      --(Wan01) - END

      -- Disable ShelfLife validation if Lottable04Label is disabled  
      IF ISNULL(@c_Lottable04Label, '') = ''  
         SELECT @n_StorerMinShelfLife = 0  
  
  
--      IF @n_StorerMinShelfLife > 0   

      IF ISNULL(@c_Lottable04Label, '') <> ''  
      BEGIN  
        
         SELECT @c_Condition = ISNULL(dbo.fnc_RTrim(@c_Condition),'') + ' AND DATEADD(Day, ' +   
                               CAST(ISNULL(@n_StorerMinShelfLife, 0 ) AS NVARCHAR(10)) + ', LOTATTRIBUTE.Lottable04) > GETDATE() '   
      END   


      SET @c_UOMBase = @n_uombase  
  
      SELECT @c_SQLStatement =    
            'DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR ' +  
            'SELECT MIN(LOTXLOCXID.STORERKEY) , MIN(LOTXLOCXID.SKU), LOT.LOT, ' +  
            'QTYAVAILABLE = CASE WHEN (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated, 0))) < ' + @c_UOMBase + ' ' +  
            '                    THEN (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated, 0))) ' +   
            '                    WHEN (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated, 0))) % ' + @c_UOMBase + ' = 0 ' +   
            '                    THEN (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated, 0))) ' +   
            '               ELSE ' +  
            '                  (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated, 0))) ' +  
            '                  - (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QTYALLOCATED) - SUM(LOTXLOCXID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated,0))) % ' + @c_UOMBase + ' ' +  
            '               END ' +  
  
            'FROM dbo.LOT (NOLOCK) ' +  
            'INNER JOIN dbo.LOTXLOCXID (NOLOCK) ON LOT.LOT = LOTXLOCXID.LOT ' +   
            'INNER JOIN dbo.LOC (NOLOCK) ON LOTXLOCXID.LOC = LOC.LOC ' +   
            'INNER JOIN dbo.LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT ' +   
            'LEFT OUTER JOIN dbo.ID (NOLOCK) ON LOTXLOCXID.ID = ID.ID ' +   
            'LEFT OUTER JOIN (SELECT p.Lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) ' +   
            '                 FROM   dbo.PreallocatePickdetail p (NOLOCK), ORDERS (NOLOCK) ' +   
            '                 WHERE  p.Orderkey = ORDERS.Orderkey ' +   
            '                   AND  p.SKU = N''' + + ISNULL(dbo.fnc_RTrim(@c_SKU),'') + ''' ' +  
            '                   AND  p.StorerKey = N''' + + ISNULL(dbo.fnc_RTrim(@c_StorerKey),'') + ''' ' +  
            '                   AND  p.Qty > 0 ' +  
            '                   GROUP BY p.Lot, ORDERS.Facility) As P ON LOTXLOCXID.Lot = P.Lot AND LOC.Facility = P.Facility ' +  
            'WHERE LOTXLOCXID.STORERKEY = N''' + ISNULL(dbo.fnc_RTrim(@c_storerkey),'') + ''' ' +  
            '  AND LOTXLOCXID.SKU = N''' + ISNULL(dbo.fnc_RTrim(@c_SKU),'') + ''' ' +  
            '  AND LOT.STATUS = ''OK'' AND LOC.STATUS = ''OK'' AND ID.STATUS = ''OK'' ' +  
            '  AND LOC.LocationFlag = ''NONE'' ' +   
            '  AND LOC.Facility = N''' + ISNULL(dbo.fnc_RTrim(@c_facility),'') + ''' ' +  
            '  AND LOTATTRIBUTE.STORERKEY = N''' + ISNULL(dbo.fnc_RTrim(@c_storerkey),'') + ''' ' +  
            '  AND LOTATTRIBUTE.SKU = N''' + ISNULL(dbo.fnc_RTrim(@c_SKU),'') + ''' ' +  
            ISNULL(dbo.fnc_RTrim(@c_Condition),'') +   
            'GROUP BY LOT.LOT , LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable05 ' +  
            'HAVING (SUM(LOTXLOCXID.QTY) - SUM(LOTXLOCXID.QtyAllocated) - SUM(LOTXLOCXID.QTYPicked)- MIN(ISNULL(P.QtyPreAllocated, 0))) >= ' + @c_UOMBase + ' ' +  
            'ORDER BY LOTATTRIBUTE.Lottable04, LOT.Lot '   
   
      EXEC(@c_SQLStatement)  
   
  END -- Lot is Null  
END  

GO

GRANT EXECUTE ON nspPRFEFO6 TO NSQL
GO
