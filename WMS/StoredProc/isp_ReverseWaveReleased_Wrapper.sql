if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_ReverseWaveReleased_Wrapper]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_ReverseWaveReleased_Wrapper]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/*************************************************************************/  
/* Stored Procedure: isp_ReverseWaveReleased_Wrapper                     */  
/* Creation Date: 12-Apr-2013                                            */  
/* Copyright: IDS                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose: SOS#256796 - Configurable custom reverse Wave                */  
/*          Storerconfig ReverseWaveReleased_SP={ispRVWAVxx} to call     */
/*          customize SP                                                 */       
/*                                                                       */  
/* Called By: wave                                                       */  
/*                                                                       */  
/* PVCS Version: 1.0                                                     */  
/*                                                                       */  
/* Version: 5.4                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author   Ver  Purposes                                   */
/* 04-AUG-2014  YTWan    1.1  SOS#313850 - Wave Enhancement - Delete     */
/*                            Orders. (Wan01)                            */
/*************************************************************************/   
CREATE PROCEDURE [dbo].[isp_ReverseWaveReleased_Wrapper]  
      @c_WaveKey    NVARCHAR(10) 
   ,  @c_Orderkey   NVARCHAR(10) = ''                 --(Wan01)
   ,  @b_Success    INT OUTPUT    
   ,  @n_Err        INT OUTPUT
   ,  @c_Errmsg     NVARCHAR(255) OUTPUT

AS  
BEGIN  
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @n_Continue     INT
         , @c_SPCode       NVARCHAR(50)
         , @c_StorerKey    NVARCHAR(15)
         , @c_SQL          NVARCHAR(MAX)

   SET @n_err        = 0
   SET @b_Success    = 1
   SET @c_errmsg     = ''

   SET @n_Continue   = 1
   SET @c_SPCode     = ''
   SET @c_StorerKey  = ''
   SET @c_SQL        = ''
   
   SELECT TOP 1 @c_StorerKey = O.Storerkey
   FROM WAVEDETAIL WD (NOLOCK)
   JOIN ORDERS O (NOLOCK) ON (WD.Orderkey = O.Orderkey)
   WHERE WD.Wavekey = @c_Wavekey  

   SELECT @c_SPCode = sVALUE 
   FROM   StorerConfig WITH (NOLOCK) 
   WHERE  StorerKey = @c_StorerKey
   AND    ConfigKey = 'ReverseWaveReleased_SP'  

   IF ISNULL(RTRIM(@c_SPCode),'') = ''
   BEGIN  
       SET @n_Continue = 3  
       SET @n_Err = 31210
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)  
                        + ': Storerconfig ReverseWaveReleased_SP Not Yet Setup'
                        + '). (isp_ReverseWaveReleased_Wrapper)'  
       GOTO QUIT_SP
   END
   
   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')
   BEGIN
       SET @n_Continue = 3  
       SET @n_Err = 31211
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)  
                        + ': Storerconfig ReverseWaveReleased_SP - Stored Proc name invalid ('+RTRIM(ISNULL(@c_SPCode,''))
                        + '). (isp_ReverseWaveReleased_Wrapper)'  
       GOTO QUIT_SP
   END

   --(Wan01) - Add Orderkey (START)
   SET @c_SQL = 'EXEC ' + @c_SPCode + ' @c_Wavekey=@c_Wavekey, @c_Orderkey=@c_Orderkey, @b_Success=@b_Success OUTPUT, @n_Err=@n_Err OUTPUT, @c_ErrMsg=@c_ErrMsg OUTPUT'

   EXEC sp_executesql @c_SQL 
      ,  N'@c_Wavekey NVARCHAR(10), @c_Orderkey NVARCHAR(10), @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT' 
      ,  @c_Wavekey
      ,  @c_Orderkey                                  
      ,  @b_Success OUTPUT   
      ,  @n_Err OUTPUT
      ,	 @c_ErrMsg OUTPUT
              
   --(Wan01) - Add Orderkey (END)
          
   IF @b_Success <> 1
   BEGIN
       SELECT @n_Continue = 3  
       GOTO QUIT_SP
   END
                    
   QUIT_SP:
   IF @n_Continue = 3
   BEGIN
       SELECT @b_Success = 0
       EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_ReverseWaveReleased_Wrapper'  
       --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END   
END  
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [isp_ReverseWaveReleased_Wrapper] TO NSQL
GO

