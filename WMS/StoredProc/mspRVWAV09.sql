SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRVWAV09                                          */    
/* Creation Date: 2025-11-24                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by:                                                           */    
/*                                                                       */    
/* Purpose: Reverse release wave SP for VIVO							 */  
/*                                                                       */  
/*                                                                       */    
/* Called By: Wave Release                                               */    
/*                                                                       */    
/* PVCS Version: 1.0                                                     */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/*************************************************************************/
CREATE OR ALTER PROCEDURE   PROCEDURE [dbo].[mspRVWAV09]
  @c_Wavekey      NVARCHAR(10)
 ,@c_Orderkey     NVARCHAR(10)   = ''
 ,@b_Success      int            = 1   OUTPUT
 ,@n_Err          int            = 0   OUTPUT
 ,@c_Errmsg       NVARCHAR(250)  = ''  OUTPUT
 AS
 BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT = 1
         , @n_StartTCnt          INT = @@TRANCOUNT         -- Holds the current transaction count
         , @n_debug              INT = 0
         , @n_cnt                INT = 0

         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_Facility           NVARCHAR(5)    = ''
         , @c_SourceType         NVARCHAR(30)   = 'mspRLWAV09'
         , @c_TaskDetailKey      NVARCHAR(10)    = ''
         , @c_TaskType           NVARCHAR(10)    = ''
         , @c_SourceKey          NVARCHAR(10)    = ''
         , @c_GroupKey           NVARCHAR(10)    = ''
         , @c_PickDetailKey      NVARCHAR(10)    = ''

         , @CUR_DELTASK    CURSOR
         , @CUR_DELPICK    CURSOR

   SET @b_success = 0
   SET @n_Err = 0
   SET @c_Errmsg = ''

   -----Get Storerkey and facility

   SELECT TOP 1 @c_StorerKey = O.Storerkey,
               @c_Facility = O.Facility
   FROM WAVE W (NOLOCK)
   JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
   WHERE WD.Wavekey = @c_Wavekey

   IF NOT EXISTS (SELECT 1 FROM TASKDETAIL TD (NOLOCK)   
                  WHERE TD.Wavekey  = @c_Wavekey 
                  AND TD.SourceType = @c_SourceType
                  AND TD.TaskType IN ('RPF','FPK', 'FCP')
                 ) 
   BEGIN
      SET @n_Continue = 3    
      SET @n_Err   = 81010    
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                   +': This Wave has not been released (mspRVWAV09)'         
   END

----reject if any task was started  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN 
      IF EXISTS ( SELECT 1  
                  FROM TASKDETAIL TD (NOLOCK)   
                  WHERE TD.Wavekey = @c_Wavekey  
                  AND  TD.Sourcetype = @c_SourceType
                  AND  TD.TaskType IN ('FPK','FCP','RPF')
                  AND  TD.[Status] NOT IN ('H', '0', 'X')
                )
      BEGIN  
          SET @n_Continue = 3    
          SET @n_Err    = 81020    
          SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                       +': Some Tasks have been started. Not allow to Reverse Wave Released (mspRVWAV09)'         
      END                   
   END  
    
   ----delete tasks  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN 
      SET @CUR_DELTASK = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT TD.Storerkey, TD.TaskDetailKey, TD.TaskType
            ,TD.Sourcekey, TD.GroupKey
      FROM TASKDETAIL TD (NOLOCK)   
      WHERE TD.Wavekey = @c_Wavekey  
      AND  TD.Sourcetype = @c_SourceType 
      AND  TD.TaskType IN ('FPK','FCP', 'RPF')                                  
      AND  TD.[Status] IN ('0', 'H')                                               
      ORDER BY TD.TaskType, TD.TaskDetailKey 

      OPEN @CUR_DELTASK

      FETCH NEXT FROM @CUR_DELTASK INTO @c_Storerkey, @c_TaskDetailKey, @c_TaskType
                                       ,@c_Sourcekey, @c_GroupKey
 
      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         IF @c_TaskType = 'RPF'
         BEGIN 
            IF EXISTS (SELECT 1 FROM REPLENISHMENT rp (NOLOCK)
                       WHERE rp.ReplenishmentKey = @c_Sourcekey
                       AND   rp.ReplenishmentGroup = 'DYNAMIC'
                       AND   rp.Storerkey = @c_Storerkey
                       AND   rp.Confirmed = 'Y'
                       )
            BEGIN
               UPDATE REPLENISHMENT WITH (ROWLOCK)
                   SET Confirmed = 'N'
                      ,ArchiveCop= NULL
               WHERE ReplenishmentKey = @c_Sourcekey

               SET @n_err = @@ERROR  
               IF @n_err <> 0   
               BEGIN  
                  SET @n_continue = 3    
               END 
            END
         END

         DELETE TASKDETAIL WITH (ROWLOCK)
         WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey   
           
         SET @n_err = @@ERROR  
         IF @n_err <> 0   
         BEGIN  
            SET @n_continue = 3    
         END 
         FETCH NEXT FROM @CUR_DELTASK INTO @c_Storerkey, @c_TaskDetailKey, @c_TaskType
                                          ,@c_Sourcekey, @c_GroupKey
      END
      CLOSE @CUR_DELTASK
      DEALLOCATE @CUR_DELTASK
   END  

   ----Remove taskdetailkey from pickdetail of the wave  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN 
      SET @CUR_DELPICK = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT PickDetailKey = PICKDETAIL.PickDetailKey
      FROM WAVEDETAIL (NOLOCK)    
      JOIN PICKDETAIL (NOLOCK) ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
      WHERE WAVEDETAIL.Wavekey = @c_Wavekey
      ORDER BY PICKDETAIL.PickDetailKey

      OPEN @CUR_DELPICK

      FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey

      WHILE @@FETCH_STATUS = 0  AND @n_Continue = 1
      BEGIN
         UPDATE PICKDETAIL WITH (ROWLOCK)   
            SET PICKDETAIL.TaskdetailKey = ''   
               ,TrafficCop = NULL                                                                   
         FROM PICKDETAIL                                                                            
         WHERE PICKDETAIL.PickDetailKey = @c_PickDetailKey   
           
         SET @n_err = @@ERROR  
         IF @n_err <> 0   
         BEGIN  
            SET @n_continue = 3    
         END 
         FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey
      END
      CLOSE @CUR_DELPICK
      DEALLOCATE @CUR_DELPICK
   END             

QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
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
      execute nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV09'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END --sp end
GO
GRANT EXECUTE ON  [dbo].[mspRVWAV09] TO [NSQL]
GO
