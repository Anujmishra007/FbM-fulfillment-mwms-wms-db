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
           , @n_WarningNo = 2
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

            /* Call procedure to generate replenishment for open orders which are not fulfilled due to inventory availability and update priority to existing tasks if replenishment already exist for the open orders*/
             BEGIN TRY
                EXEC [dbo].[mspSKURPL01]
                    @c_StorerKey = @c_StorerKey
                   , @c_Facility = @c_Facility
                   , @c_PickLocType = @c_PickLocType
                   , @c_DynamicPickLocType = @c_DynamicPickLocType
                   , @c_ReplGroup = @c_ReplGroup
                   , @b_Success = 1
                   , @n_Err = 0
                   , @c_Errmsg = ''
             END TRY
             BEGIN CATCH
                  SELECT @n_continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
                  SET @n_err = 550160
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+ '(' + @c_errmsg + '): Execute mspSKURPL01 Failed. (msp_BEJ_AutoInventoryReplenishment)'
                  EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoInventoryReplenishment'
             END CATCH
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

