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
/* GitHub Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 01-Oct-2025 WLChooi  1.0   Initial Version                           */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortPickReAlloc01] (    
       @c_Wavekey          NVARCHAR(10)
     , @c_SKU              NVARCHAR(20)
     , @c_UCCNo            NVARCHAR(20)
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
         , @c_PackKey                  NVARCHAR(10) = ''
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
         , @c_TaskdetailKey            NVARCHAR(10) = ''
         , @c_Message02                NVARCHAR(20) = ''
         , @c_TableName                NVARCHAR(30) = ''

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   SET @c_SourceKey = @c_Wavekey
   SET @c_PackKey = ''
   SET @c_UOM = ''
   SET @c_StrategykeyParm = ''
   SET @c_SourceType = 'msp_ProcessShortPickReAlloc01'
   SET @c_Message02 = 'SKIP1'
   SET @c_TableName = N'WSSOAlloUpd'
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      CREATE TABLE #T_AllocOrders (    
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
   END

   IF @b_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END
        
   SELECT @c_StorerKey  = OH.StorerKey
        , @c_Facility   = OH.Facility
        , @c_Automation = ISNULL(W.Userdefine09, '')
   FROM WAVE W WITH (NOLOCK)
   JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
   JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
   WHERE WD.WaveKey = @c_Wavekey

   SELECT @c_PackKey = S.PackKey
        , @c_UOM     = P.PackUOM3
   FROM SKU S WITH (NOLOCK)
   JOIN PACK P WITH (NOLOCK) ON S.PackKey = P.PackKey
   WHERE S.STORERKEY = @c_StorerKey
   AND   S.SKU       = @c_SKU

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
                      AND PD.[Status] = '4' )    
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
      INSERT INTO #T_AllocOrders (OrderKey)
      SELECT PD.OrderKey
      FROM PICKDETAIL PD WITH (NOLOCK)    
      WHERE PD.Storerkey = @c_StorerKey    
      AND   PD.Sku = @c_SKU    
      AND   PD.DropID = @c_UCCNo    
      AND   PD.[Status] = '4'
      GROUP BY PD.OrderKey
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
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH

      IF @b_debug = 0
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

   --Compare Pickdetail Line
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

      IF @b_debug = 0
      BEGIN
         BEGIN TRAN
      END

      -- ReAllocStatus
      -- 0 - Not Allocated after shorted
      -- 1 - Partial Allocated after shorted
      -- 2 - Fully Allocated after shorted
      SET @CUR_UpdatePick = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      WITH AllPick AS (
         SELECT OrderKey = PD.OrderKey
              , ReAllocStatus = CASE WHEN SUM(PD.Qty) = 0 THEN '0' ELSE '1' END
              , QtyInDiff = ABS(SUM(PD.QtyMoved) - SUM(PD.Qty))
         FROM #PickDetail_WIP PD (NOLOCK)
         JOIN #T_AllocOrders T ON PD.OrderKey = T.OrderKey
         WHERE PD.[Status] <= '4'
         GROUP BY PD.OrderKey
         HAVING SUM(PD.Qty) < SUM(PD.QtyMoved)   --Only check Not/Partial allocated after reallocation
      ), ShortPick AS (
         SELECT Orderkey = PD.Orderkey
              , Pickdetailkey = PD.PickDetailKey
         FROM #PickDetail_WIP PD (NOLOCK)
         JOIN #T_AllocOrders T ON PD.OrderKey = T.OrderKey
         WHERE PD.[Status] IN ('4')
         GROUP BY PD.PickDetailKey, PD.OrderKey
      )
      SELECT AP.OrderKey
           , AP.ReAllocStatus
           , SP.Pickdetailkey
           , AP.QtyInDiff
      FROM ShortPick SP
      JOIN AllPick AP ON AP.OrderKey = SP.OrderKey

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

      IF @b_debug = 0
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
      END
   END
   
   --Initialize Data - Copy from mspRLWAV03
   IF @n_Continue IN (1,2) AND @c_Automation = 'Y'                 
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

      INSERT INTO #T_ORDERSKU (Orderkey, Storerkey, SKU, WCS)
      SELECT DISTINCT P.OrderKey, P.Storerkey, P.SKU, 0
      FROM #PickDetail_WIP P
      WHERE P.WaveKey = @c_Wavekey
      AND P.UOM IN ('2','6')
      AND (P.TaskDetailKey = '' OR P.TaskDetailKey IS NULL)
      AND P.[Status] = '0'
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
         WHERE P.WaveKey = @c_Wavekey
         AND P.UOM IN ('2','6')
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
      
         FETCH NEXT FROM @CUR_PTASK INTO @c_WaveKey, @c_Orderkey, @c_OrderLineNumber
                                       , @c_Storerkey, @c_Sku, @c_LOT, @c_FromLOC, @c_ID, @n_PickdetQty 
                                       , @c_UOM, @c_PickMethod, @c_DropId, @c_LabelNo, @b_WCS
                                       , @c_FromLogicalLoc, @c_FromLocType, @c_FromPAZone
      
         WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
         BEGIN
            SET @c_TaskStatus    = 'H'
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

                  IF EXISTS(SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                            WHERE WaveKey = @c_WaveKey
                            AND TaskType = 'RPF'
                            AND Caseid = CASE WHEN @c_DropId = '' THEN @c_LabelNo ELSE @c_DropId END
                            AND FromLoc = @c_FromLoc)
                  BEGIN
                     SET @b_InsertTask = 0
                  END
                  
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
                  ,  @keystring     =  @c_TaskdetailKey OUTPUT
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
                        SET @c_RefTaskkey = @c_TaskdetailKey
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
                       @c_TaskDetailKey
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
                     , @c_WaveKey
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

               IF @n_Continue IN (1,2) AND @b_InsertTask = 1
               BEGIN
                  SET @CUR_UPDATEPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
                  SELECT P.PickDetailKey
                  FROM #PickDetail_WIP P
                  WHERE P.UOM = @c_UOM
                  AND   P.PickMethod = @c_PickMethod
                  AND   p.Lot = @c_Lot
                  AND   p.Loc = @c_FromLoc
                  AND   p.ID  = @c_ID
                  AND   p.DropID  = @c_DropID

                  OPEN @CUR_UPDATEPD

                  FETCH NEXT FROM @CUR_UPDATEPD INTO @c_PickDetailKey
         
                  WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
                  BEGIN
                     UPDATE #PickDetail_WIP
                     SET TaskDetailKey = @c_TaskDetailKey 
                     WHERE PickDetailKey = @c_PickDetailKey

                     SET @n_err = @@ERROR
                     IF @n_err <> 0
                     BEGIN
                        SET @n_Continue = 3
                        SET @c_ErrMsg = CONVERT(CHAR(250), @n_err)
                        SET @n_err = 82016
                        SET @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) + ': Updating PickDetail Failed (msp_ProcessShortPickReAlloc01)'  
                                       + ' ( '+' SQLSvr MESSAGE= ' + @c_ErrMsg + ' ) '
                     END
                     FETCH NEXT FROM @CUR_UPDATEPD INTO @c_PickDetailKey
                  END
                  CLOSE @CUR_UPDATEPD
                  DEALLOCATE @CUR_UPDATEPD
               END
            END
            FETCH NEXT FROM @CUR_PTASK INTO @c_WaveKey, @c_Orderkey, @c_OrderLineNumber
                                          , @c_Storerkey, @c_Sku, @c_LOT, @c_FromLOC, @c_ID, @n_PickdetQty  
                                          , @c_UOM, @c_PickMethod, @c_DropId, @c_LabelNo, @b_WCS
                                          , @c_FromLogicalLoc, @c_FromLocType, @c_FromPAZone 
         END
         CLOSE @CUR_PTASK
         DEALLOCATE @CUR_PTASK
      END

      IF @b_debug = 0
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
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
   IF OBJECT_ID('tempdb..#T_AllocOrders ','u') IS NOT NULL 
      DROP TABLE #T_AllocOrders

   IF OBJECT_ID('tempdb..#T_ORDERSKU ','u') IS NOT NULL 
      DROP TABLE #T_ORDERSKU

   IF (XACT_STATE()) = -1 
   BEGIN
      SET @n_Continue = 3
      ROLLBACK TRAN
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
GRANT EXECUTE ON [dbo].[msp_ProcessShortPickReAlloc01] TO [NSQL]
GO