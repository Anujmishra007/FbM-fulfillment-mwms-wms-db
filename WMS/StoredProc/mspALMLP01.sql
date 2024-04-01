SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: mspALMLP01                                            */
/* Creation Date: 2024-03-14                                               */
/* Copyright: Maersk                                                       */
/* Written by:Wan                                                          */
/*                                                                         */
/* Purpose:                                                                */
/*          (Work with SkipPreAllocation)                                  */
/*                                                                         */
/* Called By: nspOrderProcessing                                           */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 8.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Rev  Purposes                                      */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[mspALMLP01]
   @c_DocumentNo        NVARCHAR(10)
,  @c_Facility          NVARCHAR(5)
,  @c_StorerKey         NVARCHAR(15)
,  @c_SKU               NVARCHAR(20)
,  @c_Lottable01        NVARCHAR(18)
,  @c_Lottable02        NVARCHAR(18)
,  @c_Lottable03        NVARCHAR(18)
,  @d_Lottable04        DATETIME
,  @d_Lottable05        DATETIME
,  @c_Lottable06        NVARCHAR(30)
,  @c_Lottable07        NVARCHAR(30)
,  @c_Lottable08        NVARCHAR(30)
,  @c_Lottable09        NVARCHAR(30)
,  @c_Lottable10        NVARCHAR(30)
,  @c_Lottable11        NVARCHAR(30)
,  @c_Lottable12        NVARCHAR(30)
,  @d_Lottable13        DATETIME
,  @d_Lottable14        DATETIME
,  @d_Lottable15        DATETIME
,  @c_UOM               NVARCHAR(10)
,  @c_HostWHCode        NVARCHAR(10)
,  @n_UOMBase           INT
,  @n_QtyLeftToFulfill  INT
,  @c_OtherParms        NVARCHAR(200)=''
AS
BEGIN
   DECLARE @n_StorerSkuMinShelfLife          INT            = 0   
         , @n_ConsigneeSkuMinShelfLife       INT            = 0
         , @n_SkuOutGoingMinShelfLife        INT            = 0
         , @n_OrderMinShelfLife              INT            = 0
         , @n_ConsigneeSkuGroupMinShelfLife  INT            = 0
         , @c_ContinueChkShelfLife           NCHAR(1)       = 0
         , @c_Condition                      NVARCHAR(MAX)  =''
         , @c_SQL                            NVARCHAR(MAX)  =''
         , @c_SQLParms                       NVARCHAR(MAX)  =''     
         , @C_SortBy                         NVARCHAR(2000) =''
         , @c_Orderkey                       NVARCHAR(10)   =''
         , @c_OrderLineNumber                NVARCHAR(5)    =''
         , @c_OverAllocateFlag               NCHAR(1)       =''
         , @c_FullPalletByLocFlag            NCHAR(1)       ='Y'
         , @c_ShelfLifeFlag                  NCHAR(1)       ='' 
         , @n_LotQtyAvailable                INT            =0
         , @n_QtyAvailable                   INT            =''
         , @n_QtyToTake                      INT            =''
         , @n_NoOfLot                        INT            =''
         , @c_LOT                            NVARCHAR(10)   =''
         , @c_LOC                            NVARCHAR(10)   =''
         , @c_ID                             NVARCHAR(18)   =''
         , @c_OtherValue                     NVARCHAR(20)   =''
         , @c_Wavekey                        NVARCHAR(10)   =''
         , @c_Loadkey                        NVARCHAR(10)   =''
         , @c_key3                           NVARCHAR(10)   =''
         , @c_LocationCategory               NVARCHAR(10)   ='VNA'
           
   SET @c_Condition = ''
   SET @n_SkuOutGoingMinShelfLife = 0
   SET @n_OrderMinShelfLife = 0
   SET @n_StorerSkuMinShelfLife = 0
   SET @n_ConsigneeSkuMinShelfLife = 0
   SET @n_ConsigneeSkuGroupMinShelfLife = 0
   SET @c_ContinueChkShelfLife = 'N'

   EXEC isp_Init_Allocate_Candidates          

   IF LEN(@c_OtherParms) > 0
   BEGIN
      SET @c_OrderLineNumber = SUBSTRING(@c_OtherParms, 11, 5)
      SET @c_Key3 = SUBSTRING(@c_OtherParms, 16, 1)

      IF ISNULL(@c_OrderLineNumber,'') <> ''
      BEGIN
         SET @c_Orderkey = LEFT(@c_OtherParms, 10)  --discrete by order

         SELECT @c_ID = ID,
                @n_OrderMinShelfLife = MinShelfLife
         FROM ORDERDETAIL(NOLOCK)
         WHERE Orderkey = @c_Orderkey
         AND OrderLineNumber = @c_OrderLineNumber

         SELECT @c_Loadkey = Loadkey
         FROM LOADPLANDETAIL(NOLOCK)
         WHERE Orderkey = @c_Orderkey
         
         SELECT @c_Wavekey = Wavekey
         FROM WAVEDETAIL(NOLOCK)
         WHERE Orderkey = @c_Orderkey
      END
      
      IF ISNULL(@c_OrderLineNumber,'')='' AND ISNULL(@c_key3,'')=''       
      BEGIN
         SET @c_Loadkey = LEFT(@c_OtherParms, 10)  --Load conso
         
         SELECT @c_Wavekey = MAX(WD.Wavekey)
         FROM LOADPLANDETAIL LPD (NOLOCK)
         JOIN WAVEDETAIL WD (NOLOCK) ON LPD.Orderkey = WD.Orderkey
         AND LPD.Loadkey = @c_Loadkey
         HAVING COUNT(DISTINCT WD.Wavekey) = 1
      END
      
      IF ISNULL(@c_OrderLineNumber,'')='' AND ISNULL(@c_key3,'')='W'       
      BEGIN
         SET @c_Wavekey = LEFT(@c_OtherParms, 10) --Wave conso
      END   
   END

   CREATE TABLE #TMP_LOT (LOT NVARCHAR(10) NULL,
                          QtyAvailable INT NULL DEFAULT(0))                                     
   
   IF ISNULL(@c_Lottable01,'') <> '' 
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND LOTTABLE01 = RTRIM(@c_Lottable01)'  
   END

   IF ISNULL(@c_Lottable02,'') <> '' 
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND LOTTABLE02 = RTRIM(@c_Lottable02)'          
   END

   IF ISNULL(@c_Lottable03,'') <> ''  
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND LOTTABLE03 = RTRIM(@c_Lottable03)'          
   END

   IF CONVERT(char(10), @d_Lottable04, 103) <> '01/01/1900' AND @d_Lottable04 IS NOT NULL 
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND LOTTABLE04 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable04, 106))'  
   END
   
   IF CONVERT(char(10), @d_Lottable05, 103) <> '01/01/1900' AND @d_Lottable05 IS NOT NULL 
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND LOTTABLE05 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable05, 106))'  
   END

   IF ISNULL(@c_Lottable06,'') <> '' 
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'')+ ' AND Lottable06 = RTRIM(@c_Lottable06) '              
   END                                                                                                          
                                                                                                                
   IF ISNULL(@c_Lottable07,'') <> ''                                                                            
   BEGIN                                                                                                        
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable07 = RTRIM(@c_Lottable07) '             
   END                                                                                                          
                                                                                                                
   IF ISNULL(@c_Lottable08,'') <> ''                                                                            
   BEGIN                                                                                                        
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable08 = RTRIM(@c_Lottable08) '             
   END                                                                                                          
                                                                                                                
   IF ISNULL(@c_Lottable09,'') <> ''                                                                            
   BEGIN                                                                                                        
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable09 = RTRIM(@c_Lottable09) '             
   END

   IF ISNULL(@c_Lottable10,'') <> ''  
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable10 = RTRIM(@c_Lottable10) '             
   END                                                                                                          
                                                                                                                
   IF ISNULL(@c_Lottable11,'') <> ''                                                                            
   BEGIN                                                                                                        
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable11 = RTRIM(@c_Lottable11) '             
   END                                                                                                          
                                                                                                                
   IF ISNULL(@c_Lottable12,'') <> ''                                                                            
   BEGIN                                                                                                        
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable12 = RTRIM(@c_Lottable12) '             
   END

   IF CONVERT(char(10), @d_Lottable13, 103) <> '01/01/1900' 
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable13 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) '  
   END                                                                                                                            
                                                                                                                                  
   IF CONVERT(char(10), @d_Lottable14, 103) <> '01/01/1900'                                                                       
   BEGIN                                                                                                                          
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable14 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) '  
   END                                                                                                                            
                                                                                                                                  
   IF CONVERT(char(10), @d_Lottable15, 103) <> '01/01/1900'                                                                       
   BEGIN                                                                                                                          
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable15 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) '  
   END

   ------Order shelflife (orderdetail.Minshelflife)
   IF ISNULL(@n_OrderMinShelfLife,0) > 0 AND ISNULL(@c_OrderKey,'') <> '' AND @c_ContinueChkShelfLife = 'Y'
   BEGIN
        IF @c_ShelfLifeFlag = 'E'
        BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_OrderMinShelfLife '     
                             + 'OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'') '                              
      END
      ELSE IF @c_ShelfLifeFlag = 'M'
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_OrderMinShelfLife '   
                             + 'OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'') '                       
      END

      SET @c_ContinueChkShelfLife = 'N'
   END

   IF ISNULL(@c_OrderKey,'') <> '' AND @c_ContinueChkShelfLife = 'Y'
   BEGIN
      ------Consignee shelflife (Storer.MinShelfLife)
      /*
      SELECT @n_ConsigneeMinShelfLife = ISNULL(STORER.MinShelfLife,0)
      FROM ORDERS (NOLOCK)
      JOIN STORER (NOLOCK) ON (ORDERS.ConsigneeKey = STORER.StorerKey)
      WHERE ORDERS.OrderKey = @c_OrderKey

      IF ISNULL(@n_ConsigneeMinShelfLife,0) > 0
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= '
         + CAST(@n_ConsigneeMinShelfLife AS NVARCHAR(10)) + ' OR Lottable04 IS NULL OR CONVERT(char(10), Lottable04, 103) = ''01/01/1900'')'
      END
      */
      ------Consignee+Sku shelflife (Storer.MinShelflife * Sku.Shelflife)
      SELECT @n_ConsigneeSkuMinShelfLife = (Sku.Shelflife * Storer.MinShelflife/100)
      FROM ORDERS O (NOLOCK)
      JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey
      JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
      JOIN STORER (NOLOCK) ON O.Consigneekey = STORER.Storerkey
      WHERE O.Orderkey = @c_Orderkey
      AND OD.OrderLineNumber = @c_OrderLineNumber

      IF ISNULL(@n_ConsigneeSkuMinShelfLife,0) > 0
      BEGIN
          IF @c_ShelfLifeFlag = 'E'
         BEGIN
            SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_ConsigneeSkuMinShelfLife'
                             + ' OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'')'
         END
         ELSE IF @c_ShelfLifeFlag = 'M'
         BEGIN
            SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_ConsigneeSkuMinShelfLife'
                             + ' OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'')'
         END

         SET @c_ContinueChkShelfLife = 'N'
      END

      ------Consigneegroup + skugroup shelflife (Doclkup.consigneegroup + Doclkup.skugroup)
      IF @c_ContinueChkShelfLife = 'Y'
      BEGIN
         SELECT @n_ConsigneeSkuGroupMinShelfLife = DOCLKUP.Shelflife
         FROM ORDERS O (NOLOCK)
         JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey
         JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
         JOIN STORER (NOLOCK) ON O.Consigneekey = STORER.Storerkey
         JOIN DOCLKUP (NOLOCK) ON STORER.Secondary = DOCLKUP.ConsigneeGroup AND SKU.Skugroup = DOCLKUP.Skugroup
         WHERE O.Orderkey = @c_Orderkey
         AND OD.OrderLineNumber = @c_OrderLineNumber

         IF ISNULL(@n_ConsigneeSkuGroupMinShelfLife,0) > 0
         BEGIN
            IF @c_ShelfLifeFlag = 'E'
            BEGIN
               SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_ConsigneeSkuGroupMinShelfLife'
                                + ' OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'')'                                        
            END
            ELSE IF @c_ShelfLifeFlag = 'M'
            BEGIN
               SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_ConsigneeSkuGroupMinShelfLife'  
                                + ' OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'')'                                        
            END

            SET @c_ContinueChkShelfLife = 'N'
         END
      END
   END

   ------Sku outgoing shelflife (Sku.SUSR2)
   IF @c_ContinueChkShelfLife = 'Y'
   BEGIN
      SELECT @n_SkuOutGoingMinShelfLife = CASE WHEN ISNUMERIC(SUSR2) = 1 THEN CAST(SUSR2 AS INT)
                                          ELSE 0 END
      FROM  SKU (NOLOCK)
      WHERE SKU = @c_SKU
      AND   STORERKEY = @c_StorerKey

      IF ISNULL(@n_SkuOutGoingMinShelfLife,0) > 0
      BEGIN
        IF @c_ShelfLifeFlag = 'E'
          BEGIN
             SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_SkuOutGoingMinShelfLife'  
                              + ' OR Lottable04 IS NULL OR CONVERT(char(10), Lottable04, 103) = ''01/01/1900'')'                                
         END
         ELSE IF @c_ShelfLifeFlag = 'M'
         BEGIN
             SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_SkuOutGoingMinShelfLife'  
                                 + ' OR Lottable04 IS NULL OR CONVERT(char(10), Lottable04, 103) = ''01/01/1900'')'                                
         END

         SET @c_ContinueChkShelfLife = 'N'
      END
   END

   ------Storer+Sku shelflife (Storer.MinShelflife * Sku.Shelflife)
   IF @c_ContinueChkShelfLife = 'Y'
   BEGIN
      SELECT @n_StorerSkuMinShelfLife = (Sku.Shelflife * Storer.MinShelflife/100)
      FROM Sku (nolock)
      JOIN Storer (nolock) ON Sku.Storerkey = Storer.Storerkey
      WHERE Sku.Sku = @c_sku
      AND Sku.Storerkey = @c_storerkey

      IF ISNULL(@n_StorerSkuMinShelfLife,0) > 0
      BEGIN
        IF @c_ShelfLifeFlag = 'E'
        BEGIN
            SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_StorerSkuMinShelfLife'   
                             + ' OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'')'
         END
         ELSE IF @c_ShelfLifeFlag = 'M'
         BEGIN
            SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_StorerSkuMinShelfLife'   
                             + ' OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = ''01/01/1900'')'
         END

         SET @c_ContinueChkShelfLife = 'N'
      END
   END

   IF @c_UOM = '1'
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') 
                       + ' AND SKUXLOC.LocationType NOT IN (''PICK'',''CASE'')'
                       + ' AND LOC.LocationCategory = @c_LocationCategory'
   END
   ELSE
   BEGIN
      SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND SKUXLOC.LocationType IN (''PICK'',''CASE'')'
   END

   SET @c_SortBy = ' ORDER BY Lotattribute.Lottable04, Lotattribute.Lottable05,'
                 + CASE WHEN @c_UOM = 1 THEN 'LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN DESC'
                                        ELSE '1' END
                 + ',Lotattribute.Lot, LotxLocxID.ID'

   IF (@c_FullPalletByLocFlag = 'Y' AND @c_UOM = '1') --OR (@c_OverAllocateFlag = 'Y')  
   BEGIN
      SET @c_SQL = N'DECLARE CURSOR_AVAILABLECFG CURSOR FAST_FORWARD READ_ONLY FOR'  
                 + ' SELECT LOTxLOCxID.LOT, LOTxLOCxID.LOC,LOTxLOCxID.ID'
                 + ' ,QTYAVAILABLE = LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN' 
                 + ' FROM LOTxLOCxID (NOLOCK)'
                 + ' JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot'
                 + ' JOIN LOT (NOLOCK) ON LOTxLOCxID.Lot = LOT.Lot'
                 + ' JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC'
                 + ' JOIN ID (NOLOCK) ON LOTxLOCxID.Id = ID.ID'
                 + ' JOIN SKUXLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUXLOC.Storerkey'
                 +                      ' AND LOTxLOCxID.Sku = SKUXLOC.Sku AND LOTxLOCxID.Loc = SKUXLOC.Loc'
                 + ' JOIN SKU (NOLOCK) ON LOTxLOCxID.Storerkey = SKU.Storerkey AND SKU.Sku = SKUXLOC.Sku'
                 + ' JOIN STORER (NOLOCK) ON LOTxLOCxID.Storerkey = STORER.Storerkey'
                 + ' JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey'
                 + ' WHERE LOTxLOCxID.Storerkey = @c_Storerkey'
                 + ' AND LOTxLOCxID.Sku = @c_Sku'
                 + ' AND LOC.Facility = @c_Facility'
                 + ' AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN) > 0'
                 + ' AND LOT.STATUS = ''OK'' AND LOC.STATUS = ''OK'' AND ID.STATUS = ''OK'''
                 + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'
                 + ' ' +  ISNULL(RTRIM(@c_Condition),'') 
                 + ' ' + @c_SortBy

      SET @c_SQLParms = N'@c_Facility NVARCHAR(5), @c_StorerKey NVARCHAR(15), @c_SKU  NVARCHAR(20), @c_UOM NVARCHAR(10), @c_HostWHCode NVARCHAR(10)'
          +', @n_UOMBase INT, @n_QtyLeftToFulfill INT, @c_Orderkey NVARCHAR(10), @c_OrderLineNumber NVARCHAR(5), @c_Loadkey NVARCHAR(10), @c_Wavekey NVARCHAR(10)'
          +',@c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18), @d_Lottable04 DATETIME, @d_Lottable05 DATETIME'
          +',@c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30), @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30)'
          +',@c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME'
          +',@n_OrderMinShelfLife INT, @n_ConsigneeSkuMinShelfLife INT,@n_ConsigneeSkuGroupMinShelfLife INT'
          +',@n_SkuOutGoingMinShelfLife INT, @n_StorerSkuMinShelfLife INT'
          +',@c_ID NVARCHAR(18), @c_LocationCategory NVARCHAR(10)'

      EXEC sp_executesql @c_SQL
                        ,@c_SQLParms 
                        ,@c_Facility    
                        ,@c_StorerKey   
                        ,@c_SKU         
                        ,@c_UOM         
                        ,@c_HostWHCode  
                        ,@n_UOMBase     
                        ,@n_QtyLeftToFulfill 
                        ,@c_Orderkey 
                        ,@c_OrderLineNumber 
                        ,@c_Loadkey   
                        ,@c_Wavekey   
                        ,@c_Lottable01                                   
                        ,@c_Lottable02                                   
                        ,@c_Lottable03                                   
                        ,@d_Lottable04                                   
                        ,@d_Lottable05                                   
                        ,@c_Lottable06                                   
                        ,@c_Lottable07                                   
                        ,@c_Lottable08                                   
                        ,@c_Lottable09                                   
                        ,@c_Lottable10                                   
                        ,@c_Lottable11                                   
                        ,@c_Lottable12                                   
                        ,@d_Lottable13                                   
                        ,@d_Lottable14                                   
                        ,@d_Lottable15                                   
                        ,@n_OrderMinShelfLife                            
                        ,@n_ConsigneeSkuMinShelfLife                     
                        ,@n_ConsigneeSkuGroupMinShelfLife                
                        ,@n_SkuOutGoingMinShelfLife                      
                        ,@n_StorerSkuMinShelfLife                        
                        ,@c_ID                                           
                        ,@c_LocationCategory                                      

      OPEN CURSOR_AVAILABLECFG

      FETCH NEXT FROM CURSOR_AVAILABLECFG INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable

      WHILE (@@FETCH_STATUS <> -1) AND (@n_QtyLeftToFulfill > 0)
      BEGIN
         IF NOT EXISTS(SELECT 1 FROM #TMP_LOT WHERE Lot = @c_Lot)
         BEGIN
           INSERT INTO #TMP_LOT (Lot, QtyAvailable)
           SELECT LOTXLOCXID.Lot
               , SUM(LOTXLOCXID.Qty - LOTXLOCXID.QtyAllocated - LOTXLOCXID.QtyPicked - LOTXLOCXID.QtyReplen)  
           FROM LOTXLOCXID (NOLOCK)
           JOIN LOT (NOLOCK) ON (LOTxLOCxID.Lot = LOT.Lot)
           JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
           JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
           WHERE LOTXLOCXID.Lot = @c_Lot
           AND   LOT.Status = 'OK'
           AND   ID.Status = 'OK'
           AND   LOC.Status = 'OK'
           AND   LOC.LocationFlag NOT IN ('HOLD','DAMAGE')
           AND   LOC.Facility = @c_Facility       
           GROUP BY LOTXLOCXID.Lot      
         END
         
         SET @n_LotQtyAvailable = 0

         SELECT @n_LotQtyAvailable = QtyAvailable
         FROM #TMP_LOT
         WHERE Lot = @c_Lot

         IF @n_LotQtyAvailable < @n_QtyAvailable
         BEGIN
            IF @c_UOM = '1'
               SET @n_QtyAvailable = 0
            ELSE
               SET @n_QtyAvailable = @n_LotQtyAvailable
         END

         IF @c_UOM = '1' AND @c_FullPalletByLocFlag = 'Y' --Pallet
         BEGIN
            SET @n_NoOfLot = 0

            SELECT @n_NoOfLot = COUNT(DISTINCT LLI.Lot)
            FROM LOTXLOCXID LLI (NOLOCK)
            WHERE LLI.Loc = @c_LOC
            AND LLI.ID = @c_ID
            AND LLI.Storerkey = @c_Storerkey
            AND LLI.Sku = @c_Sku

            IF @n_QtyLeftToFulfill >= @n_QtyAvailable
               AND @n_NoOfLot = 1 -- if multi lot per sku/loc/id then proceed to next strategy allocation by carton
            BEGIN
               SET @n_QtyToTake = @n_QtyAvailable
            END
            ELSE
            BEGIN
               SET @n_QtyToTake = 0
            END
         END
         ELSE
         BEGIN
            IF @n_UOMBase > 0        
            BEGIN
               IF @n_QtyLeftToFulfill >= @n_QtyAvailable
               BEGIN
                  SET @n_QtyToTake = Floor(@n_QtyAvailable / @n_UOMBase) * @n_UOMBase
               END
               ELSE
               BEGIN
                  SET @n_QtyToTake = Floor(@n_QtyLeftToFulfill / @n_UOMBase) * @n_UOMBase
               END
            END                     
         END

         IF @n_QtyToTake > 0
         BEGIN
            UPDATE #TMP_LOT
            SET QtyAvailable = QtyAvailable - @n_QtyToTake
            WHERE Lot = @c_Lot

            IF @n_QtyToTake = @n_QtyAvailable AND @c_UOM = '1' AND @c_FullPalletByLocFlag = 'Y'
               SET @c_OtherValue = '@c_FULLPALLET=Y'
            ELSE
               SET @c_OtherValue = '1'

            SET @c_Lot       = RTRIM(@c_Lot)
            SET @c_Loc       = RTRIM(@c_Loc)
            SET @c_ID        = RTRIM(@c_ID)

            EXEC isp_Insert_Allocate_Candidates
               @c_Lot = @c_Lot
            ,  @c_Loc = @c_Loc
            ,  @c_ID  = @c_ID
            ,  @n_QtyAvailable = @n_QtyToTake
            ,  @c_OtherValue = @c_OtherValue

            SET @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - @n_QtyToTake
         END

         FETCH NEXT FROM CURSOR_AVAILABLECFG INTO @c_LOT, @c_LOC, @c_ID, @n_QtyAvailable
      END
      CLOSE CURSOR_AVAILABLECFG
      DEALLOCATE CURSOR_AVAILABLECFG

      EXEC isp_Cursor_Allocate_Candidates @n_SkipPreAllocationFlag = 1    
   END
   ELSE
   BEGIN
      SET @c_SQL = N'DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR'
                 + ' SELECT LOTxLOCxID.LOT, LOTxLOCxID.LOC,LOTxLOCxID.ID'
                 + ' ,QTYAVAILABLE = LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN'
                 + ' ,''1'''
                 + ' FROM LOTxLOCxID (NOLOCK)'
                 + ' JOIN LOTATTRIBUTE (NOLOCK) ON LOTxLOCxID.Lot = LOTATTRIBUTE.Lot'
                 + ' JOIN LOT (NOLOCK) ON LOTxLOCxID.Lot = LOT.Lot'
                 + ' JOIN LOC (NOLOCK) ON LOTxLOCxID.Loc = LOC.LOC'
                 + ' JOIN ID (NOLOCK) ON LOTxLOCxID.Id = ID.ID'
                 + ' JOIN SKUXLOC (NOLOCK) ON LOTxLOCxID.Storerkey =  SKUXLOC.Storerkey'
                 +                      ' AND LOTxLOCxID.Sku = SKUXLOC.Sku AND LOTxLOCxID.Loc =  SKUXLOC.Loc'
                 + ' JOIN SKU (NOLOCK) ON LOTxLOCxID.Storerkey = SKU.Storerkey AND SKU.Sku =  SKUXLOC.Sku'
                 + ' JOIN STORER (NOLOCK) ON LOTxLOCxID.Storerkey = STORER.Storerkey'
                 + ' JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey'
                 + ' WHERE LOTxLOCxID.Storerkey = @c_Storerkey'   
                 + ' AND LOTxLOCxID.Sku = @c_Sku'
                 + ' AND LOC.Facility = @c_Facility'
                 + ' AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN) > 0'
                 + ' AND LOT.STATUS = ''OK'' AND LOC.STATUS = ''OK'' AND ID.STATUS = ''OK'''
                 + ' AND LOC.LocationFlag NOT IN (''HOLD'',''DAMAGE'')'
                 + ' ' + ISNULL(RTRIM(@c_Condition),'') 
                 + ' ' + @c_SortBy

      SET @c_SQLParms = N'@c_Facility NVARCHAR(5), @c_StorerKey NVARCHAR(15), @c_SKU  NVARCHAR(20), @c_UOM NVARCHAR(10), @c_HostWHCode NVARCHAR(10)'
          +', @n_UOMBase INT, @n_QtyLeftToFulfill INT, @c_Orderkey NVARCHAR(10), @c_OrderLineNumber NVARCHAR(5), @c_Loadkey NVARCHAR(10), @c_Wavekey NVARCHAR(10)'
          +',@c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18), @d_Lottable04 DATETIME, @d_Lottable05 DATETIME'
          +',@c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30), @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30)'
          +',@c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME'
          +',@n_OrderMinShelfLife INT, @n_ConsigneeSkuMinShelfLife INT,@n_ConsigneeSkuGroupMinShelfLife INT'
          +',@n_SkuOutGoingMinShelfLife INT, @n_StorerSkuMinShelfLife INT'
          +',@c_ID NVARCHAR(18), @c_LocationCategory NVARCHAR(10)'
          --+',@c_UDF01 NVARCHAR(30), @c_UDF02 NVARCHAR(30), @c_UDF03 NVARCHAR(30), @c_UDF04 NVARCHAR(30), @c_UDF05 NVARCHAR(30)'

      EXEC sp_executesql @c_SQL 
                        ,@c_SQLParms   
                        ,@c_Facility   
                        ,@c_StorerKey  
                        ,@c_SKU        
                        ,@c_UOM        
                        ,@c_HostWHCode 
                        ,@n_UOMBase    
                        ,@n_QtyLeftToFulfill 
                        ,@c_Orderkey 
                        ,@c_OrderLineNumber 
                        ,@c_Loadkey  
                        ,@c_Wavekey  
                        ,@c_Lottable01                                   
                        ,@c_Lottable02                                   
                        ,@c_Lottable03                                   
                        ,@d_Lottable04                                   
                        ,@d_Lottable05                                   
                        ,@c_Lottable06                                   
                        ,@c_Lottable07                                   
                        ,@c_Lottable08                                   
                        ,@c_Lottable09                                   
                        ,@c_Lottable10                                   
                        ,@c_Lottable11                                   
                        ,@c_Lottable12                                   
                        ,@d_Lottable13                                   
                        ,@d_Lottable14                                   
                        ,@d_Lottable15                                   
                        ,@n_OrderMinShelfLife                            
                        ,@n_ConsigneeSkuMinShelfLife                     
                        ,@n_ConsigneeSkuGroupMinShelfLife                
                        ,@n_SkuOutGoingMinShelfLife                      
                        ,@n_StorerSkuMinShelfLife                        
                        ,@c_ID                                           
                        ,@c_LocationCategory                                       
   END
 
   IF CURSOR_STATUS('GLOBAL' , 'CURSOR_AVAILABLECFG') in (0 , 1)
   BEGIN
      CLOSE CURSOR_AVAILABLECFG
      DEALLOCATE CURSOR_AVAILABLECFG
   END
END
GO
GRANT EXECUTE ON  [dbo].[mspALMLP01] TO [NSQL]
GO


