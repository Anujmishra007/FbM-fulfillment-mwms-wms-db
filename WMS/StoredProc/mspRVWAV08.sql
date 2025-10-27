SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspRVWAV08                                          */
/* Creation Date: 27-Oct-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-8650 Sweden - Maersk WMS v2 - SCE Task Reverse Wave      */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Github Version: 1.0                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 27-Oct-2025 WLChooi  1.0   Initial version                            */
/*************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV08]
      @c_Wavekey      NVARCHAR(10)
    , @c_Orderkey     NVARCHAR(10) = ''
    , @b_Success      INT        OUTPUT
    , @n_Err          INT        OUTPUT
    , @c_Errmsg       NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT
         , @n_starttcnt INT      -- Holds the current transaction count
         , @n_debug INT
         , @n_cnt INT

   SET @n_debug = @n_Err
   SELECT @n_starttcnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 0, @n_Err = 0, @c_Errmsg = '', @n_cnt = 0

   DECLARE @c_Taskdetailkey NVARCHAR(10) = ''
 
   ----reject if wave not yet release
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF NOT EXISTS ( SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                      WHERE TD.Wavekey = @c_Wavekey
                      AND TD.Sourcetype IN ('mspRLWAV08')
                      AND TD.Tasktype IN ('FPK') )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 81010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': This Wave has not been released. (mspRVWAV08)'
      END
   END

   ----reject if any task was started
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS ( SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                  WHERE TD.Wavekey = @c_Wavekey
                  AND TD.Sourcetype IN ('mspRLWAV08')
                  AND TD.[Status] <> '0'
                  AND TD.Tasktype IN ('FPK') )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 81020
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Some Tasks have been started. Not allow to Reverse Wave Released (mspRVWAV08)'
      END
   END

   IF @n_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
         COMMIT TRAN

      IF @@TRANCOUNT = 0
         BEGIN TRAN
   END

   ----Delete Taskdetail
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE CUR_TASK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Taskdetailkey
      FROM TASKDETAIL (NOLOCK)
      WHERE Wavekey = @c_Wavekey
      AND Sourcetype IN ('mspRLWAV08')
      AND Tasktype IN ('FPK')

      OPEN CUR_TASK

      FETCH NEXT FROM CUR_TASK INTO @c_Taskdetailkey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN(1,2)
      BEGIN
         DELETE FROM TASKDETAIL 
         WHERE Taskdetailkey = @c_Taskdetailkey

         SELECT @n_Err = @@ERROR

         IF @n_Err <> 0
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 81030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Delete Taskdetail Table Failed. (mspRVWAV08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
         END
      	         	  
         FETCH NEXT FROM CUR_TASK INTO @c_Taskdetailkey 	
      END
      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK    	        	        	        	        	 
   END

   ----Remove taskdetailkey from pickdetail of the wave
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      UPDATE PICKDETAIL WITH (ROWLOCK)
       SET PICKDETAIL.TaskdetailKey = '',
          TrafficCop = NULL
      FROM WAVEDETAIL (NOLOCK)
      JOIN PICKDETAIL ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
      WHERE WAVEDETAIL.Wavekey = @c_Wavekey
      
      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
        SELECT @n_Continue = 3
        SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 81040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
        SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update Pickdetail Table Failed. (mspRVWAV08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END

   -----Reverse wave status------
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      UPDATE WAVE WITH (ROWLOCK)
         SET TMReleaseFlag = 'N'              
          ,  TrafficCop = NULL                
          ,  EditWho = dbo.fnc_GetUserName()
          ,  EditDate= dbo.fnc_GetDate()
      WHERE WaveKey = @c_Wavekey

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 81050   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRVWAV08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END

   IF (XACT_STATE()) = -1
   BEGIN
      IF @@TRANCOUNT > 0 
      BEGIN
         ROLLBACK TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_starttcnt
      BEGIN TRAN

   IF CURSOR_STATUS('LOCAL', 'CUR_TASK') IN (0 , 1)
   BEGIN
      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK   
   END
   
   IF @n_Continue = 3  -- Error Occured - Process And Return
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
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV08'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
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
END --sp end
GO
GRANT EXECUTE ON  [dbo].[mspRVWAV08] TO [NSQL]
GO