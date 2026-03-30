SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: msp_ProcessShortPickReAlloc05                      */
/* Creation Date: 09-Jan-2026                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-10032 CSCUK - Reallocation SP for Skip and Replace      */
/*                                                                      */
/* Called By: Q-Commander                                               */
/*                                                                      */
/* GitHub Version: 1.2                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 09-Jan-2026 WLChooi  1.0   Initial Version                           */
/* 25-Feb-2026 WLChooi  1.1   UWP-49450 Clear Userdefine01 value (WL01) */
/* 30-Mar-2026 WLChooi  1.2   FCR-12094 Delete shorted PICKDETAIL line  */
/*                            if reallocation succeed (WL02)            */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc05] (    
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

   DECLARE @c_StrategykeyParm          NVARCHAR(10) = ''
         , @c_SourceType               NVARCHAR(30) = ''
         , @c_Facility                 NVARCHAR(5)  = ''
         , @c_Message02                NVARCHAR(20) = ''
         , @n_SkipNumber               INT = 0
         , @c_RCMConfigSP              NVARCHAR(60) = ''
         , @c_WVRCMConfigCode          NVARCHAR(30) = ''
         , @n_SkipProcess              INT = 0
         , @c_PickCondition_SQL        NVARCHAR(MAX) = ''
         , @c_PickDetailKey            NVARCHAR(10)  = ''   --WL02
         , @CUR_UNALLOC                CURSOR               --WL02
         , @n_RemoveShort              INT = 0              --WL02
         , @n_ShortQty                 INT = 0              --WL02

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   SET @c_StrategykeyParm = ''
   SET @c_SourceType = 'msp_ProcessShortPickReAlloc05'
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      CREATE TABLE #T_ShortOrders (    
            OrderKey    NVARCHAR(10) PRIMARY KEY
      )

      CREATE TABLE #T_ORDERSKU (
            Orderkey    NVARCHAR(10)
          , Storerkey   NVARCHAR(15)
          , SKU         NVARCHAR(20)
          , WCS         NVARCHAR(10) DEFAULT 0
          , PRIMARY KEY (Orderkey, Storerkey, SKU)
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

      CREATE TABLE #T_CaseID (
            Storerkey   NVARCHAR(15)
          , CaseID      NVARCHAR(20)
          , SKU         NVARCHAR(20)
          , Qty         INT
          , PRIMARY KEY (Storerkey, CaseID, SKU)
      )

      CREATE TABLE #T_Packdetail (
            PickSlipNo  NVARCHAR(10)
          , CartonNo    INT
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

      CREATE TABLE #T_ShortPick (    
            Pickdetailkey     NVARCHAR(18) PRIMARY KEY
          , Orderkey          NVARCHAR(10)
          , Qty               INT
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
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      WHERE W.WaveKey = @c_Wavekey

      IF ISNULL(@c_Taskdetailkey, '') <> ''
      BEGIN
         SELECT @c_Message02 = ISNULL(TD.Message02, '')
         FROM TASKDETAIL TD WITH (NOLOCK)
         WHERE TD.TaskDetailKey = @c_Taskdetailkey
      END

      -- Get current taskdetail for the SKU
      INSERT INTO #TMP_TASK_CURRENT (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD WITH (NOLOCK)
      WHERE TD.Wavekey = @c_Wavekey
      AND TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU

      IF ISNULL(@c_Message02, '') = ''
      BEGIN
         SET @c_Message02 = 'SKIP1'
      END
      ELSE
      BEGIN
         SET @n_SkipNumber = TRY_CAST(REPLACE(@c_Message02, 'SKIP', '') AS INT)
         SET @n_SkipNumber = ISNULL(@n_SkipNumber, 0) + 1
         SET @c_Message02 = 'SKIP' + CAST(@n_SkipNumber AS NVARCHAR(10))
      END

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
   --RDT update QtyMoved = Qty, Qty = 0, Status = '4'
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                      WHERE PD.Storerkey = @c_StorerKey
                      AND PD.Sku = @c_SKU    
                      AND PD.DropID = @c_UCCNo    
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
         SELECT @n_Err = 64503
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': UCC#: ' + TRIM(@c_UCCNo) + ' No Record Found (msp_ProcessShortPickReAlloc05)'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END
   
   --Get Orderkeys that have UCC being shorted
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      INSERT INTO #T_ShortPick (Pickdetailkey, Orderkey, Qty)
      SELECT PD.PickDetailKey, PD.OrderKey, PD.QtyMoved
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.Storerkey = @c_StorerKey    
      AND   PD.Sku = @c_SKU    
      AND   PD.DropID = @c_UCCNo    
      AND   PD.[Status] = '4'
      AND   EXISTS ( SELECT 1 
                     FROM WAVEDETAIL WD (NOLOCK)
                     WHERE WD.WaveKey = @c_Wavekey
                     AND WD.OrderKey = PD.OrderKey )
      GROUP BY PD.PickDetailKey, PD.OrderKey, PD.QtyMoved

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

   --Rollback UCC Status to 1
   --nspInventoryHold only allow holding Status in (1, 2)
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF @b_debug = 0
      BEGIN
         BEGIN TRAN
      END

      BEGIN TRY
         UPDATE UCC WITH (ROWLOCK)
         SET UCC.[Status] = '1'
           , UCC.PickdetailKey = ''
           , UCC.OrderKey = ''
           , UCC.OrderLineNumber = ''
           , UCC.WaveKey = ''
         WHERE UCC.Storerkey = @c_Storerkey
         AND UCC.SKU = @c_SKU
         AND UCC.UCCNo = @c_UCCNo
         AND UCC.[Status] = '3'
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH

      IF @b_debug = 0 AND @n_Continue IN (1,2)
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
   END

   --Hold the UCC
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      BEGIN TRY
         EXEC dbo.nspInventoryHoldWrapper @c_lot = N'' -- nvarchar(10)
                                        , @c_Loc = N'' -- nvarchar(10)
                                        , @c_ID = N'' -- nvarchar(18)
                                        , @c_StorerKey = @c_Storerkey -- nvarchar(15)
                                        , @c_SKU = @c_SKU -- nvarchar(20)
                                        , @c_Lottable01 = N'' -- nvarchar(18)
                                        , @c_Lottable02 = N'' -- nvarchar(18)
                                        , @c_Lottable03 = N'' -- nvarchar(18)
                                        , @dt_Lottable04 = NULL -- datetime
                                        , @dt_Lottable05 = NULL -- datetime
                                        , @c_Lottable06 = '' -- nvarchar(30)
                                        , @c_Lottable07 = '' -- nvarchar(30)
                                        , @c_Lottable08 = '' -- nvarchar(30)
                                        , @c_Lottable09 = '' -- nvarchar(30)
                                        , @c_Lottable10 = '' -- nvarchar(30)
                                        , @c_Lottable11 = '' -- nvarchar(30)
                                        , @c_Lottable12 = '' -- nvarchar(30)
                                        , @dt_Lottable13 = NULL -- datetime
                                        , @dt_Lottable14 = NULL -- datetime
                                        , @dt_Lottable15 = NULL -- datetime
                                        , @c_Status = N'SHORT' -- nvarchar(10)
                                        , @c_Hold = N'1' -- nvarchar(1)
                                        , @b_success = @b_success OUTPUT -- int
                                        , @n_Err = @n_Err OUTPUT -- int
                                        , @c_Errmsg = @c_Errmsg OUTPUT -- nvarchar(250)
                                        , @c_Remark = '' -- nvarchar(260)
                                        , @c_UCCNo = @c_UCCNo -- nvarchar(20)
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH
   END
   
   --Reallocate
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @c_StrategykeyParm <> ''
   BEGIN
      -- Update to ALLOC to indicate shorted line
      UPDATE P
      SET P.TaskManagerReasonKey = IIF(P.TaskManagerReasonKey = 'SHORT', P.TaskManagerReasonKey, 'ALLOC')
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
      END CATCH

      -- Revert
      UPDATE P
      SET P.TaskManagerReasonKey = IIF(P.TaskManagerReasonKey = 'SHORT', P.TaskManagerReasonKey, '')
        , P.TrafficCop = NULL
      FROM PICKDETAIL P
      JOIN #T_ShortPick T ON T.Pickdetailkey = P.PickDetailKey
   END

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      --Initialize Pickdetail work in progress staging table   
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = @c_PickCondition_SQL
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

   -- If nothing new allocated, skip replenishment and Wave release
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM #PickDetail_WIP P
                      WHERE P.Storerkey = @c_StorerKey
                      AND   P.Sku = @c_SKU
                      AND   P.[Status] < '4' 
                      AND   EXISTS ( SELECT 1 
                                     FROM #T_ShortOrders T
                                     WHERE T.OrderKey = P.OrderKey )
                      AND NOT EXISTS ( SELECT 1
                                        FROM #T_PICKDETAIL_CURRENT T
                                        WHERE T.Pickdetailkey = P.PickDetailKey ) )
      BEGIN
         SET @n_SkipProcess = 1
      END
   END

   --WL02 S
   -- If partial reallocation, do not delete the shorted pickdetail lines
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_SkipProcess = 0
   BEGIN
      SELECT @n_ShortQty = SUM(Qty) 
      FROM #T_ShortPick

      IF EXISTS ( SELECT 1
                  FROM #PickDetail_WIP P
                  WHERE P.Storerkey = @c_StorerKey
                  AND   P.Sku = @c_SKU
                  AND   P.[Status] < '4' 
                  AND   EXISTS ( SELECT 1 
                                 FROM #T_ShortOrders T
                                 WHERE T.OrderKey = P.OrderKey )
                  AND NOT EXISTS ( SELECT 1
                                    FROM #T_PICKDETAIL_CURRENT T
                                    WHERE T.Pickdetailkey = P.PickDetailKey )
                  HAVING SUM(P.Qty) = @n_ShortQty
                )
      BEGIN
         SET @n_RemoveShort = 1
      END
   END
   --WL02 E
   
   -- Confirm Replenishment via RCMConfig
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_SkipProcess = 0
   BEGIN
      SET @c_WVRCMConfigCode = 'CFMREPL'

      SELECT @c_RCMConfigSP = TRIM(CL.Long)
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.ListName = 'RCMConfig'
      AND   CL.Code = @c_WVRCMConfigCode
      AND   CL.UDF01= 'wave'
      AND   CL.Short= 'storedproc'
      AND   CL.Storerkey = @c_Storerkey
      
      IF ISNULL(@c_RCMConfigSP, '') = ''
         SET @c_RCMConfigSP = 'msp_RCM_WV_Col_DynamicReplen'   --FCR-9741

      IF @c_RCMConfigSP <> ''
      BEGIN
         IF EXISTS (SELECT 1 FROM sys.objects (NOLOCK) WHERE OBJECT_ID(@c_RCMConfigSP) = object_id AND [Type] = 'P')
         BEGIN
            --WL01 S
            BEGIN TRY   
               UPDATE dbo.WAVE
               SET UserDefine01 = ''
                 , EditDate = GETDATE()
                 , EditWho = SUSER_SNAME()
                 , TrafficCop = NULL    
               WHERE WaveKey = @c_WaveKey   
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @c_ErrMsg = ERROR_MESSAGE()
            END CATCH    

            IF @n_Continue IN (1, 2)
            BEGIN
               BEGIN TRY   
                  SET @b_Success = 1
                
                  EXEC @c_RCMConfigSP 
                     @c_Wavekey        = @c_Wavekey
                  ,  @b_Success        = @b_Success   OUTPUT
                  ,  @n_Err            = @n_Err       OUTPUT  
                  ,  @c_ErrMsg         = @c_ErrMsg    OUTPUT   
                  ,  @c_Code           = @c_WVRCMConfigCode        
            
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH    
            
               IF @n_err <> 0 
               BEGIN
                  SET @n_Continue = 3
               END
            END
            --WL01 E
         END
      END
   END

   -- Delete Packdetail based on CaseID
   -- Clear Caseid for shorted lines
   IF (@n_Continue = 1 OR @n_Continue = 2)
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

      INSERT INTO #T_Packdetail (PickSlipNo, CartonNo)
      SELECT DISTINCT PD.PickSlipNo, PD.CartonNo
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
              , PackDetailQty = IIF(PD.Qty > 0, PD.Qty, PD.ExpQty)
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
         UPDATE SET Qty = SRC.PackDetailQty - SRC.CaseIDQty;

      IF @b_debug = 0 AND @n_Continue IN (1,2) 
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END

      -- Clear CaseID
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
   
   -- Update to PICKDETAIL first before redo Pre-cartonization
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_SkipProcess = 0
   BEGIN
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = @c_PickCondition_SQL
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
   
   --Wave Release - Redo Pre-cartonization
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_SkipProcess = 0           
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
   
   -- Re-initialize #PICKDETAIL_WIP after redo Pre-cartonization
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_SkipProcess = 0
   BEGIN
      --Initialize Pickdetail work in progress staging table   
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = @c_PickCondition_SQL
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

   -- Update TaskDetail Message02 for reallocated tasks
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_SkipProcess = 0
   BEGIN
      -- Insert new taskdetailkeys into temp table after wave releasing
      INSERT INTO #TMP_TASK_NEW (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD WITH (NOLOCK)
      WHERE TD.Wavekey = @c_Wavekey
      AND TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU
      AND TD.TaskType IN ('RPF', 'CPK')
      AND NOT EXISTS ( SELECT 1
                       FROM #TMP_TASK_CURRENT T
                       WHERE T.Taskdetailkey = TD.Taskdetailkey )

      IF EXISTS ( SELECT 1
                  FROM #TMP_TASK_NEW )
      BEGIN
         -- Set Message02 = @c_Message02 for all new tasks
         UPDATE TD
         SET TD.Message02 = @c_Message02
           , TD.TrafficCop = NULL
         FROM TASKDETAIL TD (NOLOCK)
         JOIN #TMP_TASK_NEW T ON T.Taskdetailkey = TD.Taskdetailkey
         WHERE TD.Wavekey = @c_Wavekey
      END
   END

   --WL02 S
   -- Delete shorted pickdetail line if able to reallocate
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_RemoveShort = 1
   BEGIN
      SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT T.Pickdetailkey
      FROM #T_ShortPick T
      ORDER BY T.Pickdetailkey

      OPEN @CUR_UNALLOC

      FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
      BEGIN
         BEGIN TRY
            DELETE FROM PICKDETAIL
            WHERE PickDetailKey = @c_PickDetailKey
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         -- Delete from temp table as well
         DELETE FROM #PICKDETAIL_WIP
         WHERE PickDetailKey = @c_PickDetailKey

         FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
      END
      CLOSE @CUR_UNALLOC
      DEALLOCATE @CUR_UNALLOC
   END
   --WL02 E

   --Update pickdetail_WIP work in progress staging table back to pickdetail 
   IF (@n_Continue = 1 or @n_Continue = 2) AND @n_SkipProcess = 0
   BEGIN
      EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = @c_PickCondition_SQL
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

   IF OBJECT_ID('tempdb..#T_ORDERSKU ','u') IS NOT NULL 
      DROP TABLE #T_ORDERSKU

   IF OBJECT_ID('tempdb..#T_CaseID ','u') IS NOT NULL 
      DROP TABLE #T_CaseID

   IF OBJECT_ID('tempdb..#T_Packdetail ','u') IS NOT NULL 
      DROP TABLE #T_Packdetail

   IF OBJECT_ID('tempdb..#TMP_TASK_CURRENT ','u') IS NOT NULL 
      DROP TABLE #TMP_TASK_CURRENT

   IF OBJECT_ID('tempdb..#TMP_TASK_NEW ','u') IS NOT NULL 
      DROP TABLE #TMP_TASK_NEW

   IF OBJECT_ID('tempdb..#TMP_PICKDETAIL_CURRENT ','u') IS NOT NULL 
      DROP TABLE #TMP_PICKDETAIL_CURRENT
      
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'msp_ProcessShortPickReAlloc05'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR
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
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc05] TO [NSQL]
GO