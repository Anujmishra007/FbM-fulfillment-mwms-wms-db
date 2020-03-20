if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_PackAutoCloseCarton_Wrapper ]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_PackAutoCloseCarton_Wrapper ]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/  
/* Stored Procedure: isp_PackAutoCloseCarton_Wrapper                    */  
/* Creation Date: 08-Aug-2018                                           */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: WMS-5729 CN Puma auto close carton                          */  
/*                                                                      */  
/* Called By: Packing (Call ispPKCLOSECTN01)                            */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
 
CREATE PROCEDURE [dbo].[isp_PackAutoCloseCarton_Wrapper ]
   @c_PickSlipNo  NVARCHAR(10),
   @c_Storerkey   NVARCHAR(15),  
   @c_ScanSkuCode NVARCHAR(50),
   @c_Sku         NVARCHAR(20),    
   @c_CloseCarton NVARCHAR(10) OUTPUT,
   @b_Success     INT      OUTPUT,
   @n_Err         INT      OUTPUT, 
   @c_ErrMsg      NVARCHAR(250) OUTPUT
AS  
BEGIN  
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @n_continue      INT,
           @c_SPCode        NVARCHAR(30),
           @c_SQL           NVARCHAR(MAX)
                                                      
   SELECT @c_SPCode = '', @n_err=0, @b_success=1, @c_errmsg=''
      
   SELECT @c_SPCode = sVALUE 
   FROM   StorerConfig WITH (NOLOCK) 
   WHERE  StorerKey = @c_StorerKey
   AND    ConfigKey = 'PackAutoCloseCarton_SP'  

   IF ISNULL(RTRIM(@c_SPCode),'') =''
   BEGIN
       SELECT @n_continue = 4  
       SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),
              @n_Err = 31011 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
              ': Please Setup Stored Procedure Name into Storer Configuration for '+RTRIM(@c_StorerKey)+' (isp_PackAutoCloseCarton_Wrapper )'  
       GOTO QUIT_SP
   END
   
   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')
   BEGIN
       SELECT @n_continue = 3  
       SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),
              @n_Err = 31012 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
              ': Storerconfig PackAutoCloseCarton_SP - Stored Proc name invalid ('+RTRIM(ISNULL(@c_SPCode,''))+') (isp_PackAutoCloseCarton_Wrapper )'  
       GOTO QUIT_SP
   END
   
   SET @c_SQL = 'EXEC ' + @c_SPCode + ' @c_Pickslipno, @c_Storerkey, @c_ScanSkuCode, @c_Sku, @c_CloseCarton OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT,' +
                ' @c_ErrMsg OUTPUT '
     
   EXEC sp_executesql @c_SQL, 
        N'@c_Pickslipno NVARCHAR(10), @c_Storerkey NVARCHAR(15), @c_ScanSkuCode NVARCHAR(50), @c_Sku NVARCHAR(20), @c_CloseCarton NVARCHAR(10) OUTPUT, @b_Success int OUTPUT, @n_Err int OUTPUT, @c_ErrMsg NVARCHAR(250) OUTPUT', 
        @c_Pickslipno,
        @c_Storerkey,
        @c_ScanSkuCode,
        @c_Sku,
        @c_CloseCarton OUTPUT,
        @b_Success OUTPUT,                      
        @n_Err OUTPUT, 
        @c_ErrMsg OUTPUT
                         
   IF @b_Success <> 1
   BEGIN
       SELECT @n_continue = 3  
       GOTO QUIT_SP
   END
                    
   QUIT_SP:
   IF @n_continue = 3
   BEGIN
       SELECT @b_success = 0
       EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_PackAutoCloseCarton_Wrapper '  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END   
END  
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [isp_PackAutoCloseCarton_Wrapper ] TO NSQL
GO

