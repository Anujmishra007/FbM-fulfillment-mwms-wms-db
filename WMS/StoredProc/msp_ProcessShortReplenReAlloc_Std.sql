SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: msp_ProcessShortReplenReAlloc_Std                   */
/* Creation Date: 31-Jul-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-14930 Std SP for Short Replenishment Reallocation        */
/*                                                                       */
/* Called By: Q-Commander                                                */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 31-Jul-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_ProcessShortReplenReAlloc_Std] (    
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
   --General    
   DECLARE @n_Continue                 INT = 1
         , @n_StartTCnt                INT
         , @c_StorerKey                NVARCHAR(15) = ''

   DECLARE @c_PickDetailKey            NVARCHAR(18) = ''
         , @CUR_UNALLOC                CURSOR
         , @CUR_ALLOC                  CURSOR
         , @c_Facility                 NVARCHAR(5)  = ''
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
         , @c_CLNotes                  NVARCHAR(MAX) = ''
         , @c_ShortPickSP              NVARCHAR(100) = 'msp_ProcessShortPickReAlloc02'
         , @c_PickTaskType             NVARCHAR(100) = ''
         , @c_PickTaskStatus           NVARCHAR(100) = ''
         , @c_DelPickdetail            NVARCHAR(1)   = 'N'

   SET @n_StartTCnt = @@TRANCOUNT
   SET @b_Success = 0
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_debug = ISNULL(@b_debug, 0)
   
   IF @n_Continue = 1
   BEGIN
      IF OBJECT_ID('tempdb..#TMP_PICK_SHORT', 'U') IS NOT NULL
         DROP TABLE #TMP_PICK_SHORT

      IF OBJECT_ID('tempdb..#TMP_TASK_PICK', 'U') IS NOT NULL
         DROP TABLE #TMP_TASK_PICK

      CREATE TABLE #TMP_PICK_SHORT
      (
         Pickdetailkey  NVARCHAR(18) PRIMARY KEY
       , Wavekey        NVARCHAR(10)
      )

      CREATE TABLE #TMP_TASK_PICK
      (
         Taskdetailkey  NVARCHAR(10) PRIMARY KEY
      )
   END

   IF @b_debug = 0 AND @n_Continue = 1
   BEGIN
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END

   -- Validation
   IF @n_Continue = 1
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM TASKDETAIL (NOLOCK)
                      WHERE TaskDetailKey = @c_Taskdetailkey
                      AND TaskType = 'RPF' )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 65000
         SET @c_Errmsg = 'NSQL'+ CONVERT(NVARCHAR(5), @n_Err)+': Taskdetailkey#: ' + TRIM(@c_Taskdetailkey) + ' is not a valid RPF task. (msp_ProcessShortReplenReAlloc_Std)'
                       + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(TRIM(@c_Errmsg), '') + ' ) '   
      END
   END

   -- Initialize Data
   IF @n_Continue = 1
   BEGIN
      -- @n_DynReplen
      -- 1 - Dynamic Replen
      -- 0 - Normal Min-Max Replen
      SELECT @n_DynReplen = IIF(ISNULL(TD.WaveKey, '') = '', 0, 1)
           , @c_StorerKey = TD.Storerkey
           , @c_Facility = L.Facility
           , @c_SKU = CASE WHEN ISNULL(@c_SKU, '') = '' THEN TD.SKU ELSE @c_SKU END
      FROM TASKDETAIL TD (NOLOCK)
      JOIN LOC L (NOLOCK) ON TD.FromLoc = L.Loc
      WHERE TD.TaskDetailKey = @c_Taskdetailkey
      AND TD.TaskType = 'RPF'

      -- Configuration for SHORTREPL
      SELECT TOP 1 @c_CLNotes = ISNULL(CL.Notes, '')
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'SHORTREPL'
      AND CL.Storerkey = @c_Storerkey
      AND CL.Short = 'Y'
      AND CL.Long = 'msp_ProcessShortReplenReAlloc_Std'
      AND (ISNULL(TRIM(CL.Code2), '') = '' OR CL.Code2 = @c_Facility)
      ORDER BY CASE WHEN ISNULL(TRIM(CL.Code2), '') = @c_Facility THEN 0 ELSE 1 END

      IF @@ROWCOUNT = 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 65001
         SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                       + ': CODELKUP SHORTREPL not set up for Storerkey: ' + ISNULL(TRIM(@c_Storerkey), '')
                       + ', Facility: ' + ISNULL(TRIM(@c_Facility), '')
                       + ' (msp_ProcessShortReplenReAlloc_Std)'
      END

      IF @n_Continue = 1
      BEGIN
         SELECT @c_ShortPickSP = dbo.fnc_GetParamValueFromString('@c_ShortPickSP', @c_CLNotes, @c_ShortPickSP)
         SELECT @c_ReplenishStrategy = dbo.fnc_GetParamValueFromString('@c_ReplenishStrategy', @c_CLNotes, @c_ReplenishStrategy)
         SELECT @c_ReplenType = dbo.fnc_GetParamValueFromString('@c_ReplenType', @c_CLNotes, @c_ReplenType)
         SELECT @c_PickTaskType = dbo.fnc_GetParamValueFromString('@c_PickTaskType', @c_CLNotes, @c_PickTaskType)
         SELECT @c_PickTaskStatus = dbo.fnc_GetParamValueFromString('@c_PickTaskStatus', @c_CLNotes, @c_PickTaskStatus)
         SELECT @c_DelPickdetail = dbo.fnc_GetParamValueFromString('@c_DelPickdetail', @c_CLNotes, @c_DelPickdetail)
         
         IF ISNULL(TRIM(@c_ReplenishStrategy), '') = ''
            SET @c_ReplenishStrategy = 'Gen-UCC'
         
         IF ISNULL(TRIM(@c_ReplenType), '') = ''
            SET @c_ReplenType = 'R'

         IF ISNULL(TRIM(@c_PickTaskType), '') = ''
            SET @c_PickTaskType = 'ASTCPK, FCP'

         IF ISNULL(TRIM(@c_PickTaskStatus), '') = ''
            SET @c_PickTaskStatus = '0, H'

         IF ISNULL(TRIM(@c_DelPickdetail), '') = ''
            SET @c_DelPickdetail = 'N'

         SET @n_DynReplen = ISNULL(@n_DynReplen, 0)

         IF @n_DynReplen = 1
         BEGIN
            IF (ISNULL(TRIM(@c_ShortPickSP), '') = '' OR OBJECT_ID(TRIM(@c_ShortPickSP), 'P') IS NULL)
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 65002
               SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err)
                           + ': Short Pick SP not found: ' + ISNULL(@c_ShortPickSP, '') + ' (msp_ProcessShortReplenReAlloc_Std)'
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1 @c_ReplenishCode = ISNULL(TRIM(RSD.ReplenCode), '')
            FROM REPLENISHSTRATEGYDETAIL RSD (NOLOCK)
            WHERE RSD.ReplenishStrategykey = @c_ReplenishStrategy
            AND (RSD.ReplenCode IS NOT NULL AND RSD.ReplenCode <> '')
      
            IF CHARINDEX('@', @c_ReplenishCode) > 0
               SET @c_ReplenSPName = TRIM(SUBSTRING(@c_ReplenishCode, 1, CHARINDEX('@', @c_ReplenishCode, 1) - 1))
            ELSE
               SET @c_ReplenSPName = TRIM(@c_ReplenishCode)
         END
      END
   END

   -- Prepare temp data
   IF @n_Continue = 1 AND @n_DynReplen = 1
   BEGIN
      SELECT @c_FinalLoc = ISNULL(TD.FinalLOC, '')
           , @c_FinalID  = ISNULL(TD.FinalID, '')
      FROM TASKDETAIL TD (NOLOCK)
      WHERE TD.TaskDetailKey = @c_Taskdetailkey
      AND TD.TaskType = 'RPF'

      IF ISNULL(@c_FinalLoc, '') = ''
      BEGIN
         SELECT @c_FinalLoc = ISNULL(TD.ToLoc, '')
              , @c_FinalID  = ISNULL(TD.ToID, '')
         FROM TASKDETAIL TD (NOLOCK)
         WHERE TD.TaskDetailKey = @c_Taskdetailkey
         AND TD.TaskType = 'RPF'
      END
      
      INSERT INTO #TMP_TASK_PICK (Taskdetailkey)
      SELECT TD.Taskdetailkey
      FROM TASKDETAIL TD (NOLOCK)
      WHERE TD.Storerkey = @c_StorerKey
      AND TD.Sku = @c_SKU
      AND TD.TaskType IN (SELECT TRIM([Value]) FROM STRING_SPLIT(@c_PickTaskType, ','))
      AND TD.FromLoc = @c_FinalLoc
      --AND TD.FromID = @c_FinalID
      AND TD.[Status] IN (SELECT TRIM([Value]) FROM STRING_SPLIT(@c_PickTaskStatus, ','))
      
      INSERT INTO #TMP_PICK_SHORT (Pickdetailkey, Wavekey)
      SELECT DISTINCT PD.Pickdetailkey, PD.Wavekey
      FROM PICKDETAIL PD (NOLOCK)
      WHERE PD.Storerkey = @c_StorerKey
      AND PD.SKU = @c_SKU
      AND EXISTS ( SELECT 1
                   FROM #TMP_TASK_PICK TF
                   WHERE TF.Taskdetailkey = PD.TaskDetailKey )
   END

   IF @n_Continue = 1
   BEGIN
      -- Dynamic Replen - @n_DynReplen = 1
      IF @n_DynReplen = 1
      BEGIN
         -- Update all FCP tasks to X
         IF @n_Continue = 1
         AND EXISTS ( SELECT 1
                      FROM #TMP_PICK_SHORT )
         BEGIN
            BEGIN TRY
               UPDATE TD WITH (ROWLOCK)
               SET TD.[Status] = 'X'
               FROM TASKDETAIL TD
               JOIN #TMP_TASK_PICK TF ON TD.Taskdetailkey = TF.TaskDetailKey
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3
               SET @c_ErrMsg = ERROR_MESSAGE()
            END CATCH
         END

         -- Unalloc Pickdetail
         IF @n_Continue = 1
         BEGIN
            SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT T.Pickdetailkey
            FROM #TMP_PICK_SHORT T
            ORDER BY T.Pickdetailkey
      
            OPEN @CUR_UNALLOC
      
            FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
      
            WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
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
      
         -- Call Short Pick Reallocate SP to perform downstream process
         IF @n_Continue = 1
         BEGIN
            SET @c_SQL = 'EXEC ' + TRIM(@c_ShortPickSP)
                       + '  @c_Wavekey = @c_Wavekey'
                       + ', @c_SKU = @c_SKU'
            
            IF EXISTS ( SELECT 1
                        FROM sys.parameters P (NOLOCK)
                        WHERE P.object_id = OBJECT_ID(TRIM(@c_ShortPickSP))
                        AND P.name = '@c_Loc' )
            BEGIN
               SET @c_SQL = @c_SQL + ', @c_Loc = @c_FinalLoc'
            END
            ELSE IF EXISTS ( SELECT 1
                             FROM sys.parameters P (NOLOCK)
                             WHERE P.object_id = OBJECT_ID(TRIM(@c_ShortPickSP))
                             AND P.name = '@c_UCCNo' )
            BEGIN
               SET @c_SQL = @c_SQL + ', @c_UCCNo = @c_FinalLoc'
            END

            SET @c_SQL = @c_SQL
                       + ', @c_Taskdetailkey = @c_Taskdetailkey'
                       + ', @b_Success = @b_Success OUTPUT'
                       + ', @n_Err = @n_Err OUTPUT'
                       + ', @c_ErrMsg = @c_ErrMsg OUTPUT'
                       + ', @b_Debug = @b_Debug'

            SET @c_SQLParms = '  @c_Wavekey       NVARCHAR(10)'
                            + ', @c_SKU           NVARCHAR(20)'
                            + ', @c_FinalLoc      NVARCHAR(20)'
                            + ', @c_Taskdetailkey NVARCHAR(10)'
                            + ', @b_Success       INT           OUTPUT'
                            + ', @n_Err           INT           OUTPUT'
                            + ', @c_ErrMsg        NVARCHAR(225) OUTPUT'
                            + ', @b_Debug         INT'

            SET @CUR_ALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT T.Wavekey
            FROM #TMP_PICK_SHORT T
            ORDER BY T.Wavekey
      
            OPEN @CUR_ALLOC
      
            FETCH NEXT FROM @CUR_ALLOC INTO @c_GetWavekey
      
            WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
            BEGIN
               BEGIN TRY
                  EXEC sp_ExecuteSql @c_SQL
                                   , @c_SQLParms
                                   , @c_GetWavekey
                                   , @c_SKU
                                   , @c_FinalLoc
                                   , @c_Taskdetailkey
                                   , @b_Success       OUTPUT
                                   , @n_Err           OUTPUT
                                   , @c_ErrMsg        OUTPUT
                                   , @b_Debug

                  -- Check for errors from ShortPick SP
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

            -- DELETE Pickdetail by config
            IF @n_Continue = 1 AND @c_DelPickdetail = 'Y'
            BEGIN
               SET @CUR_UNALLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT T.Pickdetailkey
               FROM #TMP_PICK_SHORT T
               ORDER BY T.Pickdetailkey
         
               OPEN @CUR_UNALLOC
         
               FETCH NEXT FROM @CUR_UNALLOC INTO @c_PickDetailKey
         
               WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
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
      ELSE   -- Normal Min-Max Replen - @n_DynReplen <> 1
      BEGIN
         IF ISNULL(@c_Storerkey, '') <> '' AND ISNULL(@c_Facility, '') <> ''
         BEGIN
            IF @n_Continue = 1
               AND OBJECT_ID(TRIM(@c_ReplenSPName), 'P') IS NOT NULL
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

                  IF EXISTS ( SELECT 1
                             FROM sys.parameters P (NOLOCK)
                             WHERE P.object_id = OBJECT_ID(TRIM(@c_ReplenSPName))
                             AND P.name = '@c_ReplenType' )
                  BEGIN 
                     SET @c_SQL = @c_SQL + '                                  , @c_ReplenType = @c_ReplenType '
                  END
               
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

               IF @n_Continue = 1
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
   END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_PICK_SHORT', 'U') IS NOT NULL
      DROP TABLE #TMP_PICK_SHORT

   IF OBJECT_ID('tempdb..#TMP_TASK_PICK', 'U') IS NOT NULL
      DROP TABLE #TMP_TASK_PICK

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
GRANT EXECUTE ON [dbo].[msp_ProcessShortReplenReAlloc_Std] TO [NSQL]
GO