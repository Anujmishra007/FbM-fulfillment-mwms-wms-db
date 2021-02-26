IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WaveReleaseToWCS]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WaveReleaseToWCS] 
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: lsp_WaveReleaseToWCS                                */                                                                                  
/* Creation Date: 2019-04-18                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-1794 - SPs for Wave Control Screens - Release to WCS   */
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
/* 2021-02-10  mingle01 1.1   Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/************************************************************************/                                                                                  
CREATE PROC [WM].[lsp_WaveReleaseToWCS]                                                                                                                     
      @c_WaveKey              NVARCHAR(10)
   ,  @b_Success              INT = 1           OUTPUT  
   ,  @n_err                  INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg               NVARCHAR(255)     OUTPUT 
   ,  @n_WarningNo            INT          = 0  OUTPUT
   ,  @c_ProceedWithWarning   CHAR(1)      = 'N'                      
   ,  @c_UserName             NVARCHAR(50) = ''                                                                                                                         
   ,  @n_ErrGroupKey          BIGINT       = 0  OUTPUT
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt         INT = @@TRANCOUNT  
         ,  @n_Continue          INT = 1

         ,  @n_PreAllocOrderCnt  INT = 0

         ,  @c_TableName      NVARCHAR(50)   = 'WAVE'
         ,  @c_SourceType     NVARCHAR(50)   = 'lsp_WaveReleaseToWCS'

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
   
   --(mingle01) - START
   BEGIN TRY

      IF @c_ProceedWithWarning = 'N' AND @n_WarningNo < 1
      BEGIN
         SET @c_ErrMsg = 'Confirm Release to WCS ?'

         SET @n_PreAllocOrderCnt = 0
         SELECT @n_PreAllocOrderCnt = COUNT(DISTINCT WD.Orderkey)
         FROM WAVEDETAIL WD WITH (NOLOCK)
         JOIN PREALLOCATEPICKDETAIL PD WITH (NOLOCK) ON (WD.Orderkey = PD.Orderkey)
         WHERE WD.Wavekey = @c_Wavekey
         AND PD.Qty > 0

         IF @n_PreAllocOrderCnt > 0
         BEGIN
            SET @c_ErrMsg = 'Found ' + CONVERT(NVARCHAR(10), @n_PreAllocOrderCnt) + ' Pre-Allocated Orders, Confirm Release to WCS ?'
         END

         EXEC [WM].[lsp_WriteError_List] 
               @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
            ,  @c_TableName   = @c_TableName
            ,  @c_SourceType  = @c_SourceType
            ,  @c_Refkey1     = @c_WaveKey
            ,  @c_Refkey2     = '' 
            ,  @c_Refkey3     = '' 
            ,  @c_WriteType   = 'QUESTION' 
            ,  @n_err2        = @n_err 
            ,  @c_errmsg2     = @c_errmsg 
            ,  @b_Success     = @b_Success   OUTPUT 
            ,  @n_err         = @n_err       OUTPUT 
            ,  @c_errmsg      = @c_errmsg    OUTPUT       

         SET @n_WarningNo = 1
         GOTO EXIT_SP 
      END

      BEGIN TRY
         EXEC [dbo].[isp_WaveReleaseToWCS_Wrapper]    
              @c_WaveKey = @c_WaveKey    
            , @b_Success = @b_Success OUTPUT
            , @n_Err     = @n_Err     OUTPUT 
            , @c_ErrMsg  = @c_ErrMsg  OUTPUT 
      END TRY

      BEGIN CATCH
         SET @b_Success = 0
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH
     
      IF @b_Success = 0 
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 556401
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Error Executing isp_WaveReleaseToWCS_Wrapper. (lsp_WaveReleaseToWCS)'   
                        + '(' + @c_ErrMsg + ')'       
         GOTO EXIT_SP   
      END

      SET @c_ErrMsg = 'Wave Release To WCS action Completed.'
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
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_WaveReleaseToWCS'
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
GRANT EXECUTE ON [WM].[lsp_WaveReleaseToWCS] TO nSQL 
GO  