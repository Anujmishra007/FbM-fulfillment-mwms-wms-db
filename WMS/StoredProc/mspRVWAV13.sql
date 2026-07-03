SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/    
/* Stored Procedure: mspRVWAV13                                           */    
/* Creation Date: 2026-06-30                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-13361 - AEOMX Reverse Wave                                */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          :                                                             */    
/* PVCS Version: 1.0                                                      */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */ 
/**************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV13]        
   @c_Wavekey     NVARCHAR(10) 
,  @c_Orderkey    NVARCHAR(10)   = ''   
,  @b_Success     INT            = 1   OUTPUT    
,  @n_err         INT            = 0   OUTPUT    
,  @c_errmsg      NVARCHAR(250)  = ''  OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
      
   DECLARE @n_Continue           INT = 1     
         , @n_StartTCnt          INT = @@TRANCOUNT         -- Holds the current transaction count    
         , @n_debug              INT = 0 
         , @n_Cnt                INT = 0

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'
         , @c_UserName           NVARCHAR(128)= ''
         , @c_Facility           NVARCHAR(5) = ''
         , @c_Storerkey          NVARCHAR(15)= ''

         , @c_Channel_b          NVARCHAR(20)= ''

         , @c_Taskdetailkey      NVARCHAR(10)= ''
         , @c_PickDetailKey      NVARCHAR(10)= ''
         , @c_CartonType         NVARCHAR(10)= ''
         , @c_Caseid             NVARCHAR(20)= '' 

         , @c_PickSlipNo         NVARCHAR(10)= ''
         , @n_CartonNo           INT         = 0
         , @c_LabelNo            NVARCHAR(20)= ''
         , @c_LabelLine          NVARCHAR(5) = ''

         , @c_TaskType           NVARCHAR(10)= ''
         , @c_GroupKey           NVARCHAR(10)= ''
         , @c_TableName_ITF      NVARCHAR(10)= 'WSWCSCANCT'
         , @c_Key1               NVARCHAR(10) = ''  
         , @c_Key2               NVARCHAR(30) = ''  
         , @c_Key3               NVARCHAR(20) = '' 
         , @c_TransmitBatch      NVARCHAR(10) = '0' 

         , @b_Reverse            INT         = 0
         , @b_Reverse_RPF        INT         = 0

         , @c_Authority          NVARCHAR(10)  = ''
         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''

         , @CUR_DELTASK          CURSOR
         , @CUR_DELPICK          CURSOR 
         , @CUR_ORD              CURSOR
         , @CUR_PACK             CURSOR
         , @CUR_ITF              CURSOR
 
   SET @c_UserName = dbo.fnc_GetUserName()

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
   ,  [UCCNo]           NVARCHAR(20)   NOT NULL DEFAULT('')
   ,  [GroupKey]        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [RefTaskKey]      NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [FinalLoc]        NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [FinalID]         NVARCHAR(10)   NOT NULL DEFAULT('')
   ,  [Reverse]         INT            NOT NULL DEFAULT(0)
   ,  [Reverse_RPF]     INT            NOT NULL DEFAULT(1)
   ) 

   IF OBJECT_ID('tempdb..#TMP_ITF') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_ITF  
   END

   CREATE TABLE #TMP_ITF
   ( 
      [GroupKey]        NVARCHAR(20)   NOT NULL DEFAULT('') PRIMARY KEY
   ,  [Storerkey]       NVARCHAR(20)   NOT NULL DEFAULT('')
   ) 

   SELECT @c_Channel_b = w.UserDefine03
   FROM WAVE w (NOLOCK) 
   WHERE w.Wavekey = @c_Wavekey
   
   SELECT TOP 1 @c_StorerKey = O.Storerkey   
               ,@c_Facility = O.Facility   
   FROM WAVEDETAIL WD (NOLOCK)  
   JOIN ORDERS O (NOLOCK) ON (WD.Orderkey = O.Orderkey)  
   WHERE WD.Wavekey = @c_Wavekey 

   ----reject if wave not yet release        
   IF @n_Continue = 1  
   BEGIN
      INSERT INTO #TMP_TASK( TaskDetailKey, TaskType, TaskStatus, Storerkey, Sku 
                            ,UCCNo, GroupKey, RefTaskKey, FinalLoc, FinalID, [Reverse] 
                           )
      SELECT TD.TaskDetailKey
            ,TD.TaskType
            ,TD.[Status]
            --,TaskStatus= CASE WHEN TD.TaskType = 'RPF' AND Message01 > '' THEN 'X'
            --                  ELSE TD.[Status]
            --                  END
            ,TD.Storerkey
            ,TD.Sku
            ,TD.CaseID
            ,TD.Groupkey
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
      AND TD.TaskType IN ('FPK','FCP','RPF')
      AND TD.[Status] <> 'X'

      SET @n_Cnt = @@ROWCOUNT

      IF @n_Cnt = 0
      BEGIN                                            
         SET @n_Continue = 3    
         SET @n_Err = 70010    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                      +': This Wave has not been released. (mspRVWAV09)'           
      END                   
   END  

   IF @n_Continue = 1  
   BEGIN 
      IF EXISTS ( SELECT 1
                  FROM #TMP_TASK tt
                  WHERE tt.[Reverse] = 0
                )
      BEGIN  
          SET @n_Continue = 3    
          SET @n_Err = 70020    
          SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Some Tasks have been started'
                       +'. Reverse Wave Released Abort. (mspRVWAV09)'         
      END                   
   END  

   IF @n_Continue = 1  
   BEGIN 
      UPDATE tt SET Reverse_RPF = 0
      FROM  #TMP_TASK tt
      WHERE tt.TaskType = 'RPF'
      AND   tt.[Reverse]= 1
      AND EXISTS (SELECT 1
                  FROM TASKDETAIL TD (NOLOCK) 
                  WHERE TD.TaskType = 'FCP'
                  AND   TD.Storerkey= tt.Storerkey
                  AND   TD.CaseID   = ''
                  AND   TD.FromLoc  = tt.FinalLoc
                  AND   TD.FromID   = tt.FinalID
                  AND   TD.UOM      = '6'
                  AND   TD.[Status] = 'H'
                  AND   TD.Wavekey  <> @c_Wavekey
                  AND   TD.SourceType = @c_SourceType
                  )

      IF EXISTS ( SELECT 1
                  FROM #TMP_TASK tt
                  WHERE tt.TaskType = 'RPF'
                  AND tt.[Reverse_RPF] = 0
                )
      BEGIN
          SET @n_Continue = 3    
          SET @n_Err = 70030    
          SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                       +': RPF is needed for multiple released wave picking found'
                       +'. Reverse Wave Released Abort. (mspRVWAV09)'
      END
   END

   IF @n_Continue = 1  
   BEGIN 
      -- The whole wave ready to reverse
      SET @CUR_DELTASK = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT tt.TaskDetailKey
            ,tt.TaskType
            ,tt.Storerkey
            ,tt.GroupKey
            ,tt.[Reverse]
            ,tt.Reverse_RPF
      FROM #TMP_TASK tt
      WHERE tt.[Reverse] = 1
      ORDER BY CASE WHEN tt.TaskType = 'RPF' THEN 1 ELSE 0 END
 
      OPEN @CUR_DELTASK

      FETCH NEXT FROM @CUR_DELTASK INTO @c_TaskDetailKey
                                       ,@c_TaskType
                                       ,@c_Storerkey
                                       ,@c_GroupKey
                                       ,@b_Reverse 
                                       ,@b_Reverse_RPF

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         IF @c_TaskType = 'RPF'  
         BEGIN 
            SET @b_Reverse = @b_Reverse_RPF
         END

         IF @b_Reverse = 1
         BEGIN
            DELETE TASKDETAIL WITH (ROWLOCK) 
            WHERE TASKDETAIL.TaskDetailKey = @c_TaskDetailKey   
            AND TASKDETAIL.Sourcetype = @c_SourceType 
            AND TASKDETAIL.TaskType = @c_TaskType
  
           
            SET @n_Err = @@ERROR  
            IF @n_Err <> 0   
            BEGIN  
               SET @n_Continue = 3    
               SET @n_Err = 70040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
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
                        ,CartonType = @c_CartonType
                        ,Caseid = @c_Caseid                      
                        ,TrafficCop = NULL  
                  WHERE PICKDETAIL.PickDetailKey = @c_PickDetailKey   
           
                  SET @n_Err = @@ERROR  
                  IF @n_Err <> 0   
                  BEGIN  
                     SET @n_Continue = 3    
                     SET @n_Err = 70050   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
                     SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Update Pickdetail Table Failed. (mspRVWAV09)'      
                  END 
                  FETCH NEXT FROM @CUR_DELPICK INTO @c_PickDetailKey
               END
               CLOSE @CUR_DELPICK
               DEALLOCATE @CUR_DELPICK

               IF @n_Continue = 1
               BEGIN
                  SET @n_Cnt = 0 
                  SELECT @n_Cnt = 1 
                  FROM #TMP_ITF ti 
                  WHERE ti.Groupkey = @c_GroupKey

                  IF @n_Cnt = 0            
                  BEGIN
                     INSERT INTO #TMP_ITF ( GroupKey, Storerkey )
                     VALUES ( @c_GroupKey, @c_Storerkey )
                  END
               END
            END
         END
         FETCH NEXT FROM @CUR_DELTASK INTO @c_TaskDetailKey
                                          ,@c_TaskType
                                          ,@c_Storerkey
                                          ,@c_GroupKey
                                          ,@b_Reverse 
                                          ,@b_Reverse_RPF
      END
      CLOSE @CUR_DELTASK
      DEALLOCATE @CUR_DELTASK
   END
   
   -----Reverse SOStatus--------- 
   IF @n_Continue = 1 
   BEGIN    
      SELECT @c_Authority = dbo.fnc_GetRight(@c_facility, @c_StorerKey,'','UpdateSOReleaseTaskStatus')
   
      IF @c_Authority = '1' OR @c_Channel_b = 'ECOM'
      BEGIN 
         IF @c_Orderkey > ''
         BEGIN
            SET @CUR_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT Orderkey = @c_Orderkey
         END
         ELSE
         BEGIN
            SET @CUR_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT wd.Orderkey
            FROM WAVEDETAIL wd (NOLOCK)    
            WHERE wd.Wavekey = @c_Wavekey
            AND EXISTS (SELECT 1 FROM PICKDETAIL pd (NOLOCK) 
                        WHERE pd.Orderkey = wd.Orderkey
                       )
         END

         OPEN @CUR_ORD

         FETCH NEXT FROM @CUR_ORD INTO @c_Orderkey

         WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
         BEGIN
            SET @c_PickSlipNo = ''

            IF @c_Orderkey > ''
            BEGIN
               SELECT @c_PickSlipNo = ph.PickSlipNo
               FROM PACKHEADER ph (NOLOCK) 
               WHERE ph.Orderkey  = @c_Orderkey
            END

            IF @c_PickSlipNo > ''
            BEGIN
               SET @CUR_PACK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT pd.CartonNo 
                     ,pd.LabelNo
                     ,pd.LabelLine
               FROM PACKDETAIL pd (NOLOCK)
               WHERE pd.PickSlipNo = @c_PickSlipNo

               OPEN @CUR_PACK

               FETCH NEXT FROM @CUR_PACK INTO @n_CartonNo
                                             ,@c_LabelNo
                                             ,@c_LabelLine

               WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
               BEGIN
                  DELETE pd
                  FROM PackDetail pd  
                  WHERE pd.PickSlipNo = @c_PickSlipNo
                  AND pd.CartonNo = @n_CartonNo
                  AND pd.LabelNo  = @c_LabelNo
                  AND pd.LabelLine= @c_LabelLine

                  SET @n_Err = @@ERROR  
                  IF @n_Err <> 0   
                  BEGIN  
                     SET @n_Continue = 3 
                  END 

                  FETCH NEXT FROM @CUR_PACK INTO @n_CartonNo
                                                ,@c_LabelNo
                                                ,@c_LabelLine
               END
               CLOSE @CUR_PACK
               DEALLOCATE @CUR_PACK

               DELETE ph
               FROM PACKHEADER ph
               WHERE ph.PickSlipNo  = @c_PickSlipNo

               SET @n_Err = @@ERROR  
               IF @n_Err <> 0   
               BEGIN  
                  SET @n_Continue = 3 
               END 
            END

            IF @n_Continue = 1 AND @c_Authority = '1'
            BEGIN
               UPDATE ORDERS WITH (ROWLOCK) 
               SET SOStatus = '0'  
                  ,TrafficCop = NULL   
                  ,EditWho = @c_UserName 
                  ,EditDate = GETDATE()  
               WHERE Orderkey = @c_Orderkey  
               AND SOStatus = 'TSRELEASED'  

               SET @n_Err = @@ERROR  
               IF @n_Err <> 0   
               BEGIN  
                  SET @n_Continue = 3 
               END 
            END

            FETCH NEXT FROM @CUR_ORD INTO @c_Orderkey
         END
         CLOSE @CUR_ORD
         DEALLOCATE @CUR_ORD
      END            
   END  

   -----Interface Canc WCS Task ---------  
   IF @n_Continue = 1  
   BEGIN 
      SET @CUR_ITF = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT ti.GroupKey
            ,ti.Storerkey
      FROM #TMP_ITF ti (NOLOCK)  
         
      OPEN @CUR_ITF

      FETCH NEXT FROM @CUR_ITF INTO @c_GroupKey
                                 ,  @c_Storerkey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         SET @c_Key1 = @c_GroupKey
         SET @c_Key2 = ''
         SET @c_Key3 = @c_Storerkey

         EXEC ispGenTransmitLog2
            @c_TableName      = @c_TableName_ITF
         ,  @c_Key1           = @c_Key1
         ,  @c_Key2           = @c_Key2
         ,  @c_Key3           = @c_Key3
         ,  @c_TransmitBatch  = @c_TransmitBatch
         ,  @b_Success        = @b_Success   OUTPUT  
         ,  @n_err            = @n_err       OUTPUT  
         ,  @c_errmsg         = @c_errmsg    OUTPUT  

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3        
            SET @n_err      = 70060        
            SET @c_errmsg   = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)
                              + ': Error Executing ispGenTransmitLog2'
                              + '. (mspWaveReleaseWCS03)'        
         END

         FETCH NEXT FROM @CUR_ITF INTO @c_GroupKey
                                    ,  @c_Storerkey
      END
      CLOSE @CUR_ITF
      DEALLOCATE @CUR_ITF
   END  
QUIT_SP: 
   IF OBJECT_ID('tempdb..#TMP_TASK') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_TASK
   END 

   IF OBJECT_ID('tempdb..#TMP_ITF') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_ITF  
   END


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
      execute nsp_logerror @n_err, @c_errmsg, "mspRVWAV13"    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
   END    
   ELSE    
   BEGIN    
      SET @b_success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
   END        
END
GO


