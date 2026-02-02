SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/  
/* Stored Procedure: nspPRStag1                                         */  
/* Creation Date: 23-Jan-2026                                           */  
/* Copyright: Maersk                                                    */  
/* Written by: JihHaur                                                  */  
/*                                                                      */  
/* Purpose: For FCR-9687 DAMIND Preallocation Strategy - for Staging    */  
/*                                                                      */  
/* Called By:                                                           */  
/*                                                                      */  
/* PVCS Version: 1.2                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Ver.  Purposes                                  */  
/* 23-Jan-2026  JH01    1.0   Created.                                  */     
/************************************************************************/  
  
CREATE OR ALTER PROC [dbo].[nspPRStag1]   
    @c_StorerKey NVARCHAR(15) ,    
    @c_SKU NVARCHAR(20) ,    
    @c_LOT NVARCHAR(10) ,    
    @c_Lottable01 NVARCHAR(18) ,    
    @c_Lottable02 NVARCHAR(18) ,    
    @c_Lottable03 NVARCHAR(18) ,    
    @d_Lottable04 datetime ,    
    @d_Lottable05 datetime ,  
    @c_lottable06 NVARCHAR(30) ,      
    @c_lottable07 NVARCHAR(30) ,      
    @c_lottable08 NVARCHAR(30) ,    
    @c_lottable09 NVARCHAR(30) ,    
    @c_lottable10 NVARCHAR(30) ,    
    @c_lottable11 NVARCHAR(30) ,    
    @c_lottable12 NVARCHAR(30) ,    
    @d_lottable13 DATETIME ,        
    @d_lottable14 DATETIME ,           
    @d_lottable15 DATETIME ,          
    @c_UOM NVARCHAR(10) ,  
    @c_Facility NVARCHAR(10)  ,  
    @n_UOMBase int ,    
    @n_QtyLeftToFulfill int  
   ,@c_OtherParms NVARCHAR(200)=''
AS    
SET CONCAT_NULL_YIELDS_NULL OFF  
SET NOCOUNT ON  
  
DECLARE @b_debug int,    
        @c_OrderKey     NVARCHAR(10),
        @c_Type         NVARCHAR(10),
        @n_AllocStagingLoc   INT            = 0,
        @n_continue     INT            = 1,
        @c_LimitString  NVARCHAR(4000),         
        @c_SQL          NVARCHAR(max) ,         
        @c_SQLParms     NVARCHAR(4000) = ''         
    
SELECT @b_debug=0  
  
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
    SELECT 'nspPRStag1 : After Lot Lookup .....'    
    SELECT '@c_LOT'=@c_LOT,'@c_Lottable01'=@c_Lottable01, '@c_Lottable02'=@c_Lottable02, '@c_Lottable03'=@c_Lottable03  
    SELECT '@d_Lottable04' = @d_Lottable04, '@d_Lottable05' = @d_Lottable05  
    SELECT '@c_StorerKey' = @c_StorerKey  
END    
     
-- Get OrderKey
IF ISNULL(RTRIM(@c_OtherParms),'') <> ''
BEGIN
   SELECT @c_OrderKey = LEFT(LTRIM(RTRIM(@c_OtherParms)), 10)

   IF @c_OrderKey <> ''
   BEGIN
      SELECT @c_Type = O.Type FROM Orders O (NOLOCK) 
      WHERE OrderKey = @c_OrderKey
   END   
END
ELSE
BEGIN
   SET @n_continue = 3
END

IF @c_Type = ''
BEGIN
   SET @n_AllocStagingLoc = 0
END

IF @c_Type <> ''
BEGIN 
   IF EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Storerkey = @c_StorerKey AND LISTNAME = 'VORORDTYPE' AND Code = @c_Type)
   BEGIN
      SET @n_AllocStagingLoc = 1
   END   
END


