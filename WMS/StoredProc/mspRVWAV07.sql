SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspRVWAV07                                          */
/* Creation Date: 15-MAY-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by:                                                           */
/*                                                                       */
/* Purpose: FCR-4175  VN DIAGEOVN Reverse Wave from Replenishment and Pick*/
/*                                                                       */
/* Called By: wave                                                       */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 15-MAY-2025 NJOW     1.0   DEVOPS Combine Script                      */
/* 10-Oct-2025 SSA01    1.1   UWP-42248 -Enhanced session management     */
/*************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV07]
  @c_wavekey      NVARCHAR(10)
 ,@c_Orderkey     NVARCHAR(10) = ''
 ,@b_Success      int        OUTPUT
 ,@n_err          int        OUTPUT
 ,@c_errmsg       NVARCHAR(250)  OUTPUT
 AS
 BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @n_continue int,
            @n_starttcnt int,         -- Holds the current transaction count
            @n_debug int,
            @n_cnt int

    SELECT @n_starttcnt=@@TRANCOUNT , @n_continue=1, @b_success=0,@n_err=0,@c_errmsg='',@n_cnt=0, @n_debug = 0

    DECLARE @c_Storerkey NVARCHAR(15)
           ,@c_Sku NVARCHAR(20)
           ,@c_Taskdetailkey NVARCHAR(10)
           ,@c_TaskType NVARCHAR(10)
           ,@c_Message03 NVARCHAR(20)
           ,@c_UCCNo NVARCHAR(20)

    ----reject if wave not yet release
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                   WHERE TD.Wavekey = @c_Wavekey
                   AND TD.Sourcetype IN ('mspRLWAV07')
                   AND TD.Tasktype IN ('RPF','FCP'))
        BEGIN
           SELECT @n_continue = 3
           SELECT @n_err = 81010
           SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave has not been released. (mspRVWAV07)'
        END
    END

    ----reject if any task was started
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                  WHERE TD.Wavekey = @c_Wavekey
                  AND TD.Sourcetype IN ('mspRLWAV07')
                  AND TD.Status <> '0'
                  AND TD.Tasktype IN ('RPF','FCP'))
       BEGIN
          SELECT @n_continue = 3
          SELECT @n_err = 81020
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Some Tasks have been started. Not allow to Reverse Wave Released (mspRVWAV07)'
       END
    END

    BEGIN TRAN

    ----delete replenishment
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
    	 DECLARE cur_task CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    	    SELECT Taskdetailkey, TaskType, CaseID, Message03, Storerkey, Sku
    	    FROM TASKDETAIL (NOLOCK)
    	    WHERE Wavekey = @c_Wavekey
    	    AND Sourcetype IN ('mspRLWAV07')
    	    AND Tasktype IN ('RPF','FCP')

       OPEN cur_task

       FETCH NEXT FROM cur_task INTO @c_Taskdetailkey, @c_TaskType, @c_UCCNo, @c_Message03, @c_Storerkey, @c_Sku

       WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
       BEGIN
       	  DELETE FROM TASKDETAIL WHERE Taskdetailkey = @c_Taskdetailkey

          SELECT @n_err = @@ERROR
          IF @n_err <> 0
          BEGIN
             SELECT @n_continue = 3
             SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
             SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Delete Taskdetail Table Failed. (mspRVWAV07)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
          END
       	         	  
          FETCH NEXT FROM cur_task INTO @c_Taskdetailkey, @c_TaskType, @c_UCCNo, @c_Message03, @c_Storerkey, @c_Sku       	
       END
       CLOSE cur_task
       DEALLOCATE cur_task    	        	        	        	        	 
    END

    ----Remove taskdetailkey from pickdetail of the wave
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
         UPDATE PICKDETAIL WITH (ROWLOCK)
          SET PICKDETAIL.TaskdetailKey = '',
             TrafficCop = NULL
         FROM WAVEDETAIL (NOLOCK)
         JOIN PICKDETAIL ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
         WHERE WAVEDETAIL.Wavekey = @c_Wavekey

         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (mspRVWAV07)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END
    END

    -----Reverse wave status------
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       UPDATE WAVE WITH (ROWLOCK)
          SET TMReleaseFlag = 'N'              
           ,  TrafficCop = NULL                
           ,  EditWho = dbo.fnc_GetUserName()       --(SSA01)
           ,  EditDate= dbo.fnc_GetDate()   --(SSA01)
       WHERE WAVEKEY = @c_wavekey
       SELECT @n_err = @@ERROR
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81050   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (mspRVWAV07)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
       END
    END

RETURN_SP:

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
       execute nsp_logerror @n_err, @c_errmsg, "mspRVWAV07"
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
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
 END --sp end
GO
GRANT EXECUTE ON  [dbo].[mspRVWAV07] TO [NSQL]
GO
