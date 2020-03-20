if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspPR_SG07]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspPR_SG07]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspPR_SG07                                         */
/* Creation Date: 28-Jun-2018                                           */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-5471 - SG Pernod ricard pre-allocation                  */
/*                                                                      */
/* Called By: nspOrderProcessing                                        */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */ 
/*                                                                      */
/* Updates:                                                             */
/* Date        Author  Rev  Purposes								                    */
/* 03/01/2019  NJOW01  1.0  WMS-7293 PRSG only sort by lottable08 and   */
/*                          try allocate COPACK in same pallet          */
/************************************************************************/

CREATE PROC nspPR_SG07
@c_storerkey NVARCHAR(15) ,
@c_sku NVARCHAR(20) ,
@c_lot NVARCHAR(10) ,
@c_lottable01 NVARCHAR(18) ,
@c_lottable02 NVARCHAR(18) ,
@c_lottable03 NVARCHAR(18) ,
@d_lottable04 datetime ,
@d_lottable05 datetime ,
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
@c_uom NVARCHAR(10) ,
@c_facility NVARCHAR(5),   
@n_uombase int ,
@n_qtylefttofulfill INT,
@c_OtherParms NVARCHAR(200)=''
AS
BEGIN   
   DECLARE @c_Condition NVARCHAR(4000),      
           @c_SQLStatement NVARCHAR(MAX),
           @c_SQL NVARCHAR(MAX),
           @c_CaseNoMixLot26 NVARCHAR(10),
           @c_Orderkey NVARCHAR(10),
           @c_OrderLineNumber NVARCHAR(5),
           @n_Casecnt INT,
           @c_lottable02_W NVARCHAR(18),
           @c_lottable06_W NVARCHAR(30),
           @n_QtyToTake INT,
           @n_QtyAvailable INT,
           @n_QtyMaxByCase INT,
           @c_SortBy NVARCHAR(1000),  --NJOW01   
           @c_Skucopack1 NVARCHAR(20), --NJOW01
           @c_skucopack2 NVARCHAR(20) --NJOW01
   
   --NJOW01        
   DECLARE @c_lottable01_CP2 NVARCHAR(18) ,
           @c_lottable02_CP2 NVARCHAR(18) ,
           @c_lottable03_CP2 NVARCHAR(18) ,
           @c_lottable06_CP2 NVARCHAR(30) ,  
           @c_lottable07_CP2 NVARCHAR(30) ,  
           @c_lottable08_CP2 NVARCHAR(30) ,  
           @c_lottable09_CP2 NVARCHAR(30) ,  
           @c_lottable10_CP2 NVARCHAR(30) ,  
           @c_lottable11_CP2 NVARCHAR(30) ,  
           @c_lottable12_CP2 NVARCHAR(30)            

	 SELECT @c_SQLStatement = '', @c_Condition = '', @c_CaseNoMixLot26 = 'N', @n_Casecnt = 0, @c_SQL = ''
    
   IF NOT EXISTS(SELECT 1 FROM CODELKUP (NOLOCK) 
             WHERE Listname = 'PKCODECFG'
             AND Storerkey = @c_Storerkey
             AND Long = 'nspPR_SG07'
             AND Code = 'EMPTYLOT2'
             AND ISNULL(Short,'') <> 'N') AND ISNULL(@c_lottable02,'') = ''
   BEGIN
      DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
         SELECT TOP 1 NULL, NULL, NULL, NULL
         
      RETURN   
   END 

   SELECT @c_Orderkey = LEFT(@c_OtherParms,10)
   SELECT @c_OrderLineNumber = SUBSTRING(@c_OtherParms, 11,5)
   
   --NJOW01 S For PRHK only
   CREATE TABLE #TMP_ID (ID NVARCHAR(18) NULL,
                         Lottable05 DATETIME NULL,
                         Seq NVARCHAR(10) NULL)      

   SELECT @C_Skucopack1 = SKU.Sku
   FROM SKU (NOLOCK)
   WHERE SKU.Storerkey = @c_Storerkey
   AND SKU.Sku = @c_Sku
   AND SKU.Productmodel = 'COPACK'

   IF ISNULL(@c_Skucopack1,'') <> ''
   BEGIN
   	  SELECT TOP 1 @c_Skucopack2 = OD.SKU
   	        ,@c_lottable01_CP2 = OD.Lottable01
            ,@c_lottable02_CP2 = OD.Lottable02
            ,@c_lottable03_CP2 = OD.Lottable03
            ,@c_lottable06_CP2 = OD.Lottable06
            ,@c_lottable07_CP2 = OD.Lottable07
            ,@c_lottable08_CP2 = OD.Lottable08
            ,@c_lottable09_CP2 = OD.Lottable09
            ,@c_lottable10_CP2 = OD.Lottable10
            ,@c_lottable11_CP2 = OD.Lottable11
            ,@c_lottable12_CP2 = OD.Lottable12
   	  FROM ORDERDETAIL OD (NOLOCK)
   	  JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
   	  WHERE OD.Orderkey = @c_Orderkey
   	  AND SKU.Productmodel = 'COPACK'
   	  AND OD.Sku <> @c_skucopack1
   	  AND SKU.Style = @c_skucopack1
   	  ORDER BY CASE WHEN OD.OpenQty = @n_qtylefttofulfill THEN 1 ELSE 2 END, 
   	           CASE WHEN LEFT(OD.Lottable02,3) = LEFT(@c_lottable02,3) THEN 1 ELSE 2 END   	          
   END
   
   IF ISNULL(@c_Skucopack2,'') <> ''
   BEGIN
   	  --Get copack2 available pallets
   	  INSERT INTO #TMP_ID (ID, Lottable05, Seq)
   	  SELECT LOTxLOCxID.ID, MIN(LOTATTRIBUTE.Lottable05), 
   	         CASE WHEN ALLOCID.ID IS NOT NULL OR PREALLOCID.ID IS NOT NULL THEN '1' ELSE '2' END  --pallet with allocated by current order get first priority
      FROM LOTxLOCxID (NOLOCK) 
      JOIN SKUXLOC (NOLOCK) ON LOTXLOCXID.Storerkey = SKUXLOC.Storerkey AND LOTXLOCXID.Sku = SKUXLOC.Sku AND LOTXLOCXID.Loc = SKUXLOC.Loc
      JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
      JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID) 
      JOIN LOT (NOLOCK) ON (LOTXLOCXID.LOT = LOT.LOT)
      JOIN LOTATTRIBUTE (NOLOCK) ON LOT.Lot = LOTATTRIBUTE.Lot
      OUTER APPLY (SELECT TOP 1 PD.ID FROM PICKDETAIL PD (NOLOCK)  --Get pallet allready allocated by current order
                   WHERE PD.Id = LOTxLOCxID.ID
                   AND PD.Storerkey = LOTxLOCxID.Storerkey
                   AND PD.Sku = LOTxLOCxID.Sku 
                   AND PD.Orderkey = @c_Orderkey) AS ALLOCID
      OUTER APPLY (SELECT TOP 1 LLI.ID FROM PREALLOCATEPICKDETAIL PAL (NOLOCK) --Get pallet already preallocated by current order
                   JOIN LOTXLOCXID LLI (NOLOCK) ON PAL.Lot = LLI.Lot
                   WHERE LLI.ID = LOTxLOCxID.ID
                   AND PAL.Storerkey = LOTxLOCxID.Storerkey
                   AND PAL.Sku = LOTxLOCxID.Sku 
                   AND PAL.Orderkey = @c_Orderkey) AS PREALLOCID
      OUTER APPLY (SELECT SUM(Qty) AS Qty --Get Copack qty 
                   FROM LOTXLOCXID LLI (NOLOCK)
                   WHERE LLI.ID = LOTxLOCxID.ID
                   AND LLI.Storerkey = LOTxLOCxID.Storerkey
                   AND LLI.Sku = @C_Skucopack1) AS COPACK1                                    
      WHERE LOTxLOCxID.Storerkey = @c_Storerkey
      AND LOTxLOCxID.Sku = @c_Skucopack2
      AND LOC.Locationflag <> 'HOLD'
      AND LOC.Locationflag <> 'DAMAGE'
      AND LOC.Status <> 'HOLD'
      AND LOC.Facility = @c_Facility
      AND ID.STATUS <> 'HOLD'
      AND LOT.STATUS <> 'HOLD' 
      AND LOTxLOCxID.ID <> ''
      AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN) > 0      
      AND LOTATTRIBUTE.Lottable01 = CASE WHEN ISNULL(@c_Lottable01_CP2,'') <> '' THEN @c_Lottable01_CP2 ELSE LOTATTRIBUTE.Lottable01 END 
      AND LOTATTRIBUTE.Lottable02 = CASE WHEN ISNULL(@c_Lottable02_CP2,'') <> '' THEN @c_Lottable02_CP2 ELSE LOTATTRIBUTE.Lottable02 END 
      AND LOTATTRIBUTE.Lottable03 = CASE WHEN ISNULL(@c_Lottable03_CP2,'') <> '' THEN @c_Lottable03_CP2 ELSE LOTATTRIBUTE.Lottable03 END 
      AND LOTATTRIBUTE.Lottable06 = CASE WHEN ISNULL(@c_Lottable06_CP2,'') <> '' THEN @c_Lottable06_CP2 ELSE LOTATTRIBUTE.Lottable06 END 
      AND LOTATTRIBUTE.Lottable07 = CASE WHEN ISNULL(@c_Lottable07_CP2,'') <> '' THEN @c_Lottable07_CP2 ELSE LOTATTRIBUTE.Lottable07 END 
      AND LOTATTRIBUTE.Lottable08 = CASE WHEN ISNULL(@c_Lottable08_CP2,'') <> '' THEN @c_Lottable08_CP2 ELSE LOTATTRIBUTE.Lottable08 END 
      AND LOTATTRIBUTE.Lottable09 = CASE WHEN ISNULL(@c_Lottable09_CP2,'') <> '' THEN @c_Lottable09_CP2 ELSE LOTATTRIBUTE.Lottable09 END 
      AND LOTATTRIBUTE.Lottable10 = CASE WHEN ISNULL(@c_Lottable10_CP2,'') <> '' THEN @c_Lottable10_CP2 ELSE LOTATTRIBUTE.Lottable10 END 
      AND LOTATTRIBUTE.Lottable11 = CASE WHEN ISNULL(@c_Lottable11_CP2,'') <> '' THEN @c_Lottable11_CP2 ELSE LOTATTRIBUTE.Lottable11 END 
      AND LOTATTRIBUTE.Lottable12 = CASE WHEN ISNULL(@c_Lottable12_CP2,'') <> '' THEN @c_Lottable12_CP2 ELSE LOTATTRIBUTE.Lottable12 END       
      GROUP BY LOTxLOCxID.ID, CASE WHEN ALLOCID.ID IS NOT NULL OR PREALLOCID.ID IS NOT NULL THEN '1' ELSE '2' END, ISNULL(COPACK1.Qty,0)
      HAVING SUM(LOTxLOCxID.Qty) = ISNULL(COPACK1.Qty,0) --only get the pallet with all copack item have tally qty
   END   
   --NJOW01 E
   
   IF @c_UOM = '6'
   BEGIN
      IF EXISTS(SELECT 1 FROM CODELKUP (NOLOCK) 
                WHERE Listname = 'PKCODECFG'
                AND Storerkey = @c_Storerkey
                AND Long = 'nspPR_SG07'
                AND Code = 'CaseNoMixLot26'
                AND ISNULL(Short,'') <> 'N')
      BEGIN   	  
      	  SELECT @n_Casecnt = PACK.Casecnt  
      	  FROM ORDERDETAIL OD (NOLOCK)
      	  JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
      	  JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey AND OD.UOM = PACK.PackUOM1
      	  WHERE OD.Orderkey = @c_Orderkey
      	  AND OD.OrderLineNumber = @c_OrderLineNumber
      	  
      	  IF @n_Casecnt > 0
      	  BEGIN             	                  	  	
            SET @c_CaseNoMixLot26 = 'Y'
         END
      END
   END
   	   
   IF ISNULL(@c_Lottable01,'') <> '' 
   BEGIN
      SELECT @c_Condition = " AND LOTATTRIBUTE.LOTTABLE01 = N'" + RTRIM(ISNULL(@c_Lottable01,'')) + "' "
   END   
   IF ISNULL(@c_Lottable02,'') <> '' 
   BEGIN
      SELECT @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + " AND LOTATTRIBUTE.LOTTABLE02 = N'" + RTRIM(ISNULL(@c_Lottable02,'')) + "' "
   END   
   
   IF ISNULL(@c_Lottable03,'') <> '' 
   BEGIN
      SELECT @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + " AND LOTATTRIBUTE.LOTTABLE03 = N'" + RTRIM(ISNULL(@c_Lottable03,'')) + "' "
   END
   ELSE 
      SELECT @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + " AND LOTATTRIBUTE.LOTTABLE03 = N'OK' "
   
   IF CONVERT(char(10), @d_Lottable04, 103) <> "01/01/1900" AND @d_Lottable04 IS NOT NULL
   BEGIN
      SELECT @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + " AND LOTATTRIBUTE.LOTTABLE04 = N'" + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable04, 106)) + "' "
   END
   IF CONVERT(char(10), @d_Lottable05, 103) <> "01/01/1900" AND @d_Lottable05 IS NOT NULL
   BEGIN
      SELECT @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + " AND LOTATTRIBUTE.LOTTABLE05 = N'" + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable05, 106)) + "' "
   END
   IF ISNULL(@c_Lottable06,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable06 = N''' + RTRIM(ISNULL(@c_Lottable06,'')) + '''' 
   END   
   IF ISNULL(@c_Lottable07,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable07 = N''' + RTRIM(ISNULL(@c_Lottable07,'')) + '''' 
   END   
   IF ISNULL(@c_Lottable08,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable08 = N''' + RTRIM(ISNULL(@c_Lottable08,'')) + '''' 
   END   
   IF ISNULL(@c_Lottable09,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable09 = N''' + RTRIM(ISNULL(@c_Lottable09,'')) + '''' 
   END   
   IF ISNULL(@c_Lottable10,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable10 = N''' + RTRIM(ISNULL(@c_Lottable10,'')) + '''' 
   END   
   IF ISNULL(@c_Lottable11,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable11 = N''' + RTRIM(ISNULL(@c_Lottable11,'')) + '''' 
   END   
   IF ISNULL(@c_Lottable12,'') <> '' 
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable12 = N''' + RTRIM(ISNULL(@c_Lottable12,'')) + '''' 
   END  
   IF CONVERT(char(10), @d_Lottable13, 103) <> '01/01/1900' AND @d_Lottable13 IS NOT NULL
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable13 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) + ''''
   END
   IF CONVERT(char(10), @d_Lottable14, 103) <> '01/01/1900' AND @d_Lottable14 IS NOT NULL
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable14 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) + ''''
   END
   IF CONVERT(char(10), @d_Lottable15, 103) <> '01/01/1900' AND @d_Lottable15 IS NOT NULL
   BEGIN
      SET @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + ' AND LOTATTRIBUTE.Lottable15 = N''' + RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) + ''''
   END

	 --NJOW01
	 IF @c_Storerkey = 'PRSG'
	    SET @c_SortBy = 'ORDER BY CASE WHEN ISNULL(MIN(LOTATTRIBUTE.Lottable08),'''') <> '''' THEN 1 ELSE 2 END, MIN(LOTATTRIBUTE.Lottable08), MIN(LOTATTRIBUTE.Lottable05), MIN(LOTATTRIBUTE.Lot)'  
	 ELSE
	    SET @c_SortBy = 'ORDER BY MIN(LOTATTRIBUTE.Lottable05), MIN(LOTATTRIBUTE.Lot)'  
	          	 
	 IF @c_CaseNoMixLot26 = 'Y'
	 BEGIN	 	     	 	  
      SELECT @c_SQLStatement = " DECLARE CURSOR_LOTTABLE CURSOR FAST_FORWARD READ_ONLY FOR " +
            " SELECT LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable06, " +
            " QTYAVAILABLE = (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) )  " +            
            " FROM LOT WITH (NOLOCK) " +
            " JOIN LOTATTRIBUTE (NOLOCK) ON (LOT.lot = LOTATTRIBUTE.lot) " +   
            " JOIN LOTxLOCxID (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT) " +    
            " JOIN LOC (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC) " +    
            " JOIN ID (NOLOCK) ON (LOTxLOCxID.ID = ID.ID) " +        
            " LEFT OUTER JOIN (SELECT LA.Lottable02, LA.Lottable06, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) " +    
            "                FROM   PreallocatePickdetail P (NOLOCK) " +
            "                JOIN   LOTATTRIBUTE LA (NOLOCK) ON P.Lot = LA.Lot " +
            "                JOIN   ORDERS (NOLOCK) ON P.Orderkey = ORDERS.Orderkey " +  
            "                JOIN   ORDERDETAIL (NOLOCK) ON ORDERS.Orderkey = ORDERDETAIL.Orderkey AND P.OrderLineNumber = ORDERDETAIL.OrderLineNumber " +  
            "                WHERE  P.Storerkey = @c_storerkey " +     
            "                AND    P.SKU = @c_SKU " +
            "                AND    ORDERS.FACILITY = @c_facility " +   
            "                AND    P.qty > 0 " +    
            "                GROUP BY LA.Lottable02, LA.Lottable06, ORDERS.Facility) P ON LOTATTRIBUTE.Lottable02 = P.Lottable02 AND LOTATTRIBUTE.Lottable06 = P.Lottable06 AND P.Facility = LOC.Facility " +   
            " WHERE LOT.STORERKEY = @c_storerkey " +   
            " AND LOT.SKU = @c_SKU " +
            " AND LOT.STATUS = 'OK'  " +   
            " AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' " +     
            " AND LOC.LocationFlag = 'NONE' " +  
            " AND LOC.Facility = @c_facility "  +
            ISNULL(RTRIM(@c_Condition),'')  + 
            " GROUP By LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable06 " +
            " HAVING SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) >= @n_Casecnt " +
            @c_SortBy --NJOW01
		        --" ORDER BY MIN(LOTATTRIBUTE.Lottable05), MIN(LOTATTRIBUTE.Lot) " 		     

      EXEC sp_executesql @c_SQLStatement,
           N'@c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20), @c_facility NVARCHAR(5), @n_casecnt INT', 
           @c_Storerkey,
           @c_Sku,
           @c_Facility,
           @n_Casecnt
            		        
       OPEN CURSOR_LOTTABLE                    
       FETCH NEXT FROM CURSOR_LOTTABLE INTO @c_lottable02_W, @c_lottable06_W, @n_QtyMaxByCase   
              
       WHILE (@@FETCH_STATUS <> -1) 
       BEGIN    	 	    
       	  SET @n_QtyMaxByCase = FLOOR(@n_QtyMaxByCase / (@n_Casecnt * 1.00)) * @n_Casecnt
       	   
          SELECT @c_SQLStatement = " DECLARE CURSOR_AVAILABLELOT CURSOR FAST_FORWARD READ_ONLY FOR " +
               " SELECT LOT.LOT, " +
               " QTYAVAILABLE = (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) )  " +
               " FROM LOT WITH (NOLOCK) " +
               " JOIN LOTATTRIBUTE (NOLOCK) ON (LOT.lot = LOTATTRIBUTE.lot) " +   
               " JOIN LOTxLOCxID (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT) " +    
               " JOIN LOC (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC) " +    
               " JOIN ID (NOLOCK) ON (LOTxLOCxID.ID = ID.ID) " +        
               " LEFT OUTER JOIN (SELECT P.lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) " +    
               "                FROM   PreallocatePickdetail P (NOLOCK) " +
               "                JOIN   ORDERS (NOLOCK) ON P.Orderkey = ORDERS.Orderkey " +  
               "                JOIN   ORDERDETAIL (NOLOCK) ON ORDERS.Orderkey = ORDERDETAIL.Orderkey AND P.OrderLineNumber = ORDERDETAIL.OrderLineNumber " +  
               "                WHERE  P.Storerkey = @c_storerkey " +     
               "                AND    P.SKU = @c_SKU " +
               "                AND    ORDERS.FACILITY = @c_facility " +   
               "                AND    P.qty > 0 " +    
               "                GROUP BY p.Lot, ORDERS.Facility) P ON LOTxLOCxID.Lot = P.Lot AND P.Facility = LOC.Facility " +   
               " WHERE LOT.STORERKEY = @c_storerkey " +   
               " AND LOT.SKU = @c_SKU " +
               " AND LOT.STATUS = 'OK'  " +   
               " AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' " +     
               " AND LOC.LocationFlag = 'NONE' " +  
               " AND LOC.Facility = @c_facility "  +
               " AND LOTATTRIBUTE.Lottable02 = @c_lottable02 "  +
               " AND LOTATTRIBUTE.Lottable06 = @c_lottable06 "  +
               ISNULL(RTRIM(@c_Condition),'')  + 
               " GROUP By LOT.LOT, Lotattribute.Lottable05, Lotattribute.Lottable04, LOTATTRIBUTE.Lottable08 " +
               --" GROUP By LOT.LOT, Lotattribute.Lottable05, Lotattribute.Lottable04, LOTxLOCxID.LOC, LOTxLOCxID.QTY " +
               " HAVING SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) > 0 " +
               @c_SortBy --NJOW01
		           --" ORDER BY Lotattribute.Lottable05, Lot.Lot "
		            		     
          EXEC sp_executesql @c_SQLStatement,
              N'@c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20), @c_facility NVARCHAR(5), @c_Lottable02 NVARCHAR(18), @c_Lottable06 NVARCHAR(30)', 
              @c_Storerkey,
              @c_Sku,
              @c_Facility,
              @c_Lottable02_W,
              @c_Lottable06_W

          SET @n_QtyToTake = 0
          
          OPEN CURSOR_AVAILABLELOT                    
          FETCH NEXT FROM CURSOR_AVAILABLELOT INTO @c_LOT, @n_QtyAvailable   
                 
          WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0) AND (@n_QtyMaxByCase > 0)          
          BEGIN              	
          	  IF @n_QtyAvailable > @n_QtyLeftToFulfill
          	     SET @n_QtyToTake = @n_QtyLeftToFulfill
          	  ELSE
          	     SET @n_QtyToTake = @n_QtyAvailable
          	     
          	  IF @n_QtyToTake > @n_QtyMaxByCase
          	     SET @n_QtyToTake = @n_QtyMaxByCase           	           	  
          	        	  
             IF ISNULL(@c_SQL,'') = ''
             BEGIN
                SET @c_SQL = N'   
                      DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR   
                      SELECT '''  + @c_Storerkey + ''', ''' + @c_Sku + ''', ''' + @c_Lot + ''', ' + CAST(@n_QtyToTake AS NVARCHAR(10))
             END
             ELSE
             BEGIN
                SET @c_SQL = @c_SQL + N'  
                      UNION ALL
                      SELECT '''  + @c_Storerkey + ''', ''' + @c_Sku + ''', ''' + @c_Lot + ''', ' + CAST(@n_QtyToTake AS NVARCHAR(10))
             END
          
          	 SELECT @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - @n_QtyToTake 
          	 SELECT @n_QtyMaxByCase = @n_QtyMaxByCase - @n_QtyToTake
                    
             FETCH NEXT FROM CURSOR_AVAILABLELOT INTO @c_LOT, @n_QtyAvailable   
          END 		 
          CLOSE CURSOR_AVAILABLELOT
          DEALLOCATE CURSOR_AVAILABLELOT       	 		 
		              		                        	
          FETCH NEXT FROM CURSOR_LOTTABLE INTO @c_lottable02_W, @c_lottable06_W, @n_QtyMaxByCase   
       END
       CLOSE CURSOR_LOTTABLE
       DEALLOCATE CURSOR_LOTTABLE
       
       IF ISNULL(@c_SQL,'') <> ''
       BEGIN
          EXEC sp_ExecuteSQL @c_SQL
       END
       ELSE
       BEGIN
          DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
          SELECT TOP 0 NULL, NULL, NULL, NULL    
       END                       
	 END
	 ELSE
	 BEGIN	 
      /*SELECT @c_SQLStatement = " DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR " +
            " SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT, " +
            " QTYAVAILABLE = (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) )  " +
            " FROM LOT WITH (NOLOCK) " +
            " JOIN LOTATTRIBUTE (NOLOCK) ON (LOT.lot = LOTATTRIBUTE.lot) " +   
            " JOIN LOTxLOCxID (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT) " +    
            " JOIN LOC (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC) " +    
            " JOIN ID (NOLOCK) ON (LOTxLOCxID.ID = ID.ID) " +        
            " LEFT OUTER JOIN (SELECT P.lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) " +    
            "                FROM   PreallocatePickdetail P (NOLOCK) " +
            "                JOIN   ORDERS (NOLOCK) ON P.Orderkey = ORDERS.Orderkey " +  
            "                JOIN   ORDERDETAIL (NOLOCK) ON ORDERS.Orderkey = ORDERDETAIL.Orderkey AND P.OrderLineNumber = ORDERDETAIL.OrderLineNumber " +  
            "                WHERE  P.Storerkey = N'" + RTRIM(@c_storerkey) + "' " +     
            "                AND    P.SKU = N'" + RTRIM(@c_SKU) + "' " +
            "                AND    ORDERS.FACILITY = N'" + RTRIM(@c_facility) + "' " +   
            "                AND    P.qty > 0 " +    
            "                GROUP BY p.Lot, ORDERS.Facility) P ON LOTxLOCxID.Lot = P.Lot AND P.Facility = LOC.Facility " +   
            " WHERE LOT.STORERKEY = N'" + RTRIM(@c_storerkey) + "' " +   
            " AND LOT.SKU = N'" + RTRIM(@c_SKU) + "' " +
            " AND LOT.STATUS = 'OK'  " +   
            " AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' " +     
            " AND LOC.LocationFlag = 'NONE' " +  
            " AND LOC.Facility = N'" + RTRIM(@c_facility) + "' "  +
            ISNULL(RTRIM(@c_Condition),'')  + 
            --" GROUP By LOT.STORERKEY, LOT.SKU, LOT.LOT, Lotattribute.Lottable05, Lotattribute.Lottable04, LOTxLOCxID.LOC, LOTxLOCxID.QTY " +
            " GROUP By LOT.STORERKEY, LOT.SKU, LOT.LOT, Lotattribute.Lottable05, Lotattribute.Lottable04 " +
            " HAVING SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) >= " + CAST(@n_UOMBase AS VARCHAR(10)) +
            @c_SortBy --NJOW01
		        --" ORDER BY Lotattribute.Lottable05, Lot.Lot " 		     
      
      EXEC(@c_SQLStatement)
      */

	    IF ISNULL(@c_Skucopack1,'') <> '' --NJOW01
	    BEGIN
         SET @c_Condition = @c_Condition + ' AND TI.ID IS NOT NULL ' 
	    END   
      
   	  IF @c_Storerkey = 'PRHK'
	       SET @c_SortBy = 'ORDER BY CASE WHEN TI.ID IS NOT NULL THEN TI.Seq ELSE ''3'' END, CASE WHEN TI.ID IS NOT NULL THEN CONVERT(NVARCHAR, TI.Lottable05,112) ELSE ''ZZZZZZZZZZ'' END, LOTATTRIBUTE.Lottable05, LOT.Lot'  
      
      SELECT @c_SQLStatement = " DECLARE CURSOR_AVAILABLELOT CURSOR FAST_FORWARD READ_ONLY FOR " +
            " SELECT LOT.LOT, " +
            " QTYAVAILABLE = (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) )  " +
            " FROM LOT WITH (NOLOCK) " +
            " JOIN LOTATTRIBUTE (NOLOCK) ON (LOT.lot = LOTATTRIBUTE.lot) " +   
            " JOIN LOTxLOCxID (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT) " +    
            " JOIN LOC (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC) " +    
            " JOIN ID (NOLOCK) ON (LOTxLOCxID.ID = ID.ID) " +        
            " LEFT OUTER JOIN #TMP_ID TI ON LOTXLOCXID.ID = TI.ID " +
            " LEFT OUTER JOIN (SELECT P.lot, ORDERS.Facility, QtyPreallocated = SUM(P.Qty) " +    
            "                FROM   PreallocatePickdetail P (NOLOCK) " +
            "                JOIN   ORDERS (NOLOCK) ON P.Orderkey = ORDERS.Orderkey " +  
            "                JOIN   ORDERDETAIL (NOLOCK) ON ORDERS.Orderkey = ORDERDETAIL.Orderkey AND P.OrderLineNumber = ORDERDETAIL.OrderLineNumber " +  
            "                WHERE  P.Storerkey = @c_storerkey " +     
            "                AND    P.SKU = @c_SKU " + 
            "                AND    ORDERS.FACILITY = @c_facility " +   
            "                AND    P.qty > 0 " +    
            "                GROUP BY p.Lot, ORDERS.Facility) P ON LOTxLOCxID.Lot = P.Lot AND P.Facility = LOC.Facility " +   
            " WHERE LOT.STORERKEY = @c_storerkey " +   
            " AND LOT.SKU = @c_SKU " +
            " AND LOT.STATUS = 'OK'  " +   
            " AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' " +     
            " AND LOC.LocationFlag = 'NONE' " +  
            " AND LOC.Facility = @c_facility "  +
            ISNULL(RTRIM(@c_Condition),'')  + 
            " GROUP By LOT.LOT, Lotattribute.Lottable05, Lotattribute.Lottable04, CASE WHEN TI.ID IS NOT NULL THEN TI.Seq ELSE '3' END, CASE WHEN TI.ID IS NOT NULL THEN CONVERT(NVARCHAR, TI.Lottable05,112) ELSE 'ZZZZZZZZZZ' END " +
            " HAVING SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) >= @n_UOMBase " +
            @c_SortBy --NJOW01                   
  
      EXEC sp_executesql @c_SQLStatement,
           N'@c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20), @c_facility NVARCHAR(5), @n_UOMBase INT, @n_qtylefttofulfill INT', 
           @c_Storerkey,
           @c_Sku,
           @c_Facility,
           @n_UOMBase,
           @n_qtylefttofulfill            		        

       SET @n_QtyToTake = 0
       
       OPEN CURSOR_AVAILABLELOT                    
       FETCH NEXT FROM CURSOR_AVAILABLELOT INTO @c_LOT, @n_QtyAvailable   
              
       WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0)     
       BEGIN              	
       	  IF @n_QtyAvailable > @n_QtyLeftToFulfill
       	     SET @n_QtyToTake = @n_QtyLeftToFulfill
       	  ELSE
       	     SET @n_QtyToTake = @n_QtyAvailable
       	            	        	  
          IF ISNULL(@c_SQL,'') = ''
          BEGIN
             SET @c_SQL = N'   
                   DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR   
                   SELECT '''  + @c_Storerkey + ''', ''' + @c_Sku + ''', ''' + @c_Lot + ''', ' + CAST(@n_QtyToTake AS NVARCHAR(10))
          END
          ELSE
          BEGIN
             SET @c_SQL = @c_SQL + N'  
                   UNION ALL
                   SELECT '''  + @c_Storerkey + ''', ''' + @c_Sku + ''', ''' + @c_Lot + ''', ' + CAST(@n_QtyToTake AS NVARCHAR(10))
          END
       
       	  SELECT @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - @n_QtyToTake 
                 
          FETCH NEXT FROM CURSOR_AVAILABLELOT INTO @c_LOT, @n_QtyAvailable   
       END 		 
       CLOSE CURSOR_AVAILABLELOT
       DEALLOCATE CURSOR_AVAILABLELOT       	 		 
		              		                        	       
       IF ISNULL(@c_SQL,'') <> ''
       BEGIN
          EXEC sp_ExecuteSQL @c_SQL
       END
       ELSE
       BEGIN
          DECLARE PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR 
          SELECT TOP 0 NULL, NULL, NULL, NULL    
       END                             
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE on nspPR_SG07 to nSQL

GO




