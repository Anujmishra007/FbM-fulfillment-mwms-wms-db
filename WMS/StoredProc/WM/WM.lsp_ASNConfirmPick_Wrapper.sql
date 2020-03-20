if exists (select * from dbo.sysobjects where id = object_id(N'[WM].[lsp_ASNConfirmPick_Wrapper]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [WM].[lsp_ASNConfirmPick_Wrapper]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/  
/* Stored Procedure: lsp_ASNConfirmPick_Wrapper                         */  
/* Creation Date: 29-Jan-2018                                           */  
/* Copyright: LFLogistics                                               */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: Crossdock confirm pick                                      */  
/*                                                                      */  
/* Called By: XDock Confirm Pick                                        */  
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
CREATE PROCEDURE [WM].[lsp_ASNConfirmPick_Wrapper]
  @c_StorerKey    NVARCHAR(15) ,
  @c_ExternPOKey  NVARCHAR(20), 
  @b_Success      INT OUTPUT, 
  @n_err          INT OUTPUT,
  @c_ErrMsg       NVARCHAR(215) OUTPUT,
  @c_UserName     NVARCHAR(128) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @b_Success = 0

   --EXECUTE AS LOGIN=@c_UserName
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

   EXECUTE AS LOGIN = @c_UserName

   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END 
    
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

   IF NOT EXISTS (SELECT 1 FROM ORDERDETAIL AS o WITH(NOLOCK)
                WHERE o.StorerKey = @c_StorerKey
                AND o.ExternPOKey = @c_ExternPOKey)
   BEGIN
      SET @n_err = 554001
      SET @c_ErrMsg = 'Error: ' + CAST(@n_err AS VARCHAR(6)) + ': Invalid Extern PO Key.'
      SET @b_Success = 0
      GOTO EXIT_SP        
   END
      
   EXEC dbo.ispASNConfirmPick
        @cStorerKey = @c_Storerkey,
        @cExternPOKey = @c_ExternPOkey, -- For one storer, pass in the Storerkey; For All Storer, pass in '%'
         @b_Success    = @b_Success OUTPUT, 
         @n_err        = @n_err OUTPUT,
         @c_ErrMsg     = @c_ErrMsg OUTPUT 
          
   EXIT_SP:
   REVERT     
END  
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [WM].[lsp_ASNConfirmPick_Wrapper] TO NSQL
GO

GRANT EXECUTE ON [WM].[lsp_ASNConfirmPick_Wrapper] TO [ALPHA\GTWMSinfosys]
GO
