SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: msp_ProcessShortPickReAlloc04                      */  
/* Creation Date: 17-Dec-2025                                           */  
/* Copyright: MAERSK                                                    */  
/* Written by: JihHaur                                                  */  
/*                                                                      */  
/* Purpose: FCR-9567 ZAFBAT - Reallocation SP                           */  
/*                                                                      */  
/* Called By: Q-Commander                                               */  
/*                                                                      */  
/* GitHub Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/* 17-Dec-2025 JihHaur  1.0   Initial Version                           */  
/************************************************************************/  
  
CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc04] (      
       @c_Wavekey          NVARCHAR(10)  
     , @c_SKU              NVARCHAR(20)  
     , @c_UCCNo            NVARCHAR(20)  
     , @c_Taskdetailkey    NVARCHAR(10)   = ''  
     , @b_Success          INT            = 0   OUTPUT  
     , @n_Err              INT            = 0   OUTPUT  
     , @c_ErrMsg           NVARCHAR(225)  = ''  OUTPUT  
     , @b_Debug            INT            = 0      
) AS      
BEGIN      
   SET NOCOUNT ON      
   SET ANSI_NULLS OFF      
   SET QUOTED_IDENTIFIER OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
                        
   /*********************************************/      
   /* Variables Declaration (Start)             */      
   /*********************************************/      
   --General      
   DECLARE @n_Continue                 INT = 1  
         , @n_StartTCnt                INT  
         , @c_StorerKey                NVARCHAR(15) = ''  
         , @c_Facility                 NVARCHAR(5)  = ''  
  
   DECLARE @c_StrategykeyParm          NVARCHAR(10) = ''  
         , @c_SourceType               NVARCHAR(30) = ''  
         , @c_PickDetailKey            NVARCHAR(18) = ''           
         , @CUR_UNALLOC                CURSOR  
         , @c_PickSlipNo               NVARCHAR(10) = ''      
  
   SET @n_StartTCnt = @@TRANCOUNT  
   SET @b_Success = 0  
   SET @n_Err     = 0  
   SET @c_ErrMsg  = ''  
   SET @b_debug = ISNULL(@b_debug, 0)  
   SET @c_StrategykeyParm = ''  
     
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      CREATE TABLE #TMP_SHORTED  
      (  
         Pickdetailkey NVARCHAR(18) PRIMARY KEY  
      )  
  
      --CREATE TABLE #TMP_TASK_CURRENT  
      --(  
      --   Taskdetailkey NVARCHAR(10) PRIMARY KEY  
      --)  
  
      --CREATE TABLE #TMP_TASK_NEW  
      --(  
      --   Taskdetailkey NVARCHAR(10) PRIMARY KEY  
      --)  
  
      CREATE TABLE #PickDetail_WIP  
      (  
         [PickDetailKey]        [NVARCHAR](18)   NOT NULL PRIMARY KEY  
       , [CaseID]               [NVARCHAR](20)   NOT NULL DEFAULT (' ')  
       , [PickHeaderKey]        [NVARCHAR](18)   NOT NULL  
       , [OrderKey]             [NVARCHAR](10)   NOT NULL  
       , [OrderLineNumber]      [NVARCHAR](5)    NOT NULL  
       , [Lot]                  [NVARCHAR](10)   NOT NULL  
       , [Storerkey]            [NVARCHAR](15)   NOT NULL  
       , [Sku]                  [NVARCHAR](20)   NOT NULL  
       , [AltSku]               [NVARCHAR](20)   NOT NULL DEFAULT (' ')  
       , [UOM]                  [NVARCHAR](10)   NOT NULL DEFAULT (' ')  
       , [UOMQty]               [INT]            NOT NULL DEFAULT ((0))  
       , [Qty]                  [INT]            NOT NULL DEFAULT ((0))  
       , [QtyMoved]             [INT]            NOT NULL DEFAULT ((0))  
       , [Status]               [NVARCHAR](10)   NOT NULL DEFAULT ('0')  
       , [DropID]               [NVARCHAR](20)   NOT NULL DEFAULT ('')  
       , [Loc]                  [NVARCHAR](10)   NOT NULL DEFAULT ('UNKNOWN')  
       , [ID]                   [NVARCHAR](18)   NOT NULL DEFAULT (' ')  
       , [PackKey]              [NVARCHAR](10)   NULL DEFAULT (' ')  
       , [UpdateSource]         [NVARCHAR](10)   NULL DEFAULT ('0')  
       , [CartonGroup]          [NVARCHAR](10)   NULL  
       , [CartonType]           [NVARCHAR](10)   NULL  
       , [ToLoc]                [NVARCHAR](10)   NULL DEFAULT (' ')  
       , [DoReplenish]          [NVARCHAR](1)    NULL DEFAULT ('N')  
       , [ReplenishZone]        [NVARCHAR](10)   NULL DEFAULT (' ')  
       , [DoCartonize]          [NVARCHAR](1)    NULL DEFAULT ('N')  
       , [PickMethod]           [NVARCHAR](1)    NOT NULL DEFAULT (' ')  
       , [WaveKey]              [NVARCHAR](10)   NOT NULL DEFAULT (' ')  
       , [EffectiveDate]        [DATETIME]       NOT NULL DEFAULT (GETDATE())  
       , [AddDate]              [DATETIME]       NOT NULL DEFAULT (GETDATE())  
       , [AddWho]               [NVARCHAR](128)  NOT NULL DEFAULT (SUSER_SNAME())  
       , [EditDate]             [DATETIME]       NOT NULL DEFAULT (GETDATE())  
       , [EditWho]              [NVARCHAR](128)  NOT NULL DEFAULT (SUSER_SNAME())  
       , [TrafficCop]           [NVARCHAR](1)    NULL  
       , [ArchiveCop]           [NVARCHAR](1)    NULL  
       , [OptimizeCop]          [NVARCHAR](1)    NULL  
       , [ShipFlag]             [NVARCHAR](1)    NULL DEFAULT ('0')  
       , [PickSlipNo]           [NVARCHAR](10)   NULL  
       , [TaskDetailKey]        [NVARCHAR](10)   NULL  
       , [TaskManagerReasonKey] [NVARCHAR](10)   NULL  
       , [Notes]                [NVARCHAR](4000) NULL  
       , [MoveRefKey]           [NVARCHAR](10)   NULL DEFAULT ('')  
       , [WIP_Refno]            [NVARCHAR](30)   NULL DEFAULT ('')  
       , [Channel_ID]           [BIGINT]         NULL DEFAULT ((0))  
       , [TmpReplenKey]         [NVARCHAR](10)   NOT NULL DEFAULT ('')  
      )  
  
      CREATE INDEX IX_PickDetail_WIP_OrderKey_Status ON #PickDetail_WIP (OrderKey, [Status]) INCLUDE (Qty, QtyMoved, PickDetailKey)  
      CREATE INDEX IX_PickDetail_WIP_WaveKey_UOM_Status ON #PickDetail_WIP (WaveKey, UOM, [Status]) INCLUDE (OrderKey, Storerkey, SKU, TaskDetailKey)  
      CREATE INDEX IX_PickDetail_WIP_TaskUpdate ON #PickDetail_WIP (UOM, PickMethod, Lot, Loc, ID, DropID) INCLUDE (PickDetailKey)  
      CREATE INDEX IX_PickDetail_WIP_Wave_Storer_Sku_Loc ON #PickDetail_WIP (WaveKey, Storerkey, Sku, Loc, [Status]) INCLUDE (Qty, QtyMoved, PickDetailKey)  
   END  
  
   WHILE @@TRANCOUNT > 0 AND @b_debug = 0  
   BEGIN  
      COMMIT TRAN  
   END  
     
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      SELECT @c_StorerKey  = OH.StorerKey  
           , @c_Facility   = OH.Facility  
           , @c_PickSlipNo = PD.PickSlipNo  
      FROM WAVE W WITH (NOLOCK)  
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey  
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey  
      JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = OH.OrderKey  
      WHERE W.WaveKey = @c_Wavekey  
  
      IF @c_PickSlipNo = ''  
      BEGIN  
         SET @n_Continue = 3  
         SELECT @n_Err = 95671  
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': PickSlipNo: ' + TRIM(@c_PickSlipNo) + ' No PickSlipNo Found (msp_ProcessShortPickReAlloc04)'  
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END  
   END  
  
   --Validation  
   --RDT update QtyMoved = Qty, Qty = 0, Status = '4'    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      IF NOT EXISTS ( SELECT 1    
                      FROM dbo.PICKDETAIL PD WITH (NOLOCK)    
                      WHERE PD.Storerkey = @c_StorerKey    
                      AND PD.Sku = @c_SKU        
                      AND PD.DropID = @c_UCCNo        
                      --AND PD.QtyMoved > 0    
                      --AND PD.Qty = 0    
                      AND PD.[Status] = '4'    
                      AND EXISTS ( SELECT 1     
                                   FROM WAVEDETAIL WD (NOLOCK)    
                                   WHERE WD.WaveKey = @c_Wavekey    
                                   AND WD.OrderKey = PD.OrderKey )     
                    )        
      BEGIN    
         SELECT @n_Continue = 3    
         SELECT @n_Err = 95670    
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': UCC#: ' + TRIM(@c_UCCNo) + ' No Record Found (msp_ProcessShortPickReAlloc04)'    
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '       
      END    
   END   
  
   --Initialize Data  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      BEGIN TRY  
         --Initialize Pickdetail work in progress staging table     
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey  
                                     , @c_WIP_RefNo = @c_SourceType  
                                     , @c_PickCondition_SQL = ''  
                                     , @c_Action = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records      
                                     , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization      
                                     , @b_Success = @b_Success OUTPUT  
                                     , @n_Err = @n_err OUTPUT  
                                     , @c_ErrMsg = @c_errmsg OUTPUT  
      END TRY  
      BEGIN CATCH  
         SET @n_Continue = 3  
         SET @c_ErrMsg = ERROR_MESSAGE()  
      END CATCH  
  
      IF @n_Continue IN (1, 2)  
      BEGIN  
         --RDT update Status = '4'， QtyMoved, Qty no change  
         INSERT INTO #TMP_SHORTED (Pickdetailkey)  
         SELECT PD.Pickdetailkey  
         FROM #PICKDETAIL_WIP PD WITH (NOLOCK)  
         WHERE PD.Wavekey = @c_Wavekey  
         AND PD.Storerkey = @c_StorerKey  
         AND PD.Sku = @c_SKU  
         AND PD.DropID = @c_UCCNo  
         --AND PD.QtyMoved > 0  
         --AND PD.Qty = 0  
         AND PD.[Status] = '4'  
  
         --IF ISNULL(@c_Taskdetailkey, '') <> ''  
         --BEGIN  
         --   INSERT INTO #TMP_TASK_CURRENT (Taskdetailkey)  
         --   SELECT @c_Taskdetailkey  
         --END  
         --ELSE  
         --BEGIN  
         --   INSERT INTO #TMP_TASK_CURRENT (Taskdetailkey)  
         --   SELECT TD.Taskdetailkey  
         --   FROM TASKDETAIL TD WITH (NOLOCK)  
         --   WHERE TD.Wavekey = @c_Wavekey  
         --   AND TD.Storerkey = @c_StorerKey  
         --   AND TD.Sku = @c_SKU  
         --   AND TD.TaskType IN ('RPF', 'FCP')  
         --END  
      END  
   END  
  
   --Get Storerconfig setup  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      BEGIN TRY  
         EXEC dbo.nspGetRight @c_Facility = @c_Facility -- nvarchar(5)  
                            , @c_StorerKey = @c_StorerKey -- nvarchar(15)  
                            , @c_sku = N'' -- nvarchar(20)  
                            , @c_ConfigKey = N'RealloStrategy' -- nvarchar(30)  
                            , @b_Success = @b_Success OUTPUT -- int  
                            , @c_authority = @c_StrategykeyParm OUTPUT -- nvarchar(30)  
                            , @n_err = @n_err OUTPUT -- int  
                            , @c_errmsg = @c_errmsg OUTPUT -- nvarchar(250)  
      END TRY  
      BEGIN CATCH  
         SET @n_Continue = 3  
         SET @c_ErrMsg = ERROR_MESSAGE()  
      END CATCH  
  
      IF ISNULL(@c_StrategykeyParm, '') = ''  
         SET @c_StrategykeyParm = ''  
   END  
  
   --Validation  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      IF NOT EXISTS ( SELECT 1  
                      FROM #TMP_SHORTED )      
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @n_Err = 95672  
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': UCCNo: ' + TRIM(@c_UCCNo) + ' No Record Found (msp_ProcessShortPickReAlloc04)'  
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '     
      END  
   END  
  
   --Unallocate  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      IF @b_debug = 0  
      BEGIN  
         BEGIN TRAN  
      END  
  
      SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT T.Pickdetailkey  
      FROM #TMP_SHORTED T  
      ORDER BY T.Pickdetailkey  
  
      OPEN @CUR_UNALLOC  
  
      FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey  
  
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)  
      BEGIN  
         BEGIN TRY  
            --DELETE FROM PICKDETAIL  
            --WHERE PickDetailKey = @c_PickDetailKey  
            UPDATE PICKDETAIL SET QtyMoved = Qty, Qty = 0  
            WHERE PickDetailKey = @c_PickDetailKey AND Status = '4'  
         END TRY  
         BEGIN CATCH  
            SET @n_Continue = 3  
            SET @c_ErrMsg = ERROR_MESSAGE()  
            SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Error update Pickdetail for ' + @c_PickDetailKey + ' (msp_ProcessShortPickReAlloc04)'  
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '     
         END CATCH  
  
         FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey  
      END  
      CLOSE @CUR_UNALLOC  
      DEALLOCATE @CUR_UNALLOC  
  
      IF @b_debug = 0 AND @n_Continue IN (1,2)  
      BEGIN  
         WHILE @@TRANCOUNT > 0  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
   END  
  
   --Reallocate  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      BEGIN TRY  
         EXEC dbo.ispWaveProcessing @c_WaveKey = @c_Wavekey -- nvarchar(10)  
                                  , @b_Success = @b_Success OUTPUT -- int  
                                  , @n_Err = @n_Err OUTPUT -- int  
                                  , @c_ErrMsg = @c_ErrMsg OUTPUT -- nvarchar(250)  
                                  , @b_debug = @b_debug -- int  
                                  , @c_StrategykeyParm = @c_StrategykeyParm -- nvarchar(10)  
      END TRY  
      BEGIN CATCH  
         SET @n_Continue = 3  
         SET @c_ErrMsg = ERROR_MESSAGE()  
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Error while reallocate ' + @c_Wavekey + ' (msp_ProcessShortPickReAlloc04)'  
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '     
      END CATCH  
   END  
  
   --Check reallocation success or not  
   IF (@n_Continue = 1 OR @n_Continue = 2) AND EXISTS (SELECT 1  
      FROM WAVEDETAIL WD   
      JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = WD.OrderKey  
      WHERE WD.WaveKey = @c_Wavekey  
            --AND ISNULL(PD.PickSlipNo,'') = ''   
            AND PD.Storerkey = @c_StorerKey  
            AND PD.Sku = @c_SKU  
            AND PD.STATUS = '0'  
            AND PD.PickDetailKey NOT IN (SELECT PickDetailKey FROM #PickDetail_WIP))  
   BEGIN  
      --Add into current active PickSlipNo  
      BEGIN TRY  
         UPDATE PD SET PD.PickSlipNo = @c_PickSlipNo  
         FROM WAVEDETAIL WD WITH (NOLOCK)   
               JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = WD.OrderKey  
         WHERE WD.WaveKey = @c_Wavekey  
            AND ISNULL(PD.PickSlipNo,'') = ''   
            AND PD.Storerkey = @c_StorerKey  
            AND PD.Sku = @c_SKU  
            AND PD.STATUS = '0'  
            AND PD.PickDetailKey NOT IN (SELECT PickDetailKey FROM #PickDetail_WIP)             
      END TRY  
      BEGIN CATCH  
         SET @n_Continue = 3  
         SET @c_ErrMsg = ERROR_MESSAGE()  
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Error update into active PickSlipNo (msp_ProcessShortPickReAlloc04)'  
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '    
      END CATCH  
  
      IF (@n_Continue = 1 OR @n_Continue = 2)  
      BEGIN  
         DELETE FROM PICKDETAIL  
         WHERE PickDetailKey IN (SELECT PickDetailKey FROM #TMP_SHORTED)  
      END         
   END  
   ELSE  
   BEGIN  
      UPDATE PICKDETAIL SET Qty = QtyMoved,   
                       QtyMoved = 0,         
                          Notes = Notes + ' No new Loc found after reallocation (msp_ProcessShortPickReAlloc04)',   
                     TrafficCop = NULL    
      WHERE PickDetailKey IN (SELECT PickDetailKey FROM #TMP_SHORTED)     
               AND Status = '4'  
  
      ----Rollback UCC Status to 1      
      --BEGIN TRY    
      --   UPDATE UCC WITH (ROWLOCK)    
      --   SET UCC.[Status] = '1'    
      --      , UCC.PickdetailKey = ''    
      --      , UCC.OrderKey = ''    
      --      , UCC.OrderLineNumber = ''    
      --      , UCC.WaveKey = ''    
      --   WHERE UCC.Storerkey = @c_Storerkey    
      --   AND UCC.SKU = @c_SKU    
      --   AND UCC.UCCNo = @c_UCCNo    
      --END TRY    
      --BEGIN CATCH    
      --   SET @n_Continue = 3    
      --   SET @c_ErrMsg = ERROR_MESSAGE()    
      --END CATCH     
   END     
  
   --Wave Release  
   --IF (@n_Continue = 1 OR @n_Continue = 2)  
   --BEGIN  
   --   BEGIN TRY  
   --      EXEC dbo.isp_ReleaseWave_Wrapper @c_WaveKey = @c_WaveKey -- nvarchar(10)  
   --                                     , @b_Success = @b_Success OUTPUT -- int  
   --                                     , @n_Err = @n_Err OUTPUT -- int  
   --                                     , @c_Errmsg = @c_Errmsg OUTPUT -- nvarchar(255)  
           
   --   END TRY  
   --   BEGIN CATCH  
   --      SET @n_Continue = 3  
   --      SET @c_ErrMsg = ERROR_MESSAGE()  
   --   END CATCH  
   --END  
  
  
   -- Update TaskDetail Message02 field to 'SHORT' or 'SHORT1' for reallocated tasks  
   --IF (@n_Continue = 1 OR @n_Continue = 2)  
   --BEGIN  
   --   -- Insert new taskdetailkeys into temp table after wave releasing  
   --   INSERT INTO #TMP_TASK_NEW (Taskdetailkey)  
   --   SELECT TD.Taskdetailkey  
   --   FROM TASKDETAIL TD WITH (NOLOCK)  
   --   WHERE TD.Wavekey = @c_Wavekey  
   --   AND TD.Storerkey = @c_StorerKey  
   --   AND TD.Sku = @c_SKU  
   --   AND TD.TaskType IN ('RPF', 'FCP')  
   --   AND NOT EXISTS ( SELECT 1  
   --                    FROM #TMP_TASK_CURRENT T  
   --                    WHERE T.Taskdetailkey = TD.Taskdetailkey )  
  
   --   IF EXISTS ( SELECT 1  
   --               FROM #TMP_TASK_NEW )  
   --   BEGIN  
   --      -- If allocation from pick location, set Message02 = 'SHORT1'  
   --      -- If not above, RPF from BULK and FCP with HOLD status, set Message02 = 'SHORT'  
   --      -- Only FCP task need filter by Status = 'H', RPF task filter Status = '0'  
   --      UPDATE TD  
   --      SET TD.Message02 = CASE WHEN (TD.TaskType = 'FCP' AND TD.[Status] = '0') THEN 'SHORT1'  
   --                              WHEN (TD.TaskType = 'FCP' AND TD.[Status] = 'H')   
   --                                OR (TD.TaskType = 'RPF' AND TD.[Status] = '0') THEN 'SHORT'  
   --                              ELSE TD.Message02  -- Keep existing value if no condition matches  
   --                         END  
   --        , TD.TrafficCop = NULL  
   --      FROM TASKDETAIL TD (NOLOCK)  
   --      JOIN #TMP_TASK_NEW T ON T.Taskdetailkey = TD.Taskdetailkey  
   --      WHERE TD.Wavekey = @c_Wavekey  
   --      AND (  
   --         (TD.TaskType = 'FCP' AND TD.[Status] IN ('0', 'H'))  
   --         OR  
   --         (TD.TaskType = 'RPF' AND TD.[Status] = '0')  
   --      )  
   --   END  
   --END  
  
   --Delete pickdetail_WIP work in progress staging table      
   IF (@n_Continue = 1 or @n_Continue = 2)  
   BEGIN  
      BEGIN TRY  
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey  
                                     , @c_WIP_RefNo = @c_SourceType  
                                     , @c_PickCondition_SQL = ''  
                            , @c_Action = 'D' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records     
                                     , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization      
                                     , @b_Success = @b_Success OUTPUT  
                                     , @n_Err = @n_err OUTPUT  
                                     , @c_ErrMsg = @c_errmsg OUTPUT  
      END TRY  
      BEGIN CATCH  
         SET @n_Continue = 3  
         SET @c_ErrMsg = ERROR_MESSAGE()  
      END CATCH  
   END  
  
   QUIT_SP:  
   IF OBJECT_ID('tempdb..#TMP_SHORTED', 'u') IS NOT NULL   
      DROP TABLE #TMP_SHORTED  
  
   --IF OBJECT_ID('tempdb..#TMP_TASK_CURRENT', 'u') IS NOT NULL   
   --   DROP TABLE #TMP_TASK_CURRENT  
  
   --IF OBJECT_ID('tempdb..#TMP_TASK_NEW', 'u') IS NOT NULL   
   --   DROP TABLE #TMP_TASK_NEW  
  
   IF OBJECT_ID('tempdb..#PickDetail_WIP', 'u') IS NOT NULL   
      DROP TABLE #PickDetail_WIP  
  
   IF (XACT_STATE()) = -1   
   BEGIN  
      SET @n_Continue = 3  
      ROLLBACK TRAN  
   END  
  
   WHILE @@TRANCOUNT < @n_StartTCnt  
   BEGIN  
      BEGIN TRAN  
   END  
  
   IF @n_Continue = 3  -- Error Occured      
   BEGIN      
      SELECT @b_Success = 0  
      IF @@TRANCOUNT > @n_StartTCnt  
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
      RETURN  
   END  
   ELSE  
   BEGIN  
      SELECT @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END  
END  
GO
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc04] TO [NSQL]
GO