-- UPDATED: Now checks Lottable parameters (01-15) to ensure the specific required batch is in Staging.
IF @n_AllocStagingLoc = 1 AND @c_OrderKey IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM LOTxLOCxID lli (NOLOCK)
        JOIN LOC l (NOLOCK) ON lli.Loc = l.Loc
        JOIN LOTATTRIBUTE la (NOLOCK) ON lli.Lot = la.Lot AND lli.Sku = la.Sku -- Join Attributes
        WHERE lli.SKU = @c_SKU
        AND lli.StorerKey = @c_StorerKey
        AND l.LocationType = 'IDZ' -- Checking Staging Only
        AND l.Facility = @c_Facility
        AND (lli.Qty - lli.QtyAllocated - lli.QtyPicked) > 0
        
        -- 1. Check Specific LOT if passed
        AND (ISNULL(@c_LOT, '') = '' OR lli.Lot = @c_LOT)

        -- 2. Check Lottable String Parameters (Standard WMS usually passes ' ' for empty)
        AND (ISNULL(@c_Lottable01, ' ') = ' ' OR la.Lottable01 = @c_Lottable01)
        AND (ISNULL(@c_Lottable02, ' ') = ' ' OR la.Lottable02 = @c_Lottable02)
        AND (ISNULL(@c_Lottable03, ' ') = ' ' OR la.Lottable03 = @c_Lottable03)
        AND (ISNULL(@c_Lottable06, '') = '' OR la.Lottable06 = @c_Lottable06)
        AND (ISNULL(@c_Lottable07, '') = '' OR la.Lottable07 = @c_Lottable07)
        AND (ISNULL(@c_Lottable08, '') = '' OR la.Lottable08 = @c_Lottable08)
        AND (ISNULL(@c_Lottable09, '') = '' OR la.Lottable09 = @c_Lottable09)
        AND (ISNULL(@c_Lottable10, '') = '' OR la.Lottable10 = @c_Lottable10)
        AND (ISNULL(@c_Lottable11, '') = '' OR la.Lottable11 = @c_Lottable11)
        AND (ISNULL(@c_Lottable12, '') = '' OR la.Lottable12 = @c_Lottable12)

        -- 3. Check Date Parameters (Standard WMS uses '1900-01-01' or NULL)
        AND (ISNULL(@d_Lottable04, '1900-01-01') = '1900-01-01' OR la.Lottable04 = @d_Lottable04)
        AND (ISNULL(@d_Lottable05, '1900-01-01') = '1900-01-01' OR la.Lottable05 = @d_Lottable05)
        AND (ISNULL(@d_Lottable13, '1900-01-01') = '1900-01-01' OR la.Lottable13 = @d_Lottable13)
        AND (ISNULL(@d_Lottable14, '1900-01-01') = '1900-01-01' OR la.Lottable14 = @d_Lottable14)
        AND (ISNULL(@d_Lottable15, '1900-01-01') = '1900-01-01' OR la.Lottable15 = @d_Lottable15)
    )
    BEGIN
        UPDATE ORDERS 
        SET LabelPrice = 1 
        WHERE OrderKey = @c_OrderKey
    END
    ELSE
    BEGIN
      SET @n_continue = 3
    END
END

