IF EXISTS (SELECT name FROM dbo.sysobjects WHERE  name = N'nspPRFEFO2' AND type = 'P')
    DROP PROCEDURE nspPRFEFO2
GO
SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS OFF 
GO

/************************************************************************/      
/* Stored Procedure: nspPRFEFO2                                         */      
/* Creation Date:                                                       */      
/* Copyright: IDS                                                       */      
/* Written by:                                                          */      
/*                                                                      */      
/* Purpose:                                                             */
/*                                                                      */      
/* Called By:                                                           */      
/*                                                                      */      
/* PVCS Version: 1.1                                                    */      
/*                                                                      */      
/* Version: 5.4                                                         */      
/*                                                                      */      
/* Data Modifications:                                                  */      
/*                                                                      */      
/* Updates:                                                             */      
/* Date         Author  Ver   Purposes                                  */  
/* 18-AUG-2015  YTWan   1.1   SOS#350432 - Project Merlion - Allocation */
/*                            Strategy (Wan01)                          */
/* 01-JUN-2018  NJOW01  1.2   WMS-5158 Prestige allocate shelflife by   */
/*                            consignee                                 */  
/* 09-NOV-2018  NJOW02  1.3   WMS-6892 change FEFO shelflife filter     */
/* 24-JUL-2019  NJOW03  1.4   WMS-9509 SG Prestige lottable03 filter    */
/************************************************************************/      

-- PGD TH Preallocation Strategy 
CREATE PROC nspPRFEFO2 
    @c_StorerKey NVARCHAR(15) ,  
    @c_SKU NVARCHAR(20) ,  
    @c_LOT NVARCHAR(10) ,  
    @c_Lottable01 NVARCHAR(18) ,  
    @c_Lottable02 NVARCHAR(18) ,  
    @c_Lottable03 NVARCHAR(18) ,  
    @d_Lottable04 datetime ,  
    @d_Lottable05 datetime ,
    @c_lottable06 NVARCHAR(30) ,  --(Wan01)  
    @c_lottable07 NVARCHAR(30) ,  --(Wan01)  
    @c_lottable08 NVARCHAR(30) ,  --(Wan01)
    @c_lottable09 NVARCHAR(30) ,  --(Wan01)
    @c_lottable10 NVARCHAR(30) ,  --(Wan01)
    @c_lottable11 NVARCHAR(30) ,  --(Wan01)
    @c_lottable12 NVARCHAR(30) ,  --(Wan01)
    @d_lottable13 DATETIME ,      --(Wan01)
    @d_lottable14 DATETIME ,      --(Wan01)   
    @d_lottable15 DATETIME ,      --(Wan01)  
    @c_UOM NVARCHAR(10) ,
    @c_Facility NVARCHAR(10)  ,
    @n_UOMBase int ,  
    @n_QtyLeftToFulfill int  -- new column
   ,@c_OtherParms NVARCHAR(200)=''--(Wan01) 
AS  

DECLARE @b_debug int,  
        @c_Manual NVARCHAR(1),
        @c_LimitString NVARCHAR(4000),  --(Wan01) 
        @n_ShelfLife int,
        @c_SQL NVARCHAR(max)
   
DECLARE @c_Lottable04Label NVARCHAR(20),
        @c_SortOrder       NVARCHAR(255),
        @n_ConMinShelfLife INT, --NJOW01
        @c_Orderkey        NVARCHAR(10), --NJOW01
        @c_Strategykey     NVARCHAR(10)  --NJOW01

SELECT @c_Orderkey = LEFT(@c_OtherParms,10) --NJOW01

SELECT @b_debug=0, @c_Manual = 'N'  

If @d_Lottable04 = '1900-01-01'
Begin
    SELECT @d_Lottable04 = null
End

If @d_Lottable05 = '1900-01-01'
Begin
   SELECT @d_Lottable05 = null
End

--(Wan01) - START
IF @d_lottable13 = '1900-01-01'
BEGIN
   SET @d_lottable13 = NULL
