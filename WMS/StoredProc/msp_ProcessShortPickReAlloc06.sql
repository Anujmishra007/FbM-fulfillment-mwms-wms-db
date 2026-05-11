SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: msp_ProcessShortPickReAlloc06                      */
/* Creation Date: 12-Mar-2026                                           */
/* Copyright: MAERSK                                                    */
/* Written by: JihHaur                                                  */
/*                                                                      */
/* Purpose: FCR-11313 DAMIND - Reallocation SP                          */  
/*                                                                      */
/* Called By: Q-Commander                                               */
/*                                                                      */
/* GitHub Version: 1.4                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 12-Mar-2026 JihHaur  1.0   Initial Version                           */
/* 27-Apr-2026 JihHaur  1.1   Add config to udpate Pickslipno (JH01)    */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc06] (    
       @c_Wavekey          NVARCHAR(10)
     , @c_SKU              NVARCHAR(20)
     , @c_InputValue       NVARCHAR(20)  --Loc
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
         --, @c_LOT                      NVARCHAR(10) = ''
         --, @c_ID                       NVARCHAR(18) = ''
         --, @c_SourceKey                NVARCHAR(50) = ''

   DECLARE @c_StrategykeyParm          NVARCHAR(10) = ''
         , @c_SourceType               NVARCHAR(50) = ''
         , @c_Facility                 NVARCHAR(5)  = ''
         , @c_PickCondition_SQL        NVARCHAR(MAX) = ''  
         , @c_Loc                      NVARCHAR(10) = ''          
         , @c_PickSlipNo               NVARCHAR(10) = ''   /*JH01*/

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   --SET @c_SourceKey = @c_Wavekey
   --SET @c_UOM = ''
   SET @c_StrategykeyParm = ''
   SET @c_SourceType = 'msp_ProcessShortPickReAlloc06'   
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      CREATE TABLE #T_ShortOrders (    
            OrderKey    NVARCHAR(10) PRIMARY KEY
      )

      --CREATE TABLE #T_ORDERSKU (
      --      Orderkey    NVARCHAR(10)
      --    , Storerkey   NVARCHAR(15)
      --    , SKU         NVARCHAR(20)
      --    , WCS         NVARCHAR(10) DEFAULT 0
      --    , PRIMARY KEY (Orderkey, Storerkey, SKU)
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

      --CREATE TABLE #T_CaseID (
      --      Storerkey   NVARCHAR(15)
      --    , CaseID      NVARCHAR(20)
      --    , SKU         NVARCHAR(20)
      --    , PRIMARY KEY (Storerkey, CaseID, SKU)
      --)

      --CREATE TABLE #T_Packdetail (
      --      PickSlipNo  NVARCHAR(10)
      --    , CartonNo    INT
      --   PRIMARY KEY (PickSlipNo, CartonNo)
      --)

      CREATE TABLE #T_PICKDETAIL_CURRENT (
            Pickdetailkey NVARCHAR(18) PRIMARY KEY
      )

      CREATE TABLE #T_ShortPick (    
            Pickdetailkey     NVARCHAR(18) PRIMARY KEY
          , Orderkey          NVARCHAR(10)
          , Qty               INT
          , SourceType        NVARCHAR(50)          
      )
   END

   IF @b_debug = 0 AND @n_Continue IN (1,2)
   BEGIN
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END
   
   --Initialize Data
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SELECT @c_StorerKey  = OH.StorerKey
           , @c_Facility   = OH.Facility            
           , @c_PickSlipNo = PD.PickSlipNo  /*JH01*/
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey   
      JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = OH.OrderKey  
      WHERE W.WaveKey = @c_Wavekey    
      
      SET @c_PickCondition_SQL = 'AND PICKDETAIL.Storerkey = ' + QUOTENAME(TRIM(ISNULL(@c_Storerkey, '')), '''')
                               + ' AND PICKDETAIL.SKU = ' + QUOTENAME(TRIM(ISNULL(@c_SKU, '')), '''')
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
   --@c_InputValue Exists in Loc
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF EXISTS ( SELECT 1
                      FROM dbo.LOC WITH (NOLOCK)
                      WHERE Facility = @c_Facility
                      AND LOC = @c_InputValue         
                    )    
      BEGIN
         SET @c_Loc = @c_InputValue
      END
      ELSE
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 13133
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Loc: ' + TRIM(@c_InputValue) + ' Loc not Found (msp_ProcessShortPickReAlloc06)'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END

   --RDT update QtyMoved = Qty, Qty = 0, Status = '4'
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                      WHERE PD.Storerkey = @c_StorerKey
                      AND PD.Sku = @c_SKU    
                      AND PD.Loc = @c_Loc    
                      AND PD.QtyMoved > 0
                      AND PD.Qty = 0
                      AND PD.[Status] = '4'
                      AND EXISTS ( SELECT 1 
                                   FROM WAVEDETAIL WD (NOLOCK)
                                   WHERE WD.WaveKey = @c_Wavekey
                                   AND WD.OrderKey = PD.OrderKey ) 
                    )    
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 13134
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+':Pickdetail Loc: ' + TRIM(@c_Loc) + ' not found (msp_ProcessShortPickReAlloc06)'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END
   
   --Get Orderkeys that have being shorted
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      INSERT INTO #T_ShortPick (Pickdetailkey, Orderkey, Qty, SourceType) 
      SELECT PD.PickDetailKey, PD.OrderKey, PD.QtyMoved, PD.SourceType
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.Storerkey = @c_StorerKey    
      AND   PD.Sku = @c_SKU    
      AND   PD.Loc = @c_Loc    
      AND   PD.[Status] = '4'
      AND   EXISTS ( SELECT 1 
                     FROM WAVEDETAIL WD (NOLOCK)
                     WHERE WD.WaveKey = @c_Wavekey
                     AND WD.OrderKey = PD.OrderKey )
      GROUP BY PD.PickDetailKey, PD.OrderKey, PD.QtyMoved, SourceType

      INSERT INTO #T_ShortOrders (OrderKey)
      SELECT DISTINCT T.Orderkey
      FROM #T_ShortPick T

      INSERT INTO #T_PICKDETAIL_CURRENT (Pickdetailkey)
      SELECT PD.Pickdetailkey
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.Storerkey = @c_StorerKey
      AND   PD.Sku = @c_SKU
      AND   PD.[Status] < '4'
      AND   EXISTS ( SELECT 1 
                     FROM #T_ShortOrders T
                     WHERE T.OrderKey = PD.OrderKey )
      GROUP BY PD.Pickdetailkey
   END   
   
   --Reallocate
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @c_StrategykeyParm <> ''
   BEGIN
      IF @b_debug = 0
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END

      BEGIN TRAN
      -- Update to @c_SourceType to indicate shorted line
      UPDATE P
      SET P.SourceType = @c_SourceType 
        , P.TrafficCop = NULL
      FROM PICKDETAIL P
      JOIN #T_ShortPick T ON T.Pickdetailkey = P.PickDetailKey
      
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
         ROLLBACK TRAN
      END CATCH   
      
      --Check reallocation success or not  /*JH01 start*/
      IF (@n_Continue = 1 OR @n_Continue = 2) AND EXISTS (SELECT 1  
         FROM WAVEDETAIL WD   
         JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = WD.OrderKey  
         WHERE WD.WaveKey = @c_Wavekey  
               --AND ISNULL(PD.PickSlipNo,'') = ''   
               AND PD.Storerkey = @c_StorerKey  
               AND PD.Sku = @c_SKU  
               AND PD.STATUS = '0'  
               AND PD.PickDetailKey NOT IN (SELECT PickDetailKey FROM #PickDetail_WIP))  
         AND EXISTS (SELECT 1 FROM STORERCONFIG WITH (NOLOCK)     
                                WHERE Configkey = 'ReallocUpdPickSlipNo'     
                                AND Storerkey = @c_StorerKey AND sValue = '1')    
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
            SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Error update into active PickSlipNo (msp_ProcessShortPickReAlloc06)'  
                             + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '    
         END CATCH  
  
         --IF (@n_Continue = 1 OR @n_Continue = 2)  
         --BEGIN  
         --   DELETE FROM PICKDETAIL  
         --   WHERE PickDetailKey IN (SELECT PickDetailKey FROM #TMP_SHORTED)  
         --END         
      END  

      -- Update PickDetail.SourceType back to original one
      UPDATE P
      SET P.SourceType = T.SourceType         
        , P.TrafficCop = NULL
      FROM PICKDETAIL P
      JOIN #T_ShortPick T ON T.Pickdetailkey = P.PickDetailKey
      WHERE P.SourceType = @c_SourceType 

      IF @b_debug = 0 AND @n_Continue IN (1,2)
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
   END /*JH01 end*/
   
   --IF (@n_Continue = 1 OR @n_Continue = 2)
   --BEGIN
   --   --Initialize Pickdetail work in progress staging table   
   --   EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
   --                               , @c_WIP_RefNo = @c_SourceType
   --                               , @c_PickCondition_SQL = @c_PickCondition_SQL   
   --                               , @c_Action = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
   --                               , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
   --                               , @b_Success = @b_Success OUTPUT
   --                               , @n_Err = @n_err OUTPUT
   --                               , @c_ErrMsg = @c_errmsg OUTPUT
   
   --   IF @b_Success <> 1
   --   BEGIN
   --      SET @n_Continue = 3
   --   END
   --END
   
   ----Compare Pickdetail Line
   --IF (@n_Continue = 1 OR @n_Continue = 2)
   --BEGIN
   --   -- ReAllocStatus
   --   -- 0 - Not Allocated after shorted
   --   IF NOT EXISTS ( SELECT 1
   --                   FROM #PickDetail_WIP P
   --                   WHERE P.Storerkey = @c_StorerKey
   --                   AND   P.Sku = @c_SKU
   --                   AND   P.[Status] < '4' 
   --                   AND NOT EXISTS ( SELECT 1
   --                                     FROM #T_PICKDETAIL_CURRENT T
   --                                     WHERE T.Pickdetailkey = P.PickDetailKey ) )
   --   BEGIN
   --      -- Trigger ITF
   --      SET @CUR_SHORT = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   --      SELECT DISTINCT T.Pickdetailkey, T.Orderkey
   --      FROM #T_ShortPick T

   --      OPEN @CUR_SHORT

   --      FETCH NEXT FROM @CUR_SHORT INTO @c_PickDetailKey, @c_Orderkey

   --      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
   --      BEGIN           

   --         BEGIN TRY
   --            UPDATE P
   --            SET P.TaskManagerReasonKey = 'SHORT'
   --              , P.TrafficCop = NULL
   --            FROM PICKDETAIL P
   --            WHERE P.PickDetailKey = @c_PickDetailKey
   --         END TRY
   --         BEGIN CATCH
   --            SET @n_Continue = 3
   --            SET @c_ErrMsg = ERROR_MESSAGE()
   --         END CATCH

   --         UPDATE P
   --         SET P.TaskManagerReasonKey = 'SHORT'
   --         FROM #PickDetail_WIP P
   --         WHERE P.PickDetailKey = @c_PickDetailKey

   --         FETCH NEXT FROM @CUR_SHORT INTO @c_PickDetailKey, @c_Orderkey
   --      END
   --      CLOSE @CUR_SHORT
   --      DEALLOCATE @CUR_SHORT

   --      GOTO UPD_PD
   --   END
   --END
  
   --UPD_PD:
   --Update pickdetail_WIP work in progress staging table back to pickdetail 
   --IF (@n_Continue = 1 or @n_Continue = 2)
   --BEGIN
   --   EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
   --                               , @c_WIP_RefNo = @c_SourceType
   --                               , @c_PickCondition_SQL = @c_PickCondition_SQL   --WL04
   --                               , @c_Action = 'U' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records   
   --                               , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
   --                               , @b_Success = @b_Success OUTPUT
   --                               , @n_Err = @n_err OUTPUT
   --                               , @c_ErrMsg = @c_errmsg OUTPUT

   --   IF @b_Success <> 1
   --   BEGIN
   --      SET @n_Continue = 3
   --   END
   --END

   ----Delete pickdetail_WIP work in progress staging table    
   --IF (@n_Continue = 1 or @n_Continue = 2)
   --BEGIN
   --   EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
   --                               , @c_WIP_RefNo = @c_SourceType
   --                               , @c_PickCondition_SQL = ''
   --                               , @c_Action = 'D' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records   
   --                               , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
   --                               , @b_Success = @b_Success OUTPUT
   --                               , @n_Err = @n_err OUTPUT
   --                               , @c_ErrMsg = @c_errmsg OUTPUT

   --   IF @b_Success <> 1
   --   BEGIN
   --      SET @n_Continue = 3
   --   END
   --END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#T_ShortOrders ','u') IS NOT NULL 
      DROP TABLE #T_ShortOrders

   IF OBJECT_ID('tempdb..#T_ShortPick ','u') IS NOT NULL 
      DROP TABLE #T_ShortPick
   
   IF OBJECT_ID('tempdb..#T_PICKDETAIL_CURRENT ','u') IS NOT NULL 
      DROP TABLE #T_PICKDETAIL_CURRENT

   --IF OBJECT_ID('tempdb..#T_ORDERSKU ','u') IS NOT NULL 
   --   DROP TABLE #T_ORDERSKU

   --IF OBJECT_ID('tempdb..#T_CaseID ','u') IS NOT NULL 
   --   DROP TABLE #T_CaseID

   --IF OBJECT_ID('tempdb..#T_Packdetail ','u') IS NOT NULL 
   --   DROP TABLE #T_Packdetail
      
   IF (XACT_STATE()) = -1 
   BEGIN
      SET @n_Continue = 3
      ROLLBACK TRAN
   END

   IF @b_debug = 0
   BEGIN
      WHILE @@TRANCOUNT < @n_StartTCnt
      BEGIN
         BEGIN TRAN
      END
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'msp_ProcessShortPickReAlloc06'   --WL01
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR   --WL01
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
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc06] TO [NSQL]
GO
