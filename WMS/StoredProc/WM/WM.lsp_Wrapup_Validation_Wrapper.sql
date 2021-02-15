IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Wrapup_Validation_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_Wrapup_Validation_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_Wrapup_Validation_Wrapper                       */  
/* Creation Date: 25-Oct-2017                                            */  
/* Copyright: LFL                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose:                                                              */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.3                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date       Author   Ver   Purposes                                    */ 
/* 2020-06-16 Wan01    1.1   WMS-2049. Fix not to return correct         */
/*                           @b_success when error executing             */
/*                           isp_Wrapup_Validation                       */
/* 2020-11-18 SWT01    1.2   Bug fixing                                  */ 
/* 2020-11-23 Wan02    1.2   Add Big Outer Begin Try..End Try to enable  */
/*                           Revert when Sub SP Raise error              */ 
/* 2021-01-15 Wan03    1.3   Execute Login if @c_UserName<>SUSER_SNAME() */
/*************************************************************************/   
CREATE PROCEDURE [WM].[lsp_Wrapup_Validation_Wrapper]  
      @c_Module               NVARCHAR(60) = ''
   ,  @c_ControlObject        NVARCHAR(60) = ''
   ,  @c_UpdateTable          NVARCHAR(30)
   ,  @c_XMLSchemaString      NVARCHAR(MAX) 
   ,  @c_XMLDataString        NVARCHAR(MAX) 
   ,  @b_Success              INT OUTPUT    
   ,  @n_Err                  INT OUTPUT
   ,  @c_Errmsg               NVARCHAR(255) OUTPUT
   ,  @c_UserName             NVARCHAR(128) = ''
   ,  @n_WarningNo            INT = 0       OUTPUT
   ,  @c_ProceedWithWarning   CHAR(1) = 'N' 
   ,  @c_IsSupervisor         CHAR(1) = 'N' 
   ,  @c_XMLDataString_Prev   NVARCHAR(MAX) = '' 
