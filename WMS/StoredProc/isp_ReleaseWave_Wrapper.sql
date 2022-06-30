SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: isp_ReleaseWave_Wrapper                             */  
/* Creation Date: 24-Sep-2012                                            */  
/* Copyright: IDS                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose: SOS#256796 - Configurable custom release Wave                */  
/*          Storerconfig ReleaseWave_SP={ispRLWAVxx} to call customize SP*/
/*                                                                       */  
/* Called By: wave                                                       */  
/*                                                                       */  
/* PVCS Version: 1.2                                                     */  
/*                                                                       */  
/* Version: 5.4                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author   Ver  Purposes                                   */  
/* 17-Oct-2014  NJOW01   1.0  314930-Update wave status and order        */
/*                            sostatus to release                        */ 
/* 17-Sep-2017  TLTING   1.1  NOLOCK                                     */
/* 22-Oct-2019  Wan01    1.2  Update TMReleaseFlag, Sync Exceed & SCE    */
/* 21-Mar-2022  NJOW02   1.3  WMS-19267 Support config by facility       */
/* 21-Mar-2022  NJOW02   1.3  DEVOPS Combine script                      */
/*************************************************************************/   
CREATE OR ALTER PROCEDURE [dbo].[isp_ReleaseWave_Wrapper]  
      @c_WaveKey    NVARCHAR(10) 
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
         , @c_facility     NVARCHAR(5)  --NJOW01
         , @c_authority    NVARCHAR(10) --NJOW01

   SET @n_err        = 0
   SET @b_Success    = 1
   SET @c_errmsg     = ''

   SET @n_Continue   = 1
   SET @c_SPCode     = ''
   SET @c_StorerKey  = ''
   SET @c_SQL        = ''
   
   SELECT TOP 1 @c_StorerKey = O.Storerkey,
                @c_Facility = O.Facility --NJOW01
   FROM WAVEDETAIL WD (NOLOCK)
   JOIN ORDERS O (NOLOCK) ON (WD.Orderkey = O.Orderkey)
   WHERE WD.Wavekey = @c_Wavekey  

   SET @c_SPCode = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP')  --NJOW02

   IF ISNULL(RTRIM(@c_SPCode),'') IN('','0') --NJOW02
   BEGIN  
        SET @c_SPCode = 'nspReleaseWave'
   END
   
   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = RTRIM(@c_SPCode) AND type = 'P')
   BEGIN
       SET @n_Continue = 3  
       SET @n_Err = 31211
       SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)  
                        + ': Storerconfig ReleaseWave_SP - Stored Proc name invalid ('+RTRIM(ISNULL(@c_SPCode,''))
                        + '). (isp_ReleaseWave_Wrapper)'  
       GOTO QUIT_SP
   END
   
   SET @c_SQL = 'EXEC ' + @c_SPCode + ' @c_Wavekey, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT'

   EXEC sp_executesql @c_SQL 
      ,  N'@c_Wavekey NVARCHAR(10), @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT' 
      ,  @c_Wavekey
      ,  @b_Success OUTPUT   
      ,  @n_Err OUTPUT
      ,   @c_ErrMsg OUTPUT
                        
   IF @b_Success <> 1
   BEGIN
       SELECT @n_Continue = 3  
       GOTO QUIT_SP
   END
   ELSE
   BEGIN 
         --NJOW01
         UPDATE WAVE WITH (ROWLOCK)
         --SET Status = '1',              --Wan01
         SET TMReleaseFlag = 'Y',         --Wan01
             TrafficCop = NULL,
             EditWho = SUSER_SNAME(),
             EditDate = GETDATE()             
         WHERE Wavekey = @c_Wavekey
         
         EXECUTE nspGetRight 
          @c_facility,  
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
           WHERE Userdefine09 = @c_Wavekey           
       END          
   END
                    
   QUIT_SP:
   IF @n_Continue = 3
   BEGIN
       SELECT @b_Success = 0
       EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_ReleaseWave_Wrapper'  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END   
END
GO
GRANT EXECUTE ON [dbo].[isp_ReleaseWave_Wrapper] TO nSQL 
GO
