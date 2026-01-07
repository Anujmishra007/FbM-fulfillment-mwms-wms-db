SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRVWAV02                                          */    
/* Creation Date: 2024-05-15                                             */
/* Copyright: Maersk                                                     */    
/* Written by: Supriya Sangeetham                                        */    
/*                                                                       */    
/* Purpose: UWP-18823 - cancel replenishment post wave cancellation      */   
/*                                                                       */    
/* Called By: Wave Release                                               */    
/*                                                                       */    
/* Version: 1.0                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 2024-11-11  SSA01    1.1   Updated to restrict release for already    */
/*                            started tasks                              */
/* 2025-05-15  Wan01    1.8   FCR-3958 - JCB Picking Task                */
/*                            Overwrite the whole logic as implement new */
/*                            process. Use back same SP                  */
/* 2025-12-31                 Version 1.90, CR V2.4                      */
/*************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV02]        
   @c_Wavekey      NVARCHAR(10) 
,  @c_Orderkey     NVARCHAR(10) = ''     
,  @b_Success      int          = 1    OUTPUT    
,  @n_err          int          = 0    OUTPUT    
,  @c_errmsg       NVARCHAR(250)= ''   OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
      
   DECLARE @n_Continue       int = 1      
         , @n_StartTCnt      int = @@TRANCOUNT        -- Holds the current transaction count    
         , @n_debug          int = 0  
         , @n_Cnt            INT = 0 
         , @c_TaskStatus     NCHAR(1) = ''
 
         , @c_TaskType       NVARCHAR(10) = ''
         , @c_Storerkey      NVARCHAR(15) = '' 
         , @c_Facility       NVARCHAR(5)  = ''  
         , @c_Taskdetailkey  NVARCHAR(10) = '' 
         , @c_PickDetailKey  NVARCHAR(10) = '' 
         , @c_UOM            NVARCHAR(10) = ''
         , @c_FromLot        NVARCHAR(10) = ''
         , @c_FromLoc        NVARCHAR(18) = ''
         , @c_FromID         NVARCHAR(18) = ''
         , @c_ToLoc          NVARCHAR(18) = ''
         , @c_ToID           NVARCHAR(18) = ''
         , @c_RefTaskkey     NVARCHAR(10) = ''                                      --v1.90 
         , @c_SourceType     NVARCHAR(30) = 'mspRLWAV02'
                                      
         , @CUR_DELTASK      CURSOR
         , @CUR_DELPICK      CURSOR
      
   SET @b_success=0
   SET @n_err=0
   SET @c_errmsg=''
   SET @n_Cnt=0  

   IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL                                     
   BEGIN
      DROP TABLE #TMP_ORD
   END

   CREATE TABLE #TMP_ORD
      (  RowID          INT            NOT NULL    IDENTITY(1,1)
      ,  Orderkey       NVARCHAR(10)   NOT NULL    DEFAULT('') PRIMARY KEY
      ,  Facility       NVARCHAR(5)    NOT NULL    DEFAULT('') 
      ,  Storerkey      NVARCHAR(15)   NOT NULL    DEFAULT('')
      )

   IF @c_Orderkey = ''
   BEGIN
      INSERT INTO #TMP_ORD (Orderkey, Storerkey, Facility)
      SELECT O.Orderkey, O.StorerKey, O.Facility   
      FROM WAVEDETAIL WD (NOLOCK)  
      JOIN ORDERS O (NOLOCK) ON (WD.Orderkey = O.Orderkey)  
      WHERE WD.Wavekey = @c_Wavekey 
      ORDER BY WD.WaveDetailKey
   END
   ELSE 
   BEGIN
      INSERT INTO #TMP_ORD (Orderkey, Storerkey, Facility)
      SELECT O.Orderkey, O.StorerKey, O.Facility   
      FROM ORDERS O (NOLOCK)   
      WHERE O.OrderKey = @c_Orderkey
   END

   -----Get Storerkey and facility 
   SELECT TOP 1 
            @c_StorerKey = O.Storerkey  
         ,  @c_Facility = O.Facility   
   FROM #TMP_ORD O 
   ORDER BY O.RowID
  
   ----reject if wave not yet release        
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN 
      SET @c_TaskStatus = ''
      SELECT TOP 1 
            @c_TaskStatus = CASE WHEN TD.[Status] IN ('0', 'S') THEN '0' ELSE '3' END
      FROM TASKDETAIL TD (NOLOCK) 
      JOIN #TMP_ORD O ON O.Orderkey  = TD.Orderkey
      WHERE TD.Wavekey  = @c_Wavekey 
      AND TD.SourceType = @c_SourceType
      AND TD.TaskType   IN ('FCP')
      ORDER BY 1 

      IF @c_TaskStatus  = ''
      BEGIN                                            
         SET @n_Continue = 3    
         SET @n_err = 81010    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                      +': This Wave has not been released. (mspRVWAV02)'           
      END 

      IF @c_TaskStatus  = '3'
      BEGIN                                            
         SET @n_Continue = 3    
         SET @n_err = 81020    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                      +': Nothing to Reverse. (mspRVWAV02)'           
      END 
   END  
      
   BEGIN TRAN  
   
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN 
      SET @CUR_DELTASK = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT td.TaskDetailKey
            ,td.RefTaskKey                                                          --v1.90
      FROM TASKDETAIL td (NOLOCK)
      JOIN #TMP_ORD O ON O.Orderkey  = TD.Orderkey
      OUTER APPLY (SELECT td1.TaskDetailKey                                         --2025-12-17 - START
                        , Status_RPF = CASE WHEN td1.TaskType = 'RP1' AND
                                                 td1.[Status] <> 'X'
                                            THEN '3'                                --3: In Progress
                                            WHEN td1.TaskType = 'RPF' AND
                                                 td1.[Status] NOT IN ('0','X')
                                            THEN '3'
                                            ELSE '0'                                --0: Can be Reversed
                                            END
                   FROM  TaskDetail td1 (NOLOCK)
                   WHERE td1.TaskDetailKey = td.RefTaskkey
                   AND   td1.TaskType IN ('RPF', 'RP1')
                   ) trp                                                            --2025-12-17 - END
      WHERE td.Wavekey    = @c_Wavekey
      AND   td.SourceType = @c_SourceType
      AND   td.TaskType   = 'FCP'
      AND   td.[Status]    IN ('0','S')
      AND   trp.Status_RPF IN (NULL,'0')                                            --2025-12-17
      ORDER BY td.TaskDetailKey

      OPEN @CUR_DELTASK

      FETCH NEXT FROM @CUR_DELTASK INTO @c_TaskDetailKey
                                       ,@c_RefTaskkey                               --v1.90

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         DELETE TASKDETAIL WITH (ROWLOCK) 
         WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey   
         AND TASKDETAIL.Sourcetype = @c_SourceType 
         AND TASKDETAIL.TaskType = 'FCP' 
         AND TASKDETAIL.Status IN ('0','S') 
      
         SET @n_err = @@ERROR  
         IF @n_err <> 0   
         BEGIN  
            SET @n_Continue = 3    
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
            SET @n_err = 81040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                         +': Delete Taskdetail Table Failed. (mspRVWAV02)' 
         END 

         IF @n_Continue = 1
         BEGIN
            SET @CUR_DELPICK = CURSOR FAST_FORWARD READ_ONLY FOR
            SELECT pd.PickDetailKey
                  ,pd.Orderkey
                  ,pd.UOM
                  ,pd.ToLoc
                  ,pd.CaseId
                  ,pd.Lot
                  ,pd.Loc
                  ,pd.ID
            FROM WAVEDETAIL wd (NOLOCK)    
            JOIN PICKDETAIL pd (NOLOCK) ON pd.Orderkey = wd.Orderkey  
            WHERE wd.Wavekey = @c_Wavekey
            AND   pd.TaskDetailKey = @c_Taskdetailkey
            ORDER BY pd.PickDetailKey

            OPEN @CUR_DELPICK

            FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey
                                             ,@c_Orderkey
                                             ,@c_UOM
                                             ,@c_FromLoc
                                             ,@c_FromID
                                             ,@c_FromLot
                                             ,@c_ToLoc
                                             ,@c_ToID

            WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
            BEGIN
               IF @n_Continue = 1 
               BEGIN
                  UPDATE PICKDETAIL WITH (ROWLOCK)   
                     SET PICKDETAIL.TaskdetailKey = ''   
                        ,TrafficCop = NULL  
                  WHERE PICKDETAIL.PickDetailKey = @c_PickDetailKey   
           
                  SET @n_err = @@ERROR  
                  IF @n_err <> 0   
                  BEGIN  
                     SET @n_Continue = 3    
                     SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                     SET @n_err = 81050   
                     SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                  +': Update Pickdetail Table Failed. (mspRVWAV02)' 
                  END 
               END
                              
               IF @c_UOM = '7' AND @c_FromLoc > '' AND @c_FromID > ''
               BEGIN
                  SET @c_TaskDetailKey = ''
                  SELECT @c_TaskDetailKey =  td.TaskDetailKey 
                  FROM TASKDETAIL td (NOLOCK)
                  WHERE td.TaskDetailKey = @c_RefTaskKey                            --v1.90
                  AND   td.TaskType   = 'RPF'
                  AND   td.Storerkey  = @c_Storerkey
                  AND   td.[Status]   = '0'
                  AND   td.SourceType = @c_SourceType

                  IF @c_TaskDetailKey > ''
                  BEGIN
                     IF NOT EXISTS (SELECT 1                                        --v1.90         
                                    FROM TASKDETAIL td (NOLOCK)
                                    WHERE td.TaskType   = 'FCP'
                                    AND   td.CaseID     >= ''
                                    AND   td.Storerkey  = @c_Storerkey
                                    AND   td.Sourcetype = @c_SourceType 
                                    AND   td.RefTaskkey = @c_RefTaskkey
                                    AND   td.[Status] IN ('0','S')
                                    AND   td.FromID     = @c_ToID                   --Loose ID
                                    AND   td.UOM        = '7'
                                   )
                     BEGIN
                        DELETE TASKDETAIL WITH (ROWLOCK) 
                        WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey   
                        AND TASKDETAIL.Sourcetype = @c_SourceType 
                        AND TASKDETAIL.TaskType   = 'RPF' 

                        SET @n_err = @@ERROR  
                        IF @n_err <> 0   
                        BEGIN  
                           SET @n_Continue = 3    
                           SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                           SET @n_err = 81060   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
                           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                        +': Delete Taskdetail Table Failed. (mspRVWAV02)' 
                        END 
                     END
                  END
               END

               FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey
                                                ,@c_Orderkey
                                                ,@c_UOM
                                                ,@c_FromLoc
                                                ,@c_FromID
                                                ,@c_FromLot
                                                ,@c_ToLoc
                                                ,@c_ToID
            END
            CLOSE @CUR_DELPICK
            DEALLOCATE @CUR_DELPICK
         END
         FETCH NEXT FROM @CUR_DELTASK INTO @c_TaskDetailKey
                                          ,@c_RefTaskkey                            --v1.90
      END
      CLOSE @CUR_DELTASK
      DEALLOCATE @CUR_DELTASK
   END  
   
   -----Reverse wave status------  
   IF @n_Continue = 1 or @n_Continue = 2    
   BEGIN    
      UPDATE WAVE   
         SET TMReleaseFlag = 'N'                
          ,  TrafficCop = NULL                  
      WHERE WAVEKEY = @c_wavekey 
      
      SET @n_err = @@ERROR    
      IF @n_err <> 0    
      BEGIN    
         SET @n_Continue = 3    
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
         SET @n_err = 81060   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (mspRVWAV02)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '    
      END    
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
      execute nsp_logerror @n_err, @c_errmsg, "mspRVWAV02"    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN    
   END    
   ELSE    
   BEGIN    
      SET @b_success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
      RETURN    
   END       
END --sp end  
GO
GRANT EXECUTE ON [dbo].[mspRVWAV02] TO [NSQL]
GO