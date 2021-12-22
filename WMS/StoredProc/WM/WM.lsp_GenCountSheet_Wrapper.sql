IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_GenCountSheet_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_GenCountSheet_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_GenCountSheet_Wrapper                           */  
/* Creation Date: 14-MAR-2018                                            */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: LFWM-263 - Stored Procedures for Release 2 Feature -         */
/*          Inventory  Cycle Count  Stock Take Parameters                */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.2                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 2021-02-05  mingle01 1.1   Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2021-12-02  Wan01    1.2   WMS-18332 - [TW]LOR_CycleCount_CR          */
/*             Wan01    1.2   DevOps Combine Script                      */
/*************************************************************************/   
CREATE PROCEDURE [WM].[lsp_GenCountSheet_Wrapper]  
   @c_StockTakeKey         NVARCHAR(10)
,  @c_GenType              CHAR(1)      = 'N'   -- B:Blank, N:Normal, U:UCC
,  @c_BlankCSheetHideLoc   CHAR(1)      = ''
,  @n_BlankCSheetNoOfPage  INT          = 0
,  @b_Success              INT          = 1   OUTPUT   
,  @n_Err                  INT          = 0   OUTPUT
,  @c_Errmsg               NVARCHAR(255)= ''  OUTPUT
,  @n_WarningNo            INT          = 0   OUTPUT
,  @c_ProceedWithWarning   CHAR(1)      = 'N' 
,  @c_UserName             NVARCHAR(128)= ''
AS  
BEGIN  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT = 1
         , @n_StartTCnt       INT = @@TRANCOUNT

         , @n_Count           INT = 0 
         , @c_CCSheetNo_Min   NVARCHAR(10) = ''
         , @c_CCSheetNo_Max   NVARCHAR(10) = ''
         , @c_CountNo         CHAR(1)      = '1'
         

   CREATE TABLE #TMP_CC
         (  DataCount INT )

   SET @b_Success = 1
   SET @c_ErrMsg = ''

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

   BEGIN TRAN     --(Wan01)
   --(mingle01) - START
   BEGIN TRY 

      IF @c_GenType = 'B'
      BEGIN
         IF @c_BlankCSheetHideLoc = 'Y' AND ISNULL(@n_BlankCSheetNoOfPage, 0) = 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 552401
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Please Key-in No Of Blank Count Sheet. (lsp_GenCountSheet_Blank_Wrapper)'
            GOTO EXIT_SP      
         END 
      END
      ELSE
      BEGIN
         SET @n_Count = 0
 
         IF @c_ProceedWithWarning = 'N' AND @n_WarningNo < 1 
         BEGIN
            BEGIN TRY      
               EXECUTE @n_Count = ispCheckOutstandingOrders        
                  @c_StockTakeKey = @c_StockTakeKey         
               ,  @c_CountNo = @c_CountNo 
            END TRY

            BEGIN CATCH
               SET @n_err = 552402
               SET @c_ErrMsg = ERROR_MESSAGE()
               SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispCheckOutstandingOrders. (lsp_GenCountSheet_Wrapper)'
                              + '( ' + @c_errmsg + ' )'
            END CATCH    
                   
            IF @b_success = 0 OR @n_Err <> 0        
            BEGIN        
               SET @n_continue = 3      
               GOTO EXIT_SP
            END        

            IF @n_Count > 0 
            BEGIN
               SET @n_continue  = 3
               SET @c_ErrMsg= 'Warning !' + CONVERT(NVARCHAR(10),@n_Count) + ' Outstanding record(s) found! Please close all the Shipment Orders before you proceed. ' + CHAR(13) 
                              + 'Warning, System will generate Count Sheet even with Outstanding record(s) being found ! '
                              + 'Are you sure you want to proceed?'
               SET @n_WarningNo = 1
               GOTO EXIT_SP
            END
         END
      END

      SET @n_Count = 0
      BEGIN TRY
         INSERT INTO #TMP_CC (DataCount)
         EXECUTE ispCheckCCkey        
          @c_StockTakeKey = @c_StockTakeKey
      END TRY

      BEGIN CATCH
         SET @n_err = 552403
         SET @c_ErrMsg = ERROR_MESSAGE()
         SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispCheckCCkey. (lsp_GenCountSheet_Wrapper)'
                        + '( ' + @c_errmsg + ' )'
      END CATCH    
                   
      IF @b_success = 0 OR @n_Err <> 0        
      BEGIN        
         SET @n_continue = 3      
         GOTO EXIT_SP
      END        

      IF (SELECT DataCount FROM #TMP_CC) > 0 
      BEGIN
         SET @n_continue = 3    
         SET @n_err = 552404
         SET @c_ErrMsg = 'CCDetail Transaction Found ! Regeneration Not Allow.' 
      
         GOTO EXIT_SP
      END

      IF @c_GenType = 'B'
      BEGIN
         BEGIN TRY      
         EXECUTE ispGenBlankSheet        
            @c_StockTakeKey = @c_StockTakeKey         
         END TRY

         BEGIN CATCH
            SET @n_err = 552405
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispGenBlankSheet. (lsp_GenCountSheet_Blank_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
         END CATCH    
                   
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN        
            SET @n_continue = 3      
            GOTO EXIT_SP
         END  
      END

      IF @c_GenType = 'N'
      BEGIN
         BEGIN TRY      
            EXECUTE ispGenCountSheet        
               @c_StockTakeKey = @c_StockTakeKey         
         END TRY

         BEGIN CATCH
            SET @n_err = 552406
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispGenCountSheet. (lsp_GenCountSheet_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
         END CATCH    
                  
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN        
            SET @n_continue = 3      
            GOTO EXIT_SP
         END        
      END

      IF @c_GenType = 'U'
      BEGIN
         BEGIN TRY      
            EXECUTE ispCheckUCCBal        
               @c_StockTakeKey = @c_StockTakeKey         
         END TRY

         BEGIN CATCH
            SET @n_err = 552407
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispCheckUCCBal. (lsp_GenCountSheet_UCC_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
         END CATCH    
                   
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN        
            SET @n_continue = 3      
            GOTO EXIT_SP
         END        

         SET @n_Count = 0
         SELECT TOP 1 @n_Count = 1
         FROM STOCKTAKEERRORREPORT WITH (NOLOCK)
         WHERE StockTakeKey = @c_StockTakeKey

         IF @n_Count > 0 
         BEGIN
            SET @n_continue = 3    
            SET @n_err = 552408
            SET @c_ErrMsg = 'UCC Qty Not Tally With LOTXLOCXID. Please Refer to STOCKTAKEERRORREPORT. (lsp_GenCountSheet_UCC_Wrapper)'
      
            GOTO EXIT_SP
         END

         BEGIN TRY      
            EXECUTE ispGenCountSheetByUCC        
               @c_StockTakeKey = @c_StockTakeKey         
         END TRY

         BEGIN CATCH
            SET @n_err = 552409
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_errmsg = 'NSQL' +CONVERT(CHAR(6),@n_err) + ': Error Executing ispGenCountSheetByUCC. (lsp_GenCountSheet_UCC_Wrapper)'
                           + '( ' + @c_errmsg + ' )'
         END CATCH    
                   
         IF @b_success = 0 OR @n_Err <> 0        
         BEGIN        
            SET @n_continue = 3      
            GOTO EXIT_SP
         END        
      END

      SET @n_Count = 0
      SELECT @c_CCSheetNo_Min = ISNULL(MIN(CCSheetNo),'')
            ,@c_CCSheetNo_Max = ISNULL(MAX(CCSheetNo),'') 
            ,@n_Count = COUNT(1)
      FROM CCDETAIL WITH (NOLOCK)
      WHERE cckey = @c_StockTakeKey

      IF @n_Count > 0 
      BEGIN
         SET @c_ErrMsg = 'Cycle Count Ref #: ' + @c_StockTakeKey + CHAR(13)
                       + 'Count Sheet # From: '+ @c_CCSheetNo_Min + ' To ' + @c_CCSheetNo_Max + CHAR(13)
                       + 'Generate Successfully'  
      
         GOTO EXIT_SP
      END

   END TRY

   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(mingle01) - END
EXIT_SP: 
   IF (XACT_STATE()) = -1     --(Wan01) - START  
   BEGIN  
      SET @n_Continue=3
      ROLLBACK TRAN;  
   END;                       --(Wan01) - END 
   
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt         --(Wan01)
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_GenCountSheet_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END

      SET @n_WarningNo = 0
   END

   REVERT      
END  
GO
GRANT EXECUTE ON [WM].[lsp_GenCountSheet_Wrapper] TO nSQL 
GO


