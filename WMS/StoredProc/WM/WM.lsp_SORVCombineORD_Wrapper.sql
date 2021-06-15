IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_SORVCombineORD_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_SORVCombineORD_Wrapper] 
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: WM.lsp_SORVCombineORD_Wrapper                       */                                                                                  
/* Creation Date: 2021-04-13                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-2713 - UAT [CN] LULU_Reverse_Combined_Order            */
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
/* 2021-04-13  Wan      1.0   Created.                                  */
/************************************************************************/                                                                                  
CREATE PROC [WM].[lsp_SORVCombineORD_Wrapper] 
      @c_OrderKey             NVARCHAR(10)             
   ,  @b_Success              INT = 1           OUTPUT  
   ,  @n_err                  INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg               NVARCHAR(255)     OUTPUT 
   ,  @n_WarningNo            INT          = 0  OUTPUT   -- SCE to Pass in initial Value '0', and continue to pass in its output value for the same orderkey if SP Increase warningno
   ,  @c_ProceedWithWarning   CHAR(1)      = 'N'         -- Pass In 'Y' if continue to call SP when increased warning # return             
   ,  @c_UserName             NVARCHAR(128)= ''                                                                                                                         
   ,  @n_ErrGroupKey          INT          = 0  OUTPUT   --Capture Warnings/Questions/Errors/Meassage into WMS_ERROR_LIST Table
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt                  INT            = @@TRANCOUNT  
         ,  @n_Continue                   INT            = 1

         ,  @c_TableName                  NVARCHAR(50)   = 'ORDERS'
         ,  @c_SourceType                 NVARCHAR(50)   = 'lsp_SORVCombineORD_Wrapper'

         ,  @c_SQL                        NVARCHAR(4000) = ''
         ,  @c_SQLParms                   NVARCHAR(4000) = ''

         ,  @c_Facility                   NVARCHAR(5)    = ''
         ,  @c_Storerkey                  NVARCHAR(15)   = ''
   
         ,  @c_RVCombineOrd_SP            NVARCHAR(30)   = ''
         
         ,  @CUR_RVCBMORD                 CURSOR

   SET @b_Success = 1
   SET @n_Err     = 0
               
   SET @n_Err = 0 
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
   
   BEGIN TRY
      
      SELECT @c_Facility    = OH.Facility
         ,   @c_Storerkey   = OH.Storerkey
      FROM ORDERS OH WITH (NOLOCK)
      WHERE OH.Orderkey = @c_OrderKey
      
      SELECT @c_RVCombineOrd_SP = Authority FROM dbo.fnc_SelectGetRight(@c_Facility, @c_Storerkey, '', 'RevCombineOrderSP')

      IF @c_RVCombineOrd_SP IN ( '0','1','' )
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 559401
         SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Custom Reverve CombineOrder SP Not setup'  
                     + '. (lsp_SORVCombineORD_Wrapper)'

         EXEC [WM].[lsp_WriteError_List] 
               @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
            ,  @c_TableName   = @c_TableName
            ,  @c_SourceType  = @c_SourceType
            ,  @c_Refkey1     = @c_OrderKey
            ,  @c_Refkey2     = ''
            ,  @c_Refkey3     = '' 
            ,  @c_WriteType   = 'ERROR' 
            ,  @n_err2        = @n_err 
            ,  @c_errmsg2     = @c_errmsg 
            ,  @b_Success     = @b_Success    
            ,  @n_err         = @n_err        
            ,  @c_errmsg      = @c_errmsg    
      END
      ELSE IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WITH (NOLOCK) WHERE [Name] = @c_RVCombineOrd_SP AND [Type] = 'P' )
      BEGIN 
         SET @n_Continue = 3
         SET @n_err = 559402
         SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Custom Reverse Combine Order SP: ' + @c_RVCombineOrd_SP + ' not found'  
                     + '. (lsp_SORVCombineORD_Wrapper) |' + @c_RVCombineOrd_SP

         EXEC [WM].[lsp_WriteError_List] 
               @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
            ,  @c_TableName   = @c_TableName
            ,  @c_SourceType  = @c_SourceType
            ,  @c_Refkey1     = @c_OrderKey
            ,  @c_Refkey2     = ''
            ,  @c_Refkey3     = '' 
            ,  @c_WriteType   = 'ERROR' 
            ,  @n_err2        = @n_err 
            ,  @c_errmsg2     = @c_errmsg 
            ,  @b_Success     = @b_Success    
            ,  @n_err         = @n_err        
            ,  @c_errmsg      = @c_errmsg  
      END
         
      IF @n_Continue = 1
      BEGIN
         BEGIN TRY
            SET @b_Success = 1
            SET @n_err = 0
         
            SET @c_SQL= N'EXEC ' + @c_RVCombineOrd_SP 
                        + ' @c_OrderKey = @c_OrderKey' 
                        + ',@b_Success  = @b_Success'  
                        + ',@n_err      = @n_err'      
                        + ',@c_errmsg   = @c_errmsg'                                
         
            SET @c_SQLParms = N'@c_OrderKey  NVARCHAR(10)'
                              + ',@b_Success   INT            OUTPUT'
                              + ',@n_err       INT            OUTPUT'
                              + ',@c_errmsg    NVARCHAR(255)  OUTPUT'
                                                         
            EXEC sp_ExecuteSql @c_SQL
                              ,@c_SQLParms
                              ,@c_OrderKey
                              ,@b_Success     = @b_Success   OUTPUT
                              ,@n_Err         = @n_Err       OUTPUT
                              ,@c_ErrMsg      = @c_ErrMsg    OUTPUT
         END TRY

         BEGIN CATCH
            SET @n_err = 559403
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         IF @b_Success = 0
         BEGIN
            SET @n_err = 559403
         END

         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err) + ': Error Executing ' + @c_RVCombineOrd_SP + '. (lsp_SORVCombineORD_Wrapper)'
                        + ' ( ' + @c_ErrMsg + ' )'

            EXEC [WM].[lsp_WriteError_List] 
                  @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
               ,  @c_TableName   = @c_TableName
               ,  @c_SourceType  = @c_SourceType
               ,  @c_Refkey1     = @c_OrderKey
               ,  @c_Refkey2     = ''
               ,  @c_Refkey3     = '' 
               ,  @c_WriteType   = 'ERROR' 
               ,  @n_err2        = @n_err 
               ,  @c_errmsg2     = @c_errmsg 
               ,  @b_Success     = @b_Success    
               ,  @n_err         = @n_err        
               ,  @c_errmsg      = @c_errmsg    
         END
      END
      
      IF @n_Continue = 1
      BEGIN
         SET @c_errmsg = 'Combine Order SuccessFully.'

         EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         ,  @c_TableName   = @c_TableName
         ,  @c_SourceType  = @c_SourceType
         ,  @c_Refkey1     = @c_OrderKey
         ,  @c_Refkey2     = ''
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
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_SORVCombineORD_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
      
   IF @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN 
   END

   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_SORVCombineORD_Wrapper] TO nSQL 
GO  