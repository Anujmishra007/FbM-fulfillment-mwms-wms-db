SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: WM.lsp_PalletMgmt_TIP_Wrapper                       */                                                                                  
/* Creation Date: 2022-01-24                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-3158 - TH-SCE All Account - Pallet Management-Transfer */
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
/* 2022-01-24  Wan01    1.0   Created.                                  */
/* 2022-01-24  Wan01    1.0   DevOps Combine Script.                    */
/* 2025-09-02  SWT01    1.1   Enhanced session management pattern       */
/************************************************************************/                                                                                  
CREATE OR ALTER PROC [WM].[lsp_PalletMgmt_TIP_Wrapper]                                                                                                                     
      @c_PMkey                NVARCHAR(10) = ''
   ,  @c_StorerRestrict       NVARCHAR(250) = '' --Pass in list of user restricted storers with comma ',' seperator  
   ,  @c_FacilityRestrict     NVARCHAR(250) = '' --Pass in list of user restricted facilities with comma ',' seperator  
   ,  @b_Success              INT = 1           OUTPUT  
   ,  @n_err                  INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg               NVARCHAR(255)     OUTPUT 
   ,  @c_UserName             NVARCHAR(128)= ''                                                                                                                         
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt            INT = @@TRANCOUNT  
         ,  @n_Continue             INT = 1
         

   SET @b_Success = 1
   SET @n_Err     = 0
   
   SET @n_Err = 0 
 
   -- Start enhanced session management (SWT01)
	 DECLARE @b_ExecuteAs        BIT = 0
	 IF SUSER_SNAME() <> @c_UserName        
	 BEGIN
	    EXEC [WM].[lsp_SetUser] 
	         @c_UserName = @c_UserName  OUTPUT
	      ,  @n_Err      = @n_Err       OUTPUT
	      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
	      , @b_ExecuteAs = @b_ExecuteAs OUTPUT

	    IF @n_Err <> 0
	    BEGIN
	       GOTO EXIT_SP
	    END

	    IF @b_ExecuteAs = 1
	       EXECUTE AS LOGIN = @c_UserName
	 END                                    
	 -- End enhanced session management (SWT01)

   BEGIN TRAN  
     
   BEGIN TRY
      
      EXEC  [dbo].[ispPalletMgmt_TransferInProgress]  
            @c_PMKey   = @c_PMKey 
         ,  @b_Success = @b_Success OUTPUT
         ,  @n_Err     = @n_Err     OUTPUT 
         ,  @c_ErrMsg  = @c_ErrMsg  OUTPUT
         ,  @c_SourceApp        = 'WM'
         ,  @c_StorerRestrict   = @c_StorerRestrict  
         ,  @c_FacilityRestrict = @c_FacilityRestrict            

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 560301
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Error Executing ispPalletMgmt_TransferInProgress. (lsp_PalletMgmt_TIP_Wrapper)'   
                        + '(' + @c_ErrMsg + ')'          
         GOTO EXIT_SP   
      END
   END TRY
   
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH

EXIT_SP:
   IF (XACT_STATE()) = -1                                     
   BEGIN
      SET @n_Continue = 3
      ROLLBACK TRAN
   END 

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt      
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
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_PalletMgmt_TIP_Wrapper'
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
         
   IF @b_ExecuteAs = 1 REVERT -- (SWT01)
   EXEC [WM].[lsp_ResetUser] -- (SWT01)
END
GO
GRANT EXECUTE ON [WM].[lsp_PalletMgmt_TIP_Wrapper] TO nSQL 
GO  