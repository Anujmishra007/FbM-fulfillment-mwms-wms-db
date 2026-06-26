SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: msp_ProcessShortPickReAlloc01                      */
/* Creation Date: 01-Oct-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-8049 LVSUSA - Reallocation SP for Skip and Replace      */
/*                                                                      */
/* Called By: Q-Commander                                               */
/*                                                                      */
/* GitHub Version: 1.5                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 13-Jan-2026 WLChooi  1.0   Initial Version                           */
/* 11-Feb-2026 WLChooi  1.1   UWP-48731 Add Error Logging (WL01)        */
/* 13-Feb-2026 WLChooi  1.2   UWP-48732 Split Pickdetail add Notes for  */
/*                            tracing purpose (WL02)                    */
/* 23-Feb-2026 WLChooi  1.3   UWP-48530 Insert RPF Task if the UCC of   */
/*                            the task has already completed (WL03)     */
/* 27-Feb-2026 WLChooi  1.4   UWP-48732 Init #PICKDETAIL_WIP with       */
/*                            condition (WL04)                          */
/* 22-Jun-2026 WLChooi  1.5   FCR-12719 Cross-wave UCC short pick       */
/*                            reallocation (WL05)                       */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc01] (    
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
         , @c_LOT                      NVARCHAR(10) = ''
         , @c_ID                       NVARCHAR(18) = ''
         , @c_SourceKey                NVARCHAR(50) = ''

   DECLARE @c_StrategykeyParm          NVARCHAR(10) = ''
         , @c_SourceType               NVARCHAR(30) = ''
         , @c_Orderkey                 NVARCHAR(10) = ''
         , @c_OrderLineNumber          NVARCHAR(5)  = ''
         , @c_ReAllocStatus            NVARCHAR(10) = ''
         , @c_PickDetailKey            NVARCHAR(18) = ''
         , @n_QtyInDiff                INT = 0
         , @CUR_PickDetailKey          CURSOR
         , @CUR_UpdatePick             CURSOR
         , @CUR_PTASK                  CURSOR
         , @CUR_UPDATEPD               CURSOR

   DECLARE @b_WCS                      INT          = 0
         , @n_PendingMoveIn            INT          = 0
         , @c_Automation               NVARCHAR(10) = ''
         , @c_PNDLoc                   NVARCHAR(10) = ''
         , @c_LocType_PND              NVARCHAR(10) = ''
         , @c_LocFac_PND               NVARCHAR(5)  = ''
         , @c_FromLOC                  NVARCHAR(10)  = ''
         , @c_DropID                   NVARCHAR(20) = ''
         , @c_UOM                      NVARCHAR(10) = ''
         , @c_PickMethod               NVARCHAR(10) = ''
         , @c_FromLocType              NVARCHAR(10) = ''
         , @c_FromLogicalLoc           NVARCHAR(10) = ''
         , @c_FromPAZone               NVARCHAR(10) = ''
         , @c_ToLocType                NVARCHAR(10) = ''
         , @c_ToLocCategory            NVARCHAR(10) = ''
         , @c_ToPAZone                 NVARCHAR(10) = ''
         , @c_TaskType                 NVARCHAR(10) = ''
         , @c_TaskStatus               NVARCHAR(10) = ''
         , @c_FinalLoc                 NVARCHAR(10) = ''
         , @c_PickMethod_TD            NVARCHAR(10) = ''
         , @c_RefTaskkey               NVARCHAR(10) = ''
         , @c_WCSPack                  NVARCHAR(10) = 'Y'
         , @b_InsertTask               INT          = 0
         , @n_PickdetQty               INT          = 0
         , @c_LabelNo                  NVARCHAR(20) = ''
         , @c_ToLoc                    NVARCHAR(10) = ''
         , @c_Facility                 NVARCHAR(5)  = ''
         , @c_AreaKey                  NVARCHAR(10) = ''
         , @c_NewTaskdetailKey         NVARCHAR(10) = ''
         , @c_NewPickdetailkey         NVARCHAR(10) = ''
         , @c_Message02                NVARCHAR(20) = ''
         , @c_TableName                NVARCHAR(30) = ''
         , @c_Consigneekey             NVARCHAR(15)
         , @c_OrderType                NVARCHAR(10)
         , @c_LabelLine                NVARCHAR(5)
         , @c_Pickslipno               NVARCHAR(10)
         , @n_CartonNo                 INT = 0
         , @n_PackQty                  INT = 0
         , @c_DefaultPackInfoFlag      NVARCHAR(10) = '0'
         , @n_TotCartonWeight          DECIMAL(15,7) = 0.00
         , @CUR_UCC                    CURSOR
         , @CUR_PICKDET_UPDATE         CURSOR
         , @n_splitqty                 INT = 0
         , @n_SkipNumber               INT = 0
         , @n_QtyLeftToFulFill         INT = 0
         , @CUR_SHORT                  CURSOR
         , @c_PickCondition_SQL        NVARCHAR(MAX) = ''   --WL04
         , @c_AllowCrossWaveTaskLinking NVARCHAR(10) = 'N'  --WL05
         , @c_RLWAV_Opt5                NVARCHAR(4000) = '' --WL05
         , @c_PDSourceType              NVARCHAR(10) = 'N'  --WL05
         , @c_GetWavekey                NVARCHAR(10) = ''   --WL05
         , @CUR_WAVE                    CURSOR              --WL05
         , @n_AvailableSOH              INT = 0             --WL05

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   SET @c_SourceKey = @c_Wavekey
   SET @c_UOM = ''
   SET @c_StrategykeyParm = ''
   SET @c_SourceType = 'msp_ProcessShortPickReAlloc01'
   SET @c_TableName = N'WSSOAlloUpd'
   
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
          , PRIMARY KEY (Storerkey, CaseID, SKU)
      )

      CREATE TABLE #T_Packdetail (
            PickSlipNo  NVARCHAR(10)
          , CartonNo    INT
         PRIMARY KEY (PickSlipNo, CartonNo)
      )

      CREATE TABLE #T_PICKDETAIL_CURRENT (
            Pickdetailkey NVARCHAR(18) PRIMARY KEY
      )

      CREATE TABLE #T_ShortPick (    --WL05
            Pickdetailkey     NVARCHAR(18) PRIMARY KEY
          , Orderkey          NVARCHAR(10)
          , WaveKey           NVARCHAR(10)
          , Qty               INT
      )

      --WL05 S
      CREATE TABLE #T_RelatedWaves (
            RowID      INT IDENTITY(1, 1) PRIMARY KEY
          , WaveKey    NVARCHAR(10)
      )
      CREATE NONCLUSTERED INDEX IDX_TRW_WAVEKEY ON #T_RelatedWaves (WaveKey)
      --WL05 E
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
           , @c_Automation = ISNULL(W.Userdefine09, '')
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      WHERE W.WaveKey = @c_Wavekey

      SELECT @c_DefaultPackInfoFlag = dbo.fnc_GetRight('', @c_StorerKey, '', 'DEFAULT_PACKINFO')

      --WL05 S
      SELECT @c_RLWAV_Opt5 = SC.Option5
      FROM dbo.fnc_GetRight2(@c_Facility, @c_StorerKey, '', 'ReleaseWave_SP') AS SC

      SELECT @c_AllowCrossWaveTaskLinking = dbo.fnc_GetParamValueFromString('@c_AllowCrossWaveTaskLinking', @c_RLWAV_Opt5, @c_AllowCrossWaveTaskLinking)

      IF ISNULL(@c_AllowCrossWaveTaskLinking, '') = ''
         SET @c_AllowCrossWaveTaskLinking = 'N'
      --WL05 E

      IF ISNULL(@c_Taskdetailkey, '') <> ''
      BEGIN
         SELECT @c_Message02 = ISNULL(TD.Message02, '')
         FROM TASKDETAIL TD WITH (NOLOCK)
         WHERE TD.TaskDetailKey = @c_Taskdetailkey
      END
      ELSE
      BEGIN
         SELECT @c_Message02 = MAX(ISNULL(TD.Message02, ''))
         FROM TASKDETAIL TD WITH (NOLOCK)
         WHERE TD.Storerkey = @c_StorerKey
         AND TD.SKU = @c_SKU
         AND TD.Caseid = @c_UCCNo
         AND ( @c_AllowCrossWaveTaskLinking = 'Y' OR TD.WaveKey = @c_Wavekey )   --WL05
      END

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

      --WL04 S
      SET @c_PickCondition_SQL = 'AND PICKDETAIL.Storerkey = ' + QUOTENAME(TRIM(ISNULL(@c_Storerkey, '')), '''')
                               + ' AND PICKDETAIL.SKU = ' + QUOTENAME(TRIM(ISNULL(@c_SKU, '')), '''')
      --WL04 E

      --WL05 S
      IF @c_AllowCrossWaveTaskLinking = 'Y'
      BEGIN
         INSERT INTO #T_RelatedWaves (WaveKey)
         SELECT X.WaveKey
         FROM ( SELECT DISTINCT W.WaveKey
                              , ROW_NUMBER() OVER (
                                   ORDER BY IIF(W.UserDefine04 = 'ACTIVE', 1, 2)
                                              , W.Wavekey
                                ) AS Seq
                FROM PICKDETAIL PD WITH (NOLOCK)
                JOIN WAVEDETAIL WD WITH (NOLOCK) ON PD.Orderkey = WD.Orderkey
                JOIN WAVE W WITH (NOLOCK) ON WD.Wavekey = W.Wavekey
                WHERE PD.Storerkey = @c_StorerKey
                AND   PD.Sku       = @c_SKU
                AND   PD.DropID    = @c_UCCNo
                AND   PD.[Status]  = '4'
              ) X
         ORDER BY X.Seq
      END
      ELSE
      BEGIN
         INSERT INTO #T_RelatedWaves (WaveKey)
         SELECT @c_Wavekey
      END
      --WL05 E
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
                      AND ( @c_AllowCrossWaveTaskLinking = 'Y'   --WL05
                         OR EXISTS ( SELECT 1 
                                     FROM WAVEDETAIL WD (NOLOCK)
                                     WHERE WD.WaveKey = @c_Wavekey
                                     AND WD.OrderKey = PD.OrderKey ) )
                    )    
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64503
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': UCC#: ' + TRIM(@c_UCCNo) + ' No Record Found (msp_ProcessShortPickReAlloc01)'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END
   
   --Get Orderkeys that have UCC being shorted
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      INSERT INTO #T_ShortPick (Pickdetailkey, Orderkey, WaveKey, Qty)
      SELECT PD.PickDetailKey, PD.OrderKey, PD.WaveKey, PD.QtyMoved
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.Storerkey = @c_StorerKey    
      AND   PD.Sku = @c_SKU    
      AND   PD.DropID = @c_UCCNo    
      AND   PD.[Status] = '4'
      AND   ( @c_AllowCrossWaveTaskLinking = 'Y'   --WL05
            OR EXISTS ( SELECT 1 
                        FROM WAVEDETAIL WD (NOLOCK)
                        WHERE WD.WaveKey = @c_Wavekey
                        AND WD.OrderKey = PD.OrderKey ) )
      GROUP BY PD.PickDetailKey, PD.OrderKey, PD.WaveKey, PD.QtyMoved

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

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      --WL05 S - Check SOH per wave; consume available qty in #T_RelatedWaves priority order
      SET @n_AvailableSOH = 0

      SELECT @n_AvailableSOH = ISNULL(SUM(UCC.Qty), 0)
      FROM UCC (NOLOCK)
      WHERE UCC.Storerkey = @c_StorerKey
      AND   UCC.SKU = @c_SKU
      AND   UCC.[Status] = '1'

      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @n_QtyLeftToFulFill = 0

         SELECT @n_QtyLeftToFulFill = ISNULL(SUM(T.Qty), 0)
         FROM #T_ShortPick T
         WHERE T.Wavekey = @c_GetWavekey

         -- If remaining SOH can fulfill this wave's short qty, proceed; else TL2 and drop wave
         IF @n_AvailableSOH >= @n_QtyLeftToFulFill
         BEGIN
            SET @n_AvailableSOH = @n_AvailableSOH - @n_QtyLeftToFulFill
         END
         ELSE
         BEGIN
            -- Trigger ITF
            SET @CUR_SHORT = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT T.Pickdetailkey, T.Orderkey
            FROM #T_ShortPick T
            WHERE T.Wavekey = @c_GetWavekey

            OPEN @CUR_SHORT

            FETCH NEXT FROM @CUR_SHORT INTO @c_PickDetailKey, @c_Orderkey

            WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
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

               BEGIN TRY
                  UPDATE P
                  SET P.TaskManagerReasonKey = 'SHORT'
                    , P.TrafficCop = NULL
                  FROM PICKDETAIL P
                  WHERE P.PickDetailKey = @c_PickDetailKey
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH

               FETCH NEXT FROM @CUR_SHORT INTO @c_PickDetailKey, @c_Orderkey
            END
            CLOSE @CUR_SHORT
            DEALLOCATE @CUR_SHORT

            DELETE FROM #T_RelatedWaves WHERE WaveKey = @c_GetWavekey   --WL05
         END

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE

      IF NOT EXISTS ( SELECT 1 FROM #T_RelatedWaves )   --WL05
         GOTO QUIT_SP
      --WL05 E
   END
   
   --Reallocate
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @c_StrategykeyParm <> ''
   BEGIN
      --WL05 S
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         -- Update to ALLOC to indicate shorted line
         UPDATE P
         SET P.TaskManagerReasonKey = IIF(P.TaskManagerReasonKey = 'SHORT', P.TaskManagerReasonKey, 'ALLOC')
           , P.TrafficCop = NULL
         FROM PICKDETAIL P
         JOIN #T_ShortPick T ON T.Pickdetailkey = P.PickDetailKey AND T.WaveKey = @c_GetWavekey   --WL05

         BEGIN TRY
            EXEC dbo.ispWaveProcessing @c_WaveKey = @c_GetWavekey -- nvarchar(10)   --WL05
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
         JOIN #T_ShortPick T ON T.Pickdetailkey = P.PickDetailKey AND T.WaveKey = @c_GetWavekey   --WL05

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
      --WL05 E
   END

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      --Initialize Pickdetail work in progress staging table
      --WL05 S
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_GetWavekey   --WL05
                                     , @c_WIP_RefNo = @c_SourceType
                                     , @c_PickCondition_SQL = @c_PickCondition_SQL   --WL04
                                     , @c_Action = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
                                     , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
                                     , @b_Success = @b_Success OUTPUT
                                     , @n_Err = @n_err OUTPUT
                                     , @c_ErrMsg = @c_errmsg OUTPUT

         IF @b_Success <> 1
         BEGIN
            SET @n_Continue = 3
         END

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
      --WL05 E
   END

   -- Delete Packdetail based on CaseID
   -- Clear Caseid for shorted lines
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      INSERT INTO #T_CaseID (CaseID, Storerkey, SKU)
      SELECT SP.CaseID, SP.Storerkey, SP.SKU
      FROM #PickDetail_WIP SP
      JOIN #T_ShortOrders T ON SP.OrderKey = T.OrderKey
      WHERE ( @c_AllowCrossWaveTaskLinking = 'Y' OR SP.WaveKey = @c_Wavekey )   --WL05
      AND SP.UOM = '2'
      AND SP.[Status] = '4'
      AND SP.DropID = @c_UCCNo
      AND SP.Storerkey  = @c_StorerKey
      AND SP.SKU = @c_SKU
      AND (SP.CaseID IS NOT NULL AND SP.CaseID <> '')

      INSERT INTO #T_Packdetail (PickSlipNo, CartonNo)
      SELECT DISTINCT PD.PickSlipNo, PD.CartonNo
      FROM PACKDETAIL PD (NOLOCK)
      JOIN #T_CaseID T ON PD.LabelNo = T.CaseID AND PD.StorerKey = T.Storerkey AND PD.SKU = T.SKU
      
      IF @b_debug = 0
      BEGIN
         BEGIN TRAN
      END

      -- Delete Packdetail
      DELETE PD
      FROM PACKDETAIL PD
      JOIN #T_Packdetail T ON PD.PickSlipNo = T.PickSlipNo AND PD.CartonNo = T.CartonNo

      -- Delete Packinfo
      DELETE PIF
      FROM PACKINFO PIF
      JOIN #T_Packdetail T ON PIF.PickSlipNo = T.PickSlipNo AND PIF.CartonNo = T.CartonNo

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
         WHERE ( @c_AllowCrossWaveTaskLinking = 'Y' OR SP.WaveKey = @c_Wavekey )   --WL05
         AND SP.UOM = '2'
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

   --WL02 S
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @c_Automation = 'Y'
   BEGIN
      --Update UOM & Pickmethod for VAS
      UPDATE #PickDetail_WIP
         SET UOM = '6'
            ,PickMethod = '3'
      FROM #PickDetail_WIP pd
      JOIN dbo.WorkOrderDetail wod (NOLOCK) ON  wod.ExternWorkOrderKey = pd.Orderkey
                                             AND wod.ExternLineNo = pd.OrderLineNumber
      WHERE pd.UOM = '2'
      AND wod.[Type] IN ( 'S02', 'S06', 'J05' )
      AND wod.Qty > 0
   END
   --WL02 E

   -- Redo Pre-cartonization
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SET @CUR_UCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.OrderKey, PD.DropID, Qty = SUM(PD.Qty), PH.PickHeaderKey
      FROM #PickDetail_WIP PD
      JOIN #T_ShortOrders T ON PD.OrderKey = T.OrderKey
      LEFT JOIN PICKHEADER PH (NOLOCK) ON PH.OrderKey = T.OrderKey
      WHERE PD.[Status] NOT IN ('4', '9')
      AND ( @c_AllowCrossWaveTaskLinking = 'Y' OR PD.WaveKey = @c_Wavekey )   --WL05
      AND PD.UOM = '2'
      AND PD.Storerkey  = @c_StorerKey
      AND PD.SKU = @c_SKU
      AND (PD.CaseID IS NULL OR PD.CaseID = '')
      AND (PD.DropID IS NOT NULL AND PD.DropID <> '')
      GROUP BY PD.OrderKey, PD.DropID, PH.PickHeaderKey
      ORDER BY PD.DropID

      OPEN @CUR_UCC

      FETCH NEXT FROM @CUR_UCC INTO @c_Orderkey, @c_UCCNo, @n_PackQty, @c_Pickslipno

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
      BEGIN
         SET @c_Consigneekey = N''
         SET @c_OrderType = N''
         SET @c_LabelNo = N''
         SET @c_LabelLine = N''
         SET @n_TotCartonWeight = 0.00

         -- Generate Pickslip & Pickheader if not exists
         IF ISNULL(@c_Pickslipno, '') = ''
         BEGIN
            EXEC dbo.isp_CreatePickSlip
                   @c_Orderkey = @c_Orderkey
                  ,@c_PickslipType = ''      
                  ,@c_ConsolidateByLoad  = 'N'
                  ,@c_Refkeylookup       = 'N'    
                  ,@c_LinkPickSlipToPick = 'Y'    
                  ,@c_AutoScanIn         = 'N'    
                  ,@b_Success            = @b_Success OUTPUT
                  ,@n_Err                = @n_Err     OUTPUT
                  ,@c_ErrMsg             = @c_ErrMsg  OUTPUT
            
            IF @b_Success <> 1
               SET @n_Continue = 3

            SELECT @c_Pickslipno = PH.PickHeaderKey
            FROM PICKHEADER PH (NOLOCK)
            WHERE PH.Orderkey = @c_Orderkey
         END

         IF @n_Continue IN (1, 2) AND ISNULL(@c_Pickslipno, '') <> ''
         BEGIN
            -- Create packheader
            IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader (NOLOCK) WHERE Pickslipno = @c_Pickslipno)
            BEGIN
               INSERT INTO dbo.PackHeader (Route, OrderKey, OrderRefNo, Loadkey, Consigneekey, StorerKey, PickSlipNo )
               SELECT TOP 1 O.Route, O.Orderkey, '', O.LoadKey, '',O.Storerkey, @c_PickSlipNo
               FROM dbo.PICKHEADER PH (NOLOCK)
               JOIN dbo.ORDERS O (NOLOCK) ON (PH.Orderkey = O.Orderkey)
               WHERE PH.PickHeaderKey = @c_PickSlipNo

               SET @n_Err = @@ERROR

               IF @n_Err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 82018
                  SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(10),@n_Err) + ': Error Insert Packheader Table (msp_ProcessShortPickReAlloc01)' 
                                   + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_Errmsg) + ' ) '
               END
            END
            
            SELECT @c_Consigneekey = O.Consigneekey
                 , @c_OrderType = O.[Type]
            FROM ORDERS O WITH (NOLOCK)
            WHERE O.Orderkey = @c_Orderkey
   
            IF EXISTS ( SELECT 1
                         FROM CODELKUP CL WITH (NOLOCK)
                         WHERE CL.ListName = 'GS1xLabel'
                         AND CL.Code = @c_Consigneekey
                       )
            BEGIN
               IF EXISTS ( SELECT 1
                           FROM CODELKUP CL WITH (NOLOCK)
                           WHERE CL.ListName = 'LVSSTO'
                           AND CL.Storerkey = @c_Storerkey
                           AND CL.Code = @c_Consigneekey
                           AND CL.Short = @c_OrderType
                         )
               BEGIN
                  SET @c_LabelNo = @c_UCCNo
               END
            END
            
            SET @n_CartonNo = 0
            SELECT @n_CartonNo = MAX(CartonNo)
            FROM PACKDETAIL (NOLOCK)
            WHERE Pickslipno = @c_Pickslipno
   
            SET @n_CartonNo = ISNULL(@n_CartonNo, 0) + 1
   
            IF ISNULL(@c_LabelNo, '') = ''
            BEGIN
               EXEC dbo.isp_GenUCCLabelNo_Std
                     @cPickslipNo = @c_Pickslipno,
                     @nCartonNo   = @n_CartonNo,
                     @cLabelNo    = @c_LabelNo  OUTPUT,
                     @b_success   = @b_Success  OUTPUT,
                     @n_err       = @n_Err      OUTPUT,
                     @c_errmsg    = @c_Errmsg   OUTPUT  
            END
   
            SELECT @c_LabelLine = RIGHT('00000' + CAST(CAST(ISNULL(MAX(PD.LabelLine), 0) AS INT) + 1 AS NVARCHAR(5)), 5)
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.Pickslipno = @c_Pickslipno
            AND PD.CartonNo = @n_CartonNo
   
            -- Insert Packdetail
            INSERT INTO dbo.PackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, DropId)
            VALUES (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLine, @c_StorerKey, @c_SKU, @n_PackQty, @c_UCCNo, '')
   
            -- Delete existing Packinfo
            DELETE FROM PACKINFO
            WHERE Pickslipno = @c_PickslipNo
            AND CartonNo = @n_CartonNo
   
            SELECT @n_TotCartonWeight = @n_PackQty * ISNULL(SKU.STDNETWGT, 0)
            FROM SKU (NOLOCK)
            WHERE Storerkey = @c_StorerKey
            AND SKU = @c_SKU
            
            -- Insert Packinfo
            INSERT INTO dbo.PackInfo (Pickslipno, CartonNo, CartonType, Qty, Weight, Cube, Length, Width, Height, RefNo)
            SELECT @c_PickslipNo, @n_CartonNo, '9999', @n_PackQty
                 , CASE WHEN @c_DefaultPackInfoFlag = '1' THEN 0 ELSE @n_TotCartonWeight END
                 , 0, 0, 0, 0, @c_LabelNo
            
            --Update Labelno to Pickdetail.Caseid
            SET @CUR_PICKDET_UPDATE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT PD.PickDetailKey, PD.Qty
               FROM #PICKDETAIL_WIP PD (NOLOCK) 
               WHERE PD.OrderKey = @c_Orderkey
               AND PD.Storerkey = @c_Storerkey
               AND PD.Sku = @c_Sku
               AND (PD.CaseID IS NULL OR PD.CaseID = '')
               AND PD.UOM = '2'
               AND PD.[Status] NOT IN ('4', '9')
               ORDER BY CASE WHEN PD.DropID = @c_UCCNo THEN 1 ELSE 2 END, PD.PickDetailKey
            
            OPEN @CUR_PICKDET_UPDATE
            
            FETCH NEXT FROM @CUR_PICKDET_UPDATE INTO @c_PickDetailKey, @n_PickdetQty
            
            WHILE @@FETCH_STATUS <> -1 AND @n_packqty > 0
            BEGIN
               IF @n_PickdetQty <= @n_packqty
               BEGIN
                  UPDATE #PICKDETAIL_WIP WITH (ROWLOCK)
                  SET CaseId = @c_labelno,
                      UOMQty = CASE WHEN UOM = '6' THEN Qty ELSE UOMQty END
                  WHERE PickDetailKey = @c_PickDetailKey
            
                 SELECT @n_packqty = @n_packqty - @n_PickdetQty
               END
               ELSE
               BEGIN  -- pickqty > packqty
                  SELECT @n_splitqty = @n_PickdetQty - @n_packqty
                  
                  EXECUTE dbo.nspg_GetKey
                  'PICKDETAILKEY',
                  10,
                  @c_NewPickdetailkey OUTPUT,
                  @b_Success OUTPUT,
                  @n_Err OUTPUT,
                  @c_Errmsg OUTPUT
                  
                  IF NOT @b_Success = 1
                  BEGIN
                     SELECT @n_continue = 3
                  END
            
                  INSERT #PICKDETAIL_WIP
                         (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                          Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, Status,
                          DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                          ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
                          WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo, Taskdetailkey, TaskManagerReasonkey, Notes, WIP_Refno, Channel_ID)
                  SELECT @c_newpickdetailkey, '', PD.PickHeaderKey, PD.OrderKey, PD.OrderLineNumber, PD.Lot,
                         PD.Storerkey, PD.Sku, PD.AltSku, PD.UOM, 
                         CASE WHEN PD.UOM = '6' THEN @n_splitqty 
                              WHEN PD.UOM = '2' AND CaseCnt > 0 AND @n_splitqty % CAST(IIF(CaseCnt > 0, CaseCnt, 1) AS INT) = 0 THEN FLOOR(@n_splitqty / CaseCnt) 
                         ELSE PD.UOMQty END , 
                         @n_splitqty, PD.QtyMoved, PD.Status,
                         PD.DropID, PD.Loc, PD.ID, PD.PackKey, PD.UpdateSource, PD.CartonGroup, PD.CartonType,
                         PD.ToLoc, PD.DoReplenish, PD.ReplenishZone, PD.DoCartonize, PD.PickMethod,
                         PD.WaveKey, PD.EffectiveDate, '9', PD.ShipFlag, PD.PickSlipNo, PD.TaskDetailKey, PD.TaskManagerReasonKey, 
                         '*RefPickKey: ' + @c_PickDetailKey + ' Qty: ' + CONVERT(NVARCHAR(10), @n_splitqty),   --WL02
                         PD.WIP_Refno, PD.Channel_ID
                  FROM #PickDetail_WIP PD (NOLOCK)
                  JOIN dbo.SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
                  JOIN dbo.PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
                  WHERE PD.PickDetailKey = @c_PickDetailKey
                     
                  UPDATE #PICKDETAIL_WIP 
                  SET CaseID = @c_labelno,
                      Qty = @n_packqty,
                      UOMQty = 
                      CASE WHEN UOM = '6' THEN @n_packqty 
                           WHEN UOM = '2' AND CaseCnt > 0 AND @n_packqty % CAST(IIF(CaseCnt > 0, CaseCnt, 1) AS INT) = 0 THEN FLOOR(@n_packqty / CaseCnt) 
                      ELSE UOMQty END,
                      Notes = '*PickDetailKey: ' + @c_PickDetailKey + ' Qty: ' + CONVERT(NVARCHAR(10), @n_packqty)   --WL02
                      --UOMQTY = CASE UOM WHEN '6' THEN @n_packqty ELSE UOMQty END
                  FROM #PICKDETAIL_WIP 
                  JOIN dbo.SKU (NOLOCK) ON #PICKDETAIL_WIP .Storerkey = SKU.Storerkey AND #PICKDETAIL_WIP .Sku = SKU.Sku
                  JOIN dbo.PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
                  WHERE PickDetailKey = @c_PickDetailKey
            
                  SELECT @n_packqty = 0
               END
               FETCH NEXT FROM @CUR_PICKDET_UPDATE INTO @c_PickDetailKey, @n_PickdetQty
            END
            CLOSE @CUR_PICKDET_UPDATE
            DEALLOCATE @CUR_PICKDET_UPDATE
         END

         FETCH NEXT FROM @CUR_UCC INTO @c_Orderkey, @c_UCCNo, @n_PackQty, @c_Pickslipno
      END
      CLOSE @CUR_UCC
      DEALLOCATE @CUR_UCC
   END

   --Compare Pickdetail Line
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      --WL05 S
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      WHERE NOT EXISTS ( SELECT 1
                         FROM #PickDetail_WIP P
                         WHERE P.Storerkey = @c_StorerKey
                         AND   P.Sku = @c_SKU
                         AND   P.Wavekey = R.Wavekey
                         AND   P.[Status] < '4' 
                         AND NOT EXISTS ( SELECT 1
                                           FROM #T_PICKDETAIL_CURRENT T
                                           WHERE T.Pickdetailkey = P.PickDetailKey )
                       )
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         -- ReAllocStatus
         -- 0 - Not Allocated after shorted
         -- Trigger ITF
         SET @CUR_SHORT = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT T.Pickdetailkey, T.Orderkey
         FROM #T_ShortPick T
         WHERE T.Wavekey = @c_GetWavekey

         OPEN @CUR_SHORT

         FETCH NEXT FROM @CUR_SHORT INTO @c_PickDetailKey, @c_Orderkey

         WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
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

            BEGIN TRY
               UPDATE P
               SET P.TaskManagerReasonKey = 'SHORT'
                 , P.TrafficCop = NULL
               FROM PICKDETAIL P
               WHERE P.PickDetailKey = @c_PickDetailKey
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @c_ErrMsg = ERROR_MESSAGE()
            END CATCH

            UPDATE P
            SET P.TaskManagerReasonKey = 'SHORT'
            FROM #PickDetail_WIP P
            WHERE P.PickDetailKey = @c_PickDetailKey

            FETCH NEXT FROM @CUR_SHORT INTO @c_PickDetailKey, @c_Orderkey
         END
         CLOSE @CUR_SHORT
         DEALLOCATE @CUR_SHORT

         --GOTO UPD_PD
         DELETE FROM #PICKDETAIL_WIP WHERE Wavekey = @c_GetWavekey
         DELETE FROM #T_RelatedWaves WHERE WaveKey = @c_GetWavekey

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
      --WL05 E

      IF NOT EXISTS (SELECT 1 FROM #T_RelatedWaves)
         GOTO UPD_PD
   END
   
   --Initialize Data - Copy from mspRLWAV03
   IF @n_Continue IN (1,2) AND @c_Automation = 'Y'                 
   BEGIN
      --WL02 S - Move up
      ----Update UOM & Pickmethod for VAS
      --UPDATE #PickDetail_WIP
      --   SET UOM = '6'
      --      ,PickMethod = '3'
      --FROM #PickDetail_WIP pd
      --JOIN dbo.WorkOrderDetail wod (NOLOCK) ON  wod.ExternWorkOrderKey = pd.Orderkey
      --                                       AND wod.ExternLineNo = pd.OrderLineNumber
      --WHERE pd.UOM = '2'
      --AND wod.[Type] IN ( 'S02', 'S06', 'J05' )
      --AND wod.Qty > 0
      --WL02 E - Move up

      INSERT INTO #T_ORDERSKU (Orderkey, Storerkey, SKU, WCS)
      SELECT DISTINCT P.OrderKey, P.Storerkey, P.SKU, 0
      FROM #PickDetail_WIP P
      --WL05 S
      WHERE EXISTS ( SELECT 1
                     FROM #T_ShortOrders T
                     WHERE T.OrderKey = P.OrderKey )
      --WL05 E
      AND P.UOM IN ('2','6')
      --AND P.UOM IN ('2')
      AND (P.TaskDetailKey = '' OR P.TaskDetailKey IS NULL)
      AND P.[Status] = '0'
      AND P.Storerkey  = @c_StorerKey
      AND P.SKU = @c_SKU
      AND (P.DropID <> '' AND P.DropID IS NOT NULL)

      SET @c_WCSPack = ''

      SELECT @c_WCSPack = ISNULL(cl.Short,'') 
      FROM CODELKUP cl (NOLOCK)
      WHERE cl.ListName = 'WCSCTNIZE'

      IF @c_WCSPack IN ( '', 'Y' ) -- Full WCS Cartonizartion: Not Setup OR Setup with 'Y'
      BEGIN
         UPDATE #T_ORDERSKU
            SET WCS = 1
         FROM #T_ORDERSKU os
         JOIN SKUInfo si (NOLOCK) ON  si.Storerkey = os.Storerkey          
                                  AND si.Sku = os.Sku 
         WHERE si.ExtendedField06 = 'sortable' 
         AND   si.ExtendedField07 = 'conveyable'
      END
      ELSE IF @c_WCSPack = 'N'
      BEGIN
         UPDATE #T_ORDERSKU
            SET WCS = 1
         FROM #T_ORDERSKU os
         JOIN SKUInfo si (NOLOCK) ON  si.Storerkey = os.Storerkey          
                                  AND si.Sku = os.Sku 
         WHERE si.ExtendedField06 = 'sortable' 
         AND   si.ExtendedField07 = 'conveyable'
         AND   NOT EXISTS (   SELECT 1 FROM dbo.WorkOrderDetail wod (NOLOCK)
                              WHERE wod.ExternWorkOrderKey = os.Orderkey
                              AND wod.Qty > 0
                           )

         -- WCSPACKREQ type need WCS but with 'WCSCTNIZE' = 'N', this type unable to do
         -- WCS correctly. WCS cartonizaton if all workorder types are not found in 'WCSPACKREQ'
         UPDATE #T_ORDERSKU
            SET WCS = 1
         FROM #T_ORDERSKU os
         JOIN SKUInfo si (NOLOCK) ON  si.Storerkey = os.Storerkey          
                                  AND si.Sku = os.Sku 
         WHERE si.ExtendedField06 = 'sortable' 
         AND   si.ExtendedField07 = 'conveyable'
         AND   NOT EXISTS (SELECT 1 FROM dbo.WorkOrderDetail wod (NOLOCK) 
                           JOIN CODELKUP cl (NOLOCK) ON cl.ListName = 'WCSPACKREQ'
                                                    AND cl.Short = wod.[Type]
                           WHERE wod.ExternWorkOrderKey = os.Orderkey
                           AND wod.Qty > 0 ) 
      END
   END

   --Taskdetail Creation - Copy from mspRLWAV03
   IF @n_Continue IN (1,2) AND @c_Automation = 'Y'                 
   BEGIN
      IF @b_debug = 0
      BEGIN
         BEGIN TRAN
      END

      --------------------------------------
      -- GEN PICK OR REPL TASK 
      --------------------------------------
      IF @n_Continue IN (1,2)                                                                             
      BEGIN
         SET @CUR_PTASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
         SELECT P.WaveKey
              , Orderkey = CASE WHEN P.UOM = '2' THEN P.Orderkey ELSE '' END
              , OrderLineNumber = CASE WHEN P.UOM = '2' THEN P.OrderLineNumber ELSE '' END
              , P.Storerkey, P.Sku, P.LOT, P.LOC, P.ID
              , Qty = SUM(P.Qty)
              , P.UOM, P.PickMethod, P.Dropid, P.CaseID, OD.WCS
              , L.LogicalLocation, L.LocationType, L.PutawayZone
         FROM #PickDetail_WIP P
         JOIN #T_ORDERSKU OD ON  OD.Orderkey = P.Orderkey
                             AND OD.Storerkey = P.Storerkey
                             AND OD.Sku = P.Sku
         JOIN LOC L (NOLOCK) ON L.Loc = P.Loc
         --WL05 S
         WHERE EXISTS ( SELECT 1
                        FROM #T_ShortOrders T
                        WHERE T.OrderKey = P.OrderKey )
         --WL05 E
         AND P.UOM IN ('2','6')
         --AND P.UOM IN ('2')
         AND (P.TaskDetailKey = '' OR P.TaskDetailKey IS NULL)
         AND P.[Status] = '0'
         AND (P.DropID <> '' AND P.DropID IS NOT NULL)
         GROUP BY P.WaveKey
               ,  CASE WHEN P.UOM = '2' THEN P.Orderkey ELSE '' END
               ,  CASE WHEN P.UOM = '2' THEN P.OrderLineNumber ELSE '' END
               ,  P.Storerkey
               ,  P.Sku
               ,  P.LOT
               ,  P.LOC
               ,  P.ID
               ,  P.UOM
               ,  P.PickMethod
               ,  P.Dropid
               ,  P.CaseID
               ,  OD.WCS
               ,  L.LogicalLocation
               ,  L.LocationType
               ,  L.PutawayZone
         ORDER BY P.UOM
               ,  CASE WHEN P.UOM = '2' THEN P.Orderkey ELSE '' END
               ,  CASE WHEN P.UOM = '2' THEN P.OrderLineNumber ELSE '' END
               ,  P.PickMethod
               ,  P.Sku
      
         OPEN @CUR_PTASK
      
         FETCH NEXT FROM @CUR_PTASK INTO @c_GetWavekey, @c_Orderkey, @c_OrderLineNumber   --WL05
                                       , @c_Storerkey, @c_Sku, @c_LOT, @c_FromLOC, @c_ID, @n_PickdetQty 
                                       , @c_UOM, @c_PickMethod, @c_DropId, @c_LabelNo, @b_WCS
                                       , @c_FromLogicalLoc, @c_FromLocType, @c_FromPAZone
      
         WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
         BEGIN
            SET @c_TaskStatus    = '0'
            SET @c_ToLoc         = ''
            SET @c_ToLocType     = ''
            SET @c_ToLocCategory = ''
            SET @c_ToPAZone      = ''  
            SET @c_FinalLoc      = ''
            SET @b_InsertTask    = 1
            
            IF @c_UOM = '2'
            BEGIN
               IF @b_WCS = 0
               BEGIN
                  SET @c_TaskType      = 'FCP'
                  SET @c_PickMethod_TD = 'PP'
                  SET @c_ToLocType     = 'PackWCS'
                  SET @c_ToLocCategory = 'Stage'
                  SET @c_ToPAZone      = 'VAS'

                  IF EXISTS ( SELECT 1
                              FROM dbo.WorkOrderDetail wod (NOLOCK)
                              WHERE wod.[Type] = ''
                              AND   wod.ExternWorkOrderKey = @c_Orderkey
                              AND   wod.ExternLineNo = @c_OrderLineNumber
                              )
                  BEGIN
                     SET @c_ToLocType = 'StageWCS'
                     SET @c_ToPAZone = 'PCB'
                  END
                  
                  SELECT TOP 1 @c_ToLoc = l.Loc
                  FROM LOC l (NOLOCK) 
                  WHERE l.Facility = @c_Facility
                  AND   l.LocationType = @c_ToLocType
                  AND   l.LocationCategory = @c_ToLocCategory
                  AND   l.PutawayZone = @c_ToPAZone
                  ORDER BY l.loc
               END
               ELSE
               BEGIN
                  IF @c_FromLocType = 'CASE'
                  BEGIN
                     SET @c_PNDLoc = ''
                     SELECT @c_PNDLoc = ISNULL(PZ.OutLoc, '')
                     FROM LOC L1 WITH (NOLOCK)
                     JOIN PutawayZone PZ WITH (NOLOCK) ON L1.PutawayZone = PZ.PutawayZone
                     WHERE L1.Loc = @c_FromLOC   --Pickdetail.Loc

                     -- Replenishment PND Lane is missing
                     IF @c_PNDLoc = ''
                     BEGIN
                        SET @n_Continue = 3
                        SET @n_Err = 82019
                        SET @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                      + ': Missing PND Location setup (PutawayZone.OutLoc) for Location "'+ @c_FromLOC + '". (msp_ProcessShortPickReAlloc01)'     
                        GOTO QUIT_SP   
                     END

                     SET @c_LocType_PND = ''
                     SET @c_LocFac_PND = ''
                     SELECT @c_LocType_PND = L2.LocationType
                          , @c_LocFac_PND  = L2.Facility 
                     FROM LOC L2 WITH (NOLOCK) 
                     WHERE L2.Loc = @c_PNDLoc
 
                     IF @c_LocType_PND <> 'PND' OR @c_LocFac_PND <> @c_Facility
                     BEGIN 
                        SET @n_Continue = 3
                        SET @n_Err = 82020
                        SET @c_Errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                                      + ': None PND Location / Unmatch PND Facility Found. (msp_ProcessShortPickReAlloc01)'     
                        GOTO QUIT_SP             
                     END

                     SET @c_TaskType      = 'RPF'
                     SET @c_PickMethod_TD = 'PP'
                     SET @c_ToLoc         = @c_PNDLoc
                  END
               END
            END
            ELSE IF @c_UOM = '6'
            BEGIN
               IF @c_PickMethod IN ('C', '3')              
               BEGIN
                  IF @b_WCS = 0 AND @c_DropID = ''
                  BEGIN
                     SET @c_TaskType      = 'ASTCPK'
                     SET @c_PickMethod_TD = 'B2B-Loose'
                     SET @c_TaskStatus    = '0'

                     SELECT TOP 1 @c_ToLoc = l.Loc
                     FROM LOC l (NOLOCK)
                     WHERE l.Facility = @c_Facility
                     AND   l.LocationType = 'PackWCS'
                     AND   l.LocationCategory = 'Stage'
                     AND   l.PutawayZone = 'VAS'
                  END
                  ELSE IF @b_WCS = 0 AND @c_DropID <> ''
                  BEGIN
                     SET @c_TaskType      = 'RPF'
                     SET @c_PickMethod_TD = 'PP'

                     SELECT TOP 1 @c_ToLoc = LOC.Loc 
                     FROM dbo.SKUXLOC sl (NOLOCK) 
                     JOIN dbo.LOC LOC (NOLOCK) ON loc.loc = sl.loc
                     LEFT OUTER JOIN dbo.LOTxLOCxID lli (NOLOCK) ON  lli.StorerKey = SL.StorerKey 
                                                                 AND lli.sku = SL.SKU 
                                                                 AND lli.loc = sl.loc
                     WHERE sl.SKU = @c_Sku
                     AND sl.StorerKey = @c_StorerKey
                     AND sl.LocationType = 'PICK'
                     AND loc.Facility = @c_Facility
                     AND loc.LocationFlag NOT IN ('DAMAGE','HOLD')  
                     AND loc.MaxCarton > 0
                     GROUP BY LOC.Loc, loc.LogicalLocation, LOC.LocAisle
                     HAVING SUM(ISNULL(lli.Qty - lli.QtyPicked + lli.PendingMoveIn,0)) 
                            + @n_PickdetQty <= MAX(sl.QtyLocationLimit)
                     ORDER BY loc.LogicalLocation

                     IF @c_ToLoc = ''
                     BEGIN
                        SELECT TOP 1 @c_ToLoc = loc.Loc 
                        FROM LOC LOC (NOLOCK) 
                        JOIN LOTxLOCxID LLI (NOLOCK) ON LLI.Loc = LOC.Loc
                        WHERE lli.SKU = @c_Sku
                        AND lli.StorerKey = @c_StorerKey
                        AND loc.LocationType = 'DYNAMICPK'
                        AND loc.Facility = @c_Facility
                        AND loc.LocationFlag NOT IN ('DAMAGE','HOLD')  
                        AND loc.MaxCarton > 0
                        AND (LLI.Qty - LLI.QtyPicked + LLI.PendingMoveIn) > 0    
                        GROUP BY loc.Loc, loc.MaxCarton, loc.LogicalLocation, LOC.LocAisle
                        HAVING CEILING(SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIn)/@n_PickdetQty) < LOC.MaxCarton
                        ORDER BY loc.LogicalLocation
                     END

                     -- Find Empty in DP loc can fit in
                     IF @c_ToLoc = ''
                     BEGIN
                        SELECT TOP 1 
                           @c_ToLoc = loc.Loc 
                        FROM LOC loc (NOLOCK)
                        LEFT OUTER JOIN LOTxLOCxID lli (NOLOCK)  ON  loc.loc = lli.loc
                        WHERE loc.LocationType = 'DYNAMICPK'
                        AND  loc.Facility = @c_Facility
                        AND loc.LocationFlag NOT IN ('DAMAGE','HOLD')  
                        AND loc.MaxCarton > 0
                        GROUP BY loc.Loc, loc.LogicalLocation, LOC.LocAisle
                        HAVING SUM(ISNULL(lli.Qty,0) - ISNULL(lli.QtyPicked,0) + ISNULL(lli.PendingMoveIn,0)) = 0
                        ORDER BY loc.LogicalLocation
                     END

                     IF @c_ToLoc = ''
                     BEGIN
                        SET @n_Continue = 3
                        SET @n_err = 82019
                        SET @c_errmsg='NSQL' + CONVERT(char(6), @n_err) 
                                     + ':No empty dynamic/pick face location available for SKU. (msp_ProcessShortPickReAlloc01)'
                     END

                     IF @n_Continue = 1
                     BEGIN
                        SELECT TOP 1 @c_FinalLoc = l.Loc
                        FROM LOC l (NOLOCK)
                        WHERE l.Facility = @c_Facility
                        AND   l.LocationType = 'PackWCS'
                        AND   l.LocationCategory = 'Stage'
                        AND   l.PutawayZone = 'VAS'
                     END
                  END
                  ELSE IF @b_WCS = 1 AND @c_DropID <> ''
                  BEGIN 
                     SET @c_TaskType      = 'RPF'
                     SET @c_PickMethod_TD = 'PP'
                     
                     IF @c_FromLocType    = 'CASE'
                     BEGIN
                        SET @c_PNDLoc = ''
                        SELECT @c_PNDLoc = ISNULL(PZ.OutLoc, '')
                        FROM LOC L1 WITH (NOLOCK)
                        JOIN PutawayZone PZ WITH (NOLOCK) ON L1.PutawayZone = PZ.PutawayZone
                        WHERE L1.Loc = @c_FromLOC   --Pickdetail.Loc
                        
                        -- Replenishment PND Lane is missing
                        IF @c_PNDLoc = ''
                        BEGIN
                           SET @n_Continue = 3
                           SET @n_Err = 82036
                           SET @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                         + ': Missing PND Location setup (PutawayZone.OutLoc) for Location "'+ @c_FromLOC + '". (msp_ProcessShortPickReAlloc01)'     
                           GOTO QUIT_SP   
                        END

                        SET @c_LocType_PND = ''
                        SET @c_LocFac_PND = ''
                        SELECT @c_LocType_PND = L2.LocationType
                             , @c_LocFac_PND  = L2.Facility 
                        FROM LOC L2 WITH (NOLOCK) 
                        WHERE L2.Loc = @c_PNDLoc

                        IF @c_LocType_PND <> 'PND' OR @c_LocFac_PND <> @c_Facility
                        BEGIN 
                           SET @n_Continue = 3
                           SET @n_Err = 82037
                           SET @c_Errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                                         + ': None PND Location / Unmatch PND Facility Found. (msp_ProcessShortPickReAlloc01)'     
                           GOTO QUIT_SP             
                        END

                        SET @c_ToLoc    = @c_PNDLoc
                     END
                     ELSE IF @c_FromLocType = 'PickWCS' AND  @c_PickMethod = '3' 
                     BEGIN
                        SET @c_TaskType      = 'ASTCPK'
                        SET @c_PickMethod_TD = 'B2B-Loose'

                        SELECT TOP 1 @c_ToLoc = ISNULL(cl.long,'')
                        FROM CODELKUP cl (NOLOCK)
                        WHERE ListName = 'BBDefLoc'
                        AND Code  = '3'
                        AND Short = @c_Facility
                        AND Storerkey = @c_Storerkey
                     END
                  END
               END   
            END

            IF @n_Continue = 1 AND @c_ToLoc > '' 
            BEGIN
               SELECT @c_AreaKey = ad.AreaKey
               FROM AreaDetail ad (NOLOCK)
               WHERE ad.PutawayZone =  @c_FromPAZone
               
               IF @c_TaskType = 'RPF'
               BEGIN 
                  SET @b_InsertTask = 1
                  SET @c_NewTaskdetailKey = ''

                  IF EXISTS(SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                            WHERE WaveKey = @c_GetWavekey   --WL05
                            AND TaskType = 'RPF'
                            AND Caseid = CASE WHEN @c_DropId = '' THEN @c_LabelNo ELSE @c_DropId END
                            AND FromLoc = @c_FromLoc) AND @c_AllowCrossWaveTaskLinking = 'N'   --WL05
                  BEGIN
                     SET @b_InsertTask = 0
                  END

                  --WL05 S
                  IF @c_AllowCrossWaveTaskLinking = 'Y' AND @b_InsertTask = 1
                  BEGIN
                     SET @c_NewTaskdetailKey  = ''
                     SELECT @c_NewTaskdetailKey = MIN(TD.TaskdetailKey)
                     FROM TASKDETAIL TD WITH (NOLOCK)
                     WHERE TD.Storerkey = @c_Storerkey
                     AND TD.TaskType = 'RPF'
                     AND TD.Caseid = CASE WHEN @c_DropId = '' THEN @c_LabelNo ELSE @c_DropId END
                     AND TD.FromLoc = @c_FromLoc
                     AND (TD.[Status] < '5' OR TD.[Status] = 'H')

                     IF @c_NewTaskdetailKey > ''
                     BEGIN
                        SET @b_InsertTask = 2
                     END
                  END
                  --WL05 E
                  
                  SELECT @n_PickdetQty = SUM(UCC.Qty) 
                  FROM UCC (NOLOCK)
                  WHERE UCC.Storerkey = @c_Storerkey
                  AND   UCC.UCCNo = @c_DropID
                  AND   UCC.[Status] = '3'
                  
                  IF ISNULL(@n_PickdetQty, 0) = 0
                  BEGIN
                     SET @n_Continue = 3
                     SET @n_err = 82035
                     SET @c_errmsg = 'NSQL' + CONVERT(char(6), @n_err) 
                                    + ': Cannot get UCC qty for RPF task.'
                                    + ' Please check if UCC# ' + TRIM(@c_DropID) + ' exists. (msp_ProcessShortPickReAlloc01)'
                     GOTO QUIT_SP
                  END
               END

               IF @b_InsertTask = 1
               BEGIN
                  SET @b_success = 1
                  EXECUTE dbo.nspg_Getkey
                     @KeyName       = 'TaskDetailKey'
                  ,  @fieldlength   =  10
                  ,  @keystring     =  @c_NewTaskdetailKey OUTPUT
                  ,  @b_Success     =  @b_success       OUTPUT
                  ,  @n_err         =  @n_err           OUTPUT
                  ,  @c_errmsg      =  @c_errmsg        OUTPUT
   
                  IF @b_success <> 1
                  BEGIN
                     SET @n_Continue = 3
                  END  
                  
                  IF @n_Continue = 1
                  BEGIN
                     SET @c_RefTaskkey = ''
                     IF @c_ToLoc <> @c_FinalLoc AND @c_FinalLoc > ''
                     BEGIN
                        SET @c_RefTaskkey = @c_NewTaskdetailKey
                     END
   
                     SET @n_PendingMoveIn = 0
                     IF @c_TaskType = 'RPF' 
                     BEGIN
                        SET @n_PendingMoveIn = @n_PickdetQty
                     END
   
                     INSERT dbo.TASKDETAIL
                           ( TaskDetailKey, TaskType, Storerkey, Sku, Lot
                           , UOM, UOMQty, Qty, FromLoc, LogicalFromLoc, FromID, ToLoc, LogicalToLoc
                           , ToId, SourceType, SourceKey, Caseid, Priority
                           , SourcePriority, OrderKey, OrderLineNumber, PickDetailKey
                           , PickMethod, STATUS, WaveKey, Areakey, Message01, Message02
                           , SystemQty, PendingMoveIn, FinalLoc, GroupKey, RefTaskKey)  
                     VALUES (
                       @c_NewTaskdetailKey
                     , @c_TaskType
                     , @c_Storerkey
                     , @c_Sku
                     , @c_Lot -- Lot,
                     , @c_UOM -- UOM
                     , @n_PickdetQty  -- UOMQty,
                     , @n_PickdetQty
                     , @c_Fromloc
                     , @c_FromLogicalLoc
                     , @c_ID
                     , @c_ToLoc
                     , @c_ToLoc
                     , @c_ID
                     , @c_SourceType
                     , '' --SourceKey
                     , CASE WHEN @c_DropId = '' THEN @c_LabelNo ELSE @c_DropId END
                     , '5' -- Priority
                     , '9' -- SourcePriority
                     , '' -- Orderkey,
                     , '' -- OrderLineNumber
                     , '' -- PickDetailKey
                     , @c_PickMethod_TD
                     , @c_TaskStatus  --Status
                     , @c_GetWavekey   --WL05
                     , @c_AreaKey
                     , ''
                     , @c_Message02
                     , @n_PickdetQty
                     , @n_PendingMoveIn
                     , @c_FinalLoc      
                     , ''
                     , @c_RefTaskkey
                     )  
   
                     SET @n_err = @@ERROR
                     IF @n_err <> 0
                     BEGIN
                        SET @n_Continue = 3
                        SET @c_ErrMsg = CONVERT(CHAR(250), @n_err)
                        SET @n_err = 82015
                        SET @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) + ': Insert Into TaskDetail Failed (msp_ProcessShortPickReAlloc01)'  
                                       +    ' ( '+' SQLSvr MESSAGE= ' + @c_ErrMsg + ' ) '
                     END
                  END
               END

               IF @n_Continue IN (1,2) AND @b_InsertTask IN (1, 2)   --WL05
               BEGIN
                  SET @CUR_UPDATEPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
                  SELECT P.PickDetailKey, PDSourceType = '1'
                  FROM #PickDetail_WIP P
                  WHERE P.UOM = @c_UOM
                  AND   P.PickMethod = @c_PickMethod
                  AND   P.Lot = @c_Lot
                  AND   P.Loc = @c_FromLoc
                  AND   P.ID  = @c_ID
                  AND   P.DropID  = @c_DropID
                  --WL05 S
                  AND   ( @c_AllowCrossWaveTaskLinking = 'Y' OR P.Wavekey = @c_GetWavekey )
                  AND   ( P.TaskDetailKey IS NULL OR P.TaskDetailKey = '' )
                  UNION
                  SELECT P.PickDetailKey, PDSourceType = '2'
                  FROM dbo.PICKDETAIL P WITH (NOLOCK)
                  WHERE P.UOM = @c_UOM
                  AND   P.PickMethod = @c_PickMethod
                  AND   P.Lot = @c_Lot
                  AND   P.Loc = @c_FromLoc
                  AND   P.ID  = @c_ID
                  AND   P.DropID = @c_DropID
                  AND   P.[Status] < '5'
                  AND   P.Storerkey = @c_Storerkey
                  AND   P.SKU = @c_SKU
                  AND   @c_AllowCrossWaveTaskLinking = 'Y'
                  AND   (P.TaskDetailKey IS NULL OR P.TaskDetailKey = '')
                  AND   NOT EXISTS ( SELECT 1
                                     FROM #PickDetail_WIP pw
                                     WHERE pw.PickDetailKey = P.PickDetailKey )
                  ORDER BY PDSourceType, PickDetailKey
                  --WL05 E

                  OPEN @CUR_UPDATEPD

                  FETCH NEXT FROM @CUR_UPDATEPD INTO @c_PickDetailKey, @c_PDSourceType   --WL05
         
                  WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
                  BEGIN
                     --WL05 S
                     IF @c_PDSourceType = '1'
                     BEGIN
                        UPDATE #PickDetail_WIP
                        SET TaskDetailKey = @c_NewTaskdetailKey 
                        WHERE PickDetailKey = @c_PickDetailKey
                     END
                     ELSE IF @c_PDSourceType = '2'
                     BEGIN
                        UPDATE PICKDETAIL
                        SET TaskDetailKey = @c_NewTaskdetailKey
                          , TrafficCop = NULL
                          , EditDate = dbo.fnc_GetDate()
                          , EditWho = dbo.fnc_GetUserName()
                        WHERE PickDetailKey = @c_PickDetailKey
                     END
                     --WL05 E

                     SET @n_err = @@ERROR
                     IF @n_err <> 0
                     BEGIN
                        SET @n_Continue = 3
                        SET @c_ErrMsg = CONVERT(CHAR(250), @n_err)
                        SET @n_err = 82016
                        SET @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) + ': Updating PickDetail Failed (msp_ProcessShortPickReAlloc01)'  
                                       + ' ( '+' SQLSvr MESSAGE= ' + @c_ErrMsg + ' ) '
                     END
                     FETCH NEXT FROM @CUR_UPDATEPD INTO @c_PickDetailKey, @c_PDSourceType   --WL05
                  END
                  CLOSE @CUR_UPDATEPD
                  DEALLOCATE @CUR_UPDATEPD
               END
            END
            FETCH NEXT FROM @CUR_PTASK INTO @c_GetWavekey, @c_Orderkey, @c_OrderLineNumber   --WL05
                                          , @c_Storerkey, @c_Sku, @c_LOT, @c_FromLOC, @c_ID, @n_PickdetQty  
                                          , @c_UOM, @c_PickMethod, @c_DropId, @c_LabelNo, @b_WCS
                                          , @c_FromLogicalLoc, @c_FromLocType, @c_FromPAZone 
         END
         CLOSE @CUR_PTASK
         DEALLOCATE @CUR_PTASK
      END

      IF @b_debug = 0 AND @n_Continue IN (1,2)
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
   END

   UPD_PD:
   --Update pickdetail_WIP work in progress staging table back to pickdetail 
   IF (@n_Continue = 1 or @n_Continue = 2)
   BEGIN
      --WL05 S
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_GetWavekey   --WL05
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

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
      --WL05 E
   END

   --Delete pickdetail_WIP work in progress staging table    
   IF (@n_Continue = 1 or @n_Continue = 2)
   BEGIN
      --WL05 S
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_GetWavekey   --WL05
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

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
      --WL05 E
   END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#T_ShortOrders ','u') IS NOT NULL 
      DROP TABLE #T_ShortOrders

   IF OBJECT_ID('tempdb..#T_ShortPick ','u') IS NOT NULL 
      DROP TABLE #T_ShortPick

   IF OBJECT_ID('tempdb..#T_ORDERSKU ','u') IS NOT NULL 
      DROP TABLE #T_ORDERSKU

   IF OBJECT_ID('tempdb..#T_CaseID ','u') IS NOT NULL 
      DROP TABLE #T_CaseID

   IF OBJECT_ID('tempdb..#T_Packdetail ','u') IS NOT NULL 
      DROP TABLE #T_Packdetail

   --WL05 S
   IF OBJECT_ID('tempdb..#T_RelatedWaves ','u') IS NOT NULL 
      DROP TABLE #T_RelatedWaves
   --WL05 E
      
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'msp_ProcessShortPickReAlloc01'   --WL01
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
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc01] TO [NSQL]
GO
