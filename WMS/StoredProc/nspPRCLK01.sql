SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: nspPRCLK01                                         */
/* Creation Date: 01-APR-2024                                           */
/* Copyright: MAERSK                                                    */
/* Written by: NJOW                                                     */
/*                                                                      */
/* Purpose: WMS-24584-Preallocation Configure by codelkup               */
/*          (Work with nspALCLK01)  Non-SkipPreallocation               */
/*                                                                      */
/* Called By: nspOrderProcessing                                        */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Rev  Purposes                                   */      
/* 01-APR-2024 NJOW     1.0  DEVOPS Combine Script                      */
/************************************************************************/

CREATE OR ALTER PROC nspPRCLK01
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
/* 
   Codelkup Setup  
   --------------    
   Listname: nspPRCLK01 
   Short: PreallocateStrategykey(optional)
   Storerkey: <Storer> (if setup short(PreAllocateStrategykey), storerkey is optional either key in storerkey or PreallocateStrategykey)
   code2: for UOM(optional)
   
   Code                 Description                                                      Notes UDF01  UDF02  UDF03  UDF04  UDF05  
   -----------------------------------------------------------------------------------------------------------------------------
   ALLOCATEHOLD         Allow allocate from Hold Inventory(default N)                          Y/N                                
   FROMPBULKLOC         Allocate from bulk only (default N)                                    Y/N                                
   FROMPICKLOC          Allocate from pick only (default N)                                    Y/N                                
   CONDITION            Addtional preallocation retrieve condition                       SQL                                     
   PRECONDITION         Addtional preallocatedqty retrieve condition                     SQL                                     
   SORTING              Custom sorting                                                   SQL                                     
   LOCTYPESEQ           Custom allocate by locationtype and sequence                           Locationtype by sequence (UDF01-05)
   SHELFLIFE            Allocation Check shelflife (default N)                                 E/M/N   
   LISTNAME             Refer the allocation setting from user created listname                <Listname>
   ALLOCATEQTYREPLEN    Allow allocate qty reserved for replenish at bulk loc                  Y/N   
   SKIPLOTTABLEFILTER   Allow skip filtering for certain lottable 01-15                        01-15
   FORCELOTTABLEFILTER  Force filtering for certain lottable 01-05 to include empty lottable   01-15   
                 
   Notes:
   1. Code2 - Optional UOM. If defined, the setup only apply to the same UOM in the strategy otherwise apply to all UOM
      using this pickcode. The values are 1 to 7 or empty.
   2. UDF01 is the Y or N flag for enable or disable ALLOCATEHOLD, FROMPICKLOC and FROMBULKLOC. If ALLOCATEHOLD is not setup, 
      will not allocate hold stock.
   3. If FROMPICKLOC and FROMBULKLOC are not enabled/setup, it will allocate from both BULK and PICK. Pick Loc is determind 
      by SKUXLOC.Locationtype IN('PICK','CASE'). 
   4. SQL for CONDITION can be any filtering condition based on tables LOT, LOTATTRIBUTE, LOTxLOCxID, SKUXLOC, LOC, ID. 
      e.g. LOC.LocationCategory='DYNPPICK' AND LOC.LocLevel=1   
   5. SQL for PRECONDITION can be any filtering condition based on table PREALLOCATEPICKDETAIL.
      e.g. PREALLOCATEPICKDETAIL.UOM='2'
   6. SQL for SORTING can be any field based on table LOTATTRIBUTE. Instead of field it also can be a code like FIFO or FIFO. 
      The default sorting is FIFO. e.g. LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable02 DESC  e.g. FEFO
   7. For LOCTYPESEQ, set the LOC.LocationType in UDF01-05. If set only allocate from the locationtype and follow the UDF field 
      sequence. Should set for both preallocation and allocation strategy.
   8.  Short - Optional preallocationstrategykey. if defined, the setup only apply to the same preallocationstrategy of the sku otherwise apply to all.      
   9.  Storerkey - storer. The setup only apply to the same storer of the sku.
       If Short is defined, storer is optional. if key-in storerkey, the setup apply to the same storer and preallocationstrategykey
       if key-in preallocationstrageykey, the setup apply to the same preallocationstrategykey of all storer.
   10. For SHELFLIFE. Set E to enable check shelflife by expiry date in lottable04, M to check by manufacturing date, N is no checking.                   
   11. For LISTNAME. Only need to provide storerkey and UDF01. This option only can apply to listname 'nspPRCLK01'
   12. For SKIPLOTTABLEFILTER, include the lottable need to skip filtering in the list delimited by comman from 01 to 15. e.g. 02,04,08
   13. For FORCELOTTABLEFILTER, include the lottable need to force filtering in the list delimited by comman from 01 to 15. e.g. 02,04,08
       The specific Orderdetail's Lottable value must exactly match with the lotattribute's lottable including empty lottable filter.
         
   Shelflife logic and sequence
   ----------------------------
   1. Order detail shelflife (orderdetail.shelflife) - if Orderinfo4PreAllocation turn on with discrete allocation
   2. Consignee+Sku shelflife ((Consingneekey=Storer.MinShelflife/100) * Sku.Shelflife) - if Orderinfo4PreAllocation turn on with discrete allocation
   3. Consigneegroup + skugroup shelflife (Doclkup.consigneegroup + Doclkup.skugroup) - if Orderinfo4PreAllocation turn on with discrete allocation
   4. Sku outgoing shelflife (Sku.SUSR2)
   5. Storer+Sku shelflife ((Storer.MinShelflife/100) * Sku.Shelflife)
*/
   
   DECLARE @n_StorerSkuMinShelfLife INT,
           @n_ConsigneeSkuMinShelfLife INT,
           --@n_ConsigneeMinShelfLife INT,
           @n_SkuOutGoingMinShelfLife INT,
           @n_OrderMinShelfLife INT,
           @n_ConsigneeSkuGroupMinShelfLife INT,
           @c_ContinueChkShelfLife NCHAR(1),
           @n_Cnt INT,
           @c_Condition NVARCHAR(MAX),            
           @c_PreCondition NVARCHAR(MAX),
           @c_SQLStatement NVARCHAR(MAX), 
             @c_SQLParms        NVARCHAR(MAX)='', 
           @C_SortBy          NVARCHAR(2000),
           @c_Orderkey        NVARCHAR(10),
           @c_OrderLineNumber NVARCHAR(5),
           @c_ID              NVARCHAR(18),
           @c_UDF01 NVARCHAR(30),
           @c_UDF02 NVARCHAR(30),
           @c_UDF03 NVARCHAR(30),
           @c_UDF04 NVARCHAR(30),
           @c_UDF05 NVARCHAR(30),
           @c_LocTypeFlag NCHAR(1),
           @c_LocTypeList NVARCHAR(1000),           
           @c_AllocateHoldFlag NCHAR(1),
           @c_AllocateQtyReplenFlag NCHAR(1),           
           @c_SortingFlag NCHAR(1),
           @c_Sortfields NVARCHAR(1000),
           @c_LocTypeSort NVARCHAR(2000),
           @c_CLKCondition NVARCHAR(MAX),
           @c_CLKConditionFlag NCHAR(1),
           @c_FromPickLocFlag NCHAR(1),
           @c_FromBulkLocFlag NCHAR(1),
           @c_PreConditionFlag NCHAR(1),
           @c_PreAllocateStrategyKey NVARCHAR(10),
           @c_ShelfLifeFlag       NCHAR(1),
           @c_ListName         NVARCHAR(10),
           @c_SkipLottableFilter  NVARCHAR(60), 
           @c_ForceLottableFilter NVARCHAR(60), 
           @c_Wavekey             NVARCHAR(10)='',
           @c_Loadkey             NVARCHAR(10)='',
           @c_key3                NVARCHAR(10)='',
           @c_StorerDefaultAllocStrategy NVARCHAR(30)=''
                                               
    SET @c_LocTypeList = ''
    SET @c_LocTypeSort = ''
    SET @c_CLKCondition = ''
    SET @c_PreCondition = ''
    SET @c_Condition = ''
   --SET @n_ConsigneeMinShelfLife = 0  
   SET @n_SkuOutGoingMinShelfLife = 0
   SET @n_OrderMinShelfLife = 0
   SET @n_StorerSkuMinShelfLife = 0
   SET @n_ConsigneeSkuMinShelfLife = 0
   SET @n_ConsigneeSkuGroupMinShelfLife = 0      
   SET @c_ContinueChkShelfLife = 'N'
   SET @c_SkipLottableFilter = '' 
   SET @c_ForceLottableFilter = ''    
   
   SELECT @c_StorerDefaultAllocStrategy = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'StorerDefaultAllocStrategy') 
     
   IF LEN(@c_OtherParms) > 0 
   BEGIN
      SELECT @c_OrderLineNumber = SUBSTRING(@c_OtherParms, 11, 5)
      SELECT @c_Key3 = SUBSTRING(@c_OtherParms, 16, 1)
      
      IF ISNULL(@c_OrderLineNumber,'') <> ''
      BEGIN
         SELECT @c_Orderkey = LEFT(@c_OtherParms, 10) --Discrete by order
                  
         SELECT @c_ID = ID
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
          SELECT @c_Loadkey = LEFT(@c_OtherParms, 10)  --Load conso
          
          SELECT @c_Wavekey = MAX(WD.Wavekey)
          FROM LOADPLANDETAIL LPD (NOLOCK)
          JOIN WAVEDETAIL WD (NOLOCK) ON LPD.Orderkey = WD.Orderkey
          AND LPD.Loadkey = @c_Loadkey
          HAVING COUNT(DISTINCT WD.Wavekey) = 1
      END

      IF ISNULL(@c_OrderLineNumber,'')='' AND ISNULL(@c_key3,'')='W'       
      BEGIN
          SELECT @c_Wavekey = LEFT(@c_OtherParms, 10) --Wave conso
      END               
   END
   
   DECLARE @TMP_CODELKUP TABLE (
       [LISTNAME] [nvarchar](10) NULL,
       [Code] [nvarchar](30) NULL,
       [Description] [nvarchar](250) NULL,
       [Short] [nvarchar](10) NULL,
       [Long] [nvarchar](250) NULL,
       [Notes] [nvarchar](4000) NULL,
       [Notes2] [nvarchar](4000) NULL,
       [Storerkey] [nvarchar](50) NULL,
       [UDF01] [nvarchar](60) NULL,
       [UDF02] [nvarchar](60) NULL,
       [UDF03] [nvarchar](60) NULL,
       [UDF04] [nvarchar](60) NULL,
       [UDF05] [nvarchar](60) NULL,
       [code2] [nvarchar](30) NULL)   
       
   IF ISNULL(@c_Wavekey,'') <> ''
   BEGIN
        --Get strategy from wave
        SELECT @c_PreallocateStrategykey = PALS.PreAllocateStrategyKey
        FROM WAVE W (NOLOCK)
        JOIN STRATEGY SY (NOLOCK) ON W.Strategykey = SY.Strategykey
        JOIN PREALLOCATESTRATEGY PALS (NOLOCK) ON SY.PreAllocateStrategyKey = PALS.PreAllocateStrategyKey
        AND W.Wavekey = @c_Wavekey
        AND W.Strategykey <> ''
        AND W.Strategykey IS NOT NULL
   END             
   
   IF ISNULL(@c_PreallocateStrategykey,'') = '' AND ISNULL(@c_Loadkey,'') <> ''
   BEGIN
        --Get strategy from load defaultstrategykey
        SELECT TOP 1 @c_PreallocateStrategykey = PALS.PreAllocateStrategyKey       
        FROM LOADPLAN LP (NOLOCK)
        JOIN LOADPLANDETAIL LPD (NOLOCK) ON LP.Loadkey = LPD.Loadkey
        JOIN ORDERS O (NOLOCK) ON LPD.Orderkey = O.Orderkey
        JOIN STORER S (NOLOCK) ON O.Storerkey = S.Storerkey
        JOIN STRATEGY SY (NOLOCK) ON S.Strategykey = SY.Strategykey
        JOIN PREALLOCATESTRATEGY PALS (NOLOCK) ON SY.PreAllocateStrategyKey = PALS.PreAllocateStrategyKey
        AND LP.Loadkey = @c_Loadkey
        AND LP.DefaultStrategykey = 'Y'
        AND S.Strategykey <> ''
        AND S.Strategykey IS NOT NULL
   END   
   
   IF ISNULL(@c_PreallocateStrategykey,'') = '' AND ISNULL(@c_StorerDefaultAllocStrategy,'') <> ''
   BEGIN
        --Get strategy from storerconfig StorerDefaultAllocStrategy
      SELECT @c_PreallocateStrategykey = PALS.PreAllocateStrategyKey
      FROM STRATEGY SY (NOLOCK)
        JOIN PREALLOCATESTRATEGY PALS (NOLOCK) ON SY.PreAllocateStrategyKey = PALS.PreAllocateStrategyKey
        WHERE SY.Strategykey = @c_StorerDefaultAllocStrategy      
   END
   
   IF ISNULL(@c_PreallocateStrategykey,'') = ''  
   BEGIN
        --Get strategy from sku
      SELECT @c_PreallocateStrategykey = STRATEGY.PreAllocateStrategykey
      FROM SKU (NOLOCK)
      JOIN STRATEGY (NOLOCK) ON SKU.Strategykey = STRATEGY.Strategykey
      WHERE SKU.Storerkey = @c_Storerkey
      AND SKU.Sku = @c_Sku
   END   
      
   INSERT INTO @TMP_CODELKUP (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)
   SELECT CODELKUP.Listname,
          CODELKUP.Code,
          CODELKUP.Description,
          CODELKUP.Short,
          CODELKUP.Long,
          CODELKUP.Notes,
          CODELKUP.Notes2,
          CODELKUP.Storerkey,
          CODELKUP.UDF01,
          CODELKUP.UDF02,
          CODELKUP.UDF03,
          CODELKUP.UDF04,
          CODELKUP.UDF05,
          CODELKUP.Code2          
   FROM CODELKUP (NOLOCK)
   LEFT JOIN STORER (NOLOCK) ON CODELKUP.Storerkey = STORER.Storerkey
   WHERE CODELKUP.Listname = 'nspPRCLK01'
   AND ISNULL(CODELKUP.Storerkey,'') = CASE WHEN ISNULL(CODELKUP.Short,'') = @c_PreallocateStrategykey AND STORER.Storerkey IS NULL THEN ISNULL(CODELKUP.Storerkey,'') ELSE @c_Storerkey END --if setup short and no setup storer ignore storer otherwise by storer. 
   AND ISNULL(CODELKUP.Short,'') = CASE WHEN ISNULL(CODELKUP.Short,'') <> '' THEN @c_PreallocateStrategykey ELSE ISNULL(CODELKUP.Short,'') END --if short setup must match preallocate strategykey
   
   SET @c_ListName = ''
   SELECT TOP 1 @c_ListName = TC.UDF01
   FROM @TMP_CODELKUP TC
   JOIN CODELKUP CL (NOLOCK) ON TC.UDF01 = CL.Listname
   WHERE CL.Code ='LISTNAME'

   --Get the configuration from user created listname
   IF ISNULL(@c_ListName,'') <> ''
   BEGIN
      INSERT INTO @TMP_CODELKUP (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, Code2)
      SELECT CODELKUP.Listname,
             CODELKUP.Code,
             CODELKUP.Description,
             CODELKUP.Short,
             CODELKUP.Long,
             CODELKUP.Notes,
             CODELKUP.Notes2,
             CODELKUP.Storerkey,
             CODELKUP.UDF01,
             CODELKUP.UDF02,
             CODELKUP.UDF03,
             CODELKUP.UDF04,
             CODELKUP.UDF05,
             CODELKUP.Code2
      FROM CODELKUP (NOLOCK)
      LEFT JOIN STORER (NOLOCK) ON CODELKUP.Storerkey = STORER.Storerkey
      WHERE CODELKUP.Listname = @c_ListName
      AND ISNULL(CODELKUP.Storerkey,'') = CASE WHEN ISNULL(CODELKUP.Short,'') = @c_PreAllocateStrategykey AND STORER.Storerkey IS NULL THEN ISNULL(CODELKUP.Storerkey,'') ELSE @c_Storerkey END --if setup short and no setup storer ignore storer otherwise by storer.
      AND ISNULL(CODELKUP.Short,'') = CASE WHEN ISNULL(CODELKUP.Short,'') <> '' THEN @c_PreAllocateStrategykey ELSE ISNULL(CODELKUP.Short,'') END --if short setup must match PreAllocate strategykey
   END   
      
   --Retrieve codelkup loc type configurations
   SELECT TOP 1 @c_UDF01 = UDF01, 
                @c_UDF02 = UDF01,
                @c_UDF03 = UDF03,
                @c_UDF04 = UDF04,
                @c_UDF05 = UDF05
   FROM @TMP_CODELKUP
   WHERE Code = 'LOCTYPESEQ'  --retrieve by location type defined in udf01-05 by field sequence
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')  --if defined uom in code2 only apply for the specific strategy uom
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END --consider matched uom first
   
   SET @n_Cnt = @@ROWCOUNT
   
   IF @n_Cnt > 0
   BEGIN      
      IF ISNULL(@c_UDF01,'') <> '' OR ISNULL(@c_UDF02,'') <> '' OR ISNULL(@c_UDF03,'') <> '' OR ISNULL(@c_UDF04,'') <> '' OR ISNULL(@c_UDF05,'') <> ''
         SET @c_LocTypeFlag = 'Y'
   END

   --Retrieve codelkup condition
   SELECT TOP 1 @c_CLKCondition = Notes
   FROM @TMP_CODELKUP 
   WHERE Code = 'CONDITION'  --retrieve addition conditions
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')  --if defined uom in code2 only apply for the specific strategy uom
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END --consider matched uom first
   
   SET @n_Cnt = @@ROWCOUNT
   
   IF @n_Cnt > 0
   BEGIN      
      IF ISNULL(@c_CLKCondition,'') <> '' 
      BEGIN
         SET @c_CLKConditionFlag = 'Y'
      END   
   END
   
   SELECT TOP 1 @c_AllocateHoldFlag = ISNULL(UDF01,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'ALLOCATEHOLD' --allow allocate hold inventory. default is filter out hold inventory.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END

   SELECT TOP 1 @c_PreCondition = ISNULL(Notes,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'PRECONDITION' --user can define preallocate qty filtering condition. Usually for filtering UOM or Pickcode to get correct preallocate qty by location type.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END
   
   SET @n_Cnt = @@ROWCOUNT
   
   IF @n_Cnt > 0
   BEGIN      
      IF ISNULL(@c_PreCondition,'') <> '' 
      BEGIN
         SET @c_PreConditionFlag = 'Y'
      END   
   END

   SELECT TOP 1 @c_FromPickLocFlag = ISNULL(UDF01,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'FROMPICKLOC' --allocation from pick location only. default is all location type.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END

   SELECT TOP 1 @c_FromBulkLocFlag = ISNULL(UDF01,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'FROMBULKLOC' --allocation from bulk location only. default is all location type.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END

   SELECT TOP 1 @c_SortFields = ISNULL(Notes,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'SORTING' --user can define sorting fields. default is FIFO.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END

   SELECT TOP 1 @c_AllocateQtyReplenFlag = ISNULL(UDF01,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'ALLOCATEQTYREPLEN' --allow allocate qtyreplen from bulk. default is not allocate from qtyreplen.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END   
   
   SELECT TOP 1 @c_ShelfLifeFlag = ISNULL(UDF01,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'SHELFLIFE' --allocation check shelflife. default is no checking.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END
   
   SELECT TOP 1 @c_SkipLottableFilter = ISNULL(UDF01,'')  
   FROM @TMP_CODELKUP
   WHERE Code = 'SKIPLOTTABLEFILTER' --Skip lottable filtering.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END

   SELECT TOP 1 @c_ForceLottableFilter = ISNULL(UDF01,'') 
   FROM @TMP_CODELKUP
   WHERE Code = 'FORCELOTTABLEFILTER' --Force lottable filtering.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END
         
   IF ISNULL(@c_ShelfLifeFlag,'') IN('E','M')  
      SET @c_ContinueChkShelfLife = 'Y'

   IF ISNULL(@c_SortFields,'') <> ''
   BEGIN      
      SET @c_SortingFlag = 'Y'
   END
      
   IF ISNULL(@c_lot,'') <> '' AND LEFT(@c_lot,1) <> '*'
   BEGIN
      /* Get Storer Minimum Shelf Life */
      
      SELECT @n_StorerSkuMinShelfLife = ((Sku.Shelflife * Storer.MinShelflife/100) * -1)
      FROM Lot (nolock) 
      JOIN Sku (nolock) ON Lot.Storerkey = Sku.Storerkey AND Lot.Sku = Sku.Sku
      JOIN Storer (nolock) ON Lot.Storerkey = Storer.Storerkey
      WHERE Lot.Lot = @c_lot
      
      DECLARE  PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT LOT.STORERKEY,LOT.SKU,LOT.LOT ,
      QTYAVAILABLE = (LOT.QTY - LOT.QTYALLOCATED - LOT.QTYPICKED - LOT.QTYPREALLOCATED)
      FROM LOT (Nolock), Lotattribute (Nolock)
      WHERE LOT.LOT = @c_lot 
      AND Lot.Lot = Lotattribute.Lot 
      AND DateAdd(Day, @n_StorerSkuMinShelfLife, Lotattribute.Lottable04) > GetDate() 
      ORDER BY Lotattribute.Lottable05, Lot.Lot
   END
   ELSE
   BEGIN
      IF (ISNULL(@c_Lottable01,'') <> '' AND CHARINDEX('01',@c_SkipLottableFilter,1) = 0)   
         OR CHARINDEX('01',@c_ForceLottableFilter,1) > 0 
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE01 = RTRIM(@c_Lottable01) "        
      END
      
      IF (ISNULL(@c_Lottable02,'') <> '' AND CHARINDEX('02',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('02',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE02 = RTRIM(@c_Lottable02) "        
      END
      
      IF (ISNULL(@c_Lottable03,'') <> '' AND CHARINDEX('03',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('03',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE03 = RTRIM(@c_Lottable03) "         
      END
      
      IF CONVERT(char(10), @d_Lottable04, 103) <> "01/01/1900" AND @d_Lottable04 IS NOT NULL AND CHARINDEX('04',@c_SkipLottableFilter,1) = 0  
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE04 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable04, 106)) " 
      END
      ELSE IF CHARINDEX('04',@c_ForceLottableFilter,1) > 0 
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900 "
      END
      
      IF CONVERT(char(10), @d_Lottable05, 103) <> "01/01/1900" AND @d_Lottable05 IS NOT NULL AND CHARINDEX('05',@c_SkipLottableFilter,1) = 0  
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE05 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable05, 106)) " 
      END
      ELSE IF CHARINDEX('05',@c_ForceLottableFilter,1) > 0 
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE05 IS NULL OR CONVERT(CHAR(10), LOTTABLE05, 103) = '01/01/1900 "
      END
      
      IF (ISNULL(@c_Lottable06,'') <> '' AND CHARINDEX('06',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('06',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'')+ ' AND Lottable06 = RTRIM(@c_Lottable06) '             
      END
      
      IF (ISNULL(@c_Lottable07,'') <> '' AND CHARINDEX('07',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('07',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable07 = RTRIM(@c_Lottable07) '            
      END
      
      IF (ISNULL(@c_Lottable08,'') <> '' AND CHARINDEX('08',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('08',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable08 = RTRIM(@c_Lottable08) '            
      END
      
      IF (ISNULL(@c_Lottable09,'') <> '' AND CHARINDEX('09',@c_SkipLottableFilter,1) = 0)
         OR CHARINDEX('09',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable09 = RTRIM(@c_Lottable09) '           
      END
      
      IF (ISNULL(@c_Lottable10,'') <> '' AND CHARINDEX('10',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('10',@c_ForceLottableFilter,1) > 0     
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable10 = RTRIM(@c_Lottable10) '            
      END
      
      IF (ISNULL(@c_Lottable11,'') <> '' AND CHARINDEX('11',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('11',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable11 = RTRIM(@c_Lottable11) '            
      END
      
      IF (ISNULL(@c_Lottable12,'') <> '' AND CHARINDEX('12',@c_SkipLottableFilter,1) = 0)  
         OR CHARINDEX('12',@c_ForceLottableFilter,1) > 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable12 = RTRIM(@c_Lottable12) '           
      END
      
      IF CONVERT(char(10), @d_Lottable13, 103) <> '01/01/1900' AND @d_Lottable13 IS NOT NULL AND CHARINDEX('13',@c_SkipLottableFilter,1) = 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable13 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable13, 106)) ' 
      END
      ELSE IF CHARINDEX('13',@c_ForceLottableFilter,1) > 0 
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE13 IS NULL OR CONVERT(CHAR(10), LOTTABLE13, 103) = '01/01/1900 "
      END   
      
      IF CONVERT(char(10), @d_Lottable14, 103) <> '01/01/1900' AND @d_Lottable14 IS NOT NULL AND CHARINDEX('14',@c_SkipLottableFilter,1) = 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable14 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable14, 106)) ' 
      END
      ELSE IF CHARINDEX('14',@c_ForceLottableFilter,1) > 0 
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE14 IS NULL OR CONVERT(CHAR(10), LOTTABLE14, 103) = '01/01/1900 "
      END
      
      IF CONVERT(char(10), @d_Lottable15, 103) <> '01/01/1900' AND @d_Lottable15 IS NOT NULL AND CHARINDEX('15',@c_SkipLottableFilter,1) = 0  
      BEGIN
         SET @c_Condition = ISNULL(RTRIM(@c_Condition),'') + ' AND Lottable15 = RTRIM(CONVERT( NVARCHAR(20), @d_Lottable15, 106)) ' 
      END
      ELSE IF CHARINDEX('15',@c_ForceLottableFilter,1) > 0 
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTTABLE15 IS NULL OR CONVERT(CHAR(10), LOTTABLE15, 103) = '01/01/1900 "
      END
            
      ------Order shelflife (orderdetail.shelflife)
      IF LEFT(@c_lot,1) = '*' AND @c_ContinueChkShelfLife = 'Y'
      BEGIN                
         SELECT @n_OrderMinShelfLife = CONVERT(INT, SUBSTRING(@c_lot, 2, 9))
         
         IF ISNULL(@n_OrderMinShelfLife,0) > 0 
         BEGIN
            IF @c_ShelfLifeFlag = 'E'
            BEGIN
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_OrderMinShelfLife "    
                                     + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "                            
            END
            ELSE IF @c_ShelfLifeFlag = 'M'
            BEGIN
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_OrderMinShelfLife "    
                                     + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "                            
            END
            
            SET @c_ContinueChkShelfLife = 'N'
         END
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
            SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= "  
            + CAST(@n_ConsigneeMinShelfLife AS NVARCHAR(10)) + " OR Lottable04 IS NULL OR CONVERT(char(10), Lottable04, 103) = '01/01/1900') "  
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
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_ConsigneeSkuMinShelfLife "   --(Wan01)
                                   + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "
            END
            ELSE IF @c_ShelfLifeFlag = 'M'
            BEGIN
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_ConsigneeSkuMinShelfLife "   --(Wan01)
                                   + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "
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
                  SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_ConsigneeSkuGroupMinShelfLife "    --(Wan01)
                                      + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "                                         --(Wan01)
               END
               ELSE IF @c_ShelfLifeFlag = 'M'
               BEGIN
                  SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_ConsigneeSkuGroupMinShelfLife "    --(Wan01)
                                      + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "                                         --(Wan01)
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
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_SkuOutGoingMinShelfLife "   
                                    + "OR Lottable04 IS NULL OR CONVERT(char(10), Lottable04, 103) = '01/01/1900') "                                  
            END
            ELSE IF @c_ShelfLifeFlag = 'M'
            BEGIN
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_SkuOutGoingMinShelfLife "   
                                    + " OR Lottable04 IS NULL OR CONVERT(char(10), Lottable04, 103) = '01/01/1900') "                                 
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
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, GETDATE(), LOTTABLE04) >= @n_StorerSkuMinShelfLife "   
                                   + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "
            END
            ELSE IF @c_ShelfLifeFlag = 'M'
            BEGIN
               SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND ( DATEDIFF(day, LOTTABLE04, GETDATE()) <= @n_StorerSkuMinShelfLife "   
                                   + "OR Lottable04 IS NULL OR CONVERT(CHAR(10), LOTTABLE04, 103) = '01/01/1900') "
            END
            
            SET @c_ContinueChkShelfLife = 'N'
         END       
      END
         
      IF ISNULL(@c_ID,'') <> ''
      BEGIN
          SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTxLOCxID.Id = RTRIM(@c_ID) "
      END  
      
      IF @c_LocTypeFlag = 'Y'
      BEGIN
         IF ISNULL(@c_UDF01,'') <> ''
            SELECT @c_LocTypeList =  @c_LocTypeList + " RTRIM(@c_UDF01),"                            
         
         IF ISNULL(@c_UDF02,'') <> ''
            SELECT @c_LocTypeList =  @c_LocTypeList + " RTRIM(@c_UDF02),"                            
         
         IF ISNULL(@c_UDF03,'') <> ''
            SELECT @c_LocTypeList =  @c_LocTypeList + " RTRIM(@c_UDF03),"                            
         
         IF ISNULL(@c_UDF04,'') <> ''
            SELECT @c_LocTypeList =  @c_LocTypeList + " RTRIM(@c_UDF04),"                            
         
         IF ISNULL(@c_UDF05,'') <> ''
            SELECT @c_LocTypeList =  @c_LocTypeList + " RTRIM(@c_UDF05),"                            
                      
          SET @c_LocTypeList = LEFT(@c_LocTypeList, LEN(@c_LocTypeList) - 1)             
          
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOC.LocationType IN (" + RTRIM(@c_LocTypeList) + ") "
         
         SELECT @c_LocTypeSort = " CASE WHEN MIN(LOC.LocationType) = '" + RTRIM(ISNULL(@c_UDF01,'')) + "' THEN 1 " +
                                      " WHEN MIN(LOC.LocationType) = '" + RTRIM(ISNULL(@c_UDF02,'')) + "' THEN 2 " +
                                      " WHEN MIN(LOC.LocationType) = '" + RTRIM(ISNULL(@c_UDF03,'')) + "' THEN 3 " +
                                      " WHEN MIN(LOC.LocationType) = '" + RTRIM(ISNULL(@c_UDF04,'')) + "' THEN 4 " +
                                      " WHEN MIN(LOC.LocationType) = '" + RTRIM(ISNULL(@c_UDF05,'')) + "' THEN 5 ELSE 6 END, " 
      END
      
      IF @c_CLKConditionFlag = 'Y'
      BEGIN
          IF LEFT(LTRIM(@c_CLKCondition),3) <> 'AND'
             SET @c_CLKCondition = ' AND ' + RTRIM(LTRIM(@c_CLKCondition))
      END

      IF @c_PreConditionFlag = 'Y'
      BEGIN
          IF LEFT(LTRIM(@c_PreCondition),3) <> 'AND'
             SET @c_PreCondition = ' AND ' + RTRIM(LTRIM(@c_PreCondition))
      END
      
      IF ISNULL(@c_AllocateHoldFlag,'') <> 'Y'
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOT.STATUS = 'OK'  " +   
                              " AND LOC.STATUS = 'OK' AND ID.STATUS = 'OK' " +     
                              " AND LOC.LocationFlag = 'NONE' " 
      END
            
      IF @c_FromPickLocFlag = 'Y'
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND SKUXLOC.LocationType IN('PICK','CASE') " 
      END
      ELSE IF @c_FromBulkLocFlag = 'Y'
      BEGIN
         SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND SKUXLOC.LocationType NOT IN('PICK','CASE') " 
      END
      
      IF @c_SortingFlag = 'Y'
      BEGIN
          IF @c_SortFields =  'FIFO'
            SET @c_SortBy = " ORDER BY " + RTRIM(@c_LocTypeSort) + " Lotattribute.Lottable05, Lotattribute.Lot " 
         ELSE IF @c_SortFields =  'FEFO'
            SET @c_SortBy = " ORDER BY " + RTRIM(@c_LocTypeSort) + " Lotattribute.Lottable04, Lotattribute.Lot " 
          ELSE            
            SET @c_SortBy = " ORDER BY " + RTRIM(@c_LocTypeSort) + RTRIM(@c_SortFields) + " "
      END
      ELSE   
         SET @c_SortBy = " ORDER BY " + RTRIM(@c_LocTypeSort) + " Lotattribute.Lottable05, Lotattribute.Lot " 

      SELECT @c_SQLStatement =  " DECLARE  PREALLOCATE_CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR " +
            " SELECT LOT.STORERKEY, LOT.SKU, LOT.LOT, " +
            CASE WHEN @c_AllocateQtyReplenFlag = 'Y' THEN 
               " QTYAVAILABLE = (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) )  "  
            ELSE
               " QTYAVAILABLE = (SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - SUM(LOTxLOCxID.QTYREPLEN) - MAX(ISNULL(P.QTYPREALLOCATED,0)) )  " 
            END +   
            " FROM LOT WITH (NOLOCK) " +
            " JOIN LOTATTRIBUTE (NOLOCK) ON (LOT.lot = LOTATTRIBUTE.lot) " +   
            " JOIN LOTxLOCxID (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT AND LOTxLOCxID.LOT = LOTATTRIBUTE.LOT) " +    
            " JOIN SKUXLOC (NOLOCK) ON (LOTxLOCxID.Storerkey = SKUXLOC.Storerkey AND LOTxLOCxID.Sku = SKUXLOC.Sku AND LOTxLOCxID.Loc = SKUXLOC.Loc) " +    
            " JOIN LOC (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC) " +    
            " JOIN ID (NOLOCK) ON (LOTxLOCxID.ID = ID.ID) " +        
            " LEFT OUTER JOIN (SELECT PREALLOCATEPICKDETAIL.lot, ORDERS.Facility, QtyPreallocated = SUM(PREALLOCATEPICKDETAIL.Qty) " +    
            "                FROM   PREALLOCATEPICKDETAIL (NOLOCK) " +
            "                JOIN   ORDERS (NOLOCK) ON PREALLOCATEPICKDETAIL.Orderkey = ORDERS.Orderkey " +  
            "                JOIN   ORDERDETAIL (NOLOCK) ON ORDERS.Orderkey = ORDERDETAIL.Orderkey AND PREALLOCATEPICKDETAIL.OrderLineNumber = ORDERDETAIL.OrderLineNumber " +  
            "                WHERE  PREALLOCATEPICKDETAIL.Storerkey = @c_storerkey " +     
            "                AND    PREALLOCATEPICKDETAIL.SKU = @c_SKU " +
            "                AND    ORDERS.FACILITY = @c_facility " +   
            "                AND    PREALLOCATEPICKDETAIL.qty > 0 " +    
                             CASE WHEN ISNULL(@c_ID,'') <> '' THEN " AND ORDERDETAIL.ID = @c_ID " ELSE " " END +  
                             ISNULL(RTRIM(@c_PreCondition),'') +
            "                GROUP BY PREALLOCATEPICKDETAIL.Lot, ORDERS.Facility) P ON LOTxLOCxID.Lot = P.Lot AND P.Facility = LOC.Facility " +   
            " WHERE LOT.STORERKEY = @c_storerkey " +   
            " AND LOT.SKU = @c_SKU " +
            " AND LOC.Facility = @c_facility "  +
            ISNULL(RTRIM(@c_Condition),'') + " " + ISNULL(RTRIM(@c_CLKCondition),'') +
            " GROUP By Lot.STORERKEY, Lot.SKU, Lot.LOT, Lotattribute.LOT, Lotattribute.Lottable01, Lotattribute.Lottable02, Lotattribute.Lottable03, Lotattribute.Lottable04, Lotattribute.Lottable05, " +
            "   Lotattribute.Lottable06, Lotattribute.Lottable07, Lotattribute.Lottable08, Lotattribute.Lottable09, Lotattribute.Lottable10, " +
            "   Lotattribute.Lottable11, Lotattribute.Lottable12, Lotattribute.Lottable13, Lotattribute.Lottable14, Lotattribute.Lottable15 " +
            CASE WHEN @c_AllocateQtyReplenFlag = 'Y' THEN 
               " HAVING SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - SUM(LOTxLOCxID.QTYPICKED) - MAX(ISNULL(P.QTYPREALLOCATED,0)) >= @n_UOMBase " 
            ELSE
               " HAVING SUM(LOTxLOCxID.QTY) - SUM(LOTxLOCxID.QTYALLOCATED) - SUM(LOTxLOCxID.QTYPICKED) - SUM(LOTxLOCxID.QTYPICKED) - SUM(LOTxLOCxID.QTYREPLEN) - MAX(ISNULL(P.QTYPREALLOCATED,0)) >= @n_UOMBase " 
            END + 
            @c_SortBy

      SET @c_SQLParms = N'@c_Facility NVARCHAR(5), @c_StorerKey NVARCHAR(15), @c_SKU  NVARCHAR(20), @c_UOM NVARCHAR(10)'
          +', @n_UOMBase INT, @n_QtyLeftToFulfill INT, @c_Orderkey NVARCHAR(10), @c_OrderLineNumber NVARCHAR(5), @c_Loadkey NVARCHAR(10), @c_Wavekey NVARCHAR(10)'
          +',@c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18), @d_Lottable04 DATETIME, @d_Lottable05 DATETIME'
          +',@c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30), @c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30)'
          +',@c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30), @d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME'
          +',@n_OrderMinShelfLife INT, @n_ConsigneeSkuMinShelfLife INT,@n_ConsigneeSkuGroupMinShelfLife INT'
          +',@n_SkuOutGoingMinShelfLife INT, @n_StorerSkuMinShelfLife INT'
          +',@c_ID NVARCHAR(18)'
          +',@c_UDF01 NVARCHAR(30), @c_UDF02 NVARCHAR(30), @c_UDF03 NVARCHAR(30), @c_UDF04 NVARCHAR(30), @c_UDF05 NVARCHAR(30)'
          
      EXEC sp_executesql @c_SQLStatement, @c_SQLParms,   
         @c_Facility   ,
         @c_StorerKey  ,
         @c_SKU        ,
         @c_UOM        ,
         @n_UOMBase    ,
         @n_QtyLeftToFulfill,
         @c_Orderkey,
         @c_OrderLineNumber,
         @c_Loadkey,  
         @c_Wavekey, 
         @c_Lottable01                                  
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
        ,@c_UDF01                                       
        ,@c_UDF02                                       
        ,@c_UDF03                                       
        ,@c_UDF04                                       
        ,@c_UDF05                                                                               
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE on nspPRCLK01 to nSQL
GO


