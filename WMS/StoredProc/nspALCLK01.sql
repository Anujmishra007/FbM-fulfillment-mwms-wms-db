SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: nspALCLK01                                         */
/* Creation Date: 01-APR-2024                                           */
/* Copyright: MAERSK                                                    */
/* Written by: NJOW                                                     */
/*                                                                      */
/* Purpose: WMS-24584-allocation Configure by codelkup                  */
/*          (Work with nspPRCLK01) Non-SkipPreallocation                */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 01-APR-2024  NJOW     1.0  DEVOPS Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[nspALCLK01]
   @c_lot NVARCHAR(10) ,
   @c_uom NVARCHAR(10) ,
   @c_HostWHCode NVARCHAR(10),
   @c_Facility NVARCHAR(5),
   @n_uombase int ,
   @n_qtylefttofulfill int,  
   @c_OtherParms NVARCHAR(200) = ''
AS
BEGIN
/* 
   Codelkup Setup  
   --------------    
   Listname: nspALCLK01 
   Short: AllocateStrategykey(optional)
   Storerkey: <Storer> (if setup short, storerkey is optional either key in storerkey or AllocateStrategykey)
   code2: for UOM(optional)
   
   Code                 Description                                                      Notes UDF01  UDF02  UDF03  UDF04  UDF05  
   -----------------------------------------------------------------------------------------------------------------------------
   ALLOCATEHOLD         Allow allocate from Hold Inventory(default N)                          Y/N             
   FROMPBULKLOC         Allocate from bulk only (default N)                                    Y/N
   FROMPICKLOC          Allocate from pick only (default N)                                    Y/N
   CONDITION            Addtional allocation retrieve condition                          SQL
   SORTING              Custom sorting                                                   SQL 
   LOCTYPESEQ           Custom allocate by locationtype and sequence                           Locationtype by sequence (UDF01-05)
   LISTNAME             Refer the allocation setting from user created listname                <Listname>
   ALLOCATEQTYREPLEN    Allow allocate qty reserved for replenish at bulk loc                  Y/N
   
   Notes:
   1. Code2 - Optional UOM. If defined, the setup only apply to the same UOM in the strategy otherwise apply to all UOM 
      using this pickcode. The values are 1 to 7 or empty.
   2. UDF01 is the Y or N flag for enable or disable ALLOCATEHOLD, FROMPICKLOC and FROMBULKLOC. If ALLOCATEHOLD is not setup,
      will not allocate hold stock.
   3. If FROMPICKLOC and FROMBULKLOC are not enabled/setup, it will allocate from both BULK and PICK. Pick Loc is determind 
      by SKUXLOC.Locationtype IN('PICK','CASE'). 
   4. SQL for CONDITION can be any filtering condition based on tables LOTxLOCxID, SKUXLOC, LOC, ID, SKU, PACK. 
      e.g. LOC.LocationCategory='DYNPPICK' AND LOC.LocLevel=1   
   5. SQL for SORTING can be any field based on tables LOTxLOCxID, SKUXLOC, LOC, ID, SKU, PACK. The default sorting is 
      Logicallocation, loc. e.g. CASE WHEN LOC.LocLevel = 1 THEN 1 ELSE 2 END, LOC.LogicalLocation, LOC.Loc   
   6. For LOCTYPESEQ, set the LOC.LocationType in UDF01-05. If set only allocate from the locationtype and follow the UDF 
      field sequence. Should set for both allocation and allocation strategy.
   7. Short - Optional allocationstrategykey. if defined, the setup only apply to the same allocationstrategy of the sku otherwise apply to all.      
   8. Storerkey - storer. The setup only apply to the same storer of the sku.
      If Short is defined, storer is optional. if key-in storerkey, the setup apply to the same storer and allocationstrategykey
   9. For LISTNAME. Only need to provide storerkey and UDF01. This option only can apply to listname 'nspALCLK01'
             
*/
   
   SET NOCOUNT ON 
   
   DECLARE @c_SQLStatement    NVARCHAR(MAX), 
             @c_SQLParms        NVARCHAR(MAX)='',    
           @c_Condition       NVARCHAR(MAX),
           @C_SortBy          NVARCHAR(2000),
           @n_Cnt             INT,
           @c_UDF01           NVARCHAR(30),
           @c_UDF02           NVARCHAR(30),
           @c_UDF03           NVARCHAR(30),
           @c_UDF04           NVARCHAR(30),
           @c_UDF05           NVARCHAR(30),
             @c_Storerkey       NVARCHAR(15),         
             @c_Sku             NVARCHAR(20),  
           @c_Orderkey        NVARCHAR(10),
           @c_OrderLineNumber NVARCHAR(5),
           @c_ID              NVARCHAR(18),
           @c_LocTypeFlag NCHAR(1),           
           @c_LocTypeList NVARCHAR(1000),
           @c_LocTypeSort NVARCHAR(2000),                                 
           @c_AllocateHoldFlag NCHAR(1),
           @c_AllocateQtyReplenFlag NCHAR(1),                      
           @c_SortingFlag NCHAR(1),
           @c_Sortfields NVARCHAR(1000),
           @c_CLKCondition NVARCHAR(MAX),
           @c_CLKConditionFlag NCHAR(1),           
           @c_FromPickLocFlag NCHAR(1),
           @c_FromBulkLocFlag NCHAR(1),
           @c_AllocateStrategyKey NVARCHAR(10),
           @c_ListName         NVARCHAR(10),
           @c_Wavekey             NVARCHAR(10)='',
           @c_Loadkey             NVARCHAR(10)='',
           @c_key3                NVARCHAR(10)='',
           @c_StorerDefaultAllocStrategy NVARCHAR(30)=''
                      
   SET @c_LocTypeList = ''
    SET @c_LOcTypeSort = ''
    SET @c_CLKCondition = ''
   SET @c_FromPickLocFlag = 'N'
   SET @c_FromBulkLocFlag = 'N'

   IF LEN(@c_OtherParms) > 0 
   BEGIN
      SELECT @c_Orderkey = LEFT(@c_OtherParms, 10)
      SELECT @c_OrderLineNumber = SUBSTRING(@c_OtherParms, 11, 5)
   END
   
   DECLARE  @TMP_CODELKUP TABLE (
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
       [code2] [nvarchar](30) NULL
       )   
   
   SELECT @c_Storerkey = Storerkey,
          @c_Sku = Sku
   FROM LOT (NOLOCK)
   WHERE Lot = @c_Lot
   
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

   IF ISNULL(@c_Wavekey,'') <> ''
   BEGIN
        --Get strategy from wave
        SELECT @c_allocateStrategykey = ALS.AllocateStrategyKey
        FROM WAVE W (NOLOCK)
        JOIN STRATEGY SY (NOLOCK) ON W.Strategykey = SY.Strategykey
        JOIN ALLOCATESTRATEGY ALS (NOLOCK) ON SY.AllocateStrategyKey = ALS.AllocateStrategyKey
        AND W.Wavekey = @c_Wavekey
        AND W.Strategykey <> ''
        AND W.Strategykey IS NOT NULL
   END             
   
   IF ISNULL(@c_allocateStrategykey,'') = '' AND ISNULL(@c_Loadkey,'') <> ''
   BEGIN
        --Get strategy from load defaultstrategykey
        SELECT TOP 1 @c_allocateStrategykey = ALS.AllocateStrategyKey        
        FROM LOADPLAN LP (NOLOCK)
        JOIN LOADPLANDETAIL LPD (NOLOCK) ON LP.Loadkey = LPD.Loadkey
        JOIN ORDERS O (NOLOCK) ON LPD.Orderkey = O.Orderkey
        JOIN STORER S (NOLOCK) ON O.Storerkey = S.Storerkey
        JOIN STRATEGY SY (NOLOCK) ON S.Strategykey = SY.Strategykey
        JOIN ALLOCATESTRATEGY ALS (NOLOCK) ON SY.AllocateStrategyKey = ALS.AllocateStrategyKey
        AND LP.Loadkey = @c_Loadkey
        AND LP.DefaultStrategykey = 'Y'
        AND S.Strategykey <> ''
        AND S.Strategykey IS NOT NULL
   END   
   
   IF ISNULL(@c_allocateStrategykey,'') = '' AND ISNULL(@c_StorerDefaultAllocStrategy,'') <> ''
   BEGIN
        --Get strategy from storerconfig StorerDefaultAllocStrategy
      SELECT @c_allocateStrategykey = ALS.AllocateStrategyKey
      FROM STRATEGY SY (NOLOCK)
        JOIN ALLOCATESTRATEGY ALS (NOLOCK) ON SY.AllocateStrategyKey = ALS.AllocateStrategyKey
        WHERE SY.Strategykey = @c_StorerDefaultAllocStrategy      
   END
   
   IF ISNULL(@c_allocateStrategykey,'') = ''  
   BEGIN
        --Get strategy from sku
      SELECT @c_allocateStrategykey = STRATEGY.AllocateStrategykey
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
   WHERE CODELKUP.Listname = 'nspALCLK01'
   AND ISNULL(CODELKUP.Storerkey,'') = CASE WHEN ISNULL(CODELKUP.Short,'') = @c_AllocateStrategykey AND STORER.Storerkey IS NULL THEN ISNULL(CODELKUP.Storerkey,'') ELSE @c_Storerkey END --if setup short and no setup storer ignore storer otherwise by storer. 
   AND ISNULL(CODELKUP.Short,'') = CASE WHEN ISNULL(CODELKUP.Short,'') <> '' THEN @c_AllocateStrategykey ELSE ISNULL(CODELKUP.Short,'') END --if short setup must match allocate strategykey
   
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
      WHERE CODELKUP.Listname = 'nspALCLK01'
      AND ISNULL(CODELKUP.Storerkey,'') = CASE WHEN ISNULL(CODELKUP.Short,'') = @c_AllocateStrategykey AND STORER.Storerkey IS NULL THEN ISNULL(CODELKUP.Storerkey,'') ELSE @c_Storerkey END --if setup short and no setup storer ignore storer otherwise by storer. 
      AND ISNULL(CODELKUP.Short,'') = CASE WHEN ISNULL(CODELKUP.Short,'') <> '' THEN @c_AllocateStrategykey ELSE ISNULL(CODELKUP.Short,'') END --if short setup must match allocate strategykey
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
   WHERE Code = 'SORTING' --user can define sorting fields. default is logicalloc,loc.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END
   
   SELECT TOP 1 @c_AllocateQtyReplenFlag = ISNULL(UDF01,'')
   FROM @TMP_CODELKUP
   WHERE Code = 'ALLOCATEQTYREPLEN' --allow allocate qtyreplen from bulk. default is not allocate from qtyreplen.
   AND (Code2 = @c_UOM OR ISNULL(Code2,'') = '')
   ORDER BY CASE WHEN Code2 = @c_UOM THEN 0 ELSE 1 END      

   IF ISNULL(@c_SortFields,'') <> ''
   BEGIN      
      SET @c_SortingFlag = 'Y'
   END

   /*
   IF ISNULL(@c_HostWHCode,'') <> ''
   BEGIN
        SELECT @c_Condition = RTRIM(ISNULL(@c_Condition,'')) + " AND LOC.HostWhCode = N'" + RTRIM(ISNULL(@c_HostWHCode,'')) + "' "       
   END
   */ 
      
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
      
      SELECT @c_LocTypeSort = " CASE WHEN LOC.LocationType = '" + RTRIM(ISNULL(@c_UDF01,'')) + "' THEN 1 " +
                                   " WHEN LOC.LocationType = '" + RTRIM(ISNULL(@c_UDF02,'')) + "' THEN 2 " +
                                   " WHEN LOC.LocationType = '" + RTRIM(ISNULL(@c_UDF03,'')) + "' THEN 3 " +
                                   " WHEN LOC.LocationType = '" + RTRIM(ISNULL(@c_UDF04,'')) + "' THEN 4 " +
                                   " WHEN LOC.LocationType = '" + RTRIM(ISNULL(@c_UDF05,'')) + "' THEN 5 ELSE 6 END, " 
   END
   
   IF @c_CLKConditionFlag = 'Y'
   BEGIN
       IF LEFT(LTRIM(@c_CLKCondition),3) <> 'AND'
          SET @c_CLKCondition = ' AND ' + RTRIM(LTRIM(@c_CLKCondition))
   END
   
   IF ISNULL(@c_ID,'') <> ''
   BEGIN
       SELECT @c_Condition = ISNULL(RTRIM(@c_Condition),'') + " AND LOTxLOCxID.Id = RTRIM(@c_ID) " 
   END


   IF ISNULL(@c_AllocateHoldFlag,'') <> 'Y'
   BEGIN
      SELECT  @c_Condition = ISNULL(RTRIM(@c_Condition),'') + 
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
      SET @c_SortBy = " ORDER BY " + RTRIM(@c_LocTypeSort) + RTRIM(@c_SortFields) + " "
   END
   ELSE      
      SET @c_SortBy = " ORDER BY " + RTRIM(@c_LocTypeSort) + " LOC.LogicalLocation, LOC.LOC " 
       
   SELECT @c_SQLStatement = " DECLARE CURSOR_CANDIDATES CURSOR FAST_FORWARD READ_ONLY FOR " +
                           " SELECT LOTxLOCxID.LOC,LOTxLOCxID.ID, " +
                           CASE WHEN @c_AllocateQtyReplenFlag = 'Y' THEN 
                              " QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) "
                           ELSE
                              " QTYAVAILABLE = (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN) "
                           END +                              
                           ", '1' " +
                           " FROM LOTxLOCxID (NOLOCK) " +
                           " JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC) " +
                           " JOIN ID (NOLOCK) ON (LOTxLOCxID.Id = ID.ID) " +
                           " JOIN SKUXLOC (NOLOCK) ON (LOTxLOCxID.Storerkey =  SKUXLOC.Storerkey AND LOTxLOCxID.Sku = SKUXLOC.Sku AND LOTxLOCxID.Loc =  SKUXLOC.Loc) " +
                           " JOIN SKU (NOLOCK) ON (LOTxLOCxID.Storerkey =  SKU.Storerkey AND SKU.Sku =  SKUXLOC.Sku) " +
                           " JOIN PACK (NOLOCK) ON (SKU.Packkey = PACK.Packkey) " +
                           " WHERE LOTxLOCxID.Lot =  @c_lot " +
                           " AND LOC.Facility = @c_Facility " +
                           CASE WHEN @c_AllocateQtyReplenFlag = 'Y' THEN 
                              " AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED) >= @n_uombase " 
                           ELSE
                              " AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QTYREPLEN) >= @n_uombase " 
                           END +
                           ISNULL(RTRIM(@c_Condition),'') + " " + ISNULL(RTRIM(@c_CLKCondition),'') + " " + @c_SortBy
                           
   SET @c_SQLParms = N'@c_Facility NVARCHAR(5), @c_StorerKey NVARCHAR(15), @c_SKU NVARCHAR(20), @c_UOM NVARCHAR(10), @c_Lot NVARCHAR(10) '
       +', @n_UOMBase INT, @n_QtyLeftToFulfill INT, @c_Orderkey NVARCHAR(10), @c_OrderLineNumber NVARCHAR(5), @c_Loadkey NVARCHAR(10), @c_Wavekey NVARCHAR(10)'    
       +', @c_ID NVARCHAR(18), @c_UDF01 NVARCHAR(30), @c_UDF02 NVARCHAR(30), @c_UDF03 NVARCHAR(30), @c_UDF04 NVARCHAR(30), @c_UDF05 NVARCHAR(30), @c_HostWHCode NVARCHAR(10)'
                           
   EXEC sp_executesql @c_SQLStatement, @c_SQLParms
     ,@c_Facility   
     ,@c_StorerKey  
     ,@c_SKU        
     ,@c_UOM        
     ,@C_Lot
     ,@n_UOMBase    
     ,@n_QtyLeftToFulfill
     ,@c_Orderkey
     ,@c_OrderLineNumber
     ,@c_Loadkey
     ,@c_Wavekey 
     ,@c_ID                                          
     ,@c_UDF01                                       
     ,@c_UDF02                                       
     ,@c_UDF03                                       
     ,@c_UDF04                                       
     ,@c_UDF05       
     ,@c_HostWHCode                                                                        
END
GO

GRANT EXECUTE ON [dbo].[nspALCLK01] TO nSQL
GO



