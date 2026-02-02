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
/* 02-Feb-2026 WLChooi  1.0   Initial Version                           */
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
     , @c_OtherParms       NVARCHAR(MAX)  = ''
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
         , @c_ReplenishStrategy        NVARCHAR(10) = 'Gen-UCC'
         , @c_ReplenishCode            NVARCHAR(500)= ''
         , @c_SQL                      NVARCHAR(MAX) = ''
         , @c_SQLParms                 NVARCHAR(MAX) = ''
         , @c_ReplenType               NVARCHAR(10) = 'R'
         , @c_ReplenSPName             NVARCHAR(50) = ''

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      CREATE TABLE #TMP_PICK_SHORT
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

      SELECT @c_ReplenishStrategy = dbo.fnc_GetParamValueFromString('@c_ReplenishStrategy', @c_OtherParms, @c_ReplenishStrategy)
      SELECT @c_ReplenType = dbo.fnc_GetParamValueFromString('@c_ReplenType', @c_OtherParms, @c_ReplenType)
      
      IF ISNULL(@c_ReplenishStrategy, '') = ''
         SET @c_ReplenishStrategy = 'Gen-UCC'
      
      IF ISNULL(@c_ReplenType, '') = ''
         SET @c_ReplenType = 'R'

      SELECT TOP 1 @c_ReplenishCode = ISNULL(TRIM(RSD.ReplenCode), '')
      FROM REPLENISHSTRATEGYDETAIL RSD (NOLOCK)
      WHERE RSD.ReplenishStrategykey = @c_ReplenishStrategy
      AND (RSD.ReplenCode IS NOT NULL OR RSD.ReplenCode <> '')

      SET @c_ReplenSPName = RTRIM(SUBSTRING(@c_ReplenishCode, 1, CHARINDEX('@',@c_ReplenishCode,1) - 1))
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
      AND TD.TaskType IN ('ASTCPK','FCP')
      AND TD.FromLoc = @c_FinalLoc
      AND TD.FromID = @c_FinalID
      AND TD.[Status] IN ('0', 'H')
      
      INSERT INTO #TMP_PICK_SHORT (Pickdetailkey, Wavekey)
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
                      FROM #TMP_PICK_SHORT )
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
            SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT T.Pickdetailkey
            FROM #TMP_PICK_SHORT T
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
         END
      
         -- Call Short Pick Reallocate SP to pre-cartonize and release Wave
         IF (@n_Continue = 1 OR @n_Continue = 2)
         BEGIN
            SET @CUR_ALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT T.Wavekey
            FROM #TMP_PICK_SHORT T
            ORDER BY T.Wavekey
      
            OPEN @CUR_ALLOC
      
            FETCH NEXT FROM @CUR_ALLOC INTO @c_GetWavekey
      
            WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
            BEGIN
               BEGIN TRY
                  EXEC dbo.msp_ProcessShortPickReAlloc03 @c_Wavekey = @c_GetWavekey -- nvarchar(10)
                                                       , @c_SKU = @c_SKU -- nvarchar(20)
                                                       , @c_Loc = @c_UCCNo -- nvarchar(20)
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

            -- Unalloc Pickdetail
            IF (@n_Continue = 1 OR @n_Continue = 2)
            BEGIN
               SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT T.Pickdetailkey
               FROM #TMP_PICK_SHORT T
               ORDER BY T.Pickdetailkey
         
               OPEN @CUR_UNALLOC
         
               FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
         
               WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
               BEGIN
                  BEGIN TRY
                     DELETE PICKDETAIL
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
            END
         END
      END
      ELSE IF @n_DynReplen <> 1   -- Normal Min-Max Replen - @n_DynReplen <> 1
      BEGIN
         IF ISNULL(@c_Storerkey, '') <> '' AND ISNULL(@c_Facility, '') <> ''
         BEGIN
            IF @n_Continue IN (1, 2)
            AND EXISTS ( SELECT 1 
                         FROM dbo.sysobjects 
                         WHERE name = TRIM(@c_ReplenSPName)
                         AND type = 'P' )
            BEGIN
               SET @c_SQL = ' EXEC ' + TRIM(@c_ReplenSPName) + ' @c_Zone01 = @c_Facility ' + CHAR(13)
                          + '                                  , @c_Zone02 = N''ALL'' ' + CHAR(13)
                          + '                                  , @c_Zone03 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone04 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone05 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone06 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone07 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone08 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone09 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone10 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone11 = N'''' ' + CHAR(13)
                          + '                                  , @c_Zone12 = N'''' ' + CHAR(13)
                          + '                                  , @c_ReplenFlag = ''N'' ' + CHAR(13)
                          + '                                  , @c_StorerKey = @c_Storerkey '  + CHAR(13) 
                          + '                                  , @c_ReplenType = @c_ReplenType '
               
               SET @c_SQLParms = '   @c_Storerkey     NVARCHAR(15) ' + CHAR(13)
                               + ' , @c_Facility      NVARCHAR(5)  ' + CHAR(13)
                               + ' , @c_ReplenType    NVARCHAR(10) '
               BEGIN TRY
                  EXEC sp_ExecuteSql @c_SQL
                                   , @c_SQLParms
                                   , @c_Storerkey
                                   , @c_Facility
                                   , @c_ReplenType
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH
            END

            IF @n_Continue IN (1, 2)
            BEGIN
               BEGIN TRY
                  EXEC dbo.ispReleaseReplenTask_Wrapper @c_Facility = @c_Facility
                                                      , @c_zone02 = N'ALL'
                                                      , @c_zone03 = N''
                                                      , @c_zone04 = N''
                                                      , @c_zone05 = N''
                                                      , @c_zone06 = N''
                                                      , @c_zone07 = N''
                                                      , @c_zone08 = N''
                                                      , @c_zone09 = N''
                                                      , @c_zone10 = N''
                                                      , @c_zone11 = N''
                                                      , @c_zone12 = N''
                                                      , @c_Storerkey = @c_Storerkey
                                                      , @b_success = @b_success OUTPUT -- int
                                                      , @n_err = @n_err OUTPUT -- int
                                                      , @c_errmsg = @c_errmsg OUTPUT -- nvarchar(250)

               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END CATCH
            END
         END
      END
   END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_PICK_SHORT ','u') IS NOT NULL 
      DROP TABLE #TMP_PICK_SHORT

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