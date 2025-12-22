SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: msp_ProcessShortReplenReAlloc01                    */
/* Creation Date: 15-Dec-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-9007 WMS - Brazil - Cajamar - ONBR - Short replenishment*/
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
/* 15-Dec-2025 WLChooi  1.0   Initial Version                           */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_ProcessShortReplenReAlloc01] (    
       @c_Wavekey          NVARCHAR(10)   = ''
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

   DECLARE @c_PickDetailKey            NVARCHAR(18) = ''
         , @CUR_UNALLOC                CURSOR
         , @CUR_ALLOC                  CURSOR
         , @c_Facility                 NVARCHAR(5)  = ''
         , @c_StrategykeyParm          NVARCHAR(10) = ''
         , @n_DynReplen                INT = 0
         , @c_GetWavekey               NVARCHAR(10)
         , @c_FinalLoc                 NVARCHAR(10) = ''
         , @c_FinalID                  NVARCHAR(18) = ''

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      CREATE TABLE #TMP_PICK
      (
         Pickdetailkey  NVARCHAR(18) PRIMARY KEY
       , Wavekey        NVARCHAR(10)
      )

      CREATE TABLE #TMP_TASK_FCP
      (
         Taskdetailkey  NVARCHAR(10) PRIMARY KEY
      )
   END

   IF @b_debug = 0 AND @n_Continue IN (1,2)
   BEGIN
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END

   -- Validation
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM TASKDETAIL (NOLOCK)
                      WHERE TaskDetailKey = @c_Taskdetailkey
                      AND TaskType = 'RPF' )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 68800
         SET @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Taskdetailkey#: ' + TRIM(@c_Taskdetailkey) + ' is not a valid RPF task. (msp_ProcessShortReplenReAlloc01)'
                       + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END

      IF ISNULL(@c_SKU, '') = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 68805
         SET @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': SKU is required! (msp_ProcessShortReplenReAlloc01)'
                       + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END

      IF ISNULL(@c_UCCNo, '') = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 68810
         SET @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': UCCNo is required! (msp_ProcessShortReplenReAlloc01)'
                       + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END

   -- Initialize Data
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      -- @n_DynReplen
      -- 1 - Dynamic Replen
      -- 0 - Normal Min-Max Replen
      SELECT @n_DynReplen = IIF(ISNULL(TD.WaveKey, '') = '', 0, 1)
           , @c_StorerKey = TD.Storerkey
           , @c_Facility = L.Facility
      FROM TASKDETAIL TD (NOLOCK)
      JOIN LOC L (NOLOCK) ON TD.FromLoc = L.Loc
      WHERE TD.TaskDetailKey = @c_Taskdetailkey
      AND TD.TaskType = 'RPF'

      SET @n_DynReplen = ISNULL(@n_DynReplen, 0)
   END

   -- Prepare temp data
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_DynReplen = 1
   BEGIN
      SELECT @c_FinalLoc = TD.FinalLOC
           , @c_FinalID = TD.FinalID
      FROM TASKDETAIL TD (NOLOCK)
      WHERE TD.TaskDetailKey = @c_Taskdetailkey
      AND TD.TaskType = 'RPF'
      
      INSERT INTO #TMP_TASK_FCP (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD (NOLOCK)
      WHERE TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU
      AND TD.TaskType = 'FCP'
      AND TD.FromLoc = @c_FinalLoc
      AND TD.FromID = @c_FinalID
      AND TD.[Status] IN ('0', 'H')
      
      INSERT INTO #TMP_PICK (Pickdetailkey, Wavekey)
      SELECT DISTINCT PD.Pickdetailkey, PD.Wavekey
      FROM PICKDETAIL PD (NOLOCK)
      WHERE PD.Storerkey = @c_StorerKey
      AND PD.SKU = @c_SKU
      AND EXISTS ( SELECT 1
                   FROM #TMP_TASK_FCP TF
                   WHERE TF.Taskdetailkey = PD.TaskDetailKey )
   END

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      -- Dynamic Replen - @n_DynReplen = 1
      IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_DynReplen = 1
      BEGIN
         -- Update all FCP tasks to X
         IF (@n_Continue = 1 OR @n_Continue = 2)
         AND EXISTS ( SELECT 1
                      FROM #TMP_PICK )
         BEGIN
            BEGIN TRY
               UPDATE TD WITH (ROWLOCK)
               SET TD.[Status] = 'X'
               FROM TASKDETAIL TD
               JOIN #TMP_TASK_FCP TF ON TD.Taskdetailkey = TF.TaskDetailKey
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @c_ErrMsg = ERROR_MESSAGE()
            END CATCH
         END

         -- Get Storerconfig setup
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
      
            SET @c_StrategykeyParm = ISNULL(@c_StrategykeyParm, '')
         END
         
         -- Unalloc Pickdetail
         IF (@n_Continue = 1 OR @n_Continue = 2)
         BEGIN
            IF @b_debug = 0
            BEGIN
               BEGIN TRAN
            END
      
            SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT T.Pickdetailkey
            FROM #TMP_PICK T
            ORDER BY T.Pickdetailkey
      
            OPEN @CUR_UNALLOC
      
            FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
      
            WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
            BEGIN
               BEGIN TRY
                  UPDATE PICKDETAIL
                  SET Status = '4', QtyMoved = Qty, Qty = 0
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
      
         -- Call Short Pick Reallocate SP to pre-cartonize and release Wave
         IF (@n_Continue = 1 OR @n_Continue = 2)
         BEGIN
            SET @CUR_ALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT T.Wavekey
            FROM #TMP_PICK T
            ORDER BY T.Wavekey
      
            OPEN @CUR_ALLOC
      
            FETCH NEXT FROM @CUR_ALLOC INTO @c_GetWavekey
      
            WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
            BEGIN
               BEGIN TRY
                  EXEC dbo.msp_ProcessShortPickReAlloc03 @c_Wavekey = @c_GetWavekey -- nvarchar(10)
                                                       , @c_SKU = @c_SKU -- nvarchar(20)
                                                       , @c_UCCNo = @c_UCCNo -- nvarchar(20)
                                                       , @c_Taskdetailkey = N'' -- nvarchar(10)
                                                       , @b_Success = @b_Success OUTPUT -- int
                                                       , @n_Err = @n_Err OUTPUT -- int
                                                       , @c_ErrMsg = @c_ErrMsg OUTPUT -- nvarchar(225)
                                                       , @b_Debug = @b_Debug -- int
                  
                  -- Check for errors from msp_ProcessShortPickReAlloc03
                  IF @b_Success = 0 OR @n_Err <> 0
                  BEGIN
                     SET @n_Continue = 3
                  END
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH
            
               FETCH NEXT FROM @CUR_ALLOC INTO @c_GetWavekey
            END
            CLOSE @CUR_ALLOC
            DEALLOCATE @CUR_ALLOC
         END
      END
      ELSE IF @n_DynReplen <> 1   -- Normal Min-Max Replen - @n_DynReplen <> 1
      BEGIN
         IF ISNULL(@c_Storerkey, '') <> '' AND ISNULL(@c_Facility, '') <> ''
         BEGIN
            BEGIN TRY
               EXEC dbo.isp_GenReplenishmentTask_01 @c_Zone01 = @c_Facility -- nvarchar(10)
                                                  , @c_Zone02 = N'ALL' -- nvarchar(10)
                                                  , @c_Zone03 = N'' -- nvarchar(10)
                                                  , @c_Zone04 = N'' -- nvarchar(10)
                                                  , @c_Zone05 = N'' -- nvarchar(10)
                                                  , @c_Zone06 = N'' -- nvarchar(10)
                                                  , @c_Zone07 = N'' -- nvarchar(10)
                                                  , @c_Zone08 = N'' -- nvarchar(10)
                                                  , @c_Zone09 = N'' -- nvarchar(10)
                                                  , @c_Zone10 = N'' -- nvarchar(10)
                                                  , @c_Zone11 = N'' -- nvarchar(10)
                                                  , @c_Zone12 = N'' -- nvarchar(10)
                                                  , @c_ReplenFlag = 'N' -- nvarchar(10)
                                                  , @c_StorerKey = @c_Storerkey -- nvarchar(15)
                                                  , @c_ReplenType = N'T' -- nvarchar(10)
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @c_ErrMsg = ERROR_MESSAGE()
            END CATCH
         END
      END
   END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_PICK ','u') IS NOT NULL 
      DROP TABLE #TMP_PICK

   IF OBJECT_ID('tempdb..#TMP_TASK_FCP ','u') IS NOT NULL 
      DROP TABLE #TMP_TASK_FCP

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
GRANT EXECUTE ON [dbo].[msp_ProcessShortReplenReAlloc01] TO [NSQL]
GO