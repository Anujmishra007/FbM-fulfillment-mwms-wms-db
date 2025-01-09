SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: mspWaveReleaseWCS01                                 */
/* Creation Date: 2024-11-19                                             */
/* Copyright: Maersk                                                     */  
/* Written by: Supriya                                                   */
/*                                                                       */  
/* Purpose: Release to WCS                                               */  
/*                                                                       */  
/* Called By: WMS Wave Release To WCS                                    */
/*                                                                       */  
/* Version: Maserk V2                                                    */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author  Ver   Purposes                                   */ 
/* 2024-11-19   SSA01   1.1   UWP-27112-[LEVI's] Release to WCS Update   */
/* 2024-12-18   SSA02   1.2   UWP-27112-Added automated wave validation  */
/*                            and update tasks status from H to 0        */
/* 2025-01-08   SSA03   1.3   UWP-27112-Added extra logic to update tasks*/
/*                            status from H to 0                         */
/*************************************************************************/   
CREATE OR ALTER PROCEDURE [dbo].[mspWaveReleaseWCS01]
  @c_Wavekey      NVARCHAR(10)  
 ,@b_Success      int        OUTPUT  
 ,@n_Err          int        OUTPUT  
 ,@c_Errmsg       NVARCHAR(250)  OUTPUT  
 AS  
 BEGIN  
    SET NOCOUNT ON   
    SET QUOTED_IDENTIFIER OFF   
    SET ANSI_NULLS OFF   
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @n_Continue          INT          = 1    
          , @n_StartTCnt         INT          = @@TRANCOUNT       -- Holds the current transaction count
          , @n_Debug             INT          = 0
          , @c_Facility          NVARCHAR(5)  = ''          
          , @c_Storerkey         NVARCHAR(15) = ''
          , @c_TableName         NVARCHAR(30) = ''
          , @c_Key1              NVARCHAR(10) = ''
          , @c_Key2              NVARCHAR(30) = ''
          , @c_Key3              NVARCHAR(20) = ''
          , @c_TransmitBatch     NVARCHAR(30) = ''
          , @c_CfgWCS            NVARCHAR(10) = ''
          , @c_ConditionQuery    NVARCHAR(1000)= ''
          , @c_TMReleaseFlag    NVARCHAR(1)= ''
          , @c_UserDefine09     NVARCHAR(1)= ''   --(SSA02)


    SELECT TOP 1
             @c_Facility  = O.Facility
           , @c_Storerkey = O.StorerKey
     FROM dbo.WAVEDETAIL WD(NOLOCK)
     JOIN dbo.ORDERS O (NOLOCK) ON O.OrderKey = WD.OrderKey
     WHERE WD.WaveKey = @c_Wavekey

    SELECT @c_TMReleaseFlag = WAVE.TMReleaseFlag, @c_UserDefine09 = WAVE.UserDefine09
                FROM dbo.WAVE WAVE (NOLOCK)
                WHERE WAVE.WaveKey = @c_Wavekey

    IF @c_TMReleaseFlag = 'N'
     BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
         SET @n_err = 81010
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Wave has not been Released.  (mspWaveReleaseWCS01) '
     END
     --(SSA02) start ---
     IF @c_UserDefine09 <> 'Y'
     BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
         SET @n_err = 81030
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Wave is not Automation.  (mspWaveReleaseWCS01) '
     END
     --(SSA02) end----
     IF @n_Continue IN (1,2)
     BEGIN
        SET @c_TableName = 'WSWAVELOG'
             SET @c_Key1 = @c_Wavekey
             SET @c_Key2 = ''
             SET @c_Key3 = @c_Storerkey

        IF EXISTS ( SELECT 1 FROM TransmitLog2 (NOLOCK) WHERE TableName = @c_TableName
						 AND Key1 = @c_Key1 AND Key2 = @c_Key2 AND Key3 = @c_Key3)
          BEGIN
		          SET @n_continue = 3
              SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
              SET @n_err = 81020
              SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Wave already released to WCS. (mspWaveReleaseWCS01) '
           END
           IF @n_Continue IN (1,2)
            BEGIN
               ----(SSA02),(SSA03) start-----
               UPDATE td SET td.STATUS = '0'
               FROM TASKDETAIL(NOLOCK) td
               JOIN LOC(NOLOCK) loc on td.FROMLOC = loc.LOC
               WHERE td.WAVEKEY = @c_Wavekey AND td.TASKTYPE <> 'ASTCPK'
               AND td.STATUS = 'H' AND loc.locationtype <> 'PICKWCS'
               ----(SSA02),(SSA03) end-----
               SET @b_Success = 1
               EXEC dbo.ispGenTransmitLog2
                     @c_TableName   = @c_TableName
                  ,  @c_Key1        = @c_Key1
                  ,  @c_Key2        = @c_Key2
                  ,  @c_Key3        = @c_Key3
                  ,  @c_TransmitBatch = @c_TransmitBatch
                  ,  @b_Success     = @b_Success OUTPUT
                  ,  @n_err         = @n_err OUTPUT
                  ,  @c_errmsg      = @c_errmsg OUTPUT

               IF @b_Success = 0
               BEGIN
                  SET @n_Continue = 3
               END
            END
     END
EXIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_Success = 0  
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "mspWaveReleaseWCS01"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    
      RETURN  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END
END --sp end
GO
GRANT EXECUTE ON [dbo].mspWaveReleaseWCS01 TO nSQL
GO
