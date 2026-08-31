SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure:  ispPRJCBUSS01                                     */
/* Creation Date: 2026-08-05                                            */
/* Copyright: MAERSK Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  FCR-14816 - US JCB allocation strategy                     */
/*           Allocate full pallet of single sku from bulk by top up     */
/*           order qty if pallet qty more than order qty. UOM 1.        */
/*           Order Group = 'Standard'                                   */
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
/* 2026-08-05  Wan      1.0   Created.                                  */
/* 2026-08-18  Wan      1.0   UWP-64392 - Fix                           */     
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPRJCBUSS01]  
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

   DECLARE @c_OrderGroup            NVARCHAR(10)   = 'Standard'
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
         , @n_QtyLeftToFulfill      INT = 0                                         --UWP-64392 
         , @n_Qty                   INT = 0                                         --UWP-64392
         , @n_QtyAllocated          INT = 0                                         --UWP-64392

         , @c_PickDetailKey         NVARCHAR(10)   = '' 
         , @c_PackUOM3              NVARCHAR(10)   = ''                                
         , @c_IDSku                 NVARCHAR(20)   = ''                                 
         , @c_IDLottable03          NVARCHAR(18)   = ''                                  
         , @c_OrderLineNoAlloc      NVARCHAR(5)    = ''                                  
         , @c_IDLottable11          NVARCHAR(30)   = ''    
         
         , @c_SQL                   NVARCHAR(MAX)  = ''
         , @c_SQLParm               NVARCHAR(MAX)  = ''
         , @c_ApplyJoin             NVARCHAR(2000) = ''                             --UWP-64392
         , @c_Condition             NVARCHAR(MAX)  = ''         
         , @c_Conditions            NVARCHAR(MAX)  = ''
         , @c_Sorting               NVARCHAR(MAX)  = ''
         , @c_OrderBy               NVARCHAR(MAX)  = ''
         , @c_Cond                  NVARCHAR(MAX)  = ''  

         , @CUR_ORDER_LINES         CURSOR
         , @CUR_LOT                 CURSOR
         , @CUR_ALC                 CURSOR                                          --UWP-64392 
                                          
   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @c_UOM     = '1' 

   IF OBJECT_ID('tempdb..#TMP_JCB_ALC') IS NOT NULL                                 --UWP-64392
   BEGIN
      DROP TABLE #TMP_JCB_ALC
   END
   
   CREATE TABLE #TMP_JCB_ALC 
   ( 
      PickDetailKey  NVARCHAR(10)   NOT NULL DEFAULT('')    PRIMARY KEY
   ,  Orderkey       NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  Loc            NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  ID             NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  Lottable11     NVARCHAR(10)   NOT NULL DEFAULT('') 
   ,  Qty            INT            NOT NULL DEFAULT(0)       
   )  
   
   CREATE NONCLUSTERED INDEX IX_TMP_JCB_ALC_OrdxID ON #TMP_JCB_ALC(Orderkey,Loc,ID);  

   --UWP-64392
   SET @c_ApplyJoin  = ' CROSS APPLY 
                        (SELECT Qty = SUM(lli1.QTY)
                         FROM LOTxLOCxID lli1 (NOLOCK) 
                         JOIN LOTAttribute la1 (NOLOCK) ON la1.Lot = lli1.Lot
                         WHERE lli1.Loc = LOTxLOCxID.Loc 
                         AND lli1.ID = LOTxLOCxID.ID
                         AND lli1.QTY > 0
                         AND lli1.QTYALLOCATED+lli1.QTYPICKED+lli1.QtyReplen = 0
                         AND la1.Lottable11 = LOTATTRIBUTE.Lottable11
                         GROUP BY lli1.Loc, lli1.ID
                         HAVING SUM(lli1.QTYALLOCATED+lli1.QTYPICKED+lli1.QtyReplen) = 0                         
                        ) ApplyJoin' + CHAR(13)
                               
   SET @c_Condition  = ' AND LOC.LocationType <> ''PICK'''
                     + ' AND LOTxLOCxID.QtyAllocated + LOTxLOCxID.QtyPicked + LOTxLOCxID.QtyReplen = 0' 
                       
   SET @c_OrderBy = ' ORDER BY LOTATTRIBUTE.Lottable05'                             --UWP-64392
                  + ', ABS(ApplyJoin.Qty - @n_QtyLeftToFulfill)'  
                  + ', ApplyJoin.Qty DESC'  
                  + ', LOTxLOCxID.LOC'   
                  + ', LOTxLOCxID.ID' 
                  + ', LOTATTRIBUTE.Lottable11'                          
                  + ', LOC.LogicalLocation'                         
   
   SELECT TOP 1 @c_Cond = cl.Notes                                                        
   FROM CODELKUP cl (NOLOCK)
   WHERE cl.ListName = 'JCB_AL'
   AND   cl.Code = 'Condition'
   AND   cl.Code2 = 'ispPRJCBUSS01' 

   SELECT TOP 1 @c_Sorting = cl.Notes                                                        
   FROM CODELKUP cl (NOLOCK)
   WHERE cl.ListName = 'JCB_AL'
   AND   cl.Code = 'Sorting'
   AND   cl.Code2 = 'ispPRJCBUSS01' 

   IF @c_Cond IN ('', NULL) SET @c_Cond = ' AND LOC.LocationFlag = ''None'''        
      
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
          
      IF NOT EXISTS( SELECT 1 FROM ORDERDETAIL (NOLOCK)
                     WHERE Orderkey = @c_Orderkey
                     AND OrderLineNumber = @c_OrderLineNumber
                     AND ISNUMERIC(UserDefine01) = 1
                   )
      BEGIN
         UPDATE ORDERDETAIL WITH (ROWLOCK)
         SET Userdefine01 = CAST(OpenQty AS NVARCHAR)
            ,Trafficcop = NULL
         WHERE Orderkey = @c_Orderkey
         AND OrderLineNumber = @c_OrderLineNumber

         SET @n_err = @@ERROR
               
         IF @n_err <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
            SET @n_err = 81010  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Orderdetail Failed. (ispPRJCBUSS01)'
                        + '( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                                                            
         END                                                                                                                
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
       N'SELECT TOP 1 
              @c_Loc = LOTxLOCxID.Loc, @c_ID = LOTxLOCxID.ID
            , @c_IDLottable11 =LOTATTRIBUTE.Lottable11 
         FROM LOTxLOCxID (NOLOCK)
         JOIN LOC (NOLOCK) ON (LOTxLOCxID.Loc = LOC.LOC)
         JOIN ID  (NOLOCK) ON (LOTxLOCxID.Id = ID.ID)
         JOIN LOT (NOLOCK) ON (LOTxLOCxID.LOT = LOT.LOT)
         JOIN LOTATTRIBUTE (NOLOCK) ON LOT.LOT = LOTATTRIBUTE.LOT
         JOIN SKUXLOC (NOLOCK) ON LOTxLOCxID.Storerkey = SKUXLOC.Storerkey 
                              AND LOTxLOCxID.Sku = SKUXLOC.Sku 
                              AND LOTxLOCxID.Loc = SKUXLOC.Loc
         JOIN SKU (NOLOCK) ON LOTxLOCxID.Storerkey = Sku.Storerkey AND LOTxLOCxID.Sku = Sku.Sku'
      +  CHAR(13) + @c_ApplyJoin                                                    --UWP-64392  
      + 'WHERE LOC.LocationFlag NOT IN ( ''HOLD'', ''DAMAGE'')                 
         AND LOC.Status = ''OK''
         AND LOT.Status = ''OK''
         AND ID.Status = ''OK''
         AND LOC.Facility = @c_Facility
         AND LOTxLOCxID.QTY-LOTxLOCxID.QTYALLOCATED-LOTxLOCxID.QTYPICKED-LOTxLOCxID.QtyReplen > 0
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
                     +  ',@c_Loc NVARCHAR(10) OUTPUT, @c_ID NVARCHAR(18) OUTPUT, @c_IDLottable11 NVARCHAR(30) OUTPUT'    
 
      WHILE @n_Continue = 1 AND @n_QtyLeftToFulFill > 0  
      BEGIN
         SET @n_PickQty = 0
         SET @c_Loc = ''
         SET @c_ID  = ''
         SET @c_IDLottable11 = ''
        
         EXEC sp_ExecuteSQL @c_SQL
                           ,@c_SQLParm  
                           ,@c_StorerKey, @c_SKU, @c_Facility
                           ,@c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
                           ,@c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                           ,@c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
                           ,@c_Orderkey, @n_QtyLeftToFulfill  
                           ,@c_Loc OUTPUT, @c_ID OUTPUT, @c_IDLottable11 OUTPUT
 
         IF @c_Loc = '' AND @c_ID = ''
         BEGIN
            BREAK
         END

         IF @b_debug = 1
         BEGIN
            SELECT @c_Loc as loc, @c_ID as id, @n_QtyLeftToFulFill as qtylefttofulfill
         END
         
         SET @c_UOM = '1'                                                           --UWP-64392                                                   
         IF @c_IDLottable11 > '' 
         BEGIN
            SET @c_UOM = '2'
         END   
                    
         SET @CUR_LOT = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
         SELECT lli.Lot
               ,lli.QTY-lli.QTYALLOCATED-lli.QTYPICKED-lli.QtyReplen
               ,lli.Sku
               ,la.Lottable03
         FROM LOTxLOCxID lli (NOLOCK)
         JOIN LOT (NOLOCK) ON LOT.Lot = lli.Lot
         JOIN LOTATTRIBUTE la (NOLOCK) ON la.Lot = lli.Lot
         WHERE lli.Storerkey = @c_Storerkey
         AND lli.Loc = @c_Loc
         AND lli.ID  = @c_ID 
         AND lli.QTY-lli.QTYALLOCATED-lli.QTYPICKED-lli.QtyReplen > 0
         AND lot.[Status] = 'OK'
         AND la.Lottable11 = @c_IDLottable11                                        --UWP-64392
         ORDER BY CASE WHEN LLI.Sku = @c_Sku THEN 1 ELSE 2 END                    
 
         OPEN @CUR_LOT
                                                               
         FETCH FROM @CUR_LOT INTO @c_Lot, @n_LotQtyAvai, @c_IDSku, @c_IDLottable03   
                                       
         WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
         BEGIN                                                
            SET @n_PickQty = 0
            SET @c_OrderLineNoAlloc = @c_OrderLineNumber                          
            SET @n_OpenQty = @n_QtyLeftToFulFill

            IF @c_Sku <> @c_IDSku  
            BEGIN
               SET @c_OrderLineNoAlloc = ''
               SELECT TOP 1
                     @c_OrderLineNoAlloc = OrderLineNumber 
                   , @n_OpenQty = OpenQty - QtyAllocated - QtyPicked
               FROM ORDERDETAIL (NOLOCK)
               WHERE Orderkey = @c_Orderkey
               AND Sku = @c_IDSku
            END                                                                  
                  
            IF @n_LotQtyAvai > @n_OpenQty                                         
            BEGIN
               SET @n_ExtraQty = @n_LotQtyAvai - @n_OpenQty                      
               SET @n_PickQty = @n_LotQtyAvai

               UPDATE ORDERDETAIL WITH (ROWLOCK)
               SET OpenQty = OpenQty + @n_ExtraQty
                  ,UserDefine01 = CASE WHEN ISNUMERIC(UserDefine01) = 0 THEN OpenQty ELSE UserDefine01 END
               WHERE Orderkey = @c_Orderkey
               AND OrderLineNumber = @c_OrderLineNoAlloc                        
                       
               SET @n_err = @@ERROR
                      
               IF @n_err <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                  SET @n_err = 81020  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Orderdetail Failed. (ispPRJCBUSS01)'
                              + '( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                                                            
               END  
            END
            ELSE
            BEGIN
               SET @n_PickQty = @n_LotQtyAvai
            END
                                 
            IF @c_Sku <> @c_IDSku  
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM ORDERDETAIL (NOLOCK)
                              WHERE Orderkey = @c_Orderkey
                              AND Sku = @c_IDSku
                              )
               BEGIN
                  SELECT @c_Packkey = p.Packkey
                        ,@c_PackUOM3 = p.PackUOM3
                  FROM SKU s (NOLOCK) 
                  JOIN PACK p (NOLOCK) ON p.packkey = s.packkey     
                  WHERE s.storerkey = @c_Storerkey
                  AND s.Sku  = @c_IDSku

                  SELECT TOP 1 
                        @c_OrderLineNoAlloc = od.OrderLineNumber 
                  FROM ORDERDETAIL od (NOLOCK)
                  WHERE od.Orderkey = @c_Orderkey
                  ORDER BY od.OrderLineNumber DESC

                  SET @c_OrderLineNoAlloc = RIGHT('00000' +
                                                CONVERT(NVARCHAR(5),
                                                CONVERT(INT, @c_OrderLineNoAlloc) + 1)
                                                      ,5)
                  INSERT INTO ORDERDETAIL (Orderkey, Orderlinenumber, Storerkey, SKu
                                          ,ExternOrderkey, ExternLineNo, POkey, ExternPOKey, ConsoOrderkey
                                          ,Packkey, UOM, OriginalQty, OpenQty ,EnteredQTY
                                          ,Loadkey, MBOLKey
                                          ,Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
                                          ,Lottable06, Lottable07, Lottable08, Lottable09, Lottable10                                             
                                          ,Lottable11, Lottable12, Lottable13, Lottable14, Lottable15                                            
                                          ,UserDefine01, UserDefine02, UserDefine03, UserDefine04, Userdefine05
                                          ,UserDefine06, UserDefine07, UserDefine08, UserDefine09, Userdefine10, Facility              
                                          )
                  SELECT od.Orderkey, @c_OrderLineNoAlloc, od.Storerkey,@c_IDSku
                        ,ExternOrderkey, ExternLineNo, '', '','' 
                        ,@c_Packkey, @c_PackUOM3, @n_PickQty, @n_PickQty, @n_PickQty
                        ,Loadkey, MBOLKey
                        ,'', '', @c_IDLottable03, NULL, NULL                     
                        ,'', '', '', '', '' 
                        ,'', '', NULL,  NULL, NULL                                                
                        ,'0', @c_OrderLineNumber,'','',''
                        ,'', '', '', '', '' ,@c_Facility                        
                  FROM ORDERDETAIL od (NOLOCK)
                  WHERE Orderkey = @c_Orderkey
                  AND OrderLineNumber = @c_OrderLineNumber
               END
            END                                                                   

            IF @b_debug = 1
            BEGIN
               SELECT @c_Lot as lot, @n_LotQtyAvai as lotqtyavai, @n_ExtraQty as extraqty, @n_PickQty as pickqty
            END
                                
            IF @n_PickQty > 0 AND @c_OrderLineNoAlloc > ''                        
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
                     @c_OrderKey,            @c_OrderLineNoAlloc, @c_LOT,       
                     @c_StorerKey,           @c_IDSKU,            '',                   
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
                     SET @n_Continue = 3
                     SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                     SET @n_err = 81030  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Pickdetail Failed. (ispPRJCBUSS01)'
                                 + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
                  END
               END  
               IF @c_IDSku = @c_Sku                                             
               BEGIN
                  SET @n_QtyLeftToFulFill = @n_QtyLeftToFulFill - @n_PickQty 
               END  
               
               IF @n_Continue = 1 AND @c_IDLottable11 > ''                         --UWP-64392
               BEGIN
                  INSERT INTO #TMP_JCB_ALC (Orderkey, Pickdetailkey, Loc, ID, Lottable11, Qty)
                  VALUES (@c_Orderkey, @c_Pickdetailkey, @c_Loc, @c_ID, @c_IDLottable11, @n_PickQty)
               END                                                                          
            END               
               
            FETCH FROM @CUR_LOT INTO @c_Lot, @n_LotQtyAvai, @c_IDSku ,@c_IDLottable03
         END
         CLOSE @CUR_LOT
         DEALLOCATE @CUR_LOT
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
   
   IF @n_Continue = 1                                                               --UWP-64392
   BEGIN
      SET @CUR_ALC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT t.Orderkey
            ,t.Loc
            ,t.ID
            ,QtyAllocated = SUM(t.Qty)
      FROM #TMP_JCB_ALC t
      GROUP BY t.Orderkey
            ,  t.Loc
            ,  t.ID

      OPEN @CUR_ALC

      FETCH NEXT FROM @CUR_ALC INTO @c_Orderkey, @c_Loc, @c_ID, @n_QtyAllocated

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         SET @n_Qty = 0
         SELECT @n_Qty = SUM(lli.Qty)
         FROM LOTxLOCxID lli(NOLOCK)
         WHERE lli.Loc = @c_Loc
         AND lli.ID  = @c_ID

         IF @n_Qty = @n_QtyAllocated
         BEGIN
            SET @c_PickDetailKey = ''
            WHILE 1=1
            BEGIN
               SELECT TOP 1 @c_PickDetailKey = t.PickdetailKey
               FROM #TMP_JCB_ALC t
               WHERE t.Orderkey = @c_Orderkey
               AND   t.Loc = @c_Loc
               AND   t.ID  = @c_ID
               AND t.PickdetailKey > @c_PickDetailKey
               ORDER BY t.PickdetailKey

               SET @n_RowCount = @@ROWCOUNT

               IF @n_RowCount = 0
               BEGIN
                  BREAK
               END

               UPDATE pd
                  SET pd.UOM = '1'
                     ,Trafficcop = NULL
               FROM PICKDETAIL pd
               WHERE pd.PickdetailKey = @c_PickDetailKey
               AND   pd.UOM = '2'

               IF @n_err <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_err = 81040  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Failed. (ispPRJCBUSS01)'
               END
            END
         END
              
         FETCH NEXT FROM @CUR_ALC INTO @c_Orderkey, @c_Loc, @c_ID, @n_QtyAllocated
      END
      CLOSE @CUR_ALC
      DEALLOCATE @CUR_ALC
   END                              
QUIT:
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPRJCBUSS01'
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
GRANT EXECUTE ON  [dbo].[ispPRJCBUSS01] TO [NSQL]
GO