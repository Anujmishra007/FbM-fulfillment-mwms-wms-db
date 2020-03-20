IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Pre_Delete_InventoryHold_STD]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_Pre_Delete_InventoryHold_STD]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: lsp_Pre_Delete_InventoryHold_STD                   */  
/* Creation Date: 27-Jul-2018                                           */  
/* Copyright: LFLogistics                                               */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: InventoryHold Pre-delete process / validation               */  
/*                                                                      */  
/* Called By: InventoryHold delete                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 8.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/   
CREATE PROCEDURE [WM].[lsp_Pre_Delete_InventoryHold_STD]
       @c_StorerKey         NVARCHAR(15)
   ,  @c_RefKey1           NVARCHAR(50)  = '' 
   ,  @c_RefKey2           NVARCHAR(50)  = '' 
   ,  @c_RefKey3           NVARCHAR(50)  = '' 
   ,  @c_RefreshHeader     CHAR(1) = 'N' OUTPUT
   ,  @c_RefreshDetail     CHAR(1) = 'N' OUTPUT 
   ,  @b_Success           INT = 1 OUTPUT   
   ,  @n_Err               INT = 0 OUTPUT
   ,  @c_Errmsg            NVARCHAR(255) = ''  OUTPUT
   ,  @c_UserName          NVARCHAR(128) = '' 
   ,  @c_IsSupervisor      CHAR(1) = 'N' 
AS
BEGIN
   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   SET QUOTED_IDENTIFIER ON
   SET CONCAT_NULL_YIELDS_NULL ON
   SET ARITHABORT ON

   DECLARE @n_Continue           INT,
           @n_starttcnt          INT,
           @c_InventoryHoldKey   NVARCHAR(10) = ''
   
   SELECT @n_starttcnt=@@TRANCOUNT, @n_err=0, @b_success=1, @c_errmsg='', @n_continue=1
   SET @c_RefreshHeader = 'Y'
   
   /*
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END   
   */
            
   SET @c_InventoryHoldKey = @c_RefKey1
       
   EXIT_SP:
   --REVERT     

   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SELECT @b_success = 0  
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
   ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_starttcnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
      execute nsp_logerror @n_err, @c_errmsg, 'lsp_Pre_Delete_InventoryHold_STD'  
      RETURN  
   END  
   ELSE  
   BEGIN  
      SELECT @b_success = 1  
      WHILE @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END              
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_Pre_Delete_InventoryHold_STD] TO nSQL 
GO
