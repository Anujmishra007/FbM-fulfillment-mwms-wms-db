SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: msp_ProcessShortPickReAlloc03                      */
/* Creation Date: 27-Nov-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-9270 WMS - Brazil - Cajamar - ONBR - Reallocation SP    */
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
/* 07-Jan-2025 WLChooi  1.0   Initial Version                           */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc03] (    
       @c_Wavekey          NVARCHAR(10)
     , @c_SKU              NVARCHAR(20)
     , @c_Loc              NVARCHAR(20)
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

   DECLARE @c_StrategykeyParm          NVARCHAR(10) = ''
         , @c_SourceType               NVARCHAR(30) = ''
         , @c_Orderkey                 NVARCHAR(10) = ''
         , @c_ReAllocStatus            NVARCHAR(10) = ''
         , @c_PickDetailKey            NVARCHAR(18) = ''
         , @n_QtyInDiff                INT = 0
         , @CUR_UpdatePick             CURSOR
         , @c_Facility                 NVARCHAR(5)  = ''
         , @c_TableName                NVARCHAR(30) = ''
         , @n_ByUCC                    INT = 1   -- @n_ByUCC = 1 - UCC   @n_ByUCC = 0 - LOC
         , @CUR_UNALLOC                CURSOR
         , @c_UCCNo                    NVARCHAR(20) = ''

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   SET @c_StrategykeyParm = ''
   SET @c_SourceType = 'msp_ProcessShortPickReAlloc03'
   SET @c_TableName = N'WSSOAlloUpd'
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      CREATE TABLE #T_ShortOrders (    
            OrderKey    NVARCHAR(10) PRIMARY KEY
      )

      CREATE TABLE #TMP_SHORTED
      (
         Pickdetailkey NVARCHAR(18) PRIMARY KEY
      )

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
      CREATE INDEX IX_PickDetail_WIP_ShortPick ON #PickDetail_WIP (WaveKey, [Status], DropID, Storerkey, SKU) INCLUDE (OrderKey, Qty, QtyMoved, PickDetailKey)

      CREATE TABLE #T_CaseID (
            Storerkey   NVARCHAR(15)
          , CaseID      NVARCHAR(20)
          , SKU         NVARCHAR(20)
          , Qty         INT
          , PRIMARY KEY (CaseID, Storerkey, SKU)
      )

      CREATE TABLE #T_Packdetail (
            PickSlipNo  NVARCHAR(10)
          , CartonNo    INT
          , Qty         INT
         PRIMARY KEY (PickSlipNo, CartonNo)
      )

      CREATE TABLE #TMP_TASK_CURRENT
      (
         Taskdetailkey NVARCHAR(10) PRIMARY KEY
      )

      CREATE TABLE #TMP_TASK_NEW
      (
         Taskdetailkey NVARCHAR(10) PRIMARY KEY
      )

      CREATE TABLE #T_PICKDETAIL_CURRENT (
            Pickdetailkey NVARCHAR(18) PRIMARY KEY
      )
   END

   IF @b_debug = 0 AND @n_Continue IN (1,2)
   BEGIN
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END
   
   --Pre-validation
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM TASKDETAIL WITH (NOLOCK)
                      WHERE Taskdetailkey = @c_Taskdetailkey )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64503
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Invalid Taskdetailkey# ' + @c_Taskdetailkey + ' (msp_ProcessShortPickReAlloc03)'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END

   --Initialize Data
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SELECT @c_StorerKey  = OH.StorerKey
           , @c_Facility   = OH.Facility
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      WHERE W.WaveKey = @c_Wavekey

      SELECT @c_UCCNo = ISNULL(TD.CaseID, '')
      FROM TASKDETAIL TD WITH (NOLOCK)
      WHERE TD.Taskdetailkey = @c_Taskdetailkey

      IF EXISTS ( SELECT 1
                  FROM UCC (NOLOCK)
                  WHERE UCCNo = @c_UCCNo
                  AND Storerkey = @c_Storerkey
                  AND SKU = @c_SKU )
      BEGIN
         SET @n_ByUCC = 1
      END
      ELSE
      BEGIN
         SET @n_ByUCC = 0
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
   --RDT update Status = '4'， QtyMoved, Qty no change
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF @n_ByUCC = 1
      BEGIN
         INSERT INTO #TMP_SHORTED (Pickdetailkey)
         SELECT PD.Pickdetailkey
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.Storerkey = @c_StorerKey
         AND PD.Sku = @c_SKU
         AND PD.DropID = @c_UCCNo
         AND PD.[Status] = '4'
         AND EXISTS ( SELECT 1 
                      FROM WAVEDETAIL WD (NOLOCK)
                      WHERE WD.WaveKey = @c_Wavekey
                      AND WD.OrderKey = PD.OrderKey )

         IF NOT EXISTS ( SELECT 1
                         FROM #TMP_SHORTED )
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_Err = 64503
            SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': UCC#: ' + TRIM(@c_UCCNo) + ' No Record Found (msp_ProcessShortPickReAlloc03)'
                             + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
         END
      END
      ELSE
      BEGIN
         INSERT INTO #TMP_SHORTED (Pickdetailkey)
         SELECT PD.Pickdetailkey
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.Storerkey = @c_StorerKey
         AND PD.Sku = @c_SKU
         AND PD.Loc = @c_Loc
         AND PD.[Status] = '4'
         AND EXISTS ( SELECT 1 
                      FROM WAVEDETAIL WD (NOLOCK)
                      WHERE WD.WaveKey = @c_Wavekey
                      AND WD.OrderKey = PD.OrderKey )

         IF NOT EXISTS ( SELECT 1
                         FROM #TMP_SHORTED )
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_Err = 64504
            SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Loc#: ' + TRIM(@c_Loc) + ' No Record Found (msp_ProcessShortPickReAlloc03)'
                             + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
         END
      END
   END
   
   --Get Orderkeys that have UCC being shorted
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF @n_ByUCC = 1
      BEGIN
         INSERT INTO #T_ShortOrders (OrderKey)
         SELECT PD.OrderKey
         FROM PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.Storerkey = @c_StorerKey    
         AND   PD.Sku = @c_SKU    
         AND   PD.DropID = @c_UCCNo    
         AND   PD.[Status] = '4'
         AND   EXISTS ( SELECT 1 
                        FROM WAVEDETAIL WD (NOLOCK)
                        WHERE WD.WaveKey = @c_Wavekey
                        AND WD.OrderKey = PD.OrderKey )
         GROUP BY PD.OrderKey
      END
      ELSE
      BEGIN
         INSERT INTO #T_ShortOrders (OrderKey)
         SELECT PD.OrderKey
         FROM PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.Storerkey = @c_StorerKey    
         AND   PD.Sku = @c_SKU    
         AND   PD.Loc = @c_Loc    
         AND   PD.[Status] = '4'
         AND   EXISTS ( SELECT 1 
                        FROM WAVEDETAIL WD (NOLOCK)
                        WHERE WD.WaveKey = @c_Wavekey
                        AND WD.OrderKey = PD.OrderKey )
         GROUP BY PD.OrderKey
      END

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

      IF ISNULL(@c_Taskdetailkey, '') <> ''
      BEGIN
         INSERT INTO #TMP_TASK_CURRENT (Taskdetailkey)
         SELECT @c_Taskdetailkey
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
            UPDATE PICKDETAIL
            SET QtyMoved = Qty, Qty = 0
            WHERE PickDetailKey = @c_PickDetailKey
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @c_ErrMsg = ERROR_MESSAGE()
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
      END CATCH
   END

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      --Initialize Pickdetail work in progress staging table   
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT
   
      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   -- Delete Packdetail based on CaseID
   -- Clear Caseid for shorted lines
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF @n_ByUCC = 1
      BEGIN
         INSERT INTO #T_CaseID (CaseID, Storerkey, SKU, Qty)
         SELECT SP.CaseID, SP.Storerkey, SP.SKU, SUM(SP.QtyMoved)
         FROM #PickDetail_WIP SP
         JOIN #T_ShortOrders T ON SP.OrderKey = T.OrderKey
         WHERE SP.WaveKey = @c_Wavekey
         AND SP.[Status] = '4'
         AND SP.DropID = @c_UCCNo
         AND SP.Storerkey  = @c_StorerKey
         AND SP.SKU = @c_SKU
         AND (SP.CaseID IS NOT NULL AND SP.CaseID <> '')
         GROUP BY SP.CaseID, SP.Storerkey, SP.SKU
      END
      ELSE
      BEGIN
         INSERT INTO #T_CaseID (CaseID, Storerkey, SKU, Qty)
         SELECT SP.CaseID, SP.Storerkey, SP.SKU, SUM(SP.QtyMoved)
         FROM #PickDetail_WIP SP
         JOIN #T_ShortOrders T ON SP.OrderKey = T.OrderKey
         WHERE SP.WaveKey = @c_Wavekey
         AND SP.[Status] = '4'
         AND SP.Loc = @c_Loc
         AND SP.Storerkey  = @c_StorerKey
         AND SP.SKU = @c_SKU
         AND (SP.CaseID IS NOT NULL AND SP.CaseID <> '')
         GROUP BY SP.CaseID, SP.Storerkey, SP.SKU
      END

      INSERT INTO #T_Packdetail (PickSlipNo, CartonNo, Qty)
      SELECT DISTINCT PD.PickSlipNo, PD.CartonNo, PD.Qty
      FROM PACKDETAIL PD (NOLOCK)
      JOIN #T_CaseID T ON PD.LabelNo = T.CaseID AND PD.StorerKey = T.Storerkey AND PD.SKU = T.SKU

      IF @b_debug = 0
      BEGIN
         BEGIN TRAN
      END

      -- Update or Delete Packdetail based on quantity comparison
      -- If T_CaseID.Qty = T_Packdetail.Qty, delete; else update Qty = T_Packdetail.Qty - T_CaseID.Qty
      MERGE PACKDETAIL AS TGT
      USING (
         SELECT PD.PickSlipNo
              , PD.CartonNo
              , PackDetailQty = PD.ExpQty
              , CaseIDQty = T_CaseID.Qty
         FROM PACKDETAIL PD (NOLOCK)
         JOIN #T_Packdetail T_Pack ON PD.PickSlipNo = T_Pack.PickSlipNo AND PD.CartonNo = T_Pack.CartonNo
         JOIN #T_CaseID T_CaseID ON PD.LabelNo = T_CaseID.CaseID 
                                 AND PD.StorerKey = T_CaseID.Storerkey 
                                 AND PD.SKU = T_CaseID.SKU
      ) AS SRC
      ON TGT.PickSlipNo = SRC.PickSlipNo 
     AND TGT.CartonNo = SRC.CartonNo
      WHEN MATCHED AND SRC.PackDetailQty = SRC.CaseIDQty THEN
         DELETE
      WHEN MATCHED AND SRC.PackDetailQty <> SRC.CaseIDQty THEN
         UPDATE SET ExpQty = SRC.PackDetailQty - SRC.CaseIDQty;

      -- Update or Delete Packinfo based on qty comparison
      -- Delete Packinfo where qty match
      -- Delete only, trigger will update the qty accordingly
      DELETE PIF
      FROM PACKINFO PIF
      JOIN PACKDETAIL PD (NOLOCK) ON PIF.PickSlipNo = PD.PickSlipNo AND PIF.CartonNo = PD.CartonNo
      JOIN #T_Packdetail T_Pack ON PIF.PickSlipNo = T_Pack.PickSlipNo AND PIF.CartonNo = T_Pack.CartonNo
      JOIN #T_CaseID T_CaseID ON PD.LabelNo = T_CaseID.CaseID 
                              AND PD.StorerKey = T_CaseID.Storerkey 
                              AND PD.SKU = T_CaseID.SKU
      WHERE PD.Qty = T_CaseID.Qty

      IF @b_debug = 0 AND @n_Continue IN (1,2) 
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
      
      -- Clear CaseID
      IF @n_ByUCC = 1
      BEGIN
         ;WITH MatchingRows AS (
            SELECT SP.PickDetailKey
            FROM #PickDetail_WIP SP
            JOIN #T_ShortOrders T ON SP.OrderKey = T.OrderKey
            WHERE SP.WaveKey = @c_Wavekey
            AND SP.[Status] = '4'
            AND SP.DropID = @c_UCCNo
            AND SP.Storerkey  = @c_StorerKey
            AND SP.SKU = @c_SKU
            AND (SP.CaseID IS NOT NULL AND SP.CaseID <> '')
         )
         UPDATE SP
         SET SP.CaseID = ''
         FROM #PickDetail_WIP SP
         JOIN MatchingRows MR ON SP.PickDetailKey = MR.PickDetailKey
      END
      ELSE
      BEGIN
         ;WITH MatchingRows AS (
            SELECT SP.PickDetailKey
            FROM #PickDetail_WIP SP
            JOIN #T_ShortOrders T ON SP.OrderKey = T.OrderKey
            WHERE SP.WaveKey = @c_Wavekey
            AND SP.[Status] = '4'
            AND SP.Loc = @c_Loc
            AND SP.Storerkey  = @c_StorerKey
            AND SP.SKU = @c_SKU
            AND (SP.CaseID IS NOT NULL AND SP.CaseID <> '')
         )
         UPDATE SP
         SET SP.CaseID = ''
         FROM #PickDetail_WIP SP
         JOIN MatchingRows MR ON SP.PickDetailKey = MR.PickDetailKey
      END
   END

   -- Update to PICKDETAIL first before redo Pre-cartonization
   IF (@n_Continue = 1 or @n_Continue = 2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'U' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records   
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   -- Redo Pre-cartonization
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      BEGIN TRY
         EXEC dbo.isp_WAVGenPackFromPicked_Wrapper @c_WaveKey = @c_Wavekey -- nvarchar(10)
                                                 , @b_Success = @b_Success OUTPUT -- int
                                                 , @n_Err = @n_Err OUTPUT -- int
                                                 , @c_ErrMsg = @c_ErrMsg OUTPUT -- nvarchar(250)
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH
   END

   -- Re-initialize #PICKDETAIL_WIP after redo Pre-cartonization
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      --Initialize Pickdetail work in progress staging table   
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT
   
      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   --Compare Pickdetail Line
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF @b_debug = 0
      BEGIN
         BEGIN TRAN
      END

      -- ReAllocStatus
      -- 0 - Not Allocated after shorted
      -- 1 - Partial Allocated after shorted
      -- 2 - Fully Allocated after shorted
      IF @n_ByUCC = 1
      BEGIN
         SET @CUR_UpdatePick = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         WITH AllPick AS (
            SELECT OrderKey = PD.OrderKey
                 , ReAllocStatus = CASE WHEN SUM(PD.Qty) = 0 THEN '0' ELSE '1' END
                 , QtyInDiff = ABS(MAX(PW.QtyMoved) - SUM(PD.Qty))
            FROM #PickDetail_WIP PD (NOLOCK)
            JOIN #T_ShortOrders T ON PD.OrderKey = T.OrderKey
            CROSS APPLY ( SELECT QtyMoved = SUM(P.QtyMoved)
                          FROM #PickDetail_WIP P
                          WHERE P.OrderKey = PD.OrderKey
                          AND P.WaveKey = PD.WaveKey
                          AND P.Storerkey = PD.Storerkey
                          AND P.SKU = PD.Sku
                          AND P.[Status] = '4'
                          AND P.DropID = @c_UCCNo ) AS PW
            WHERE PD.[Status] <= '4'
            AND PD.WaveKey = @c_Wavekey
            AND PD.Storerkey  = @c_StorerKey
            AND PD.SKU = @c_SKU
            -- To exclude those allocated line before reallocation
            AND NOT EXISTS ( SELECT 1
                             FROM #T_PICKDETAIL_CURRENT T
                             WHERE T.Pickdetailkey = PD.PickDetailKey )
            GROUP BY PD.OrderKey
            HAVING SUM(PD.Qty) < MAX(PW.QtyMoved)   --Only check Not/Partial allocated after reallocation
         ), ShortPick AS (
            SELECT Orderkey = PD.Orderkey
                 , Pickdetailkey = PD.PickDetailKey
            FROM #PickDetail_WIP PD (NOLOCK)
            JOIN #T_ShortOrders T ON PD.OrderKey = T.OrderKey
            WHERE PD.[Status] IN ('4')
            AND PD.WaveKey = @c_Wavekey
            AND PD.DropID = @c_UCCNo
            AND PD.Storerkey  = @c_StorerKey
            AND PD.SKU = @c_SKU
            GROUP BY PD.PickDetailKey, PD.OrderKey
         )
         SELECT AP.OrderKey
              , AP.ReAllocStatus
              , SP.Pickdetailkey
              , AP.QtyInDiff
         FROM ShortPick SP
         JOIN AllPick AP ON AP.OrderKey = SP.OrderKey
      END
      ELSE
      BEGIN
         SET @CUR_UpdatePick = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         WITH AllPick AS (
            SELECT OrderKey = PD.OrderKey
                 , ReAllocStatus = CASE WHEN SUM(PD.Qty) = 0 THEN '0' ELSE '1' END
                 , QtyInDiff = ABS(MAX(PW.QtyMoved) - SUM(PD.Qty))
            FROM #PickDetail_WIP PD (NOLOCK)
            JOIN #T_ShortOrders T ON PD.OrderKey = T.OrderKey
            CROSS APPLY ( SELECT QtyMoved = SUM(P.QtyMoved)
                          FROM #PickDetail_WIP P
                          WHERE P.OrderKey = PD.OrderKey
                          AND P.WaveKey = PD.WaveKey
                          AND P.Storerkey = PD.Storerkey
                          AND P.SKU = PD.Sku
                          AND P.[Status] = '4'
                          AND P.Loc = @c_Loc ) AS PW
            WHERE PD.[Status] <= '4'
            AND PD.WaveKey = @c_Wavekey
            AND PD.Storerkey  = @c_StorerKey
            AND PD.SKU = @c_SKU
            -- To exclude those allocated line before reallocation
            AND NOT EXISTS ( SELECT 1
                             FROM #T_PICKDETAIL_CURRENT T
                             WHERE T.Pickdetailkey = PD.PickDetailKey )
            GROUP BY PD.OrderKey
            HAVING SUM(PD.Qty) < MAX(PW.QtyMoved)   --Only check Not/Partial allocated after reallocation
         ), ShortPick AS (
            SELECT Orderkey = PD.Orderkey
                 , Pickdetailkey = PD.PickDetailKey
            FROM #PickDetail_WIP PD (NOLOCK)
            JOIN #T_ShortOrders T ON PD.OrderKey = T.OrderKey
            WHERE PD.[Status] IN ('4')
            AND PD.WaveKey = @c_Wavekey
            AND PD.Loc = @c_Loc
            AND PD.Storerkey  = @c_StorerKey
            AND PD.SKU = @c_SKU
            GROUP BY PD.PickDetailKey, PD.OrderKey
         )
         SELECT AP.OrderKey
              , AP.ReAllocStatus
              , SP.Pickdetailkey
              , AP.QtyInDiff
         FROM ShortPick SP
         JOIN AllPick AP ON AP.OrderKey = SP.OrderKey
      END

      OPEN @CUR_UpdatePick

      FETCH NEXT FROM @CUR_UpdatePick INTO @c_Orderkey, @c_ReAllocStatus, @c_PickDetailKey, @n_QtyInDiff

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
      BEGIN
         BEGIN TRY
            UPDATE dbo.PICKDETAIL
            SET QtyMoved = @n_QtyInDiff
              , TrafficCop = NULL
            WHERE PickDetailKey = @c_PickDetailKey
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @c_ErrMsg = ERROR_MESSAGE()
            GOTO QUIT_SP
         END CATCH

         --Trigger ITF
         IF @n_Continue IN (1,2)
         BEGIN
            BEGIN TRY
               EXEC dbo.ispGenTransmitLog2 @c_TableName = N'WSSOAlloUpd' -- nvarchar(30)
                                         , @c_Key1 = @c_Orderkey -- nvarchar(10)
                                         , @c_Key2 = @c_PickDetailKey -- nvarchar(30)
                                         , @c_Key3 = @c_Storerkey -- nvarchar(20)
                                         , @c_TransmitBatch = N'' -- nvarchar(30)
                                         , @b_Success = @b_Success OUTPUT -- int
                                         , @n_err = @n_Err OUTPUT -- int
                                         , @c_errmsg = @c_Errmsg OUTPUT -- nvarchar(250)
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @c_ErrMsg = ERROR_MESSAGE()
               GOTO QUIT_SP
            END CATCH
         END

         --Update the temp #PickDetail_WIP table
         UPDATE #PickDetail_WIP
         SET QtyMoved = @n_QtyInDiff
         WHERE PickDetailKey = @c_PickDetailKey

         FETCH NEXT FROM @CUR_UpdatePick INTO @c_Orderkey, @c_ReAllocStatus, @c_PickDetailKey, @n_QtyInDiff
      END
      CLOSE @CUR_UpdatePick
      DEALLOCATE @CUR_UpdatePick

      IF @b_debug = 0 AND @n_Continue IN (1,2) 
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
   END

   --Wave Release - Create task
   IF (@n_Continue = 1 OR @n_Continue = 2)           
   BEGIN
      BEGIN TRY
         EXEC dbo.isp_ReleaseWave_Wrapper @c_WaveKey = @c_WaveKey -- nvarchar(10)
                                        , @b_Success = @b_Success OUTPUT -- int
                                        , @n_Err = @n_Err OUTPUT -- int
                                        , @c_Errmsg = @c_Errmsg OUTPUT -- nvarchar(255)
       
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH
   END

   -- Update TaskDetail Message02 field to 'SHORT1' for reallocated tasks
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      -- Insert new taskdetailkeys into temp table after wave releasing
      INSERT INTO #TMP_TASK_NEW (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD WITH (NOLOCK)
      WHERE TD.Wavekey = @c_Wavekey
      AND TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU
      AND TD.TaskType IN ('RPF', 'FCP')
      AND NOT EXISTS ( SELECT 1
                       FROM #TMP_TASK_CURRENT T
                       WHERE T.Taskdetailkey = TD.Taskdetailkey )

      IF EXISTS ( SELECT 1
                  FROM #TMP_TASK_NEW )
      BEGIN
         -- Set Message02 = 'SHORT1' for all new tasks
         UPDATE TD
         SET TD.Message02 = 'SHORT1'
           , TD.TrafficCop = NULL
         FROM TASKDETAIL TD (NOLOCK)
         JOIN #TMP_TASK_NEW T ON T.Taskdetailkey = TD.Taskdetailkey
         WHERE TD.Wavekey = @c_Wavekey
      END
   END

   --Update pickdetail_WIP work in progress staging table back to pickdetail 
   IF (@n_Continue = 1 or @n_Continue = 2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'U' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records   
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   --Delete pickdetail_WIP work in progress staging table    
   IF (@n_Continue = 1 or @n_Continue = 2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'D' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records   
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#T_ShortOrders ','u') IS NOT NULL 
      DROP TABLE #T_ShortOrders

   IF OBJECT_ID('tempdb..#T_CaseID ','u') IS NOT NULL 
      DROP TABLE #T_CaseID

   IF OBJECT_ID('tempdb..#T_Packdetail ','u') IS NOT NULL 
      DROP TABLE #T_Packdetail

   IF OBJECT_ID('tempdb..#TMP_SHORTED ','u') IS NOT NULL 
      DROP TABLE #TMP_SHORTED
      
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
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc03] TO [NSQL]
GO