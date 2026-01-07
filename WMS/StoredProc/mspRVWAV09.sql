SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/    
/* Stored Procedure: mspRVWAV09                                           */    
/* Creation Date: 2025-12-12                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-9008 - ONBR Release Wave                                  */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          : Duplicate and Modify from Mattel mspRLWAV01                 */    
/* PVCS Version: 1.0                                                      */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */    
/**************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV09]        
   @c_Wavekey      NVARCHAR(10)    
,  @c_Orderkey     NVARCHAR(10) = ''              
,  @b_Success      int            = 1   OUTPUT    
,  @n_Err          int            = 0   OUTPUT    
,  @c_errmsg       NVARCHAR(250)  = ''  OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
      
   DECLARE @n_Continue        INT = 1     
         , @n_StartTCnt       INT = @@TRANCOUNT         -- Holds the current transaction count    
         , @n_Debug           INT = 0 
         , @n_Cnt             INT = 0
         , @n_Cnt_RV          INT = 0
         , @b_Reverse         BIT = 0

   DECLARE @c_Storerkey       NVARCHAR(15)   = ''  
         , @c_Facility        NVARCHAR(5)    = ''
         , @c_Taskdetailkey   NVARCHAR(10)   = ''
         , @c_TaskType        NVARCHAR(10)   = ''  
         , @c_Status          NVARCHAR(10)   = '' 
         , @c_SourceType      NVARCHAR(30)   = 'mspRLWAV09'
         , @c_PickDetailKey   NVARCHAR(10)   = ''

         , @c_authority       NVARCHAR(10)   = '' 

         , @CUR_DELPICK       CURSOR
         , @CUR_DELTASK       CURSOR
         , @CUR_UPDORD        CURSOR
   SET @b_Success = 0
   SET @n_Err = 0
   SET @c_errmsg = ''
 
   IF @@TRANCOUNT = 0 
   BEGIN
      BEGIN TRAN
   END

   IF OBJECT_ID('tempdb..#TMP_TASK') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_TASK  
   END

   CREATE TABLE #TMP_TASK
   ( 
      [TaskDetailKey]   NVARCHAR(20)   NOT NULL DEFAULT('') PRIMARY KEY
   ,  [TaskType]        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [TaskStatus]      NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [Storerkey]       NVARCHAR(20)   NOT NULL DEFAULT('')
   ,  [Sku]             NVARCHAR(20)   NOT NULL DEFAULT('')
   ,  [RefTaskKey]      NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [FinalLoc]        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [FinalID]         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [Reverse]         INT            NOT NULL DEFAULT(0)
   ) 

   SELECT TOP 1 @c_StorerKey = O.Storerkey   
               ,@c_Facility = O.Facility   
   FROM WAVEDETAIL WD (NOLOCK)  
   JOIN ORDERS O (NOLOCK) ON (WD.Orderkey = O.Orderkey)  
   WHERE WD.Wavekey = @c_Wavekey 

   ----reject if wave not yet release        
   IF @n_Continue = 1  
   BEGIN
      INSERT INTO #TMP_TASK( TaskDetailKey, TaskType, TaskStatus, Storerkey, Sku 
                            ,RefTaskKey, FinalLoc, FinalID, [Reverse] 
                           )
      SELECT TD.TaskDetailKey
            ,TaskType
            ,TaskStatus= CASE WHEN TD.TaskType = 'RPF' AND Message01 > '' THEN 'X'
                              ELSE TD.[Status]
                              END
            ,TD.Storerkey
            ,TD.Sku
            ,TD.RefTaskKey
            ,TD.FinalLoc
            ,TD.FinalID             
            ,[Reverse] = CASE WHEN TD.TaskType IN ('RPF','FPK') AND TD.[Status] = '0'
                              THEN 1
                              WHEN TD.TaskType = 'FCP' AND TD.[Status] IN ('0','H')
                              THEN 1
                              ELSE 0 
                              END
      FROM TASKDETAIL TD (NOLOCK)   
      WHERE TD.Wavekey = @c_Wavekey 
      AND TD.SourceType = @c_SourceType
      AND TD.TaskType IN('FPK','FCP','FPP','RPF')

      SET @n_Cnt = @@ROWCOUNT

      IF @n_Cnt = 0
      BEGIN                                            
         SET @n_Continue = 3    
         SET @n_Err = 81010    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                      +': This Wave has not been released. (mspRVWAV09)'           
      END                   
   END  

   IF @n_Continue = 1  
   BEGIN 
      SELECT @n_Cnt = COUNT(1)
            ,@n_Cnt_RV = SUM(CASE WHEN tt.[Reverse] = 1 THEN 1 ELSE 0 END)
      FROM #TMP_TASK tt
                    
      IF @n_Cnt > @n_Cnt_RV
      BEGIN  
          SET @n_Continue = 3    
          SET @n_Err = 81020    
          SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Some Tasks have been started'
                       +'. Reverse Wave Released Abort. (mspRVWAV09)'         
      END                   
   END  

   IF @n_Continue = 1  
   BEGIN 
      SET @n_Cnt = 0
      SELECT @n_Cnt = 1
      FROM  #TMP_TASK tt
      WHERE tt.TaskType = 'RPF'
      AND EXISTS (SELECT 1
                  FROM TASKDETAIL TD (NOLOCK) 
                  WHERE TD.TaskType = 'FCP'
                  AND   TD.Storerkey= tt.Storerkey
                  AND   TD.Sku      = tt.Sku
                  AND   TD.FromLoc  = tt.FinalLoc
                  AND   TD.FromID   = tt.FinalID
                  AND   TD.UOM      = '6'
                  AND   TD.[Status] = 'H'
                  AND   TD.Wavekey  <> @c_Wavekey
                  AND   TD.SourceType = @c_SourceType
                  )
      IF @n_Cnt = 1
      BEGIN
          SET @n_Continue = 3    
          SET @n_Err = 81030    
          SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                       +': RPF Qty needs for other wave picking found'
                       +'. Reverse Wave Released Abort. (mspRVWAV09)'
      END
   END

   IF @n_Continue = 1  
   BEGIN 
      SET @CUR_DELTASK = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT tt.TaskDetailKey
            ,tt.TaskType
      FROM #TMP_TASK tt
      WHERE tt.[Reverse] = 1
      ORDER BY CASE WHEN tt.TaskType = 'RPF' THEN 1 ELSE 0 END

      OPEN @CUR_DELTASK

      FETCH NEXT FROM @CUR_DELTASK INTO @c_TaskDetailKey, @c_TaskType

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         SET @b_Reverse = 0

         SELECT @c_Status = td.[Status]
         FROM TASKDETAIL td (NOLOCK)
         WHERE td.TaskDetailKey = @c_TaskDetailKey

         IF @c_TaskType IN ('RPF', 'FPK') AND @c_Status = '0' 
         BEGIN
            SET @b_Reverse = 1
         END
         ELSE IF @c_TaskType = 'FCP' AND @c_Status IN ('0','H') 
         BEGIN 
            SET @b_Reverse = 1
         END
               
         IF @b_Reverse = 1
         BEGIN
            DELETE TASKDETAIL WITH (ROWLOCK) 
            WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey   
            AND TASKDETAIL.Sourcetype = @c_SourceType 
            AND TASKDETAIL.TaskType = @c_TaskType
            AND TASKDETAIL.[Status] = @c_Status
           
            SET @n_Err = @@ERROR  
            IF @n_Err <> 0   
            BEGIN  
               SET @n_Continue = 3    
               SET @n_Err = 81040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Delete Taskdetail Table Failed. (mspRVWAV09)' 
            END 

            IF @n_Continue = 1 AND @c_TaskType = 'FCP'
            BEGIN
               SET @CUR_DELPICK = CURSOR FAST_FORWARD READ_ONLY FOR
               SELECT pd.PickDetailKey
               FROM WAVEDETAIL wd (NOLOCK)    
               JOIN PICKDETAIL pd (NOLOCK) ON wd.Orderkey = pd.Orderkey  
               WHERE wd.Wavekey = @c_Wavekey
               AND   pd.TaskDetailKey = @c_TaskDetailKey
               ORDER BY pd.PickDetailKey

               OPEN @CUR_DELPICK

               FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey

               WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
               BEGIN
                  UPDATE PICKDETAIL WITH (ROWLOCK)   
                     SET PICKDETAIL.TaskdetailKey = ''   
                        ,TrafficCop = NULL  
                  WHERE PICKDETAIL.PickDetailKey = @c_PickDetailKey   
           
                  SET @n_Err = @@ERROR  
                  IF @n_Err <> 0   
                  BEGIN  
                     SET @n_Continue = 3    
                     SET @n_Err = 81050   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
                     SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Update Pickdetail Table Failed. (mspRVWAV09)'      
                  END 
                  FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey
               END
               CLOSE @CUR_DELPICK
               DEALLOCATE @CUR_DELPICK
            END
         END
         FETCH NEXT FROM @CUR_DELTASK INTO @c_TaskDetailKey, @c_TaskType
      END
      CLOSE @CUR_DELTASK
      DEALLOCATE @CUR_DELTASK
   END
   
   -----Reverse SOStatus---------  
   IF @n_Continue = 1 or @n_Continue = 2    
   BEGIN    
      SELECT @c_authority = dbo.fnc_GetRight(@c_facility, @c_StorerKey,'','UpdateSOReleaseTaskStatus')
  
      IF @c_authority = '1'   
      BEGIN 
         IF @c_Orderkey > ''
         BEGIN
            SET @CUR_UPDORD = CURSOR FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT o.Orderkey
            FROM ORDERS o (NOLOCK)    
            JOIN PICKDETAIL pd (NOLOCK) ON pd.Orderkey = o.Orderkey  
            WHERE o.Orderkey = @c_Orderkey
            AND   o.Userdefine09 = @c_Wavekey
            ORDER BY o.Orderkey
         END
         ELSE
         BEGIN
            SET @CUR_UPDORD = CURSOR FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT pd.Orderkey
            FROM WAVEDETAIL wd (NOLOCK)    
            JOIN PICKDETAIL pd (NOLOCK) ON pd.Orderkey = wd.Orderkey  
            WHERE wd.Wavekey = @c_Wavekey
            ORDER BY pd.Orderkey
         END
         OPEN @CUR_UPDORD

         FETCH NEXT FROM @CUR_UPDORD INTO @c_Orderkey

         WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
         BEGIN
            UPDATE ORDERS WITH (ROWLOCK) 
            SET SOStatus = '0'  
               ,TrafficCop = NULL   
               ,EditWho = SUSER_SNAME() 
               ,EditDate = GETDATE()  
            WHERE Orderkey = @c_Orderkey  
            AND SOStatus = 'TSRELEASED'  

            SET @n_Err = @@ERROR  
            IF @n_Err <> 0   
            BEGIN  
               SET @n_Continue = 3 
            END 

            FETCH NEXT FROM @CUR_UPDORD INTO @c_Orderkey
         END
         CLOSE @CUR_UPDORD
         DEALLOCATE @CUR_UPDORD
      END            
   END  
QUIT_SP: 
   IF OBJECT_ID('tempdb..#TMP_TASK') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_TASK
   END
     
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
      execute nsp_logerror @n_Err, @c_errmsg, "mspRVWAV09"    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
   END    
   ELSE    
   BEGIN    
      SET @b_Success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
   END        
END
GO


