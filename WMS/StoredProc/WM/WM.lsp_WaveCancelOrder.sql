IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WaveCancelOrder]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WaveCancelOrder] 
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: lsp_WaveCancelOrder                                 */                                                                                  
/* Creation Date: 2019-04-05                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-1794 - SPs for Wave Control Screens                    */
/*          - ( Processing View OrdersLoadShipRefUnit)                  */
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.0                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */                                                                                  
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */  
/* 2021-02-10   mingle01 1.1  Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/************************************************************************/                                                                                  
CREATE PROC [WM].[lsp_WaveCancelOrder] 
      @c_WaveKey              NVARCHAR(10)                                                                                                                    
   ,  @c_Orderkey             NVARCHAR(10)
   ,  @n_TotalSelectedKeys    INT = 1
   ,  @n_KeyCount             INT = 1           OUTPUT
   ,  @b_Success              INT = 1           OUTPUT  
   ,  @n_err                  INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg               NVARCHAR(255)= '' OUTPUT 
   ,  @n_WarningNo            INT          = 0  OUTPUT
   ,  @c_ProceedWithWarning   CHAR(1)      = 'N'                     
   ,  @c_UserName             NVARCHAR(128) = ''                                                                                                                         
   ,  @n_ErrGroupKey          INT          = 0  OUTPUT
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt      INT = @@TRANCOUNT  
         ,  @n_Continue       INT = 1

         ,  @c_TableName      NVARCHAR(50)   = 'Orders'
         ,  @c_SourceType     NVARCHAR(50)   = 'lsp_WaveCancelOrder'

   SET @b_Success = 1
   SET @n_Err     = 0
               
   SET @n_Err = 0 
   --(mingle01) - START   
   IF SUSER_SNAME() <> @c_UserName
   BEGIN
      EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END
    
      EXECUTE AS LOGIN = @c_UserName
   END
   --(mingle01) - END

   -- UI Ask Confirmation Message...
   --IF @c_ProceedWithWarning = 'N' AND @n_WarningNo < 1
   --BEGIN
   --   SET @n_WarningNo = 1
   --   SET @c_ErrMsg = 'Cancel Selected Orders ?' 

   --   GOTO EXIT_SP
   --END
   
   --(mingle01) - START
   BEGIN TRY
      IF EXISTS(  SELECT 1 FROM ORDERS OH WITH (NOLOCK)
                  WHERE OH.Orderkey = @c_Orderkey
                  AND  (OH.[Status] = 'CANC'
                  AND   OH.[SOStatus] IN ('CANC'))
                  )
      BEGIN
         SET @n_continue = 3
         SET @n_err = 556101
         SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
                        + ': Orders had been cancelled. (lsp_WaveCancelOrder)'

         EXEC [WM].[lsp_WriteError_List] 
               @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
            ,  @c_TableName   = @c_TableName
            ,  @c_SourceType  = @c_SourceType
            ,  @c_Refkey1     = @c_WaveKey
            ,  @c_Refkey2     = @c_Orderkey
            ,  @c_Refkey3     = '' 
            ,  @c_WriteType   = 'ERROR' 
            ,  @n_err2        = @n_err 
            ,  @c_errmsg2     = @c_errmsg 
            ,  @b_Success     = @b_Success    
            ,  @n_err         = @n_err        
            ,  @c_errmsg      = @c_errmsg     
            
         GOTO EXIT_CANC             
      END

      BEGIN TRY
         UPDATE ORDERS 
            SET [Status] = 'CANC'
               ,[SOStatus] = 'CANC'
         WHERE Orderkey = @c_Orderkey 
      END TRY

      BEGIN CATCH
         SET @n_continue = 3
         SET @n_Err = 556102
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': UPDATE Orders fail. (lsp_WaveCancelOrder)'   
                       + '(' + @c_ErrMsg + ')' 
                       
         EXEC [WM].[lsp_WriteError_List] 
               @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
            ,  @c_TableName   = @c_TableName
            ,  @c_SourceType  = @c_SourceType
            ,  @c_Refkey1     = @c_WaveKey
            ,  @c_Refkey2     = @c_Orderkey
            ,  @c_Refkey3     = '' 
            ,  @c_WriteType   = 'ERROR' 
            ,  @n_err2        = @n_err 
            ,  @c_errmsg2     = @c_errmsg 
            ,  @b_Success     = @b_Success    
            ,  @n_err         = @n_err        
            ,  @c_errmsg      = @c_errmsg    

            IF (XACT_STATE()) = -1  
            BEGIN
               ROLLBACK TRAN

               WHILE @@TRANCOUNT < @n_StartTCnt
               BEGIN
                  BEGIN TRAN
               END
            END  
      END CATCH

      IF @n_continue = 1 
      BEGIN
         SET @c_errmsg = 'Order is cancelled.'
         EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_WaveKey
         ,  @c_Refkey2     = @c_Orderkey
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'MESSAGE' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg  
      END  
       
   EXIT_CANC:   
      --2020-04-24 - fixed  - START    
      IF @n_KeyCount < @n_TotalSelectedKeys
      BEGIN
         SET @n_KeyCount = @n_KeyCount + 1
      END
      --2020-04-24 - fixed  - END
      
      IF @n_KeyCount = @n_TotalSelectedKeys
      BEGIN
         SET @c_ErrMsg = 'Cancel Order(s) is/are done.'
         IF @n_ErrGroupKey > 0  
         BEGIN 
            IF EXISTS (SELECT 1 FROM WM.WMS_Error_List WITH (NOLOCK) WHERE ErrGroupKey = @n_ErrGroupKey AND  ErrCode > 0)
            BEGIN
               SET @n_Continue = 3
               SET @c_ErrMsg = 'Cancel Order(s) is/are done with Errors.'
            END 
         END
         
         EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_WaveKey
         ,  @c_Refkey2     = @c_Orderkey
         ,  @c_Refkey3     = '' 
         ,  @c_WriteType   = 'MESSAGE' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success    
         ,  @n_err         = @n_err        
         ,  @c_errmsg      = @c_errmsg    
      END
   END TRY
   
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(mingle01) - END 
EXIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      SET @n_WarningNo = 0
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_WaveCancelOrder'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END      
   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_WaveCancelOrder] TO nSQL 
GO  