END

IF @d_lottable14 = '1900-01-01'
BEGIN
   SET @d_lottable14 = NULL
END

IF @d_lottable15 = '1900-01-01'
BEGIN
   SET @d_lottable15 = NULL
End
--(Wan01) - END

IF @b_debug = 1  
BEGIN  
    SELECT "nspPRFEFO2 : Before Lot Lookup ....."  
    SELECT '@c_LOT'=@c_LOT,'@c_Lottable01'=@c_Lottable01, '@c_Lottable02'=@c_Lottable02, '@c_Lottable03'=@c_Lottable03   
    SELECT '@d_Lottable04' = @d_Lottable04, '@d_Lottable05' = @d_Lottable05, '@c_Manual' = @c_Manual  , '@c_SKU' = @c_SKU
    SELECT '@c_StorerKey' = @c_StorerKey, '@c_Facility' = @c_Facility
END  
     
-- when any of the Lottables is supplied, get the specific lot  
IF (@c_Lottable01 <> '' OR 
    @c_Lottable02 <> '' OR 
    @c_Lottable03 <> '' OR   
    @d_Lottable04 IS NOT NULL OR 
    @d_Lottable05 IS NOT NULL  
--(Wan01) - START
   OR @c_lottable06 <> '' 
   OR @c_lottable07 <> '' 
   OR @c_lottable08 <> '' 
   OR @c_lottable09 <> '' 
   OR @c_lottable10 <> ''
   OR @c_lottable11 <> '' 
   OR @c_lottable12 <> ''
   OR @d_lottable13 IS NOT NULL 
   OR @d_lottable14 IS NOT NULL 
   OR @d_lottable15 IS NOT NULL
--(Wan01) - END
    ) OR LEFT(@c_LOT,1) = '*'
BEGIN  
     SELECT @c_Manual = 'N'  
END  
  
IF @b_debug = 1  
BEGIN  
    SELECT "nspPRFEFO2 : After Lot Lookup ....."  
    SELECT '@c_LOT'=@c_LOT,'@c_Lottable01'=@c_Lottable01, '@c_Lottable02'=@c_Lottable02, '@c_Lottable03'=@c_Lottable03
    SELECT '@d_Lottable04' = @d_Lottable04, '@d_Lottable05' = @d_Lottable05, '@c_Manual' = @c_Manual  
    SELECT '@c_StorerKey' = @c_StorerKey
END  
   
  
IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_LOT)) IS NOT NULL AND LEFT(@c_LOT, 1) <> '*'
BEGIN       
   /* Lot specific candidate set */  
   DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR    
   SELECT LOT.STORERKEY, 
          LOT.SKU, 
          LOT.LOT,  
          QTYAVAILABLE = SUM(LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) - MIN(ISNULL(P.QTYPREALLOCATED, 0)) 
   FROM  LOT (NOLOCK) 
   INNER JOIN LOTxLOCxID (NOLOCK) ON LOT.LOT = LOTxLOCxID.LOT
   INNER JOIN LOC (NOLOCK) ON LOTxLOCxID.LOC = LOC.LOC
   INNER JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT    
   LEFT OUTER JOIN (SELECT p.Lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty)
                    FROM   PreallocatePickdetail p (NOLOCK), ORDERS (NOLOCK)
                    WHERE  p.Orderkey = ORDERS.Orderkey
                    GROUP BY p.Lot, ORDERS.Facility) As P ON LOTxLOCxID.Lot = P.Lot AND LOC.Facility = P.Facility
   WHERE LOC.Facility = @c_Facility
   AND   LOT.LOT = @c_LOT  
   GROUP BY LOT.STORERKEY, LOT.SKU, LOT.LOT, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable05
