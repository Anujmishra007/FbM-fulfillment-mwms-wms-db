SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure:  ispPRJCBUSK02                                     */
/* Creation Date: 2026-08-05                                            */
/* Copyright: MAERSK Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  FCR-14816 - US JCB allocation strategy                     */
/*           Allocate CS; UOM=2 From Stage                              */
/*           Order Group = 'Kitting'                                   */
/*                                                                      */
/*           set the sp to storerconfig PreAllocationSP                 */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/* Updates:                                                             */
/* Date        Author   Rev   Purposes                                  */
/* 2026-08-05  Wan01    1.0   Created.                                  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPRJCBUSK02]  
   @c_OrderKey        NVARCHAR(10)
,  @c_LoadKey         NVARCHAR(10)
,  @c_Wavekey         NVARCHAR(10)
,  @b_Success         INT           = '' OUTPUT
,  @n_Err             INT           = '' OUTPUT
,  @c_ErrMsg          NVARCHAR(250) = '' OUTPUT
,  @b_debug           INT = 0  
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue              INT = 1
         , @n_StartTCnt             INT = @@TRANCOUNT 
         , @n_RowCount              INT = 0
         , @n_RowID                 INT = 0

   DECLARE @c_OrderGroup            NVARCHAR(10)   = 'Kitting'
         , @c_OrderLineNumber       NVARCHAR(5)    = ''
         , @c_SKU                   NVARCHAR(20)   = ''
         , @c_StorerKey             NVARCHAR(15)   = ''
         , @c_Lottable01            NVARCHAR(18)   = ''
         , @c_Lottable02            NVARCHAR(18)   = ''
         , @c_Lottable03            NVARCHAR(18)   = ''
         , @d_Lottable04            DATETIME       
         , @d_Lottable05            DATETIME        
         , @c_Lottable06            NVARCHAR(30)   = ''
         , @c_Lottable07            NVARCHAR(30)   = ''
         , @c_Lottable08            NVARCHAR(30)   = ''
         , @c_Lottable09            NVARCHAR(30)   = ''
         , @c_Lottable10            NVARCHAR(30)   = ''
         , @c_Lottable11            NVARCHAR(30)   = ''
         , @c_Lottable12            NVARCHAR(30)   = ''
         , @d_Lottable13            DATETIME       
         , @d_Lottable14            DATETIME       
         , @d_Lottable15            DATETIME       
         , @c_Lottable04            NVARCHAR(30)   = ''
         , @c_Lottable05            NVARCHAR(30)   = ''
         , @c_Lottable13            NVARCHAR(30)   = ''
         , @c_Lottable14            NVARCHAR(30)   = ''
         , @c_Lottable15            NVARCHAR(30)   = ''
         , @c_Lot                   NVARCHAR(10)   = ''
         , @c_Loc                   NVARCHAR(10)   = ''
         , @c_ID                    NVARCHAR(18)   = ''
         , @c_Facility              NVARCHAR(5)    = ''
         , @c_PackKey               NVARCHAR(10)   = ''
         , @c_UOM                   NVARCHAR(10)   = ''
                          
         , @n_OpenQty               INT = 0
         , @n_PickQty               INT = 0
         , @n_QtyAvailable          INT = 0   
         , @n_LotQtyAvai            INT = 0
         , @n_ExtraQty              INT = 0
         , @n_QtyLeftToFulfill      INT

         , @c_PickDetailKey         NVARCHAR(10)   = '' 
         , @c_PackUOM3              NVARCHAR(10)   = ''                                
         , @c_IDLottable11          NVARCHAR(30)   = ''    
         
         , @c_SQL                   NVARCHAR(MAX)  = ''
         , @c_SQLParm               NVARCHAR(MAX)  = ''
         , @c_Condition             NVARCHAR(MAX)  = '' 
         , @c_Conditions            NVARCHAR(MAX)  = ''
         , @c_Sorting               NVARCHAR(MAX)  = ''
         , @c_OrderBy               NVARCHAR(MAX)  = ''
         , @c_Cond                  NVARCHAR(MAX)  = ''  

         , @CUR_ORDER_LINES         CURSOR
                                    
   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @c_UOM     = '2'
   
   IF OBJECT_ID('tempdb..#TMP_JCB_LLI') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_JCB_LLI
   END

   CREATE TABLE #TMP_JCB_LLI 
   ( 
      RowID          INT            NOT NULL IDENTITY(1,1) PRIMARY KEY
   ,  Storerkey      NVARCHAR(15)   NOT NULL DEFAULT('')
   ,  Sku            NVARCHAR(20)   NOT NULL DEFAULT('')    
   ,  Lot            NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  Loc            NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  ID             NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  Lottable11     NVARCHAR(10)   NOT NULL DEFAULT('')   
   ,  QtyAvailable   INT            NOT NULL DEFAULT(0)    
   )  

   --SET @c_ApplyJoin  = ' CROSS APPLY ( SELECT 
   --                                    Qty = SUM(LOTxLOCxID.Qty) OVER  
   --                                          (PARTITION BY LOTxLOCxID.LOC,LOTxLOCxID.ID)
   --                                  , Lottable05 = MAX(LOTATTRIBUTE.Lottable05) OVER
   --                                          (PARTITION BY LOTxLOCxID.LOC,LOTxLOCxID.ID)
   --                                  ) CROSSJOIN' + CHAR(13)

   SET @c_Condition  = ' AND LOC.LocationType <> ''PICK'''
                     + ' AND LOTATTRIBUTE.Lottable11 > '''''
                     + ' AND EXISTS (SELECT 1 FROM LOTxLOCxID lli1 (NOLOCK)
                                     JOIN LOTAttribute la1 (NOLOCK) ON la1.lot = lli1.lot
                                     WHERE lli1.ID = LOTxLOCxID.ID
                                     AND   lli1.Loc = LOTxLOCxID.Loc
                                     AND   la1.Lottable11 = LOTATTRIBUTE.Lottable11
                                     HAVING COUNT(DISTINCT lli1.SKU) = 1
                                    )'
   SET @c_OrderBy = ' ORDER BY 
                       MAX(LOTATTRIBUTE.Lottable05) 
                            OVER (PARTITION BY LOTxLOCxID.LOC,LOTxLOCxID.ID,LOTATTRIBUTE.Lottable11)'
                  + ', SUM(LOTxLOCxID.Qty-LOTxLOCxID.QtyAllocated-LOTxLOCxID.QtyPicked-LOTxLOCxID.QtyReplen)   
                            OVER (PARTITION BY LOTxLOCxID.LOC,LOTxLOCxID.ID,LOTATTRIBUTE.Lottable11) DESC'  
                  + ', LOTxLOCxID.Loc'   
                  + ', LOTxLOCxID.ID'  
                  + ', LOTATTRIBUTE.Lottable11'                                  
                  + ', LOC.LogicalLocation'                           
   
   SELECT TOP 1 @c_Cond = cl.Notes                                                        
   FROM CODELKUP cl (NOLOCK)
   WHERE cl.ListName = 'JCB_AL'
   AND   cl.Code = 'Condition'
   AND   cl.Short= @c_UOM
   AND   cl.Code2 = 'ispPRJCBUSK02' 

   SELECT TOP 1 @c_Sorting = cl.Notes                                                        
   FROM CODELKUP cl (NOLOCK)
   WHERE cl.ListName = 'JCB_AL'
   AND   cl.Code = 'Sorting'
   AND   cl.Short= @c_UOM
   AND   cl.Code2 = 'ispPRJCBUSK02' 

   IF @c_Cond IN ('', NULL) SET @c_Cond = ' AND LOC.LocationFlag IN (''None'','''')'        
      
   SET @c_Condition = @c_Condition + ' ' + @c_Cond 

   IF @c_Sorting > ''
   BEGIN
      SET @c_OrderBy = ' ORDER BY ' + @c_Sorting
   END

   IF ISNULL(@c_Orderkey,'') <> ''
   BEGIN
      SET @CUR_ORDER_LINES = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OD.StorerKey, OD.OrderKey, OD.OrderLineNumber, OD.Sku
            ,(OD.OpenQty - (OD.QtyAllocated + OD.QtyPicked))
            ,SKU.Packkey
            ,OD.LOTTABLE01
            ,OD.LOTTABLE02
            ,OD.LOTTABLE03
            ,OD.LOTTABLE04
            ,OD.LOTTABLE05
            ,OD.LOTTABLE06
            ,OD.LOTTABLE07
            ,OD.LOTTABLE08
            ,OD.LOTTABLE09
            ,OD.LOTTABLE10
            ,OD.LOTTABLE11
            ,OD.LOTTABLE12
            ,OD.LOTTABLE13
            ,OD.LOTTABLE14
            ,OD.LOTTABLE15
            ,O.Facility
      FROM ORDERS AS o WITH (NOLOCK)
      JOIN ORDERDETAIL AS OD WITH (NOLOCK) ON OD.OrderKey = o.OrderKey
      JOIN SKU WITH (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
      JOIN PACK WITH (NOLOCK) ON SKU.Packkey = PACK.Packkey
      WHERE o.OrderKey = @c_OrderKey
      AND (OD.OpenQty - (OD.QtyAllocated + OD.QtyPicked)) > 0
      AND o.SOStatus <> 'CANC' 
      AND o.Status < '9'            
      AND O.OrderGroup = @c_Ordergroup
      ORDER BY OD.Orderkey, OD.OrderLineNumber
   END
   ELSE IF ISNULL(@c_Loadkey,'') <> ''
   BEGIN
      SET @CUR_ORDER_LINES = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OD.StorerKey, OD.OrderKey, OD.OrderLineNumber, OD.Sku
            ,(OD.OpenQty - (OD.QtyAllocated + OD.QtyPicked))
            ,SKU.Packkey
            ,OD.LOTTABLE01
            ,OD.LOTTABLE02
            ,OD.LOTTABLE03
            ,OD.LOTTABLE04
            ,OD.LOTTABLE05
            ,OD.LOTTABLE06
            ,OD.LOTTABLE07
            ,OD.LOTTABLE08
            ,OD.LOTTABLE09
            ,OD.LOTTABLE10
            ,OD.LOTTABLE11
            ,OD.LOTTABLE12
            ,OD.LOTTABLE13
            ,OD.LOTTABLE14
            ,OD.LOTTABLE15
            ,O.Facility
      FROM ORDERS AS o WITH (NOLOCK)
      JOIN ORDERDETAIL AS OD WITH (NOLOCK) ON OD.OrderKey = o.OrderKey
      JOIN SKU WITH (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
      JOIN PACK WITH (NOLOCK) ON SKU.Packkey = PACK.Packkey
      JOIN LoadPlanDetail LPD WITH (NOLOCK) ON o.OrderKey = LPD.OrderKey
      WHERE LPD.LoadKey = @c_Loadkey
      AND (OD.OpenQty - (OD.QtyAllocated + OD.QtyPicked)) > 0
      AND o.SOStatus <> 'CANC' 
      AND o.Status < '9'                     
      AND O.OrderGroup = @c_Ordergroup
      ORDER BY OD.Orderkey, OD.OrderLineNumber
   END
   ELSE IF ISNULL(@c_Wavekey,'') <> ''
   BEGIN
      SET @CUR_ORDER_LINES = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OD.StorerKey, OD.OrderKey, OD.OrderLineNumber, OD.Sku
            ,(OD.OpenQty - (OD.QtyAllocated + OD.QtyPicked))
            ,SKU.Packkey
            ,OD.LOTTABLE01
            ,OD.LOTTABLE02
            ,OD.LOTTABLE03
            ,OD.LOTTABLE04
            ,OD.LOTTABLE05
            ,OD.LOTTABLE06
            ,OD.LOTTABLE07
            ,OD.LOTTABLE08
            ,OD.LOTTABLE09
            ,OD.LOTTABLE10
            ,OD.LOTTABLE11
            ,OD.LOTTABLE12
            ,OD.LOTTABLE13
            ,OD.LOTTABLE14
            ,OD.LOTTABLE15
            ,O.Facility
      FROM ORDERS AS o WITH (NOLOCK)
      JOIN ORDERDETAIL AS OD WITH (NOLOCK) ON OD.OrderKey = o.OrderKey
      JOIN SKU WITH (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
      JOIN PACK WITH (NOLOCK) ON SKU.Packkey = PACK.Packkey
      JOIN WaveDetail WD WITH (NOLOCK) ON o.OrderKey = WD.OrderKey
      WHERE WD.Wavekey = @c_Wavekey
      AND (OD.OpenQty - (OD.QtyAllocated + OD.QtyPicked)) > 0
      AND o.SOStatus <> 'CANC' 
      AND o.Status < '9'                     
      AND O.OrderGroup = @c_Ordergroup                   
      ORDER BY OD.Orderkey, OD.OrderLineNumber
   END
      
   OPEN @CUR_ORDER_LINES
      
   FETCH FROM @CUR_ORDER_LINES INTO @c_StorerKey, @c_OrderKey, @c_OrderLineNumber, @c_SKU, @n_OpenQty, @c_Packkey
                                 ,  @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
                                 ,  @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                                 ,  @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
                                 ,  @c_Facility
                                   
   WHILE @@FETCH_STATUS = 0 AND @n_Continue IN(1,2)
   BEGIN
      IF @b_debug = 1                                                           
      BEGIN
         SELECT @c_OrderKey as orderkey, @c_OrderLineNumber as orderlinenumber, @c_SKU as sku, @n_OpenQty as openqty
      END         
          
      SET @n_QtyLeftToFulfill = @n_OpenQty  
      
      SET @c_Conditions = @c_Condition 
           
      IF @c_Lottable01 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable01 = @c_Lottable01'
      IF @c_Lottable02 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable02 = @c_Lottable02' 
      IF @c_Lottable03 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable03 = @c_Lottable03'  
      IF CONVERT(NVARCHAR(8) ,@d_Lottable04 ,112) NOT IN ('19000101', NULL) 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable04 = RTRIM(CONVERT(NVARCHAR(20),@d_Lottable04,106))' 
      IF CONVERT(NVARCHAR(8) ,@d_Lottable05 ,112) NOT IN ('19000101', NULL) 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable05 = RTRIM(CONVERT(NVARCHAR(20),@d_Lottable05,106))'  
      IF @c_Lottable06 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable06 = @c_Lottable06'
      IF @c_Lottable07 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable07 = @c_Lottable07' 
      IF @c_Lottable08 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable08 = @c_Lottable08'  
      IF @c_Lottable09 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable09 = @c_Lottable09'
      IF @c_Lottable10 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable10 = @c_Lottable10' 
      IF @c_Lottable11 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable11 = @c_Lottable11' 
      IF @c_Lottable12 <> '' 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable12 = @c_Lottable12' 
      IF CONVERT(NVARCHAR(8) ,@d_Lottable13 ,112) NOT IN ('19000101', NULL)
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable13 = RTRIM(CONVERT(NVARCHAR(20),@d_Lottable13,106))' 
      IF CONVERT(NVARCHAR(8) ,@d_Lottable14 ,112) NOT IN ('19000101', NULL) 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable14 = RTRIM(CONVERT(NVARCHAR(20),@d_Lottable14,106))' 
      IF CONVERT(NVARCHAR(8) ,@d_Lottable15 ,112) NOT IN ('19000101', NULL) 
         SET @c_Conditions = @c_Conditions + ' AND LOTATTRIBUTE.Lottable15 = RTRIM(CONVERT(NVARCHAR(20),@d_Lottable15,106))'  

      SET @c_SQL = 
       N'SELECT LOTxLOCxID.Storerkey, LOTxLOCxID.Sku
            , LOTxLOCxID.Lot, LOTxLOCxID.Loc, LOTxLOCxID.ID, LOTATTRIBUTE.Lottable11
            , QtyAvailable = LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen
         FROM LOTxLOCxID (NOLOCK)
         JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
         JOIN ID  (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
         JOIN LOT (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT)
         JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT
         JOIN SKUXLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUXLOC.Storerkey 
                              AND LOTxLOCxID.Sku = SKUXLOC.Sku 
                              AND LOTxLOCxID.Loc = SKUXLOC.Loc
         JOIN SKU (NOLOCK) ON LOTxLOCxID.Storerkey = Sku.Storerkey AND LOTxLOCxID.Sku = Sku.Sku
         WHERE LOC.LocationFlag NOT IN ( ''HOLD'', ''DAMAGE'')                 
         AND LOC.Status = ''OK''
         AND LOT.Status = ''OK''
         AND ID.Status = ''OK''
         AND LOC.Facility = @c_Facility
         AND LOTxLOCxID.QTY - LOTxLOCxID.QTYALLOCATED - LOTxLOCxID.QTYPICKED - LOTxLOCxID.QtyReplen > 0
         AND LOTxLOCxID.STORERKEY = @c_StorerKey
         AND LOTxLOCxID.SKU = @c_SKU '  
      + CHAR(13) + @c_Conditions 
      + CHAR(13) + @c_OrderBy
          
      SET @c_SQLParm =  N'@c_StorerKey NVARCHAR(15), @c_SKU NVARCHAR(20), @c_Facility NVARCHAR(5)' 
                     +  ',@c_Lottable01 NVARCHAR(18), @c_Lottable02 NVARCHAR(18), @c_Lottable03 NVARCHAR(18)'
                     +  ',@d_Lottable04 DATETIME, @d_Lottable05 DATETIME'  
                     +  ',@c_Lottable06 NVARCHAR(30), @c_Lottable07 NVARCHAR(30), @c_Lottable08 NVARCHAR(30)'
                     +  ',@c_Lottable09 NVARCHAR(30), @c_Lottable10 NVARCHAR(30)'  
                     +  ',@c_Lottable11 NVARCHAR(30), @c_Lottable12 NVARCHAR(30)'
                     +  ',@d_Lottable13 DATETIME, @d_Lottable14 DATETIME, @d_Lottable15 DATETIME'
                     +  ',@c_Orderkey NVARCHAR(10), @n_QtyLeftToFulfill INT'                             

      TRUNCATE TABLE #TMP_JCB_LLI;
      INSERT INTO #TMP_JCB_LLI (Storerkey, Sku, Lot, Loc, ID, Lottable11, QtyAvailable)      
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParm  
                        ,@c_StorerKey, @c_SKU, @c_Facility
                        ,@c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
                        ,@c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                        ,@c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
                        ,@c_Orderkey, @n_QtyLeftToFulfill  

      SET @n_RowID   = 0                                       
      WHILE @n_Continue = 1 AND @n_QtyLeftToFulFill > 0  
      BEGIN 
         SET @n_PickQty = 0
         SET @n_QtyAvailable = 0   
         SET @c_Lot = ''
         SET @c_Loc = ''
         SET @c_ID  = ''
         SET @c_IDLottable11 =''
         
         SELECT TOP 1 
                @n_RowID = tlli.RowID
               ,@c_Lot   = tlli.Lot
               ,@c_Loc   = tlli.Loc
               ,@c_ID    = tlli.ID
               ,@c_IDLottable11 = tlli.Lottable11 
               ,@n_QtyAvailable = tlli.QtyAvailable
         FROM #TMP_JCB_LLI tlli
         WHERE tlli.RowID > @n_RowID
         ORDER BY tlli.RowID

         SET @n_RowCount = @@ROWCOUNT

         IF @n_RowCount = 0
         BEGIN
            BREAK
         END

         IF @b_debug = 1
         BEGIN
            SELECT @c_Lot as lot, @c_Loc as loc, @c_ID as id
                 , @n_QtyLeftToFulFill as qtylefttofulfill
         END

         IF EXISTS ( SELECT 1
                     FROM #TMP_JCB_LLI tlli
                     WHERE tlli.ID = @c_ID
                     AND   tlli.Loc= @c_Loc
                     AND   tlli.Lottable11 = @c_IDLottable11
                     HAVING SUM(tlli.QtyAvailable) > @n_QtyLeftToFulFill
                   )
         BEGIN
            CONTINUE
         END
         
         SET @n_PickQty = @n_QtyAvailable 
           
         IF @n_PickQty > 0                        
         BEGIN                                        
            SET @b_Success = 0
            SET @c_PickDetailKey = ''
                     
            EXEC nspg_GetKey
               @KeyName     = 'PickdetailKey' 
            ,  @fieldlength = 10 
            ,  @keystring   = @c_PickDetailKey  OUTPUT 
            ,  @b_Success   = @b_Success        OUTPUT 
            ,  @n_err       = @n_Err            OUTPUT 
            ,  @c_errmsg    = @c_ErrMsg         OUTPUT 
            ,  @b_resultset = 1 
            ,  @n_batch     = 1
                  
            IF @b_Success = 1
            BEGIN
               INSERT INTO PICKDETAIL
               (
                  PickDetailKey,          CaseID,              PickHeaderKey,
                  OrderKey,               OrderLineNumber,     Lot,
                  Storerkey,              Sku,                 AltSku,
                  UOM,                    UOMQty,              Qty,
                  QtyMoved,               [Status],            DropID,
                  Loc,                    ID,                  PackKey,
                  UpdateSource,           CartonGroup,         CartonType,
                  ToLoc,                  DoReplenish,         ReplenishZone,
                  DoCartonize,            PickMethod,          WaveKey,
                  ShipFlag,               PickSlipNo,          TaskDetailKey,
                  TaskManagerReasonKey,   Notes,               MoveRefKey,   
                  Trafficcop
               )
               VALUES 
               (  @c_PickDetailKey,       '',                  '',
                  @c_OrderKey,            @c_OrderLineNumber, @c_LOT,       
                  @c_StorerKey,           @c_SKU,              '',                    
                  @c_UOM,                 @n_PickQty,          @n_PickQty,
                  0,                      '0',                 '',
                  @c_LOC,                 @c_ID,               @c_PackKey,
                  '0',                    'STD',              '',
                  '',                     'N',                '',
                  'N',                    '',                 '',
                  'N',                    '',                 '',
                  '',                     '',                 '',
                  'U'
               )
                        
               SET @n_err = @@ERROR
                     
               IF @n_err <> 0
               BEGIN
                  SET @n_continue = 3
                  SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                  SET @n_err = 81030  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Pickdetail Failed. (ispPRJCBUSK02)'
                              + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               END
            END  
 
            SET @n_QtyLeftToFulFill = @n_QtyLeftToFulFill - @n_PickQty 
                                                             
         END 
      END

      NEXT_CANDIDATE:     
      FETCH FROM @CUR_ORDER_LINES INTO @c_StorerKey, @c_OrderKey, @c_OrderLineNumber, @c_SKU, @n_OpenQty, @c_Packkey  
                                     , @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
                                     , @c_Lottable06, @c_Lottable07, @c_Lottable08,@c_Lottable09, @c_Lottable10
                                     , @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
                                     , @c_Facility
   END
   CLOSE @CUR_ORDER_LINES
   DEALLOCATE @CUR_ORDER_LINES
                              
QUIT:
   IF OBJECT_ID('tempdb..#TMP_JCB_LLI') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_JCB_LLI
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPRJCBUSK02'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON  [dbo].[ispPRJCBUSK02] TO [NSQL]
GO