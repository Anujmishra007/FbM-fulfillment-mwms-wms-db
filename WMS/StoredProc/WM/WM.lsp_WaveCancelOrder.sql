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
/* PVCS Version: 1.2                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */                                                                                  
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */  
/* 2021-02-10  mingle01 1.1  Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2021-11-24  Wan02    1.2   LFWM-3141 - UAT - TW  Outbound - Order    */
/*                            Remove from Wave Bug                      */
/*                      1.2   DevOps Combine Script                     */
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
         
         ,  @c_Wavedetailkey  NVARCHAR(10)   = ''
   
         ,  @c_Refkey1        NVARCHAR(20)   = ''                    --(Wan02)
         ,  @c_Refkey2        NVARCHAR(20)   = ''                    --(Wan02)
         ,  @c_Refkey3        NVARCHAR(20)   = ''                    --(Wan02)
         ,  @c_WriteType      NVARCHAR(50)   = ''                    --(Wan02)
         ,  @n_LogWarningNo   INT            = 0                     --(Wan02)
         
         ,  @CUR_ERRLIST      CURSOR                                 --(Wan02)
         
   DECLARE  @t_WMSErrorList   TABLE                                  --(Wan02)
         (  RowID             INT            IDENTITY(1,1) 
         ,  TableName         NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  SourceType        NVARCHAR(50)   NOT NULL DEFAULT('')
         ,  Refkey1           NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  Refkey2           NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  Refkey3           NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  WriteType         NVARCHAR(50)   NOT NULL DEFAULT('')
         ,  LogWarningNo      INT            NOT NULL DEFAULT(0)
         ,  ErrCode           INT            NOT NULL DEFAULT(0)
         ,  Errmsg            NVARCHAR(255)  NOT NULL DEFAULT('')  
         )

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
   
   SET @n_ErrGroupKey = 0        --(Wan02)
   BEGIN TRAN                    --(Wan02) 
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

         --(Wan02) - START
         INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
         VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'ERROR', 0, @n_err, @c_errmsg)           
         --EXEC [WM].[lsp_WriteError_List] 
         --      @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         --   ,  @c_TableName   = @c_TableName
         --   ,  @c_SourceType  = @c_SourceType
         --   ,  @c_Refkey1     = @c_WaveKey
         --   ,  @c_Refkey2     = @c_Orderkey
         --   ,  @c_Refkey3     = '' 
         --   ,  @c_WriteType   = 'ERROR' 
         --   ,  @n_err2        = @n_err 
         --   ,  @c_errmsg2     = @c_errmsg 
         --   ,  @b_Success     = @b_Success    
         --   ,  @n_err         = @n_err        
         --   ,  @c_errmsg      = @c_errmsg     
         --(Wan02) - END
            
         GOTO EXIT_CANC             
      END
      
      --(Wan02) - START
      IF @c_WaveKey <> ''
      BEGIN
         SET @c_Wavedetailkey = ''
         SELECT @c_Wavedetailkey = w.WaveDetailKey
         FROM dbo.WAVEDETAIL AS w (NOLOCK)
         WHERE w.WaveKey = @c_WaveKey
         AND w.Orderkey = @c_Orderkey
         
         IF @c_Wavedetailkey <> '' AND @n_WarningNo = 0 AND @c_ProceedWithWarning = 'N'
         BEGIN
            EXECUTE [WM].[lsp_Pre_Delete_Wrapper]  
               @c_Module         = 'WAVE'
            ,  @c_Schema         = 'DBO'
            ,  @c_TableName      = 'WAVEDETAIL'
            ,  @c_RefKey1        = ''
            ,  @c_RefKey2        = @c_Wavedetailkey
            ,  @c_RefKey3        = ''
            ,  @c_ColumnsUpdated = ''
            ,  @c_RefreshHeader  = 'N' 
            ,  @c_RefreshDetail  = 'N'   
            ,  @b_Success        = @b_Success   OUTPUT   
            ,  @n_Err            = @n_Err       OUTPUT
            ,  @c_Errmsg         = @c_Errmsg    OUTPUT
            ,  @c_UserName       = @c_UserName
            ,  @c_IsSupervisor   = 'N' 
         
            IF @b_Success = 0
            BEGIN
               SET @n_continue = 3
               SET @n_err = 556103
               SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
                              + ': Error Executing WM.lsp_Pre_Delete_Wrapper. (lsp_WaveCancelOrder) '
                              + '( ' + @c_Errmsg + ')'
                              
               INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
               VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'ERROR', 0, @n_err, @c_errmsg)           

               GOTO EXIT_CANC      
            END
            
            IF @b_Success = 2 -- Question to confirm proceed.
            BEGIN
               SET @n_WarningNo = 1
               
               INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
               VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'Question', @n_WarningNo, @n_err, @c_errmsg)           
               
               GOTO EXIT_SP    
            END
         END
      END
      --(Wan02) - END

      SET @n_WarningNo = 0
      
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
                       
         --(Wan02) - START
         INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
         VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'ERROR', 0, @n_err, @c_errmsg)           
         --EXEC [WM].[lsp_WriteError_List] 
         --      @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         --   ,  @c_TableName   = @c_TableName
         --   ,  @c_SourceType  = @c_SourceType
         --   ,  @c_Refkey1     = @c_WaveKey
         --   ,  @c_Refkey2     = @c_Orderkey
         --   ,  @c_Refkey3     = '' 
         --   ,  @c_WriteType   = 'ERROR' 
         --   ,  @n_err2        = @n_err 
         --   ,  @c_errmsg2     = @c_errmsg 
         --   ,  @b_Success     = @b_Success    
         --   ,  @n_err         = @n_err        
         --   ,  @c_errmsg      = @c_errmsg         
         --(Wan02) - END                       
   
         IF (XACT_STATE()) = -1  
         BEGIN
            ROLLBACK TRAN

            WHILE @@TRANCOUNT < @n_StartTCnt
            BEGIN
               BEGIN TRAN
            END
         END 
         GOTO EXIT_CANC      
      END CATCH
      
      --(Wan02) - START
      IF @c_Wavedetailkey <> ''
      BEGIN           
         DELETE FROM dbo.WAVEDETAIL WITH (ROWLOCK)
         WHERE WaveDetailKey = @c_Wavedetailkey
            
         IF @@ERROR <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 556104
            SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
                           + ': Delete from Wavedetail fail. (lsp_WaveCancelOrder) '
                           + '( ' + ERROR_MESSAGE() + ')'

            INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
            VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'ERROR', 0, @n_err, @c_errmsg)           
            GOTO EXIT_CANC        
         END
      END
      --(Wan02) - END
      
      IF @n_continue = 1 
      BEGIN
         SET @c_errmsg = 'Order is cancelled.'
         
         --(Wan02) - START
         INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
         VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'MESSAGE', 0, @n_err, @c_errmsg)           
         --EXEC [WM].[lsp_WriteError_List] 
         --   @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         --,  @c_TableName   = @c_TableName
         --,  @c_SourceType  = @c_SourceType
         --,  @c_Refkey1     = @c_WaveKey
         --,  @c_Refkey2     = @c_Orderkey
         --,  @c_Refkey3     = '' 
         --,  @c_WriteType   = 'MESSAGE' 
         --,  @n_err2        = @n_err 
         --,  @c_errmsg2     = @c_errmsg 
         --,  @b_Success     = @b_Success    
         --,  @n_err         = @n_err        
         --,  @c_errmsg      = @c_errmsg         
         --(Wan02) - END  
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
            IF EXISTS (SELECT 1 FROM WM.WMS_Error_List WITH (NOLOCK) WHERE ErrGroupKey = @n_ErrGroupKey AND ErrCode > 0 AND WriteType = 'ERROR')   --(Wan02) 
            BEGIN
               SET @n_Continue = 3
               SET @c_ErrMsg = 'Cancel Order(s) is/are done with Errors.'
            END 
         END
         
         --(Wan02) - START
         INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
         VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'MESSAGE', 0, @n_err, @c_errmsg)           
         --EXEC [WM].[lsp_WriteError_List] 
         --   @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
         --,  @c_TableName   = @c_TableName
         --,  @c_SourceType  = @c_SourceType
         --,  @c_Refkey1     = @c_WaveKey
         --,  @c_Refkey2     = @c_Orderkey
         --,  @c_Refkey3     = '' 
         --,  @c_WriteType   = 'MESSAGE' 
         --,  @n_err2        = @n_err 
         --,  @c_errmsg2     = @c_errmsg 
         --,  @b_Success     = @b_Success    
         --,  @n_err         = @n_err        
         --,  @c_errmsg      = @c_errmsg         
         --(Wan02) - END 
         
      END
   END TRY
   
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      
      --(Wan02) - START
      INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)       
      VALUES (@c_TableName, @c_SourceType, @c_WaveKey, @c_Orderkey, '', 'ERROR', 0, @n_err, @c_errmsg)  
      --(Wan02) - END   
      GOTO EXIT_SP
   END CATCH
   --(mingle01) - END 
