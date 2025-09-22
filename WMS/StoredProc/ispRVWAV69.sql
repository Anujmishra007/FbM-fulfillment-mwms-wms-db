SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************/
/* Stored Procedure: ispRVWAV69                                          */
/* Creation Date: 21-Mar-2024                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: UWP-16612 - Wave Release - create VNAOUT tasks during wave   */
/*                      release for Picking (Reverse)                    */
/*                                                                       */
/* Called By:                                                            */
/*                                                                       */
/* Version: 1.2                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  Ver.  Purposes                                   */
/* 21-Mar-2024  WLChooi 1.0   DevOps Combine Script                      */
/* 11-Jun-2025  Wan01   1.1   FCR-2902 - MLP Enhancement - Allocate      */
/*                            Case/Shrink at BULK, Demand Replenishment  */
/*                            to DPP.                                    */
/* 20-Jun-2025  Wan02   1.2   UWP-36410 -MLP Link Repln Task ID in       */
/*                            pickDetail for FCR-2902                    */
/* 12-SEP-2025                Fixed to reverse RPF task type             */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispRVWAV69]
   @c_Wavekey  NVARCHAR(10)
 , @c_Orderkey NVARCHAR(10) = ''
 , @b_Success  INT           OUTPUT
 , @n_err      INT           OUTPUT
 , @c_errmsg   NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue  INT
         , @n_starttcnt INT -- Holds the current transaction count  
         , @n_debug     INT
         , @n_Cnt       INT  

   SELECT @n_starttcnt = @@TRANCOUNT
        , @n_continue = 1
        , @b_Success = 0
        , @n_err = 0
        , @c_errmsg = ''
        , @n_cnt = 0
   SELECT @n_debug = 0

   DECLARE @c_Storerkey     NVARCHAR(15)
         , @c_Sku           NVARCHAR(20)
         , @c_Lot           NVARCHAR(10)
         , @c_ToLoc         NVARCHAR(10)
         , @c_ToID          NVARCHAR(18)
         , @n_Qty           INT
         , @c_Taskdetailkey NVARCHAR(10)
         , @c_GetOrderkey   NVARCHAR(10)
         , @c_GetStorerkey  NVARCHAR(15)
         , @c_PickdetailKey   NVARCHAR(10) = ''                                     --(Wan01)
         , @c_TaskType        NVARCHAR(10) = ''                                     --(Wan01)
         , @c_Message03       NVARCHAR(10) = ''                                     --(Wan01)
         , @c_FromLoc         NVARCHAR(10) = ''                                     --(Wan01)
         , @c_FromID          NVARCHAR(10) = ''                                     --(Wan01)
         , @cur_DelPick       CURSOR                                                --(Wan01)
         , @cur_DelTask       CURSOR                                                --(Wan01)

   --reject if wave not yet release      
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF NOT EXISTS (  SELECT 1
                       FROM  TaskDetail TD (NOLOCK)
                       WHERE TD.WaveKey = @c_Wavekey
                       AND   TD.SourceType IN ( 'ispRLWAV69' )
                       AND   TD.TaskType IN ( 'VNAOUT', 'FCP', 'FPK' )              --(Wan01)  
                       AND   TD.[Status] NOT IN ('X','9')                           --(Wan01)
                    )  
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 67845
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) 
                          + ': This Wave has not been released. (ispRVWAV69)'
      END
   END

   --reject if any task was started
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SET @n_Cnt = 0                                                                --(Wan01) - START
      SELECT TOP 1
             @n_Cnt = CASE WHEN TD.TaskType = 'VNAOUT' AND TD.[Status] NOT IN ('Q','X') 
                           THEN 1
                           WHEN TD.TaskType = 'RPF' AND TD.[Status] NOT IN ('0','X')--2025-09-12 Include RPF task (Manual) 
                           THEN 1
                           WHEN TD.TaskType = 'FPK' AND TD.[Status] NOT IN ('0','X') 
                           THEN 1
                           WHEN TD.TaskType = 'FCP' AND TD.[Status] NOT IN ('H','0','X')
                           THEN 1
                           ELSE 0
                           END
      FROM TaskDetail TD (NOLOCK)
      WHERE TD.WaveKey = @c_Wavekey
      ORDER BY 1 DESC
       
      IF @n_Cnt = 1
      --IF EXISTS (  SELECT 1
      --             FROM TaskDetail TD (NOLOCK)
      --             WHERE TD.WaveKey = @c_Wavekey
      --             AND   TD.SourceType IN ( 'ispRLWAV69' )
      --             AND   TD.[Status] NOT IN ( 'Q', 'X', '0')
      --             AND   TD.TaskType IN ( 'VNAOUT', 'FCP' )                     
      --          )                                                                 --(Wan01) - END
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 67850
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err)
                          + ': Some Tasks have been started'
                          + '. Not allow to Reverse Wave Released (ispRVWAV69)'
      END
   END

   BEGIN TRAN

   --Delete Pickheader 
   --IF @n_continue = 1 OR @n_continue = 2
   --BEGIN
   --   DECLARE CUR_Orders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   --   SELECT DISTINCT OH.OrderKey
   --                 , OH.StorerKey
   --   FROM WAVEDETAIL WD (NOLOCK)
   --   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = WD.OrderKey
   --   WHERE WD.WaveKey = @c_Wavekey

   --   OPEN CUR_Orders

   --   FETCH NEXT FROM CUR_Orders
   --   INTO @c_GetOrderkey
   --      , @c_GetStorerkey

   --   WHILE @@FETCH_STATUS <> -1
   --   BEGIN
   --      DELETE FROM PICKHEADER
   --      WHERE OrderKey = @c_GetOrderkey AND StorerKey = @c_GetStorerkey

   --      FETCH NEXT FROM CUR_Orders
   --      INTO @c_GetOrderkey
   --         , @c_GetStorerkey
   --   END
   --   CLOSE CUR_Orders
   --   DEALLOCATE CUR_Orders
   --END

   --Remove taskdetailkey from pickdetail of the wave
   IF @n_continue = 1 OR @n_continue = 2                                            --(Wan01) - START
   BEGIN
      SET @cur_DelPick = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT pd.Pickdetailkey 
      FROM  Pickdetail pd (NOLOCK)
      JOIN  WaveDetail wd (NOLOCK) ON wd.Orderkey = pd.Orderkey
      JOIN  TaskDetail td (NOLOCK) ON  td.TaskDetailKey = pd.TaskDetailkey
                                   AND td.Wavekey = wd.Wavekey
                                   AND td.Orderkey= pd.Orderkey
      WHERE wd.WaveKey = @c_Wavekey
      AND   td.SourceType IN ( 'ispRLWAV69' )
      AND   td.TaskType IN ( 'VNAOUT', 'FCP', 'FPK' )
      AND   td.[Status] IN ('Q', '0', 'H')
      ORDER BY pd.Pickdetailkey 

      OPEN @cur_DelPick

      FETCH NEXT FROM @cur_DelPick INTO @c_PickdetailKey
 
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN 
         UPDATE PICKDETAIL WITH (ROWLOCK)
         SET TaskDetailKey = ''
           , TrafficCop = NULL
           , EditWho = SUSER_SNAME()
           , EditDate = GETDATE()
         --FROM WAVEDETAIL (NOLOCK)
         --JOIN PICKDETAIL ON WAVEDETAIL.OrderKey = PICKDETAIL.OrderKey
         --WHERE WAVEDETAIL.WaveKey = @c_Wavekey
         WHERE PICKDETAIL.PickdetailKey = @c_PickdetailKey

         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250), @n_err)
                 , @n_err = 67860 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) 
                             + ': Update Pickdetail Table Failed. (ispRVWAV69)'
                             + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END
         FETCH NEXT FROM @cur_DelPick INTO @c_PickdetailKey
      END
      CLOSE @cur_DelPick
      DEALLOCATE @cur_DelPick
   END

   --Delete VNAOUT replenishment/ FPK / FCP/ VNAOUT FPK
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SET @cur_DelTask = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT td.Taskdetailkey
            ,td.TaskType
            ,td.Storerkey
            ,td.Message03
            ,td.FromLoc
            ,td.FromID
      FROM TaskDetail td (NOLOCK)
      WHERE td.WaveKey = @c_Wavekey
      AND   td.SourceType IN ( 'ispRLWAV69' )
      AND   td.TaskType IN ( 'VNAOUT', 'FCP', 'FPK', 'RPF' )                        --2025-08-13
      AND   td.[Status] IN ('Q', '0', 'H')
      ORDER BY td.Taskdetailkey DESC                                                --(Wan02)  

      OPEN @cur_DelTask

      FETCH NEXT FROM @cur_DelTask INTO @c_TaskdetailKey
                                       ,@c_TaskType
                                       ,@c_Storerkey
                                       ,@c_Message03
                                       ,@c_FromLoc
                                       ,@c_FromID

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN  
         IF @c_TaskType IN ('VNAOUT', 'RPF') AND @c_Message03 = 'RPF'               --2025-08-13--(Wan02) - START   
         BEGIN
            IF EXISTS ( SELECT 1 FROM TASKDETAIL td (NOLOCK) 
                        WHERE td.Storerkey = @c_Storerkey
                        AND   td.TaskType = 'FCP'
                        AND   td.UOM IN ('2','3','6')                               --2025-07-09           
                        AND   td.SourceType = 'ispRLWAV69'
                        AND   td.RefTaskKey = @c_Taskdetailkey
                        AND   td.[Status] NOT IN ('X','9')
                      )
            BEGIN
               GOTO NEXT_TASK
            END
         END                                                                        --(Wan02) - END 

         DELETE TaskDetail WITH (ROWLOCK)
         WHERE TaskDetail.WaveKey = @c_Wavekey
         --AND   TaskDetail.SourceType IN ( 'ispRLWAV69' )                             
         --AND   TaskDetail.TaskType IN ( 'VNAOUT', 'FCP' )                            
         AND   TaskDetail.[Status] IN ('Q', '0', 'H')                                  
         AND   TaskDetail.Taskdetailkey = @c_Taskdetailkey                             

         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250), @n_err)
                 , @n_err = 67855 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) 
                             + ': Delete Taskdetail Table Failed. (ispRVWAV69)'
                             + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         NEXT_TASK:                                                                 --(Wan02)  
         FETCH NEXT FROM @cur_DelTask INTO @c_TaskdetailKey
                                          ,@c_TaskType
                                          ,@c_Storerkey
                                          ,@c_Message03
                                          ,@c_FromLoc
                                          ,@c_FromID
      END
      CLOSE @cur_DelTask
      DEALLOCATE @cur_DelTask
   END                                                                              --(Wan01) - END

   --Update status back to 2
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SET @c_GetOrderkey = N''

      DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT OrderKey
      FROM WAVEDETAIL (NOLOCK)
      WHERE WaveKey = @c_Wavekey

      OPEN CUR_LOOP

      FETCH NEXT FROM CUR_LOOP
      INTO @c_GetOrderkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         UPDATE ORDERS WITH (ROWLOCK)
         SET [Status] = CASE WHEN [Status] = '3' THEN '2'
                             ELSE [Status] END
         WHERE OrderKey = @c_GetOrderkey

         FETCH NEXT FROM CUR_LOOP
         INTO @c_GetOrderkey
      END
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP
   END

   --Reverse wave status
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      UPDATE WAVE
      SET TMReleaseFlag = 'N'
        , TrafficCop = NULL
        , EditWho = SUSER_SNAME()
        , EditDate = GETDATE()
      WHERE WaveKey = @c_Wavekey

      SELECT @n_err = @@ERROR

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(NVARCHAR(250), @n_err)
              , @n_err = 67865 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) + ': Update on wave Failed (ispRVWAV69)' + ' ( '
                            + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
      END
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_LOOP') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_Orders') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_Orders
      DEALLOCATE CUR_Orders
   END

   RETURN_SP:
   IF @n_continue = 3 -- Error Occured - Process And Return  
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispRVWAV69'
      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR -- SQL2012  
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
GRANT EXECUTE ON [dbo].[ispRVWAV69] TO [NSQL]
GO