IF (@n_continue=1 or @n_continue=2) AND @n_AllocStagingLoc = 1
BEGIN  
   IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_LOT)) IS NOT NULL AND dbo.fnc_LTrim(dbo.fnc_RTrim(@c_LOT)) <> ''  
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
      LEFT OUTER JOIN ID (NOLOCK) ON LOTxLOCxID.ID = ID.ID
      LEFT OUTER JOIN (SELECT p.Lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty)  
                       FROM   PreallocatePickdetail p (NOLOCK), ORDERS (NOLOCK)  
                       WHERE  p.Orderkey = ORDERS.Orderkey  
                       GROUP BY p.Lot, ORDERS.Facility) As P ON LOTxLOCxID.Lot = P.Lot AND LOC.Facility = P.Facility  
      WHERE LOC.Facility = @c_Facility  
         AND LOT.STATUS = 'OK' AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK'  And LOC.LocationFlag = 'NONE'    
         --AND (LOC.LocationType <> 'IDZ' OR @n_AllocStagingLoc = 1)
         AND (LOC.LocationType = 'IDZ' AND @n_AllocStagingLoc = 1)
         AND LOT.LOT = @c_LOT    
      GROUP BY LOT.STORERKEY, LOT.SKU, LOT.LOT, LOTATTRIBUTE.Lottable05, LOTATTRIBUTE.Lottable04, LOC.LocationType  
      HAVING (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QtyAllocated) - SUM(LOTxLOCxID.QTYPicked)- MIN(ISNULL(P.QtyPreAllocated, 0))) > 0   
      ORDER BY CASE WHEN @n_AllocStagingLoc = 1 AND LOC.LocationType = 'IDZ' THEN 0 ELSE 1 END, -- Prioritizes IDZ
               LOTATTRIBUTE.Lottable05, LOTATTRIBUTE.Lottable04  
   END    
   ELSE   
   BEGIN              
      /* Everything Else when no Lottable supplied */    
      SELECT @c_LimitString = ''    
  
      IF @c_Lottable01 <> ' '    
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable01= @c_Lottable01"    
     
      IF @c_Lottable02 <> ' '    
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable02= @c_Lottable02"    
     
      IF @c_Lottable03 <> ' '    
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable03= @c_Lottable03"          
     
      IF @d_Lottable04 IS NOT NULL AND @d_Lottable04 <> '1900-01-01'  
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable04 = @d_Lottable04"    
    
      IF @d_Lottable05 IS NOT NULL  AND @d_Lottable05 <> '1900-01-01'  
         SELECT @c_LimitString =  dbo.fnc_RTrim(@c_LimitString) + " AND Lottable05= @d_Lottable05"      
      
      IF RTRIM(@c_Lottable06) <> '' AND @c_Lottable06 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable06 = @c_Lottable06'   
      END     
  
      IF RTRIM(@c_Lottable07) <> '' AND @c_Lottable07 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable07 = @c_Lottable07'   
      END     
  
      IF RTRIM(@c_Lottable08) <> '' AND @c_Lottable08 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable08 = @c_Lottable08'   
      END     
  
      IF RTRIM(@c_Lottable09) <> '' AND @c_Lottable09 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable09 = @c_Lottable09'   
      END     
  
      IF RTRIM(@c_Lottable10) <> '' AND @c_Lottable10 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable10 = @c_Lottable10'   
      END     
  
      IF RTRIM(@c_Lottable11) <> '' AND @c_Lottable11 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable11 = @c_Lottable11'   
      END     
  
      IF RTRIM(@c_Lottable12) <> '' AND @c_Lottable12 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable12 = @c_Lottable12'   
      END    
  
      IF @d_Lottable13 <> '1900-01-01' AND @d_Lottable13 IS NOT NULL   
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable13 = @d_Lottable13'  
      END  
  
      IF @d_Lottable14 <> '1900-01-01' AND @d_Lottable14 IS NOT NULL   
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable14 = @d_Lottable14'  
      END  
  
      IF @d_Lottable15 <> '1900-01-01' AND @d_Lottable15 IS NOT NULL  
      BEGIN  
         SET @c_LimitString = @c_LimitString + ' AND Lottable15 = @d_Lottable15'  
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
         "             AND    p.SKU = @c_SKU" +   
         "             AND    p.StorerKey = @c_StorerKey" +   
         "             AND    p.Qty > 0 " +   
         "             GROUP BY p.Lot, ORDERS.Facility) As P ON LOTxLOCxID.Lot = P.Lot AND LOC.Facility = P.Facility " +  
         " WHERE LOTxLOCxID.STORERKEY = @c_StorerKey" +   
         " AND LOTxLOCxID.SKU = @c_SKU " +    
         " AND LOT.STATUS = 'OK' AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK'  And LOC.LocationFlag = 'NONE' " +    
         " AND LOC.FACILITY = @c_Facility"  +   
         --" AND (LOC.LocationType <> 'IDZ' OR " + CAST(@n_AllocStagingLoc AS NVARCHAR(1)) + " = 1) " +
         " AND (LOC.LocationType = 'IDZ' AND " + CAST(@n_AllocStagingLoc AS NVARCHAR(1)) + " = 1) " +
         " AND LOTATTRIBUTE.STORERKEY = @c_StorerKey" +   
         " AND LOTATTRIBUTE.SKU = @c_SKU " +             
         dbo.fnc_RTrim(@c_LimitString) + " " +     
         " GROUP BY LOT.LOT , LOTATTRIBUTE.Lottable05, LOTATTRIBUTE.Lottable04, LOC.LocationType  " +   
         " HAVING (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QtyAllocated) - SUM(LOTxLOCxID.QTYPicked)- MIN(ISNULL(P.QtyPreAllocated, 0))) > 0 " +  
          " ORDER BY CASE WHEN " + CAST(@n_AllocStagingLoc AS NVARCHAR(1)) + " = 1 AND LOC.LocationType = 'IDZ' THEN 0 ELSE 1 END, " +
         " LOTATTRIBUTE.Lottable05, LOTATTRIBUTE.Lottable04 "   
           
         --EXEC (@c_SQL)  
         SET @c_SQLParms= N'@c_facility   NVARCHAR(5)'  
                        + ',@c_storerkey  NVARCHAR(15)'  
                        + ',@c_SKU        NVARCHAR(20)'  
                        + ',@c_Lottable01 NVARCHAR(18)'  
                        + ',@c_Lottable02 NVARCHAR(18)'  
                        + ',@c_Lottable03 NVARCHAR(18)'  
                        + ',@d_lottable04 datetime'  
                        + ',@d_lottable05 datetime'  
                        + ',@c_Lottable06 NVARCHAR(30)'  
                        + ',@c_Lottable07 NVARCHAR(30)'  
                        + ',@c_Lottable08 NVARCHAR(30)'  
                        + ',@c_Lottable09 NVARCHAR(30)'  
                        + ',@c_Lottable10 NVARCHAR(30)'  
                        + ',@c_Lottable11 NVARCHAR(30)'  
                        + ',@c_Lottable12 NVARCHAR(30)'  
                        + ',@d_lottable13 datetime'  
                        + ',@d_lottable14 datetime'  
                        + ',@d_lottable15 datetime'  
  
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParms, @c_facility, @c_storerkey, @c_SKU  
                           ,@c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05  
                           ,@c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10  
                           ,@c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15        
  
      IF @b_debug = 1 SELECT @c_SQL            
   END  
END
ELSE
BEGIN
   DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR      
      SELECT '',   
             '',   
             '',    
             0
      FROM  LOT (NOLOCK)  
      WHERE 1 = 2
END
