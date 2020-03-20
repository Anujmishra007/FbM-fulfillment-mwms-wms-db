SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS OFF 
GO

IF EXISTS (SELECT name FROM dbo.sysobjects WHERE  name = N'nspPRFIFO2' AND type = 'P')
    DROP PROCEDURE nspPRFIFO2
GO

-- PGD TH Preallocation Strategy 
CREATE PROC nspPRFIFO2 
    @c_StorerKey NVARCHAR(15) ,  
    @c_SKU NVARCHAR(20) ,  
    @c_LOT NVARCHAR(10) ,  
    @c_Lottable01 NVARCHAR(18) ,  
    @c_Lottable02 NVARCHAR(18) ,  
    @c_Lottable03 NVARCHAR(18) ,  
    @d_Lottable04 datetime ,  
    @d_Lottable05 datetime ,  
    @c_UOM NVARCHAR(10) ,
    @c_Facility NVARCHAR(10)  ,
    @n_UOMBase int ,  
    @n_QtyLeftToFulfill int  -- new column
AS

DECLARE @b_debug int,  
        @c_Manual NVARCHAR(1),
        @c_LimitString NVARCHAR(255), 
	     @n_ShelfLife int,
		  @c_SQL NVARCHAR(max)
   
DECLARE @c_Lottable04Label NVARCHAR(20),
        @c_SortOrder       NVARCHAR(255)

SELECT @b_debug=0, @c_Manual = 'N'  

If @d_Lottable04 = '1900-01-01'
Begin
    SELECT @d_Lottable04 = null
End

If @d_Lottable05 = '1900-01-01'
Begin
	SELECT @d_Lottable05 = null
End

IF @b_debug = 1  
BEGIN  
    SELECT "nspPRFIFO2 : Before Lot Lookup ....."  
    SELECT '@c_LOT'=@c_LOT,'@c_Lottable01'=@c_Lottable01, '@c_Lottable02'=@c_Lottable02, '@c_Lottable03'=@c_Lottable03   
    SELECT '@d_Lottable04' = @d_Lottable04, '@d_Lottable05' = @d_Lottable05, '@c_Manual' = @c_Manual  , '@c_SKU' = @c_SKU
    SELECT '@c_StorerKey' = @c_StorerKey, '@c_Facility' = @c_Facility
END  
     
-- when any of the Lottables is supplied, get the specific lot  
IF (@c_Lottable01 <> '' OR 
    @c_Lottable02 <> '' OR 
    @c_Lottable03 <> '' OR   
    @d_Lottable04 IS NOT NULL OR 
    @d_Lottable05 IS NOT NULL) OR LEFT(@c_LOT,1) = '*'
BEGIN  
     SELECT @c_Manual = 'N'  
END  
  
IF @b_debug = 1  
BEGIN  
    SELECT "nspPRFIFO2 : After Lot Lookup ....."  
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
      
      IF @d_Lottable04 IS NOT NULL AND @d_Lottable04 <> '1900-01-01'
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable04 = N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(char(20), @d_Lottable04))) + "'"  
      
      IF @d_Lottable05 IS NOT NULL  AND @d_Lottable05 <> '1900-01-01'
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable05= N'" + dbo.fnc_LTrim(dbo.fnc_RTrim(CONVERT(char(20), @d_Lottable05))) + "'"  


      SELECT @n_ShelfLife = CASE WHEN ISNUMERIC(SUSR2) = 1 Then CAST(SUSR2 as int) 
                                ELSE 0
                                END, 
            @c_Lottable04Label = Lottable04Label 
      FROM 	SKU (NOLOCK)
      WHERE SKU = @c_SKU
      AND   STORERKEY = @c_StorerKey
      
      SELECT @c_SortOrder = " ORDER BY LOTATTRIBUTE.Lottable04, LOT.Lot"      

		-- Min Shelf Life Checking
      IF dbo.fnc_RTrim(@c_Lottable04Label) IS NOT NULL AND dbo.fnc_RTrim(@c_Lottable04Label) <> '' 
      BEGIN
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
			"				  FROM   PreallocatePickdetail p (NOLOCK), ORDERS (NOLOCK) " + 
			"				  WHERE  p.Orderkey = ORDERS.Orderkey " +
			"				  AND    p.SKU = N'" + dbo.fnc_RTrim(@c_SKU) + "'" + 
			"				  AND    p.StorerKey = N'" + dbo.fnc_RTrim(@c_StorerKey) + "'" + 
         "             AND    p.Qty > 0 " + 
			"				  GROUP BY p.Lot, ORDERS.Facility) As P ON LOTxLOCxID.Lot = P.Lot AND LOC.Facility = P.Facility " +
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

GRANT EXECUTE ON nspPRFIFO2 to nSQL
GO
