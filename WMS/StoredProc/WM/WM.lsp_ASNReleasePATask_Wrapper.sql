IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_ASNReleasePATask_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_ASNReleasePATask_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: lsp_ASNReleasePATask_Wrapper                       */  
/* Creation Date: 18-Sep-2012                                           */  
/* Copyright: IDS                                                       */  
/* Written by: YTWan                                                    */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */
/*                                                                      */
/*                                                                      */  
/* Called By: ASN RCM Release Putaway Tasks                             */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/ 
CREATE PROCEDURE [WM].[lsp_ASNReleasePATask_Wrapper]
   @c_ReceiptKey NVARCHAR(10),    
   @b_Success    INT   OUTPUT,
   @n_Err        INT   OUTPUT, 
   @c_ErrMsg     NVARCHAR(250) OUTPUT, 
   @n_WarningNo  INT = 0        OUTPUT,
   @c_ProceedWithWarning CHAR(1) = 'N',    
   @c_UserName   NVARCHAR(128)=''
AS  
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

   EXECUTE AS LOGIN = @c_UserName
   
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END
    
   EXEC isp_ASNReleasePATask_Wrapper 
      @c_ReceiptKey = @c_ReceiptKey,
      @b_Success = @b_Success OUTPUT, 
      @n_Err = @n_Err OUTPUT, 
      @c_ErrMsg = @c_ErrMsg OUTPUT

   EXIT_SP:       
   REVERT  
   
END
GO
GRANT EXECUTE ON [WM].[lsp_ASNReleasePATask_Wrapper] TO nSQL 
GO
