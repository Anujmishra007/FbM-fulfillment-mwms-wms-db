SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: msp_BEJ_AutoInventoryReplenishment                 */
/* Creation Date: 29-Jan-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: FCR-9772 UWP-37046 - Auto Inventory Replenishment for VIVO  */
/*                                                                      */  
/* Called By: Call by SQL Scheduler Job                                 */
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Rev   Purposes                                  */
/*2026-01-29    SSA01   1.0   Created - UWP-47046 - Auto Inventory      */
/*                            Replenishment for VIVO                    */
/************************************************************************/  
CREATE OR ALTER PROC [dbo].[msp_BEJ_AutoInventoryReplenishment]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000)  = ''
   , @b_debug       INT = 0

AS    
BEGIN    
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF     
    
   DECLARE  @n_Continue       INT
            , @b_Success     INT
            , @n_Err         INT
            , @c_ErrMsg      NVARCHAR(250)
            , @n_StartTCnt    INT -- Holds the current transaction count
            , @c_OrderKey     NVARCHAR(10)
            , @n_Qty          INT
            , @n_QtyAvailable INT
            , @c_Source       NVARCHAR(10) = ''
            , @c_ReplenishStrategyKey  NVARCHAR(30) = ''
            , @c_ReplGroup            NVARCHAR(10) = 'ALL'
            , @c_Zone02               NVARCHAR(10) = 'ALL'
            , @c_Sku              NVARCHAR(20) = ''
            , @n_Min          INT
            , @n_Max         INT
            , @c_Loc     NVARCHAR(10) = ''
            , @c_DynamicPickLocType NVARCHAR(10) = ''
            , @c_PickLocType NVARCHAR(10) = ''
            , @c_DynamicPickLoc NVARCHAR(10) = ''
            , @n_QtyToReplen  INT = 0
            , @n_QtyAllocated         INT = 0
            , @n_QtyAvailableIced INT = 0
            , @n_QtyAllocatedIced INT = 0


   SELECT @n_StartTCnt=@@TRANCOUNT , @n_Continue=1, @b_Success=1, @n_Err=0

   SELECT @c_ErrMsg=''

   SELECT @c_ReplenishStrategyKey = dbO.fnc_GetParamValueFromString ('@c_ReplenishStrategyKey',@c_OtherConfig, @c_ReplenishStrategyKey)
   SELECT @c_DynamicPickLocType = dbO.fnc_GetParamValueFromString ('@c_DynamicPickLocType',@c_OtherConfig, @c_DynamicPickLocType)
   SELECT @c_PickLocType = dbO.fnc_GetParamValueFromString ('@c_PickLocType',@c_OtherConfig, @c_PickLocType)


   IF @b_debug = 1
          BEGIN
            print('@c_StorerKey :'+@c_StorerKey )
            print('@c_Facility:'+@c_Facility)
            print('@c_ReplenishStrategyKey:'+@c_ReplenishStrategyKey)
            print('@c_DynamicPickLocType:'+@c_DynamicPickLocType)
            print(' @c_PickLocType:'+ @c_PickLocType)
          END

       /* Standard replenishment and release using MinMax criteria*/
       IF @n_Continue=1 OR @n_Continue=2
       BEGIN
           BEGIN TRY
            EXEC [WM].[lsp_Start_Replenishment_Wrapper]
             @c_Storerkey = @c_StorerKey
           , @c_Facility = @c_Facility
           , @c_ReplenishStrategyKey = @c_ReplenishStrategyKey
           , @c_ReplGroup = @c_ReplGroup
           , @c_Zone02 = @c_Zone02
           , @c_Zone03 = ''
           , @c_Zone04 = ''
           , @c_Zone05 = ''
           , @c_Zone06 = ''
           , @c_Zone07 = ''
           , @c_Zone08 = ''
           , @c_Zone09 = ''
           , @c_Zone10 = ''
           , @c_Zone11 = ''
           , @c_Zone12 = ''
           , @n_WarningNo = 0
           , @c_ProceedWithWarning = 'N'
           , @c_UserName = ''
           , @b_Success = 1
           , @n_Err = 0
           , @c_Errmsg = ''
          END TRY
          BEGIN CATCH
              SELECT @n_continue = 3
              SET @c_ErrMsg = ERROR_MESSAGE()
              SET @n_err = 550156
              SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_ReplenishStrategyKey+ '(' + @c_errmsg + '): Execute lsp_Start_Replenishment_Wrapper Failed. (msp_BEJ_AutoInventoryReplenishment)'
              EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoInventoryReplenishment'
          END CATCH
        END
       IF @n_Continue=1 OR @n_Continue=2
       BEGIN
         BEGIN TRY
         EXEC [WM].[lsp_ReleaseReplenTask_Wrapper]
            @c_Storerkey = @c_StorerKey
           , @c_Facility = @c_Facility
           , @c_ReplenishStrategyKey = @c_ReplenishStrategyKey
           , @c_ReplGroup = @c_ReplGroup
           , @c_Zone02 = @c_Zone02
           , @c_Zone03 = ''
           , @c_Zone04 = ''
           , @c_Zone05 = ''
           , @c_Zone06 = ''
           , @c_Zone07 = ''
           , @c_Zone08 = ''
           , @c_Zone09 = ''
           , @c_Zone10 = ''
           , @c_Zone11 = ''
           , @c_Zone12 = ''
           , @c_UserName = ''
           , @b_Success = 1
           , @n_Err = 0
           , @c_Errmsg = ''

         END TRY
          BEGIN CATCH
              SELECT @n_continue = 3
              SET @c_ErrMsg = ERROR_MESSAGE()
              SET @n_err = 550157
              SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_ReplenishStrategyKey+ '(' + @c_errmsg + '): Execute lsp_ReleaseReplenTask_Wrapper Failed. (msp_BEJ_AutoInventoryReplenishment)'
              EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoInventoryReplenishment'
          END CATCH
        END

        /* Open Orders to update priority to tasks*/
       IF @n_Continue=1 OR @n_Continue=2
       BEGIN
           IF OBJECT_ID('tempdb..#skuQty','u') IS NOT NULL
           BEGIN
             DROP TABLE #skuQty;
           END

           CREATE TABLE #skuQty
           (
             OrderKey       NVARCHAR(10)   NOT NULL
           , Sku            NVARCHAR(20)   NOT NULL DEFAULT('')
           , Qty       INT            NOT NULL DEFAULT(0)
           , Loc      NVARCHAR(10)   NOT NULL DEFAULT('')
           , Min          int NOT NULL DEFAULT(0)
           , Max          int NOT NULL DEFAULT(0)
          )

          INSERT INTO #skuQty
          SELECT  o.OrderKey, od.sku, sum(od.openQty), ISNULL(sl.Loc,''),
            MIN(ISNULL(sl.QtyLocationMinimum,0)) AS min,
            MAX(ISNULL(sl.QtyLocationLimit,0)) AS max
          FROM ORDERS o WITH (NOLOCK)
          JOIN ORDERDETAIL od WITH (NOLOCK) on od.OrderKey = o.Orderkey
          LEFT JOIN SKUxLOC sl WITH (NOLOCK) ON sl.StorerKey = o.StorerKey
            AND sl.SKU = od.SKU
            AND sl.LocationType = @c_PickLocType
          WHERE o.StorerKey = @c_StorerKey
          AND o.Facility = @c_Facility
          AND o.Type IN ('B2B','B2C')
          AND o.Status = '0'
          GROUP BY o.OrderKey,od.sku,sl.Loc,sl.QtyLocationMinimum,sl.QtyLocationLimit
          HAVING sum(od.openqty) > 0
          ORDER BY o.OrderKey

       DECLARE CUR_OPEN_ORDERS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT OrderKey, Sku, Qty, Loc, Min, Max  FROM #skuQty

       OPEN CUR_OPEN_ORDERS

       FETCH NEXT FROM CUR_OPEN_ORDERS INTO @c_OrderKey, @c_Sku, @n_Qty, @c_Loc, @n_Min, @n_Max

       WHILE @@FETCH_STATUS <> -1
       BEGIN
          IF @b_debug = 1
          BEGIN
           print('@c_Orderkey:'+@c_Orderkey)
           print('@c_Sku:'+@c_Sku)
           print('@c_Loc:'+@c_Loc)
           print('@n_Qty:'+CONVERT(NVARCHAR(10),@n_Qty))
           print('@n_Min:'+CONVERT(NVARCHAR(10),@n_Min))
           print('@n_Max:'+CONVERT(NVARCHAR(10),@n_Max))
           END
          SELECT @n_continue = 1
          /* Assinged pick location sku's*/
          IF @c_Loc <> ''
          BEGIN
              SET @n_QtyAvailable = 0
              SET @n_QtyAllocated = 0
              SELECT @n_QtyAvailable = ISNULL(SUM(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen),0),@n_QtyAllocated = ISNULL(SUM(LLI.QTYALLOCATED),0)
                       FROM LOTxLOCxID LLI (NOLOCK)
                       JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                       JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                       JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                       JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                       WHERE LOC.LocationFlag = 'NONE'
                       AND LOC.Status = 'OK'
                       AND LOT.Status = 'OK'
                       AND ID.Status = 'OK'
                       AND LOC.Facility = @c_Facility
                       AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) > 0
                       AND LLI.STORERKEY =  @c_StorerKey
                       AND LLI.Sku = @c_Sku
                       AND LLI.Loc = @c_Loc
                       AND LOC.LocationType =  @c_PickLocType
                       GROUP BY LLI.Storerkey, LLI.sku

                  IF (@n_Continue=1 OR @n_Continue=2) AND @n_QtyAvailable < @n_Qty AND @n_QtyAvailable > @n_Min
                  BEGIN
                      /*  generate new task*/
                        SELECT @n_QtyToReplen = @n_Max - @n_QtyAvailable + @n_QtyAllocated

                         BEGIN TRY
                                EXEC [isp_VIVORPL01]
                                @c_Facility = @c_Facility
                                , @c_Storerkey = @c_StorerKey
                                , @c_SKU       = @c_Sku
                                , @c_LOC       = @c_Loc
                                , @c_ReplenishmentGroup   = @c_ReplGroup
                                , @n_QtyReplen   = @n_QtyToReplen
                                , @c_TaskPriority  = '9'
                                , @b_Success = 1
                                , @n_Err = 0
                                , @c_Errmsg = ''

                         END TRY
                                BEGIN CATCH
                                    SELECT @n_continue = 3
                                    SET @c_ErrMsg = ERROR_MESSAGE()
                                    SET @n_err = 550158
                                    SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_ReplenishStrategyKey+ '(' + @c_errmsg + '): Execute lsp_ReleaseReplenTask_Wrapper Failed. (msp_BEJ_AutoInventoryReplenishment)'
                                    EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoInventoryReplenishment'
                         END CATCH

                  END
                  IF (@n_Continue=1 OR @n_Continue=2) AND @n_QtyAvailable < @n_Qty AND @n_QtyAvailable < @n_Min
                  BEGIN

                      /* Update priority to existing replenishment tasks and priority need to be increased to '5' */
                       BEGIN TRY
                        IF EXISTS (SELECT 1 FROM TASKDETAIL TD WITH (NOLOCK)
                           WHERE TD.STORERKEY =  @c_StorerKey
                           AND TD.Sku = @c_Sku
                           AND TD.ToLoc = @c_Loc
                           AND TD.TaskType = 'RPF'
                           AND TD.Priority = '9')
                           BEGIN
                               UPDATE TASKDETAIL WITH (ROWLOCK)
                                SET Priority = '5'
                                WHERE STORERKEY =  @c_StorerKey
                                AND Sku = @c_Sku
                                AND ToLoc = @c_Loc
                                AND TaskType = 'RPF'
                                AND Priority = '9'
                           END
                          END TRY
                          BEGIN CATCH
                          SELECT @n_continue = 3
                          SET @c_ErrMsg = ERROR_MESSAGE()
                          SET @n_err = 550159
                          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_ReplenishStrategyKey+ '(' + @c_errmsg + '): Update on TaskDetail Failed. (msp_BEJ_AutoInventoryReplenishment)'
                          EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoInventoryReplenishment'
                        END CATCH
                  END
          END
          ELSE
            BEGIN
              SET @n_QtyAvailableIced  = 0
              SET @n_QtyAllocatedIced = 0
              /* No pick location assigned - get highest priority pick loc*/
              SELECT @n_QtyAvailableIced = ISNULL(SUM(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen),0),@n_QtyAllocatedIced = ISNULL(SUM(LLI.QTYALLOCATED),0)
                       FROM LOTxLOCxID LLI (NOLOCK)
                       JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                       JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                       JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                       JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                       WHERE LOC.LocationFlag = 'NONE'
                       AND LOC.Status = 'OK'
                       AND LOT.Status = 'OK'
                       AND ID.Status = 'OK'
                       AND LOC.Facility = @c_Facility
                       AND LLI.STORERKEY =  @c_StorerKey
                       AND LLI.Sku = @c_Sku
                       AND LOC.LocationType =  @c_DynamicPickLocType
                       GROUP BY LLI.Storerkey, LLI.sku

              SELECT TOP 1 @c_DynamicPickLoc = LOC from LOC WITH (NOLOCK)
              WHERE LOC.LocationFlag = 'NONE'
                   AND LOC.Status = 'OK'
                   AND LOC.Facility = @c_Facility
                   AND LOC.LocationType = @c_DynamicPickLocType
                   GROUP BY LOC.LOC
                   ORDER BY LOC.LOC DESC
              IF EXISTS(SELECT 1 FROM LOTxLOCxID LLI (NOLOCK)
                   WHERE LLI.STORERKEY =  @c_StorerKey
                   AND LLI.Sku = @c_Sku
                   AND LLI.Loc = @c_DynamicPickLoc
                  )
              BEGIN
                 IF EXISTS (SELECT 1 FROM LOTxLOCxID LLI (NOLOCK)
                   JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                   JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                   JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                   JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                   WHERE LOC.LocationFlag = 'NONE'
                   AND LOC.Status = 'OK'
                   AND LOT.Status = 'OK'
                   AND ID.Status = 'OK'
                   AND LOC.Facility = @c_Facility
                   AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) = 0
                   AND LLI.STORERKEY =  @c_StorerKey
                   AND LLI.Sku = @c_Sku
                   AND LLI.Loc = @c_DynamicPickLoc
                   AND LOC.LocationType = @c_DynamicPickLocType
                   GROUP BY LLI.Storerkey, LLI.sku)
                   BEGIN
                    SET @c_DynamicPickLoc = @c_DynamicPickLoc
                   END
                   ELSE
                    BEGIN
                      SET @c_DynamicPickLoc = ''
                    END
                END

                IF @c_DynamicPickLoc <> '' AND @n_QtyAvailableIced < @n_Qty
                BEGIN

                    /*  generate new task and update priority = 7*/
                        SELECT @n_QtyToReplen = @n_Qty - @n_QtyAvailableIced + @n_QtyAllocatedIced
                        IF @n_Continue=1 OR @n_Continue=2
                        BEGIN
                            BEGIN TRY
                            EXEC [isp_VIVORPL01]
                                @c_Facility = @c_Facility
                            , @c_Storerkey = @c_StorerKey
                            , @c_SKU       = @c_Sku
                            , @c_LOC       = @c_DynamicPickLoc
                            , @c_ReplenishmentGroup   = @c_ReplGroup
                            , @n_QtyReplen   = @n_QtyToReplen
                            , @c_TaskPriority  = '7'
                            , @b_Success = 1
                            , @n_Err = 0
                            , @c_Errmsg = ''

                            END TRY
                            BEGIN CATCH
                                SELECT @n_continue = 3
                                SET @c_ErrMsg = ERROR_MESSAGE()
                                SET @n_err = 550160
                                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_ReplenishStrategyKey+ '(' + @c_errmsg + '): Execute lsp_ReleaseReplenTask_Wrapper Failed. (msp_BEJ_AutoInventoryReplenishment)'
                                EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoInventoryReplenishment'
                            END CATCH
                        END
                 END
            END
          FETCH NEXT FROM CUR_OPEN_ORDERS INTO @c_OrderKey, @c_Sku, @n_Qty, @c_Loc, @n_Min, @n_Max
       END
       CLOSE CUR_OPEN_ORDERS
       DEALLOCATE CUR_OPEN_ORDERS
    END

EXIT_SP:

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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoInventoryReplenishment'
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

END -- Procedure
GO
GRANT EXECUTE ON [dbo].[msp_BEJ_AutoInventoryReplenishment] TO nSQL
GO