EXIT_SP:
   --(Wan02) - START
   IF (XACT_STATE()) = -1  
   BEGIN
      SET @n_Continue=3
      ROLLBACK TRAN
   END  
   --(Wan02) - END
   
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt       --(Wan02) 
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
   
   --(Wan02) - START
   SET @CUR_ERRLIST = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT   twl.TableName         
         ,  twl.SourceType        
         ,  twl.Refkey1           
         ,  twl.Refkey2           
         ,  twl.Refkey3           
         ,  twl.WriteType         
         ,  twl.LogWarningNo      
         ,  twl.ErrCode           
         ,  twl.Errmsg               
   FROM @t_WMSErrorList AS twl
   ORDER BY twl.RowID
   
   OPEN @CUR_ERRLIST
   
   FETCH NEXT FROM @CUR_ERRLIST INTO   @c_TableName         
                                     , @c_SourceType        
                                     , @c_Refkey1           
                                     , @c_Refkey2           
                                     , @c_Refkey3           
                                     , @c_WriteType         
                                     , @n_LogWarningNo      
                                     , @n_Err           
                                     , @c_Errmsg            
   
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      EXEC [WM].[lsp_WriteError_List] 
         @i_iErrGroupKey= @n_ErrGroupKey OUTPUT 
      ,  @c_TableName   = @c_TableName
      ,  @c_SourceType  = @c_SourceType
      ,  @c_Refkey1     = @c_Refkey1
      ,  @c_Refkey2     = @c_Refkey2
      ,  @c_Refkey3     = @c_Refkey3
      ,  @n_LogWarningNo= @n_LogWarningNo
      ,  @c_WriteType   = @c_WriteType
      ,  @n_err2        = @n_err 
      ,  @c_errmsg2     = @c_errmsg 
      ,  @b_Success     = @b_Success    
      ,  @n_err         = @n_err        
      ,  @c_errmsg      = @c_errmsg         
     
      FETCH NEXT FROM @CUR_ERRLIST INTO   @c_TableName         
                                        , @c_SourceType        
                                        , @c_Refkey1           
                                        , @c_Refkey2           
                                        , @c_Refkey3           
                                        , @c_WriteType         
                                        , @n_LogWarningNo      
                                        , @n_Err           
                                        , @c_Errmsg     
   END
   CLOSE @CUR_ERRLIST
   DEALLOCATE @CUR_ERRLIST
   
   --(Wan02) - END
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END      
   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_WaveCancelOrder] TO nSQL 
GO  