AS  
BEGIN  
   SET ANSI_NULLs ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON

   DECLARE @c_SPName    NVARCHAR(50)   = ''
         , @c_SQL       NVARCHAR(4000) = ''
         , @c_SQLParms  NVARCHAR(4000) = ''
         
         , @b_logerror  BIT            = 0   --(Wan02)

   SET @n_Err = 0 
   IF SUSER_SNAME() <> @c_UserName       --(Wan03) - START
   BEGIN
      EXEC [WM].[lsp_SetUser] 
               @c_UserName = @c_UserName  OUTPUT
            ,  @n_Err      = @n_Err       OUTPUT
            ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
            
      IF @n_Err = 0   
      BEGIN       
         EXECUTE AS LOGIN = @c_UserName
      END
   END                                   --(Wan03) - END
   
   DECLARE 
      @n_Continue       INT = 1
   --(Wan02) - START  
   BEGIN TRY
      IF @c_Module = N'w_userdefine_extended_validation'
      BEGIN
         GOTO CUSTOM_VALIDATE
      END
      -- Getting the Window/object lookup between Exceed and WM system.
     
      IF @n_Continue IN (1,2) --AND ( @c_ProceedWithWarning <> 'N' OR (@c_ProceedWithWarning = 'Y' OR @n_WarningNo < 1) )
      BEGIN  

         --IF @c_UpdateTable NOT IN ( 'RECEIPT', 'PICKDETAIL' )
         BEGIN
            SET @b_Success = 1
            SET @n_Err = 0 
            SET @c_Errmsg = ''
         
            SET @c_SPName = 'lsp_Validate_' + RTRIM(@c_UpdateTable) + '_Std'

            IF EXISTS (SELECT 1 FROM sys.Objects (NOLOCK) WHERE Name = @c_SPName AND type = 'P')
            BEGIN 
               SET @c_SQL = N'EXEC WM.' + @c_SPName
                          + ' @c_XMLSchemaString   = @c_XMLSchemaString'
                          + ',@c_XMLDataString     = @c_XMLDataString'
                          + ',@b_Success           = @b_Success   OUTPUT'
                          + ',@n_Err               = @n_Err       OUTPUT'
                          + ',@c_ErrMsg            = @c_Errmsg    OUTPUT' 
                          + ',@n_WarningNo         = @n_WarningNo OUTPUT'
                          + ',@c_ProceedWithWarning= @c_ProceedWithWarning'
                          + ',@c_IsSupervisor      = @c_IsSupervisor'
                          + ',@c_XMLDataString_Prev= @c_XMLDataString_Prev'   

               SET @c_SQLParms = N'@c_XMLSchemaString    NVARCHAR(MAX)' 
                               + ',@c_XMLDataString      NVARCHAR(MAX)'
                               + ',@b_Success            INT            OUTPUT'
                               + ',@n_Err                INT            OUTPUT'
                               + ',@c_ErrMsg             NVARCHAR(255)  OUTPUT' 
                               + ',@n_WarningNo          INT            OUTPUT'
                               + ',@c_ProceedWithWarning CHAR(1)'  
                               + ',@c_IsSupervisor       CHAR(1)' 
                               + ',@c_XMLDataString_Prev NVARCHAR(MAX)'  
               -- SWT01   
               BEGIN TRY
                  SET @b_Success = 1   
                  EXEC sp_ExecuteSQL @c_SQL
                                    ,@c_SQLParms
                                    ,@c_XMLSchemaString     
                                    ,@c_XMLDataString      
                                    ,@b_Success            OUTPUT 
                                    ,@n_Err                OUTPUT 
                                    ,@c_ErrMsg             OUTPUT 
                                    ,@n_WarningNo          OUTPUT
                                    ,@c_ProceedWithWarning  
                                    ,@c_IsSupervisor  
                                    ,@c_XMLDataString_Prev
               END TRY  
     
               BEGIN CATCH  
                  SET @b_Success = 0   
                  SET @n_err = 553802  
                  SET @c_ErrMsg = ERROR_MESSAGE()  
                  SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ' + @c_SPName + '. (lsp_Wrapup_Validation_Wrapper)'  
                                 + '( ' + @c_errmsg + ' )' 
                  SET @b_logerror = 1                       --(Wan02)                
               END CATCH      
        
               IF @b_Success = 0
               BEGIN
                  SET @n_Continue = 3
                  GOTO EXIT_SP
               END
            END
         END -- @c_UpdateTable = 'RECEIPT'
      END -- @n_Continue IN (1,2)

      CUSTOM_VALIDATE:        
      IF @n_Continue IN (1,2)
      BEGIN
         BEGIN TRY      
         SET @b_Success = 1
         EXEC isp_Wrapup_Validation
             @c_Window          = @c_Module          
            ,@c_BusObj          = @c_ControlObject          
            ,@c_UpdateTable     = @c_UpdateTable     
            ,@c_XMLSchemaString = @c_XMLSchemaString 
            ,@c_XMLDataString   = @c_XMLDataString   
            ,@b_Success         = @b_Success  OUTPUT       
            ,@n_Err             = @n_Err      OUTPUT       
            ,@c_Errmsg          = @c_Errmsg   OUTPUT  
         END TRY

         BEGIN CATCH
            SET @n_err = 553801
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing isp_Wrapup_Validation. (lsp_Wrapup_Validation_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
            SET @b_logerror = 1                       --(Wan02)
         END CATCH    
                      
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN        
            SET @n_continue = 3      
            GOTO EXIT_SP
         END              
      END
   END TRY

   BEGIN CATCH
      SET @n_continue = 3 
      SET @c_errmsg = ERROR_MESSAGE()
      SET @c_errmsg = 'Save Validation Fail. (lsp_Wrapup_Validation_Wrapper)'
                    + '( SQLSvr MESSAGE=' + @c_errmsg + ' ) '  
      SET @b_logerror = 1                
      GOTO EXIT_SP      
   END CATCH --(Wan02) - END
        
   EXIT_SP:  

   SET @b_success = 0         --(Wan01)
   IF @n_Continue IN (1,2)
   BEGIN
      SET @b_success = 1      --(Wan01)
      SET @n_WarningNo = 0
   END  
   ELSE  --(Wan02) - START
   BEGIN
      IF @b_logerror = 1 
      BEGIN
         execute nsp_logerror @n_err, @c_errmsg, 'lsp_Wrapup_Validation_Wrapper' 
      END 
   END   --(Wan02) - END

   REVERT      
END
GO
GRANT EXECUTE ON [WM].[lsp_Wrapup_Validation_Wrapper] TO nSQL 
GO
