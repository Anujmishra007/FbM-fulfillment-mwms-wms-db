SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspRVWAV15                                          */
/* Creation Date: 2026-08-05                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by: Alex Keoh                                                 */    
/*                                                                       */
/* Purpose: FCR-14839 - JCBUSA - Wave Release SP                         */  
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 2026-08-05  AlexK    1.0   FCR-14839 - JCBUSA - Wave Release SP       */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV15]
      @c_Wavekey      NVARCHAR(10)
    , @c_Orderkey     NVARCHAR(10) = ''
    , @b_Success      INT              OUTPUT
    , @n_Err          INT              OUTPUT
    , @c_Errmsg       NVARCHAR(250)    OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT
         , @n_starttcnt INT
         , @n_debug INT

   SET @n_debug = @n_Err
   SELECT @n_starttcnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 0, @n_Err = 0, @c_Errmsg = ''

   DECLARE @c_Pickslipno      NVARCHAR(10)   = ''
         , @n_CartonNo        INT            = 0

   --Validation
   IF @n_Continue = 1
   BEGIN
      -- Reject if wave not yet released
      IF NOT EXISTS ( SELECT 1 FROM WAVE W (NOLOCK)
                      WHERE W.Wavekey = @c_Wavekey
                      AND W.TMReleaseFlag = 'Y' )
      BEGIN
         SET @n_Continue   = 3
         SET @n_Err        = 84010
         SET @c_Errmsg     = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) 
                           + ': This Wave has not been released. (mspRVWAV15)'
         GOTO QUIT_SP
      END

      --Reject if any tasks has been started
      IF EXISTS ( SELECT 1 FROM TASKDETAIL (NOLOCK) 
                  WHERE WaveKey = @c_Wavekey
                  AND ((TaskType = 'FCP' AND [Status] NOT IN ('S', '0'))
                        OR (TaskType = 'RPF' AND [Status] NOT IN ('0'))
                      )
                )
      BEGIN
         SET @n_Continue   = 3
         SET @n_Err        = 84011
         SET @c_Errmsg     = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) 
                           + ': TaskDetail is pending work. (mspRVWAV15)'
         GOTO QUIT_SP 
      END 
   END 


   IF @n_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
         COMMIT TRAN

      IF @@TRANCOUNT = 0
         BEGIN TRAN
   END

   --Clean taskdetail
   IF @n_Continue = 1
   BEGIN
      BEGIN TRY
         DELETE FROM TaskDetail
         WHERE WaveKey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
         GOTO QUIT_SP
      END CATCH
   END

   -- Clear pack-related fields on pickdetail of the wave
   IF @n_Continue = 1
   BEGIN
      BEGIN TRY
         UPDATE PICKDETAIL WITH (ROWLOCK)
         SET PICKDETAIL.TaskDetailKey = ''
           , TrafficCop = NULL
           , EditWho  = SUSER_SNAME()
           , EditDate = GETDATE()
         FROM WAVEDETAIL (NOLOCK)
         JOIN PICKDETAIL ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
         WHERE WAVEDETAIL.Wavekey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
         GOTO QUIT_SP
      END CATCH
   END

   -- Reverse wave status
   IF @n_Continue = 1
   BEGIN
      BEGIN TRY
         UPDATE WAVE WITH (ROWLOCK)
            SET TMReleaseFlag = 'N'
             ,  TrafficCop = NULL
             ,  EditWho  = SUSER_SNAME()
             ,  EditDate = GETDATE()
         WHERE WaveKey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END

   QUIT_SP:
   IF (XACT_STATE()) = -1
   BEGIN
      IF @@TRANCOUNT > 0 
      BEGIN
         ROLLBACK TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_starttcnt
      BEGIN TRAN

   IF CURSOR_STATUS('LOCAL', 'CUR_PACK') IN (0 , 1)
   BEGIN
      CLOSE CUR_PACK
      DEALLOCATE CUR_PACK   
   END
   
   IF @n_Continue = 3
   BEGIN
      SELECT @b_Success = 0
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
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV15'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON  [dbo].[mspRVWAV15] TO [NSQL]
GO
