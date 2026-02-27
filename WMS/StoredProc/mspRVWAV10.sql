SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRVWAV10                                          */    
/* Creation Date: 2026-02-10                                             */    
/* Copyright: Maersk Logistics                                           */    
/* Written by: WLChooi                                                   */    
/*                                                                       */    
/* Purpose: FCR-10124 - UK Columbia SportWear Reverse Wave               */   
/*                                                                       */    
/* Called By: Wave                                                       */    
/*                                                                       */    
/* Version: 1.2                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 10-Feb-2026 WLChooi  1.0   Initial Version                            */
/* 20-Feb-2026 WLChooi  1.1   FCR-11076 Added CPK filter (WL01)          */
/* 26-Feb-2026 WLChooi  1.2   FCR-11158 Added ASTCPK Task (WL02)         */
/*************************************************************************/ 
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV10]
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

   DECLARE @c_Taskdetailkey   NVARCHAR(10) = ''
         , @c_Pickslipno      NVARCHAR(10) = ''
         , @c_CartonNo        NVARCHAR(5) = ''
 
   -- Reject if wave not yet release
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF NOT EXISTS ( SELECT 1 FROM WAVE W (NOLOCK)
                      WHERE W.Wavekey = @c_Wavekey
                      AND W.TMReleaseFlag = 'Y' )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 67010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) 
                          + ': This Wave has not been released. (mspRVWAV10)'
      END
   END

   --  Reject if any task was started
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS ( SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                  WHERE TD.Wavekey = @c_Wavekey
                  AND TD.Sourcetype IN ('mspRLWAV10')
                  AND TD.[Status] NOT IN ('0', 'H')   --WL01
                  AND TD.Tasktype IN ('CPK', 'ASTCPK') )   --WL02
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 67020
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) 
                          + ': Some Tasks have been started. Not allow to Reverse Wave Released (mspRVWAV10)'
      END
   END

   IF @n_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
         COMMIT TRAN

      IF @@TRANCOUNT = 0
         BEGIN TRAN
   END

   -- Delete Taskdetail
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE CUR_TASK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Taskdetailkey
      FROM TASKDETAIL (NOLOCK)
      WHERE Wavekey = @c_Wavekey
      AND Sourcetype IN ('mspRLWAV10')
      AND Tasktype IN ('CPK', 'ASTCPK')   --WL02

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
            SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 67030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Delete Taskdetail Table Failed. (mspRVWAV10)' 
                             + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
         END
      	         	  
         FETCH NEXT FROM CUR_TASK INTO @c_Taskdetailkey 	
      END
      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK    	        	        	        	        	 
   END

   --Delete Packing Info
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE CUR_PACK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.Pickslipno, PD.CartonNo
      FROM WAVEDETAIL WD WITH (NOLOCK)
      JOIN PACKHEADER PH WITH (NOLOCK) ON WD.OrderKey = PH.OrderKey
      JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
      WHERE WD.WaveKey = @c_Wavekey

      OPEN CUR_PACK

      FETCH NEXT FROM CUR_PACK INTO @c_Pickslipno, @c_CartonNo

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         DELETE FROM dbo.PackDetail
         WHERE PickSlipNo = @c_Pickslipno
         AND CartonNo = @c_CartonNo

         SELECT @n_Err = @@ERROR

         IF @n_Err <> 0
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 67040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Delete PACKDETAIL Table Failed. (mspRVWAV10)' 
                             + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
            GOTO QUIT_SP
         END

         IF NOT EXISTS ( SELECT 1
                         FROM PACKDETAIL (NOLOCK)
                         WHERE Pickslipno = @c_Pickslipno )
         BEGIN
            DELETE FROM dbo.PackHeader
            WHERE PickSlipNo = @c_Pickslipno

            SELECT @n_Err = @@ERROR

            IF @n_Err <> 0
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 67050   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Delete PACKHEADER Table Failed. (mspRVWAV10)' 
                                + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
               GOTO QUIT_SP
            END
         END
         
         FETCH NEXT FROM CUR_PACK INTO @c_Pickslipno, @c_CartonNo
      END
      CLOSE CUR_PACK
      DEALLOCATE CUR_PACK
   END

   -- Remove taskdetailkey & CaseID from pickdetail of the wave
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      UPDATE PICKDETAIL WITH (ROWLOCK)
      SET PICKDETAIL.TaskdetailKey = ''
        , PICKDETAIL.CaseID = ''
        , TrafficCop = NULL
        , EditWho  = SUSER_SNAME()
        , EditDate = GETDATE()
      FROM WAVEDETAIL (NOLOCK)
      JOIN PICKDETAIL ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
      WHERE WAVEDETAIL.Wavekey = @c_Wavekey
      
      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 67060   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update Pickdetail Table Failed. (mspRVWAV10)' 
                          + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
         GOTO QUIT_SP
      END
   END

   -- Reverse wave status
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      UPDATE WAVE WITH (ROWLOCK)
         SET TMReleaseFlag = 'N'
          ,  TrafficCop = NULL
          ,  EditWho  = SUSER_SNAME()
          ,  EditDate = GETDATE()
      WHERE WaveKey = @c_Wavekey

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 67070   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRVWAV10)' 
                          + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
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

   IF CURSOR_STATUS('LOCAL', 'CUR_TASK') IN (0 , 1)
   BEGIN
      CLOSE CUR_TASK
      DEALLOCATE CUR_TASK   
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PACK') IN (0 , 1)
   BEGIN
      CLOSE CUR_PACK
      DEALLOCATE CUR_PACK   
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
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV10'
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
GRANT EXECUTE ON  [dbo].[mspRVWAV10] TO [NSQL]
GO