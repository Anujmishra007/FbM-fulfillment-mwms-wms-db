SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: msp_ProcessShortPickReAlloc07                      */
/* Creation Date: 06-Jul-2026                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-13788 - AEOMX Reallocation SP                           */  
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
/* 09-Jul-2026 WLChooi  1.0   Initial Version                           */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc07] (    
       @c_Wavekey          NVARCHAR(10)   = ''
     , @c_SKU              NVARCHAR(20)   = ''
     , @c_UCCNo            NVARCHAR(20)   = ''
     , @c_Taskdetailkey    NVARCHAR(10)
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
   -- General    
   DECLARE @n_Continue                 INT = 1
         , @n_StartTCnt                INT
         , @c_StorerKey                NVARCHAR(15) = ''
         , @c_SourceKey                NVARCHAR(50) = ''
         , @c_StrategykeyParm          NVARCHAR(10) = ''
         , @c_SourceType               NVARCHAR(30) = ''
         , @c_PickDetailKey            NVARCHAR(18) = ''
         , @c_Facility                 NVARCHAR(5)  = ''
         , @c_TaskType                 NVARCHAR(10) = ''
         , @c_PickCondition_SQL        NVARCHAR(MAX) = ''
         , @c_GetWavekey               NVARCHAR(10) = ''
         , @CUR_WAVE                   CURSOR
         , @n_ByUCC                    INT = 0
         , @c_ExceptionReason          NVARCHAR(10) = ''
         , @c_ExceptionCode            NVARCHAR(10) = ''
         , @c_GetUCCNo                 NVARCHAR(20) = ''
         , @c_GetFromLoc               NVARCHAR(10) = ''
         , @c_GetFromID                NVARCHAR(18) = ''
         , @c_HoldLoc                  NVARCHAR(10) = ''
         , @c_HoldUCC                  NVARCHAR(20) = ''
         , @CUR_UNALLOC                CURSOR
         , @n_TotalNewAllocQty         INT = 0
         , @n_TotalShortCaseQty        INT = 0
         , @n_TotalShortPickQty        INT = 0
         , @n_RemoveShort              INT = 0
         , @c_outstring                NVARCHAR(255) = ''
         , @c_UserKey                  NVARCHAR(18) = ''
         , @c_TaskStatus               NVARCHAR(10) = ''
         , @c_AlertMessage             NVARCHAR(255) = ''
         , @c_ModuleName               NVARCHAR(30) = ''
         , @c_DoCycleCount             NVARCHAR(1) = ''
         , @c_TaskDetailKeyCC          NVARCHAR(10) = ''
         , @c_CCKey                    NVARCHAR(10) = ''
         , @n_UCCRowRef                BIGINT = 0

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   SET @c_SourceKey = @c_Wavekey
   SET @c_StrategykeyParm = ''
   SET @c_SourceType = 'msp_ProcessShortPickReAlloc07'

   /*
   UOM 2 - SHORTAEOMX
   UOM 6 - SHORTAEOMX / SPLITAEOMX

   Locus (IML always splits before QCmd, including full short):
     - Original taskdetail: picked qty, Status='9'
     - Split taskdetail:    remaining short qty, Status='9', Message01='SHORT', ReasonKey='SHORTAEOMX'
     - QCmd passes split @c_Taskdetailkey -> mirror alert + CC (nspRFRSN01 rejects Status='9')

   RDT failover:
     - rdtfnc_TM_* reason screen already called nspRFRSN01 -> skip when CC exists
   */
   
   IF @n_Continue = 1
   BEGIN
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
      )

      CREATE INDEX IX_PickDetail_WIP_OrderKey_Status ON #PickDetail_WIP (OrderKey, [Status]) INCLUDE (Qty, QtyMoved, PickDetailKey)
      CREATE INDEX IX_PickDetail_WIP_WaveKey_UOM_Status ON #PickDetail_WIP (WaveKey, UOM, [Status]) INCLUDE (OrderKey, Storerkey, SKU, TaskDetailKey)
      CREATE INDEX IX_PickDetail_WIP_TaskUpdate ON #PickDetail_WIP (UOM, PickMethod, Lot, Loc, ID, DropID) INCLUDE (PickDetailKey)

      CREATE TABLE #T_PICKDETAIL_SHORT
      (
         Pickdetailkey NVARCHAR(18) PRIMARY KEY
      )
      
      CREATE TABLE #TMP_TASK_CURRENT
      (
         Taskdetailkey NVARCHAR(10) PRIMARY KEY
      )

      CREATE TABLE #TMP_TASK_NEW
      (
         Taskdetailkey NVARCHAR(10) PRIMARY KEY
      )

      CREATE TABLE #T_RelatedWaves (
         RowID      INT IDENTITY(1, 1) PRIMARY KEY
       , WaveKey    NVARCHAR(10)
      )
      CREATE NONCLUSTERED INDEX IDX_TRW_WAVEKEY ON #T_RelatedWaves (WaveKey)

      CREATE TABLE #T_ShortCases (
         CaseID     NVARCHAR(20) NOT NULL
       , Storerkey  NVARCHAR(15) NOT NULL
       , SKU        NVARCHAR(20) NOT NULL
       , QtyMoved   INT NOT NULL
       , PRIMARY KEY (Storerkey, SKU, CaseID)
      )

      CREATE TABLE #T_NewLines (
         PickDetailKey NVARCHAR(18) NOT NULL PRIMARY KEY
       , Qty           INT NOT NULL
      )
   END

   IF @b_debug = 0 AND @n_Continue = 1
   BEGIN
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END
   
   -- Initialize Data
   IF @n_Continue = 1
   BEGIN
      SELECT TOP 1
             @c_StorerKey  = OH.StorerKey
           , @c_Facility   = OH.Facility
      FROM WAVEDETAIL WD WITH (NOLOCK)
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      WHERE WD.WaveKey = @c_Wavekey

      IF EXISTS ( SELECT 1
                  FROM TASKDETAIL WITH (NOLOCK)
                  WHERE Taskdetailkey = @c_Taskdetailkey )
      BEGIN
         SELECT @c_GetUCCNo = ISNULL(TD.CaseID, '')
              , @c_GetFromLoc = ISNULL(TD.FromLoc, '')
              , @c_GetFromID = ISNULL(TD.FromID, '')
              , @c_TaskType = ISNULL(TD.TaskType, '')
              , @c_ExceptionReason = ISNULL(TD.ReasonKey, '')
              , @c_ExceptionCode = ISNULL(TD.Message01, '')
              , @c_TaskStatus = ISNULL(TD.Status, '')
              , @c_UserKey = ISNULL(TD.UserKey, '')
         FROM TASKDETAIL TD WITH (NOLOCK)
         WHERE TD.Taskdetailkey = @c_Taskdetailkey
         
         IF ISNULL(@c_GetUCCNo, '') <> ''
         BEGIN
            SELECT @n_UCCRowRef = UCC.UCC_RowRef
            FROM UCC WITH (NOLOCK)
            WHERE UCC.UCCNo = @c_GetUCCNo
            AND UCC.Storerkey = @c_Storerkey
            AND UCC.SKU = @c_SKU

            IF @n_UCCRowRef > 0
            BEGIN
               SET @n_ByUCC = 1
            END
         END
      END
      ELSE
      BEGIN
         -- Invalid Taskdetailkey
         SELECT @n_Continue = 3
         SELECT @n_Err = 64505
         SELECT @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Invalid Taskdetailkey# ' + @c_Taskdetailkey 
                          + ' (' + @c_SourceType + ')'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END

      INSERT INTO #T_RelatedWaves (WaveKey)
      VALUES (@c_Wavekey)
   END
   
   IF @n_Continue = 1
   BEGIN
      -- Message01 = TOTEFULL
      -- Happy flow
      IF @c_ExceptionCode = 'TOTEFULL'
         SET @n_Continue = 4
      -- Short
      ELSE IF @c_ExceptionReason = 'SHORTAEOMX' AND @c_ExceptionCode = 'SHORT'
         SET @n_Continue = 1
      -- Reasonkey = SPLITAEOMX
      -- Split taskdetail (done by IML), no reallocation
      -- Release WCS
      ELSE IF @c_ExceptionReason = 'SPLITAEOMX' AND @c_ExceptionCode = 'SHORT'
         SET @n_Continue = 2
      -- Incorrect Message01/Reasonkey
      ELSE
         SET @n_Continue = 4
   END
   
   IF @n_Continue = 1
   BEGIN
      SET @c_PickCondition_SQL = 'AND PICKDETAIL.Storerkey = ' + QUOTENAME(TRIM(ISNULL(@c_Storerkey, '')), '''')
                               + ' AND PICKDETAIL.SKU = ' + QUOTENAME(TRIM(ISNULL(@c_SKU, '')), '''')

      IF @n_ByUCC = 1
      BEGIN
         INSERT INTO #T_RelatedWaves (WaveKey)
         SELECT DISTINCT WD.WaveKey
         FROM PICKDETAIL PD WITH (NOLOCK)
         JOIN WAVEDETAIL WD WITH (NOLOCK) ON PD.Orderkey = WD.Orderkey
         WHERE PD.Storerkey = @c_StorerKey
         AND   PD.Sku       = @c_SKU
         AND   PD.DropID    = @c_GetUCCNo
         AND   PD.[Status]  = '4'
         AND   NOT EXISTS ( SELECT 1
                            FROM #T_RelatedWaves T
                            WHERE T.Wavekey = WD.WaveKey
                          )
      END
   END

   -- Get Storerconfig setup
   IF @n_Continue = 1
   BEGIN
      SELECT @c_StrategykeyParm = ISNULL(fgr2.Authority, '')
      FROM fnc_GetRight2(@c_Facility, @c_StorerKey, '', 'RealloStrategy') fgr2

      IF ISNULL(@c_StrategykeyParm, '') = ''
         SET @c_StrategykeyParm = ''
   END

   -- Validation
   -- RDT update Status = '4'， QtyMoved, Qty no change
   IF @n_Continue = 1
   BEGIN
      IF @n_ByUCC = 1
      BEGIN
         INSERT INTO #T_PICKDETAIL_SHORT (Pickdetailkey)
         SELECT PD.Pickdetailkey
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.Storerkey = @c_StorerKey
         AND PD.Sku = @c_SKU
         AND PD.DropID = @c_GetUCCNo
         AND PD.[Status] = '4'
      END
      ELSE
      BEGIN
         INSERT INTO #T_PICKDETAIL_SHORT (Pickdetailkey)
         SELECT PD.Pickdetailkey
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.Storerkey = @c_StorerKey
         AND PD.Sku = @c_SKU
         AND PD.Loc = @c_GetFromLoc
         AND PD.[Status] = '4'
         AND EXISTS ( SELECT 1 
                      FROM WAVEDETAIL WD (NOLOCK)
                      WHERE WD.WaveKey = @c_Wavekey
                      AND WD.OrderKey = PD.OrderKey )
      END

      IF NOT EXISTS ( SELECT 1
                      FROM #T_PICKDETAIL_SHORT )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64504
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + CASE WHEN @n_ByUCC = 1 
                                 THEN ': UCC#: ' + TRIM(@c_GetUCCNo)
                                 ELSE ': Loc#: ' + TRIM(@c_GetFromLoc) 
                                 END
                          + ' No Record Found (' + @c_SourceType + ')'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END

   -- Total short qty for shorted pickdetail lines
   IF @n_Continue = 1
   BEGIN
      SELECT @n_TotalShortPickQty = ISNULL(SUM(IIF(PD.QtyMoved = 0, PD.Qty, PD.QtyMoved)), 0)
      FROM PICKDETAIL PD WITH (NOLOCK)
      JOIN #T_PICKDETAIL_SHORT T ON T.Pickdetailkey = PD.PickDetailKey
      
      IF @n_TotalShortPickQty <= 0
         SET @n_Continue = 4
   END

   -- Alert + CC for SHORTAEOMX
   -- Only for Locus
   -- Logic mirrored from nspRFRSN01
   IF @n_Continue = 1
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM TASKDETAIL CC WITH (NOLOCK)
                      WHERE CC.RefTaskKey = @c_Taskdetailkey
                      AND   CC.TaskType = 'CC'
                      AND   CC.Storerkey = @c_StorerKey
                      AND   CC.SKU = @c_SKU
                      AND   CC.FromLoc = @c_GetFromLoc ) AND @c_TaskStatus = '9'
      BEGIN
         SELECT @c_DoCycleCount = ISNULL(RTRIM(DoCycleCount), '')
         FROM TASKMANAGERREASON WITH (NOLOCK)
         WHERE TaskManagerReasonKey = @c_ExceptionReason

         SET @c_AlertMessage = ''
         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' TaskDetailKey: ' + @c_Taskdetailkey + CHAR(13) + CHAR(10)
         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' TaskType: ' + @c_TaskType + CHAR(13) + CHAR(10)
         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' ReasonCode: ' + @c_ExceptionReason + CHAR(13) + CHAR(10)
         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' UserKey: ' + @c_UserKey + CHAR(13) + CHAR(10)
         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' ToteNo: ' + '' + CHAR(13) + CHAR(10)

         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' QTY: ' + CAST(@n_TotalShortPickQty AS NVARCHAR(7)) + CHAR(13) + CHAR(10)
         SET @c_AlertMessage = TRIM(@c_AlertMessage) + ' DateTime: ' + CONVERT(NVARCHAR, GETDATE(), 121) + CHAR(13) + CHAR(10)

         BEGIN TRY
            SET @b_Success = 1
            EXEC dbo.nspLogAlert
                 @c_modulename       = 'TMCC'
               , @c_AlertMessage     = @c_AlertMessage
               , @n_Severity         = '5'
               , @b_success          = @b_Success     OUTPUT
               , @n_err              = @n_Err         OUTPUT
               , @c_errmsg           = @c_ErrMsg      OUTPUT
               , @c_Activity         = 'ReasonScn'
               , @c_Storerkey        = @c_StorerKey
               , @c_SKU              = @c_SKU
               , @c_UOM              = ''
               , @c_UOMQty           = ''
               , @c_Qty              = @n_TotalShortPickQty
               , @c_Lot              = ''
               , @c_Loc              = @c_GetFromLoc
               , @c_ID               = @c_GetFromID
               , @c_TaskDetailKey    = @c_Taskdetailkey
               , @c_UCCNo            = ''
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         IF @n_Continue = 1
            AND @c_DoCycleCount = '1'
            -- AND @c_TaskType NOT IN ('CC', 'CCSV', 'CCSUP')
         BEGIN
            SET @c_TaskDetailKeyCC = ''
            SET @c_CCKey = ''

            BEGIN TRY
               EXECUTE dbo.nspg_GetKey 'TaskDetailKey'
                                     , 10
                                     , @c_TaskDetailKeyCC   OUTPUT
                                     , @b_Success           OUTPUT
                                     , @n_Err               OUTPUT
                                     , @c_ErrMsg            OUTPUT
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @n_Err = ERROR_NUMBER()
               SET @c_ErrMsg = ERROR_MESSAGE()
            END CATCH

            IF @n_Continue = 1
            BEGIN
               BEGIN TRY
                  EXECUTE dbo.nspg_GetKey 'CCKey'
                                        , 10
                                        , @c_CCKey    OUTPUT
                                        , @b_Success  OUTPUT
                                        , @n_Err      OUTPUT
                                        , @c_ErrMsg   OUTPUT
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH
            END

            IF @n_Continue = 1
            BEGIN
               BEGIN TRY
                  INSERT INTO dbo.TaskDetail (TaskDetailKey, TaskType, Storerkey, Sku, FromLoc, LogicalFromLoc, PickMethod, Status
                                            , Priority, SourcePriority, UserPosition, SourceType, SourceKey, RefTaskKey, AreaKey)
                  SELECT @c_TaskDetailKeyCC
                       , 'CC'
                       , Storerkey
                       , Sku
                       , FromLoc
                       , LogicalFromLoc
                       , 'SKU'
                       , '0'
                       , '1'
                       , '1'
                       , UserPosition
                       , @c_SourceType
                       , @c_CCKey
                       , @c_Taskdetailkey
                       , AreaKey
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE TaskDetailKey = @c_Taskdetailkey
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH
            END
         END
      END
   END

   -- Unallocate
   IF @n_Continue = 1
   BEGIN
      SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT T.Pickdetailkey
      FROM #T_PICKDETAIL_SHORT T
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
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
      END
      CLOSE @CUR_UNALLOC
      DEALLOCATE @CUR_UNALLOC
   END

   -- Rollback UCC Status to 1
   -- nspInventoryHold only allow holding Status in (1, 2)
   IF @n_Continue = 1 AND @n_ByUCC = 1
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
         WHERE UCC.UCC_RowRef = @n_UCCRowRef
         AND UCC.[Status] = '3'
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH

      IF @b_debug = 0 AND @n_Continue = 1
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
   END

   -- Hold the UCC/Loc
   IF @n_Continue = 1
   BEGIN
      SET @c_HoldLoc = IIF(@n_ByUCC = 1, '', @c_GetFromLoc)
      SET @c_HoldUCC = IIF(@n_ByUCC = 1, @c_GetUCCNo, '')
      
      BEGIN TRY
         EXEC dbo.nspInventoryHoldWrapper @c_lot = N'' -- nvarchar(10)
                                        , @c_Loc = @c_HoldLoc -- nvarchar(10)
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
                                        , @c_UCCNo = @c_HoldUCC -- nvarchar(20)
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH
   END
   
   IF @n_Continue = 1
   BEGIN
      INSERT INTO #TMP_TASK_CURRENT (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD WITH (NOLOCK)
      WHERE TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU
      AND TD.TaskType IN ('RPF', 'FCP')
      AND EXISTS ( SELECT 1
                   FROM #T_RelatedWaves T
                   WHERE T.WaveKey = TD.WaveKey )
   END

   -- Reallocate
   IF @n_Continue = 1
   BEGIN
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         BEGIN TRY
            EXEC dbo.ispWaveProcessing @c_WaveKey = @c_GetWavekey -- nvarchar(10)
                                     , @b_Success = @b_Success OUTPUT -- int
                                     , @n_Err = @n_Err OUTPUT -- int
                                     , @c_ErrMsg = @c_ErrMsg OUTPUT -- nvarchar(250)
                                     , @b_debug = @b_debug -- int
                                     , @c_StrategykeyParm = @c_StrategykeyParm -- nvarchar(10)
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
   END

   -- Initialize Pickdetail work in progress staging table
   IF @n_Continue = 1
   BEGIN
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_GetWavekey
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

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
   END

   -- Re-stamp CaseID in WIP, persist pickdetail, then update Packdetail
   IF @n_Continue = 1
   BEGIN
      -- Pre-cartonization for different scenario
      -- mspRLWAV13_Slot -> Pickdetail.CaseID = Virtual Case ID - No Packdetail
      -- mspRLWAV13_EPACK -> Pickdetail.CaseID = Packdetail.LabelNo based on Pack.CubeUOM3
      -- If new alloc qty <= shorted qty, stamp old CaseID to new pick lines.
      -- Packdetail: ActiveQty = NewAllocQty + PickedQty (PickedQty = Packdetail.ExpQty - ShortedQty, floored at 0).
      --   ActiveQty = Packdetail.ExpQty or > : no change;
      --   0 < ActiveQty < Packdetail.ExpQty : update ExpQty;
      --   ActiveQty = 0 (all shorted, realloc failed) : delete Packdetail.
      INSERT INTO #T_ShortCases (CaseID, Storerkey, SKU, QtyMoved)
      SELECT SP.CaseID
           , SP.Storerkey
           , SP.SKU
           , QtyMoved = SUM(SP.QtyMoved)
      FROM #PickDetail_WIP SP
      WHERE SP.Storerkey = @c_StorerKey
      AND SP.Sku = @c_SKU
      AND SP.CaseID IS NOT NULL
      AND SP.CaseID <> ''
      AND EXISTS ( SELECT 1
                  FROM #T_PICKDETAIL_SHORT T
                  WHERE T.Pickdetailkey = SP.PickDetailKey )
      GROUP BY SP.CaseID, SP.Storerkey, SP.SKU

      INSERT INTO #T_NewLines (PickDetailKey, Qty)
      SELECT PD.PickDetailKey
           , PD.Qty
      FROM #PickDetail_WIP PD
      WHERE PD.Storerkey = @c_StorerKey
      AND PD.Sku = @c_SKU
      AND PD.[Status] = '0'
      AND NOT EXISTS ( SELECT 1
                     FROM #T_PICKDETAIL_SHORT T
                     WHERE T.Pickdetailkey = PD.PickDetailKey )
      AND (PD.CaseID IS NULL OR PD.CaseID = '')

      SELECT @n_TotalNewAllocQty = ISNULL(N.TotalQty, 0)
           , @n_TotalShortCaseQty = ISNULL(S.TotalQty, 0)
      FROM ( SELECT TotalQty = SUM(Qty) FROM #T_NewLines ) N
      CROSS JOIN ( SELECT TotalQty = SUM(QtyMoved) FROM #T_ShortCases ) S

      -- Post allocation validation
      IF @n_TotalNewAllocQty = 0
         SET @n_Continue = 4
      ELSE IF @n_TotalNewAllocQty = @n_TotalShortPickQty   -- Total short pick qty
         SET @n_RemoveShort = 1

      IF @n_Continue = 1
      BEGIN
         IF @b_debug = 0
         BEGIN
            BEGIN TRAN
         END

         IF @n_TotalNewAllocQty > 0 AND @n_TotalNewAllocQty <= @n_TotalShortCaseQty
         BEGIN
            -- Stamp by qty bucket: each short case owns a contiguous range (e.g. 1-8, 9-16).
            -- New line inherits CaseID where its CumStart falls within that range.
            ;WITH NewLinesRunning AS (
               SELECT PickDetailKey
                    , CumStart = SUM(Qty) OVER (ORDER BY PickDetailKey) - Qty + 1
               FROM #T_NewLines
            ),
            ShortCasesRunning AS (
               SELECT CaseID
                    , CumStart = SUM(QtyMoved) OVER (ORDER BY CaseID) - QtyMoved + 1
                    , CumEnd   = SUM(QtyMoved) OVER (ORDER BY CaseID)
               FROM #T_ShortCases
            )
            UPDATE PD
            SET CaseID = SC.CaseID
            FROM #PickDetail_WIP PD
            JOIN NewLinesRunning NL ON PD.PickDetailKey = NL.PickDetailKey
            JOIN ShortCasesRunning SC ON NL.CumStart BETWEEN SC.CumStart AND SC.CumEnd
         END

         -- Clear CaseID on shorted lines before persisting WIP
         UPDATE SP
         SET SP.CaseID = ''
         FROM #PickDetail_WIP SP
         WHERE EXISTS ( SELECT 1
                        FROM #T_PICKDETAIL_SHORT T
                        WHERE T.Pickdetailkey = SP.PickDetailKey )
         AND SP.CaseID IS NOT NULL
         AND SP.CaseID <> ''

         SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT R.WaveKey
         FROM #T_RelatedWaves R
         ORDER BY R.RowID

         OPEN @CUR_WAVE

         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

         WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
         BEGIN
            EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_GetWavekey
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

         IF @n_Continue = 1
         BEGIN
            -- Packdetail.ExpQty = original carton expected qty.
            -- ActiveQty = NewAllocQty + PickedQty (PickedQty floored at 0 if ShortedQty > Packdetail.ExpQty).
            -- ActiveQty >= Packdetail.ExpQty : no change.
            -- ActiveQty < Packdetail.ExpQty and > 0 : update ExpQty.
            -- ActiveQty = 0 (all shorted, realloc failed) : delete Packdetail.  
            MERGE PACKDETAIL AS TGT
            USING (
               SELECT PD.PickSlipNo
                    , PD.CartonNo
                    , PackDetailQty = PD.ExpQty
                    , NewAllocQty   = ISNULL(W.StampedQty, 0)
                    , PickedQty     = CASE WHEN PD.ExpQty > SC.QtyMoved THEN PD.ExpQty - SC.QtyMoved ELSE 0 END
                    , ActiveQty     = ISNULL(W.StampedQty, 0)
                                    + CASE WHEN PD.ExpQty > SC.QtyMoved THEN PD.ExpQty - SC.QtyMoved ELSE 0 END
               FROM PACKDETAIL PD (NOLOCK)
               JOIN #T_ShortCases SC ON PD.LabelNo = SC.CaseID
                                    AND PD.StorerKey = SC.Storerkey
                                    AND PD.SKU = SC.SKU
               LEFT JOIN ( SELECT WIP.CaseID
                                , StampedQty = SUM(WIP.Qty)
                           FROM #PickDetail_WIP WIP
                           WHERE WIP.CaseID <> ''
                           AND EXISTS ( SELECT 1
                                       FROM #T_NewLines NL
                                       WHERE NL.PickDetailKey = WIP.PickDetailKey )
                           GROUP BY WIP.CaseID
                        ) W ON W.CaseID = SC.CaseID
            ) AS SRC
            ON TGT.PickSlipNo = SRC.PickSlipNo AND TGT.CartonNo = SRC.CartonNo
            WHEN MATCHED AND SRC.ActiveQty = 0 THEN
               DELETE
            WHEN MATCHED AND SRC.ActiveQty > 0 AND SRC.ActiveQty < SRC.PackDetailQty THEN
               UPDATE SET ExpQty = SRC.ActiveQty;
         END

         IF @b_debug = 0 AND @n_Continue = 1 
         BEGIN
            WHILE @@TRANCOUNT > 0
            BEGIN
               COMMIT TRAN
            END
         END
      END
   END

   -- Delete Shorted Pickdetail
   IF @n_Continue = 1 AND @n_RemoveShort = 1
   BEGIN
      SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT T.Pickdetailkey
      FROM #T_PICKDETAIL_SHORT  T
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
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
      END
      CLOSE @CUR_UNALLOC
      DEALLOCATE @CUR_UNALLOC
   END

   -- Delete pickdetail_WIP work in progress staging table    
   IF @n_Continue = 1
   BEGIN
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         EXEC isp_CreatePickdetail_WIP @c_Wavekey = @c_GetWavekey
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
   END

   -- Wave Release - Taskdetail Creation & Pre-cartonization
   IF @n_Continue = 1              
   BEGIN
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         BEGIN TRY
            EXEC dbo.isp_ReleaseWave_Wrapper @c_WaveKey = @c_GetWavekey -- nvarchar(10)
                                           , @b_Success = @b_Success OUTPUT -- int
                                           , @n_Err = @n_Err OUTPUT -- int
                                           , @c_Errmsg = @c_Errmsg OUTPUT -- nvarchar(255)
         
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH
         
         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
   END

   -- Update TaskDetail Message02 field to 'SHORT1' for reallocated tasks
   IF @n_Continue = 1
   BEGIN
      -- Insert new taskdetailkeys into temp table after wave releasing
      INSERT INTO #TMP_TASK_NEW (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD WITH (NOLOCK)
      WHERE TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU
      AND TD.TaskType IN ('RPF', 'FCP')
      AND EXISTS ( SELECT 1
                   FROM #T_RelatedWaves T
                   WHERE T.WaveKey = TD.WaveKey )
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
      END
   END
   
   -- Release to WCS (Only apply to UOM 6 - control by custom SP)
   IF @n_Continue IN (1,2)            
   BEGIN
      SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT R.WaveKey
      FROM #T_RelatedWaves R
      ORDER BY R.RowID

      OPEN @CUR_WAVE

      FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         BEGIN TRY
            EXEC dbo.isp_WaveReleaseToWCS_Wrapper @c_WaveKey = @c_GetWavekey -- nvarchar(10)
                                                , @b_Success = @b_Success OUTPUT -- int
                                                , @n_Err = @n_Err OUTPUT -- int
                                                , @c_Errmsg = @c_Errmsg OUTPUT -- nvarchar(255)
         
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH
         
         FETCH NEXT FROM @CUR_WAVE INTO @c_GetWavekey
      END
      CLOSE @CUR_WAVE
      DEALLOCATE @CUR_WAVE
   END

   QUIT_SP:
   IF (XACT_STATE()) = -1 
   BEGIN
      SET @n_Continue = 3
      ROLLBACK TRAN
   END

   IF OBJECT_ID('tempdb..#PickDetail_WIP ','u') IS NOT NULL 
      DROP TABLE #PickDetail_WIP

   IF OBJECT_ID('tempdb..#T_PICKDETAIL_SHORT ','u') IS NOT NULL 
      DROP TABLE #T_PICKDETAIL_SHORT

   IF OBJECT_ID('tempdb..#TMP_TASK_CURRENT ','u') IS NOT NULL 
      DROP TABLE #TMP_TASK_CURRENT

   IF OBJECT_ID('tempdb..#TMP_TASK_NEW ','u') IS NOT NULL 
      DROP TABLE #TMP_TASK_NEW

   IF OBJECT_ID('tempdb..#T_RelatedWaves ','u') IS NOT NULL 
      DROP TABLE #T_RelatedWaves

   IF OBJECT_ID('tempdb..#T_ShortCases ','u') IS NOT NULL 
      DROP TABLE #T_ShortCases

   IF OBJECT_ID('tempdb..#T_NewLines ','u') IS NOT NULL 
      DROP TABLE #T_NewLines

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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'msp_ProcessShortPickReAlloc07'
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
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc07] TO [NSQL]
GO