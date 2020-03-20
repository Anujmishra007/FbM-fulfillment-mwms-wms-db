if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_BuildLoadReleaseTask_Wrapper]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_BuildLoadReleaseTask_Wrapper]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/  
/* Stored Procedure: isp_BuildLoadReleaseTask_Wrapper                   */  
/* Creation Date: 20-Jun-2018                                           */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: WMS-4484 Build load release task                            */  
/*          (ispRLBLP??)                                                */
/*                                                                      */  
/* Called By: Build load RCM release task                               */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/* 14/08/2018   NJOW01   1.0  Fix - cater for facility                  */
/************************************************************************/   
CREATE PROCEDURE [dbo].[isp_BuildLoadReleaseTask_Wrapper]  
   @c_LoadKey    NVARCHAR(10),    
   @b_Success    INT      OUTPUT,
   @n_Err        INT      OUTPUT, 
   @c_ErrMsg     NVARCHAR(250) OUTPUT
AS  
BEGIN  
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @n_continue      INT,
           @c_StorerKey     NVARCHAR(15),
           @c_Facility      NVARCHAR(5), --NJOW01
           @c_SPCode        NVARCHAR(10),
           @c_SQL           NVARCHAR(MAX),
           @c_Authority     NVARCHAR(30)
                                                      
   SELECT @c_SPCode = '', @n_err=0, @b_success=1, @c_errmsg=''
   
   IF NOT EXISTS(SELECT 1 FROM LOADPLANDETAIL WITH (NOLOCK)
                 WHERE LoadKey = @c_LoadKey)
   BEGIN
      SELECT @n_continue = 3  
      SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),
             @n_Err = 31011 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
      SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
             ': No Orders being populated into LoadPlanDetail. Load# ' + RTRIM(@c_Loadkey) + ' (isp_BuildLoadReleaseTask_Wrapper)'  
      
      GOTO QUIT_SP
   END
   
   SELECT TOP 1 @c_Storerkey = ORDERS.Storerkey,
                @c_Facility = ORDERS.Facility
   FROM LOADPLANDETAIL (NOLOCK)
   JOIN ORDERS (NOLOCK) ON (LOADPLANDETAIL.Orderkey = ORDERS.Orderkey)
   WHERE LOADPLANDETAIL.Loadkey = @c_LoadKey    
   
   SELECT @c_SPCode = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'BuildLoadReleaseTask_SP') --NJOW01
   
   /*
   SELECT @c_SPCode = sVALUE 
   FROM   StorerConfig WITH (NOLOCK) 
   WHERE  StorerKey = @c_StorerKey
   AND    ConfigKey = 'BuildLoadReleaseTask_SP'  
   */

   IF ISNULL(RTRIM(@c_SPCode),'') =''
   BEGIN       
       SELECT @n_continue = 3  
       SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),
              @n_Err = 31011 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
              ': Stored Procedure Name Not Yet configure to storerconfig BuildLoadReleaseTask_SP for Storer: '+RTRIM(@c_StorerKey) + '. Load# ' + RTRIM(@c_Loadkey) + ' (isp_BuildLoadReleaseTask_Wrapper)'  
       GOTO QUIT_SP           
   END
   
   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')
   BEGIN
       SELECT @n_continue = 3  
       SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),
              @n_Err = 31012 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + 
              ': Storerconfig BuildLoadReleaseTask_SP - Stored Proc name invalid ('+RTRIM(ISNULL(@c_SPCode,''))+')' + '. Load# ' + RTRIM(@c_Loadkey) + ' (isp_BuildLoadReleaseTask_Wrapper)'  
       GOTO QUIT_SP
   END
   
   SET @c_SQL = 'EXEC ' + @c_SPCode + ' @c_LoadKey=@c_LoadkeyP, @b_Success=@b_SuccessP OUTPUT, @n_Err=@n_ErrP OUTPUT,' +
                ' @c_ErrMsg=@c_ErrmsgP OUTPUT, @c_Storerkey=@c_StorerkeyP '
     
   EXEC sp_executesql @c_SQL, 
        N'@c_LoadKeyP NVARCHAR(10), @b_SuccessP INT OUTPUT, @n_ErrP INT OUTPUT, @c_ErrMsgP NVARCHAR(250) OUTPUT, @c_StorerkeyP NVARCHAR(15)', 
        @c_LoadKey,
        @b_Success OUTPUT,                      
        @n_Err OUTPUT, 
        @c_ErrMsg OUTPUT,
        @c_Storerkey
                        
   IF @b_Success <> 1 OR @n_err <> 0
   BEGIN
       SELECT @n_continue = 3  
       GOTO QUIT_SP
   END
   ELSE
   BEGIN
      EXECUTE nspGetRight 
         '',  
         @c_StorerKey,              
         '', --sku
         'UpdateSOReleaseTaskStatus', -- Configkey
         @b_success    OUTPUT,
         @c_authority  OUTPUT,
         @n_err        OUTPUT,
         @c_errmsg     OUTPUT
      
      IF @b_success = 1 AND @c_authority = '1' 
      BEGIN
      	  UPDATE ORDERS WITH (ROWLOCK)
      	  SET SOStatus = 'TSRELEASED',
      	      TrafficCop = NULL,
      	      EditWho = SUSER_SNAME(),
      	      EditDate = GETDATE()
      	  WHERE Loadkey = @c_Loadkey 
      	  AND Storerkey = @c_Storerkey   	  
      END          
   END
                    
   QUIT_SP:
   IF @n_continue = 3
   BEGIN
       SELECT @b_success = 0
       EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_BuildLoadReleaseTask_Wrapper'  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END   
END  
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [isp_BuildLoadReleaseTask_Wrapper] TO NSQL
GO

