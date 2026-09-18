SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspPARL05                                           */
/* Creation Date: 11-Sep-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-16070 - Germany - RIMAN - TM Assisted Putaway logic      */
/*                                                                       */
/* Called By: isp_ASNReleasePATask_Wrapper                               */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 11-Sep-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROC [dbo].[mspPARL05]
   @c_ReceiptKey        NVARCHAR(10)  = ''
,  @b_Success           INT           = 1 OUTPUT
,  @n_Err               INT           = 0 OUTPUT
,  @c_Errmsg            NVARCHAR(250) = '' OUTPUT
,  @b_Debug             INT           = 0
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT            = @@TRANCOUNT
         , @n_Continue        INT            = 1
         , @n_NoOfTasks       INT            = 0
         , @n_QtyReceived     INT            = 0
         , @n_PickQty         INT            = 0
         , @n_PickMinQty      INT            = 0
         , @n_PickMaxQty      INT            = 0
         , @n_EarliestExpiry  DATETIME       = NULL
         , @n_CurrentExpiry   DATETIME       = NULL
         , @b_HasPickFace     BIT            = 0
         , @b_Youngest        BIT            = 0
         , @b_Exist           BIT            = 0
         , @c_Facility        NVARCHAR(5)    = N''
         , @c_Storerkey       NVARCHAR(15)   = N''
         , @c_Sku             NVARCHAR(20)   = N''
         , @c_UOM             NVARCHAR(10)   = N''
         , @c_FromLoc         NVARCHAR(10)   = N''
         , @c_FromID          NVARCHAR(18)   = N''
         , @c_SourceKey       NVARCHAR(30)   = N''
         , @c_StagingGroup    NVARCHAR(30)   = N''
         , @c_PickLoc         NVARCHAR(10)   = N''
         , @c_PickLogicalLoc  NVARCHAR(18)   = N''
         , @c_PickBay         NVARCHAR(10)   = N''
         , @c_SuggestLoc      NVARCHAR(10)   = N''
         , @c_TaskDetailKey   NVARCHAR(10)   = N''
         , @c_TaskType        NVARCHAR(10)   = N'ASTPA'
         , @c_SourceType      NVARCHAR(30)   = N'mspPARL05'
         , @c_PickMethod      NVARCHAR(10)   = N'FP'
         , @c_AlertMessage    NVARCHAR(250)  = N''
         , @c_AlertErrmsg     NVARCHAR(250)  = N''
         , @c_Option5         NVARCHAR(MAX)  = N''
         , @c_ReturnLoc       NVARCHAR(10)   = N'1RI-R-A'
         , @c_PickPAZone      NVARCHAR(MAX)  = N'DERIM_PICK'
         , @c_BulkPAZone      NVARCHAR(MAX)  = N'DERIM_BULK'
         , @c_ToID            NVARCHAR(18)   = N''
         , @CUR_RECEIPT       CURSOR

   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_Errmsg = ''

   IF @n_Continue = 1
   BEGIN
      SELECT TOP 1 @c_Storerkey = R.StorerKey
                 , @c_Facility = R.Facility
                 , @b_Exist = 1
      FROM dbo.RECEIPT R WITH (NOLOCK)
      WHERE R.ReceiptKey = @c_ReceiptKey

      IF @b_Exist = 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 60101
         SET @c_Errmsg = 'NSQL' + TRY_CAST(@n_Err AS NVARCHAR(5))
                     + ': Receipt#: ' + @c_ReceiptKey + ' not found. (mspPARL05)'
      END
   END

   IF @n_Continue = 1
   BEGIN
      -- Get optional configuration if available
      SELECT @c_Option5 = ISNULL(fgr.Option5,'')
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ASNReleasePATask_SP') AS fgr

      IF ISNULL(@c_Option5, '') <> ''
      BEGIN
         SELECT @c_TaskType = dbo.fnc_GetParamValueFromString('@c_TaskType', @c_Option5, @c_TaskType )
         SELECT @c_ReturnLoc = dbo.fnc_GetParamValueFromString('@c_ReturnLoc', @c_Option5, @c_ReturnLoc )
         SELECT @c_PickPAZone = dbo.fnc_GetParamValueFromString('@c_PickPAZone', @c_Option5, @c_PickPAZone )
         SELECT @c_BulkPAZone = dbo.fnc_GetParamValueFromString('@c_BulkPAZone', @c_Option5, @c_BulkPAZone )
      END
   END

   IF @@TRANCOUNT = 0 AND @b_Debug = 0
   BEGIN
      BEGIN TRANSACTION
   END

   IF @n_Continue = 1
   BEGIN
      BEGIN TRY
         SET @CUR_RECEIPT = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT RD.StorerKey
              , R.Facility
              , RD.Sku
              , RD.UOM
              , RD.ToLoc
              , RD.ToId
              , TRIM(RD.ReceiptKey) + TRIM(RD.ReceiptLineNumber)
              , RD.QtyReceived
              , RD.Lottable04
         FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
         JOIN dbo.RECEIPT R WITH (NOLOCK) ON R.ReceiptKey = RD.ReceiptKey
         WHERE RD.ReceiptKey = @c_ReceiptKey
         AND   RD.FinalizeFlag = 'Y'
         AND   RD.QtyReceived > 0
         AND   RD.ToId IS NOT NULL
         AND   RD.ToId <> ''
         AND   NOT EXISTS ( SELECT 1
                            FROM dbo.TaskDetail TD WITH (NOLOCK)
                            WHERE TD.SourceType = @c_SourceType
                            AND   TD.SourceKey = TRIM(RD.ReceiptKey) + TRIM(RD.ReceiptLineNumber)
                            AND   TD.FromID = RD.ToId
                            AND   TD.TaskType = @c_TaskType
                            AND   TD.Storerkey = RD.StorerKey
                            AND   TD.[Status] NOT IN ('9', 'X') )
         ORDER BY RD.ReceiptLineNumber

         OPEN @CUR_RECEIPT
         FETCH NEXT FROM @CUR_RECEIPT
         INTO @c_Storerkey, @c_Facility, @c_Sku, @c_UOM, @c_FromLoc, @c_FromID
            , @c_SourceKey, @n_QtyReceived, @n_CurrentExpiry

         WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
         BEGIN
            SET @c_PickLoc = ''
            SET @c_PickLogicalLoc = ''
            SET @c_PickBay = ''
            SET @c_SuggestLoc = ''
            SET @n_PickQty = 0
            SET @n_PickMinQty = 0
            SET @n_PickMaxQty = 0
            SET @n_EarliestExpiry = NULL
            SET @b_HasPickFace = 0
            SET @b_Youngest = 0
            SET @c_ToID = ''

            SELECT TOP 1
                   @c_PickLoc = SL.Loc
                 , @c_PickLogicalLoc = ISNULL(L.LogicalLocation, '')
                 , @c_PickBay = ISNULL(L.LocBay, '')
                 , @n_PickMinQty = SL.QtyLocationMinimum
                 , @n_PickMaxQty = SL.QtyLocationLimit
                 , @n_PickQty = SL.Qty
                              + ISNULL(SLEX.PendingMoveIn, 0)
                 , @b_HasPickFace = 1
            FROM dbo.SKUxLOC SL WITH (NOLOCK)
            JOIN dbo.LOC L WITH (NOLOCK) ON L.Loc = SL.Loc
            OUTER APPLY dbo.fnc_SKUXLOC_Extended( SL.StorerKey
                                                , SL.Sku
                                                , SL.Loc
                                                ) AS SLEX
            WHERE SL.StorerKey = @c_Storerkey
            AND   SL.Sku = @c_Sku
            AND   SL.LocationType = 'PICK'
            AND   EXISTS ( SELECT 1
                           FROM STRING_SPLIT(@c_PickPAZone, ',') PAZone
                           WHERE TRIM(PAZone.value) = L.PutawayZone )
            AND   L.Facility = @c_Facility
            ORDER BY L.LogicalLocation, L.Loc

            IF @b_HasPickFace = 0
            BEGIN
               SET @c_AlertMessage = 'No Pick Face location assigned.'
               SET @c_AlertErrmsg = ''

               BEGIN TRY
                  EXEC dbo.nspLogAlert
                       @c_modulename = 'mspPARL05'
                     , @c_AlertMessage = @c_AlertMessage
                     , @n_Severity = '5'
                     , @b_success = @b_Success OUTPUT
                     , @n_err = @n_Err OUTPUT
                     , @c_errmsg = @c_AlertErrmsg OUTPUT
                     , @c_Activity = 'Release Putaway Task'
                     , @c_Storerkey = @c_Storerkey
                     , @c_SKU = @c_Sku
                     , @c_UOM = @c_UOM
                     , @c_UOMQty = @n_QtyReceived
                     , @c_Qty = @n_QtyReceived
                     , @c_Lot = ''
                     , @c_Loc = @c_FromLoc
                     , @c_ID = @c_FromID
                     , @c_TaskDetailKey = ''
                     , @c_UCCNo = ''
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_Errmsg = ERROR_MESSAGE()
               END CATCH
            END

            -- Main Process
            IF @n_Continue = 1
            BEGIN
               -- Returns PA Logic
               IF @c_FromLoc = @c_ReturnLoc AND @b_HasPickFace = 1
               BEGIN
                  SET @c_SuggestLoc = @c_PickLoc
               END
               -- Standard PA Logic with Pickface
               ELSE IF @b_HasPickFace = 1
               BEGIN
                  -- Pickface is full
                  IF @n_PickQty >= @n_PickMaxQty
                  BEGIN
                     SELECT TOP 1 @c_SuggestLoc = L.Loc
                     FROM dbo.LOC L WITH (NOLOCK)
                     OUTER APPLY ( SELECT TotalPallet = COUNT(DISTINCT LLI.ID)
                                   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                                   WHERE LLI.Loc = L.Loc
                                   AND   LLI.ID > ''
                                   AND   LLI.Qty + LLI.PendingMoveIn > 0 ) Occupancy
                     WHERE L.Facility = @c_Facility
                     AND   L.Status = 'OK'
                     AND   L.MaxPallet > 0
                     AND   EXISTS (  SELECT 1
                                     FROM STRING_SPLIT(@c_BulkPAZone, ',') PAZone
                                     WHERE TRIM(PAZone.[value]) = L.PutawayZone )
                     AND   L.LocBay = @c_PickBay
                     AND   ABS(TRY_CAST(L.LogicalLocation AS INT) - TRY_CAST(@c_PickLogicalLoc AS INT)) <= 2
                     AND   Occupancy.TotalPallet < L.MaxPallet
                     ORDER BY ABS(TRY_CAST(L.LogicalLocation AS INT) - TRY_CAST(@c_PickLogicalLoc AS INT))
                            , L.LogicalLocation
                            , L.Loc
                  END
                  ELSE
                  BEGIN
                     -- Search youngest Lottable04 from existing inventory
                     SELECT @n_EarliestExpiry = MIN(LA.Lottable04)
                     FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                     JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LA.Lot = LLI.Lot
                     JOIN dbo.LOC L WITH (NOLOCK) ON L.Loc = LLI.Loc
                     WHERE LLI.StorerKey = @c_Storerkey
                     AND   LLI.Sku = @c_Sku
                     AND   LLI.Qty > 0
                     AND   L.Facility = @c_Facility
                     AND   L.LocationCategory NOT IN ('STAGE')

                     -- Search youngest Lottable04 from staging.
                     SELECT @n_EarliestExpiry = CASE WHEN @n_EarliestExpiry IS NULL
                                                   OR MIN(RD.Lottable04) < @n_EarliestExpiry
                                                THEN MIN(RD.Lottable04)
                                                ELSE @n_EarliestExpiry END
                     FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
                     JOIN dbo.LOC L WITH (NOLOCK) ON L.Loc = RD.ToLoc
                     WHERE RD.StorerKey = @c_Storerkey
                     AND   RD.Sku = @c_Sku
                     AND   RD.ToID IS NOT NULL
                     AND   RD.ToID <> ''
                     AND   RD.FinalizeFlag <> 'Y'
                     AND   L.LocationCategory IN ('STAGE')
                     AND   L.Facility = @c_Facility

                     IF @n_CurrentExpiry IS NOT NULL
                        AND ( @n_EarliestExpiry IS NULL OR @n_CurrentExpiry <= @n_EarliestExpiry )
                     BEGIN
                        SET @b_Youngest = 1
                     END

                     IF @b_Youngest = 1
                        AND @n_PickQty + @n_QtyReceived <= @n_PickMaxQty
                        AND @n_PickQty + @n_QtyReceived >= @n_PickMinQty
                     BEGIN
                        SET @c_SuggestLoc = @c_PickLoc
                     END
                  END
               END

               -- Standard PA Logic
               --    SKU without Pickface
               --    LPN contains the youngest Lottable04 but capacity not available
               --    LPN does not contains the youngest Lottable04
               IF @c_SuggestLoc = ''
               BEGIN
                  SELECT TOP 1 @c_SuggestLoc = L.Loc
                  FROM dbo.LOC L WITH (NOLOCK)
                    OUTER APPLY ( SELECT TotalPallet = COUNT(DISTINCT LLI.ID)
                        FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                        WHERE LLI.Loc = L.Loc
                        AND   LLI.ID > ''
                        AND   LLI.Qty + LLI.PendingMoveIn > 0 ) Occupancy
                  WHERE L.Facility = @c_Facility
                  AND   L.Status = 'OK'
                  AND   L.MaxPallet > 0
                  AND   EXISTS (  SELECT 1
                                  FROM STRING_SPLIT(@c_BulkPAZone, ',') PAZone
                                  WHERE TRIM(PAZone.[value]) = L.PutawayZone )
                  AND   Occupancy.TotalPallet < L.MaxPallet
                  ORDER BY CASE WHEN @b_HasPickFace = 1 THEN ABS(TRY_CAST(L.LogicalLocation AS INT) - TRY_CAST(@c_PickLogicalLoc AS INT))
                                ELSE 0 END
                         , L.LogicalLocation
                         , L.Loc
               END

               IF @c_SuggestLoc = ''
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err = 60103
                  SET @c_Errmsg = 'NSQL' + TRY_CAST(@n_Err AS NVARCHAR(5))
                              + ': No racking location is available for ID# '
                              + @c_FromID + ' (mspPARL05)'
                  BREAK
               END

               SELECT @c_ToID = IIF(LOC.LoseID = '1', '', @c_FromID)
               FROM dbo.LOC (NOLOCK)
               WHERE LOC.Loc = @c_SuggestLoc
               AND LOC.Facility = @c_Facility

               -- Insert Task
               SET @c_TaskDetailKey = ''
               BEGIN TRY
                  EXEC dbo.isp_InsertTaskDetail @c_TaskDetailKey = @c_TaskDetailKey OUTPUT
                                              , @c_TaskType = @c_TaskType
                                              , @c_Storerkey = @c_Storerkey
                                              , @c_Sku = @c_Sku
                                              , @c_UOM = ''
                                              , @n_UOMQty = @n_QtyReceived
                                              , @n_Qty = @n_QtyReceived
                                              , @c_FromLoc = @c_FromLoc
                                              , @c_LogicalFromLoc = '?'
                                              , @c_FromID = @c_FromID
                                              , @c_ToLoc = @c_SuggestLoc
                                              , @c_LogicalToLoc = '?'
                                              , @c_ToID = @c_ToID
                                              , @c_PickMethod = @c_PickMethod
                                              , @c_Status = '0'
                                              , @c_Priority = '5'
                                              , @c_SourcePriority = '9'
                                              , @c_SourceType = @c_SourceType
                                              , @c_SourceKey = @c_SourceKey
                                              , @n_SystemQty = @n_QtyReceived
                                              , @c_ReservePendingMoveIn = 'Y'
                                              , @c_AreaKey = '?F'
                                              , @c_CallSource = 'ASN'
                                              , @b_Success = @b_Success OUTPUT
                                              , @n_Err = @n_Err OUTPUT
                                              , @c_ErrMsg = @c_ErrMsg OUTPUT
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_Err = ERROR_NUMBER()
                  SET @c_Errmsg = ERROR_MESSAGE()
                  BREAK
               END CATCH

               SET @n_NoOfTasks = @n_NoOfTasks + 1
            END

            FETCH NEXT FROM @CUR_RECEIPT
            INTO @c_Storerkey, @c_Facility, @c_Sku, @c_UOM, @c_FromLoc, @c_FromID
               , @c_SourceKey, @n_QtyReceived, @n_CurrentExpiry
         END
         CLOSE @CUR_RECEIPT
         DEALLOCATE @CUR_RECEIPT
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END

   IF CURSOR_STATUS('local', '@CUR_RECEIPT') >= 0
      CLOSE @CUR_RECEIPT

   IF CURSOR_STATUS('local', '@CUR_RECEIPT') > -3
      DEALLOCATE @CUR_RECEIPT

   IF (XACT_STATE()) = -1  
   BEGIN
      IF @@TRANCOUNT > 0 
      BEGIN
         ROLLBACK TRAN
      END
   END

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspPARL05'
   END
   ELSE
   BEGIN
      IF @n_NoOfTasks > 0  
      BEGIN
         SET @c_errmsg = 'Total ' + @c_TaskType + ' Task: ' + CONVERT(NVARCHAR(5), @n_NoOfTasks)+ ' released sucessfully.'
      END
      ELSE IF @n_NoOfTasks = 0  
      BEGIN
         SET @c_errmsg = 'No ' + @c_TaskType + ' Task released.'        
      END
 
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO
GRANT EXECUTE ON [dbo].[mspPARL05] TO [NSQL]
GO