END  
ELSE 
BEGIN            
   /* Everything Else when no Lottable supplied */  
   IF @c_Manual = 'N'   
   BEGIN     	
      SELECT @c_LimitString = ''  
   
      IF @c_Lottable01 <> ' '  
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable01= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_Lottable01)) + "'"  
      
      IF @c_Lottable02 <> ' '  
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable02= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_Lottable02)) + "'"  
      
      IF @c_Lottable03 <> ' '  
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable03= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_Lottable03)) + "'"    
      ELSE IF @c_Storerkey = 'PRESTIGE'  --NJOW03
      BEGIN
         SET @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + ' AND Lottable03 = ''OK'' '              
      END

      IF @d_Lottable04 IS NOT NULL AND @d_Lottable04 <> '1900-01-01'
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable04 = N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(char(20), @d_Lottable04))) + "'"  
      
      IF @d_Lottable05 IS NOT NULL  AND @d_Lottable05 <> '1900-01-01'
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable05= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(char(20), @d_Lottable05))) + "'"  

      --(Wan01) - START
      IF RTRIM(@c_Lottable06) <> '' AND @c_Lottable06 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable06 = N''' + RTRIM(@c_Lottable06) + '''' 
      END   

      IF RTRIM(@c_Lottable07) <> '' AND @c_Lottable07 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable07 = N''' + RTRIM(@c_Lottable07) + '''' 
      END   

      IF RTRIM(@c_Lottable08) <> '' AND @c_Lottable08 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable08 = N''' + RTRIM(@c_Lottable08) + '''' 
      END   

      IF RTRIM(@c_Lottable09) <> '' AND @c_Lottable09 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable09 = N''' + RTRIM(@c_Lottable09) + '''' 
      END   

      IF RTRIM(@c_Lottable10) <> '' AND @c_Lottable10 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable10 = N''' + RTRIM(@c_Lottable10) + '''' 
      END   

      IF RTRIM(@c_Lottable11) <> '' AND @c_Lottable11 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable11 = N''' + RTRIM(@c_Lottable11) + '''' 
      END   

      IF RTRIM(@c_Lottable12) <> '' AND @c_Lottable12 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable12 = N''' + RTRIM(@c_Lottable12) + '''' 
      END  

      IF @d_Lottable13 <> '1900-01-01' AND @d_Lottable13 IS NOT NULL 
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable13 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) + ''''
      END

      IF @d_Lottable14 <> '1900-01-01' AND @d_Lottable14 IS NOT NULL 
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable14 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) + ''''
      END

      IF @d_Lottable15 <> '1900-01-01' AND @d_Lottable15 IS NOT NULL
      BEGIN
         SET @c_LimitString = @c_LimitString + ' AND Lottable15 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) + ''''
      END
      --(Wan01) - END

      SELECT @n_ShelfLife = CASE WHEN ISNUMERIC(SUSR2) = 1 Then CAST(SUSR2 as int) 
                                ELSE 0
                                END, 
            @c_Lottable04Label = Lottable04Label,
            @c_Strategykey = Strategykey --NJOW01 
      FROM  SKU (NOLOCK)
      WHERE SKU = @c_SKU
      AND   STORERKEY = @c_StorerKey
      
      SELECT @c_SortOrder = " ORDER BY LOTATTRIBUTE.Lottable04, LOT.Lot"      
      
      --NJOW01
    	SELECT @n_ConMinShelfLife = S.MinShelflife
      FROM ORDERS O (NOLOCK)
      JOIN STORER S (NOLOCK) ON O.Consigneekey = S.Storerkey
      WHERE O.Orderkey = @c_Orderkey

      IF @c_Strategykey = 'PPDFEFO' AND ISNULL(@n_ConMinShelfLife,0) > 0
      BEGIN
      	 --NJOW01
         --SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND Lottable04 > N'"  + CONVERT( NVARCHAR(8), DateAdd(day, @n_ConMinShelfLife, GETDATE()), 112) + "'"      	       	      	 
         SET @c_LimitString = dbo.fnc_RTrim(@c_LimitString) +  " AND DateDiff(Day, GETDATE(), LOTATTRIBUTE.Lottable04) >= " + CAST(@n_ConMinShelfLife AS NVARCHAR) --NJOW02
      END
      ELSE IF @c_Strategykey = 'PPDFEFO' AND ISNULL(@n_ShelfLife,0) > 0  --NJOW02      
      BEGIN
         SET @c_LimitString = dbo.fnc_RTrim(@c_LimitString) +  " AND DateDiff(Day, GETDATE(), LOTATTRIBUTE.Lottable04) >= " + CAST(@n_ShelfLife AS NVARCHAR) --NJOW02         
      END
      ELSE IF dbo.fnc_RTrim(@c_Lottable04Label) IS NOT NULL AND dbo.fnc_RTrim(@c_Lottable04Label) <> '' 
      BEGIN
         -- Min Shelf Life Checking
         SELECT @c_LimitString = dbo.fnc_RTrim(@c_LimitString) + " AND Lottable04 > N'"  + CONVERT( NVARCHAR(8), DateAdd(day, @n_ShelfLife, GETDATE()), 112) + "'"
     END 

      IF @b_debug = 1
      BEGIN
        SELECT 'c_LimitString', @c_LimitString
      END

      SELECT @c_SQL = " DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR " +  
         " SELECT MIN(LOTxLOCxID.STORERKEY) , MIN(LOTxLOCxID.SKU), LOT.LOT," +  
         " QTYAVAILABLE = ( SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MIN(ISNULL(P.QtyPreallocated, 0))) " +
         " FROM LOT (NOLOCK) " +  
         " INNER JOIN LOTxLOCxID (NOLOCK) ON LOT.LOT = LOTxLOCxID.LOT " + 
         " INNER JOIN LOC (NOLOCK) ON LOTxLOCxID.LOC = LOC.LOC " + 
         " INNER JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT " +
         " LEFT OUTER JOIN ID (NOLOCK) ON LOTxLOCxID.ID = ID.ID " +
         " LEFT OUTER JOIN (SELECT p.Lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) " +
         "             FROM   PreallocatePickdetail p (NOLOCK), ORDERS (NOLOCK) " + 
         "             WHERE  p.Orderkey = ORDERS.Orderkey " +
         "             AND    p.SKU = N'" + dbo.fnc_RTrim(@c_SKU) + "'" + 
         "             AND    p.StorerKey = N'" + dbo.fnc_RTrim(@c_StorerKey) + "'" + 
         "             AND    p.Qty > 0 " + 
         "             GROUP BY p.Lot, ORDERS.Facility) As P ON LOTxLOCxID.Lot = P.Lot AND LOC.Facility = P.Facility " +
         " WHERE LOTxLOCxID.STORERKEY = N'" + dbo.fnc_RTrim(@c_StorerKey) + "'" + " AND LOTxLOCxID.SKU = N'" + dbo.fnc_RTrim(@c_SKU) + "' " +  
         " AND LOT.STATUS = 'OK' AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK'  And LOC.LocationFlag = 'NONE' " +  
         " AND LOC.FACILITY = N'" + dbo.fnc_RTrim(@c_Facility) + "'"  + 
         " AND LOTATTRIBUTE.STORERKEY = N'" + dbo.fnc_RTrim(@c_StorerKey) + "'" + " AND LOTATTRIBUTE.SKU = N'" + dbo.fnc_RTrim(@c_SKU) + "' " +  
         dbo.fnc_RTrim(@c_LimitString) + " " +   
         " GROUP BY LOT.LOT , LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable05 " + 
         " HAVING (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QtyAllocated) - SUM(LOTxLOCxID.QTYPicked)- MIN(ISNULL(P.QtyPreAllocated, 0))) > 0 " +
         @c_SortOrder

      EXEC (@c_SQL)   

      IF @b_debug = 1 SELECT @c_SQL          
   END
END
GO

 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON nspPRFEFO2 to nSQL
GO
