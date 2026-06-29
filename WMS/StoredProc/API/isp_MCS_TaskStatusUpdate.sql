-- On STAGE use [GLOWMS]
-- On PROD use [DNKWMS]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: isp_MCS_TaskStatusUpdate			                     */
/* Creation Date: 25-03-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: VMA237                                                        */
/*                                                                           */
/* Purpose : Process task status updates received from MCS.					 */
/*                                                                           */
/* Called By: MCS Integration (Task Status Update process)                   */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 25-03-2026   VMA237   1.0  Initial version created                        */
/* 25-06-2026   VMA237   1.1  "NoLoad" process update                        */
/*																			 */
/*****************************************************************************/
CREATE OR ALTER             PROC [dbo].[isp_MCS_TaskStatusUpdate]
(
    @cPalletId         NVARCHAR(30),
    @cTaskId           NVARCHAR(10),
    @cStatus           NVARCHAR(50),
    @cActualDropLoc    NVARCHAR(50),
    @bSuccess          BIT				OUTPUT,
    @nErrNo            INT				OUTPUT,
    @cErrMsg           NVARCHAR(4000)	OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_NULLS OFF
	SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF
	SET ANSI_WARNINGS ON

	-- General task data
	DECLARE @cFacility		NVARCHAR(10)
	DECLARE @cStorerKey		NVARCHAR(15)
    DECLARE @cTaskDetailKey NVARCHAR(50);
	DECLARE @cTaskStatus	NVARCHAR(10);
	DECLARE @cTaskType		NVARCHAR(20);
	DECLARE @nQTY			INT
	DECLARE @cUserName      NVARCHAR(18);
	DECLARE	@nMobile        INT;
	DECLARE	@nFunc          INT;
	DECLARE @cLangCode      NVARCHAR(3);
	DECLARE @cFromLoc		NVARCHAR(18);
	DECLARE @cSuggToLoc		NVARCHAR(18);
	DECLARE @nTranCount INT;

	-- Default integration user and output values
    SET @cUserName			= 'MCS_TASK_STS_UPD';
	SET @bSuccess = 0;
    SET @nErrNo = 0;
    SET @cErrMsg = '';


    BEGIN TRY
        -- Load task details for the received TaskId
        SELECT TOP 1
			@cFacility = loc.Facility,
			@cStorerKey = td.StorerKey,
            @cTaskDetailKey = td.TaskDetailKey,
			@cTaskType = td.TaskType,
            @cTaskStatus = td.[Status],
			@cFromLoc = td.Fromloc,
			@cSuggToLoc = ISNULL(td.ToLoc, td.LogicalToLoc),
			@nQTY = td.Qty
        FROM TASKDETAIL td (NOLOCK)
		INNER JOIN LOC loc (NOLOCK) on loc.Loc = td.FromLoc
        WHERE TaskDetailKey = @cTaskId
		AND FromID = @cPalletId;

        -- Task exists
        IF @cTaskDetailKey IS NOT NULL
        BEGIN
            -- Task exists
            IF @cTaskStatus = '9'
            BEGIN
                -- No action needed
                SET @bSuccess = 1;
                RETURN;
            END

            -- Completed status received from MCS
            IF UPPER(ISNULL(@cStatus, '')) = 'COMPLETED'
            BEGIN
				-- Only PAF and FPK task types are supported for completion flow
				IF @cTaskType NOT IN ('PAF', 'FPK')
				BEGIN
					SET @nErrNo = 51052
					SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- BadTaskDtlKey 
				END
				
				-- Putaway task: confirm task and complete stock movement
				IF @cTaskType = 'PAF'
				BEGIN

					SET @nMobile			= '';
					SET @nFunc				= 1797;
					SET @cLangCode			=  'ENG';

					-- Start own transaction only if none exists, otherwise use savepoint
					SET @nTranCount = @@TRANCOUNT
					
					IF @nTranCount = 0
					BEGIN
					    BEGIN TRAN
					END
					ELSE
					BEGIN
					    SAVE TRAN MCS_Putaway_Confirmation
					END

					-- If actual drop location differs from suggested location, overwrite ToLoc before confirmation
					IF ISNULL(@cActualDropLoc, '') <> ISNULL(@cSuggToLoc, '')
					BEGIN
					   UPDATE dbo.TaskDetail SET
					      ToLoc = @cActualDropLoc
					   WHERE TaskDetailKey = @cTaskDetailKey

					   IF @@ERROR <> 0
					   BEGIN
						   SET @nErrNo = 79364
						   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- OverWrite Fail

						   IF @nTranCount = 0
						   BEGIN
							   ROLLBACK TRAN
						   END
						   ELSE
						   BEGIN
							   ROLLBACK TRAN MCS_Putaway_Confirmation
						   END

						   RETURN
					   END
					END
					
					-- Save received status into TaskDetail.Message02 for completed updates
					UPDATE dbo.TaskDetail
					SET Message02 = @cStatus,
						EditDate = GETDATE(),
						EditWho = @cUserName
					WHERE TaskDetailKey = @cTaskDetailKey;

					-- Confirm putaway task through standard RDT logic
					EXEC rdt.rdt_TM_PutawayFrom_Confirm 
								@nMobile, 
								@nFunc, 
								@cLangCode, 
								@cUserName,
								@cTaskDetailKey,
								@nErrNo  OUTPUT,
								@cErrMsg OUTPUT;
					
					-- Remove zero-qty stock line if task is fully completed and no open tasks remain for the pallet
					IF EXISTS (
						SELECT 1
						FROM LOTxLOCxID (NOLOCK)
						WHERE ID = @cPalletId
						AND Loc = @cSuggToLoc
						AND QTY = 0
						AND PendingMoveIN > 0
					)
					AND NOT EXISTS (
						SELECT 1
						FROM TaskDetail (NOLOCK)
						WHERE FromID = @cPalletId
						AND Status <> '9'
					)
					BEGIN
						UPDATE LOTxLOCxID SET PendingMoveIN = 0 WHERE ID = @cPalletId AND Loc = @cSuggToLoc AND QTY = 0 AND PendingMoveIN > 0
					END

					-- Roll back or commit depending on confirmation result
					IF @nErrNo <> 0
					BEGIN
						IF @nTranCount = 0
						BEGIN
							ROLLBACK TRAN
						END
						ELSE
						BEGIN
							ROLLBACK TRAN MCS_Putaway_Confirmation
						END

						RETURN;
					END
					ELSE
					BEGIN
						IF @nTranCount = 0
						BEGIN
							COMMIT TRAN;
						END

						SET @bSuccess = 1;
						RETURN;
					END
				END

				-- Full pallet pick task: confirm task and complete stock movement
				IF @cTaskType = 'FPK'
				BEGIN

					SET @nMobile			= '';
					SET @nFunc				= 1770;
					SET @cLangCode			=  'ENG';

					-- Start own transaction only if none exists, otherwise use savepoint
					SET @nTranCount = @@TRANCOUNT
					
					IF @nTranCount = 0
					BEGIN
					    BEGIN TRAN
					END
					ELSE
					BEGIN
					    SAVE TRAN MCS_FP_Pick_Confirmation
					END

					-- For FPK tasks, actual drop location must match suggested location
					IF ISNULL(@cActualDropLoc, '') <> ISNULL(@cSuggToLoc, '')
					BEGIN
						SET @nErrNo = 79364
						SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- OverWrite Fail

						IF @nTranCount = 0
						BEGIN
							ROLLBACK TRAN
						END
						ELSE
						BEGIN
							ROLLBACK TRAN MCS_FP_Pick_Confirmation
						END

						RETURN
					END

					-- Save received status into TaskDetail.Message02 for completed updates
					UPDATE dbo.TaskDetail
					SET Message02 = @cStatus,
						EditDate = GETDATE(),
						EditWho = @cUserName,
						-- Correct Status from 0 to 5, rdt_TM_PalletPick_Confirm expects status not to be 0
						[Status] = CASE WHEN @cTaskStatus = 0 THEN 5 ELSE @cTaskStatus END
					WHERE TaskDetailKey = @cTaskDetailKey;

					-- For FPK tasks, actual drop location must match suggested location
					EXECUTE [RDT].[rdt_TM_PalletPick_Confirm] 
								@nMobile = @nMobile,
								@nFunc = @nFunc,
								@cLangCode = @cLangCode,
								@cUserName = @cUserName,
								@cFacility = @cFacility,
								@cStorerKey = @cStorerKey,
								@cTaskDetailKey = @cTaskDetailKey,
								@cDropID = @cPalletId,
								@nQTY = @nQTY,
								@cFinalLOC = @cActualDropLoc,
								@cReasonKey = '',
								@cListKey = '',
								@nErrNo = @nErrNo OUTPUT,
								@cErrMsg = @cErrMsg OUTPUT,
								@cDebug = NULL
					
					-- Roll back or commit depending on confirmation result
					IF @nErrNo <> 0
					BEGIN
						IF @nTranCount = 0
						BEGIN
							ROLLBACK TRAN
						END
						ELSE
						BEGIN
							ROLLBACK TRAN MCS_FP_Pick_Confirmation
						END

						RETURN;
					END
					ELSE
					BEGIN
						IF @nTranCount = 0
						BEGIN
							COMMIT TRAN
						END

						SET @bSuccess = 1;
						RETURN;
					END
				END
            END
            ELSE
            BEGIN
                -- Save received status into TaskDetail.Message02 for non-completed updates
                UPDATE dbo.TaskDetail
                SET Message02 = @cStatus,
                    EditDate = GETDATE(),
                    EditWho = @cUserName
                WHERE TaskDetailKey = @cTaskDetailKey;

				-- Statuses that only require tracking in Message02
				IF UPPER(ISNULL(@cStatus, '')) IN ('IN TRANSIT', 'UNLOADED')
				BEGIN
					-- No additional action
					SET @bSuccess = 1;
					RETURN;
				END

				-- Occupied: suspend task and store actual drop location in Message03
				IF UPPER(ISNULL(@cStatus, '')) = 'OCCUPIED'
				BEGIN
					UPDATE dbo.TaskDetail
					SET [Status] = 'S',
						Message03 = @cActualDropLoc,
						EditDate = GETDATE(),
						EditWho = @cUserName
					WHERE TaskDetailKey = @cTaskDetailKey;
				END

				-- NoLoad: suspend task and place source location on hold (for full pallet pick task only)
				IF UPPER(ISNULL(@cStatus, '')) = 'NOLOAD'
				BEGIN
					UPDATE dbo.TaskDetail
					SET [Status] = 'S',
						EditDate = GETDATE(),
						EditWho = @cUserName
					WHERE TaskDetailKey = @cTaskDetailKey;
					
					-- VMA237 - v1.1 Start
					IF (
						@cTaskType = 'FPK'
					)
					BEGIN
						DECLARE @c_Remark NVARCHAR (255) = 'LPN# ' + @cPalletId + ' is missing there. '
															+ 'Task # '+ @cTaskDetailKey

						EXECUTE [WM].[lsp_Inventoryhold_Wrapper] 
								   @c_StorerKey		= @cStorerKey
								  ,@c_SKU = NULL
								  ,@c_lot = NULL
								  ,@c_Loc = @cFromLoc
								  ,@c_ID = NULL
								  ,@c_lottable01 = NULL
								  ,@c_lottable02 = NULL
								  ,@c_lottable03 = NULL
								  ,@dt_lottable04 = NULL
								  ,@dt_lottable05 = NULL
								  ,@c_lottable06 = NULL
								  ,@c_lottable07 = NULL
								  ,@c_lottable08 = NULL
								  ,@c_lottable09 = NULL
								  ,@c_lottable10 = NULL
								  ,@c_lottable11 = NULL
								  ,@c_lottable12 = NULL
								  ,@dt_lottable13 = NULL
								  ,@dt_lottable14 = NULL
								  ,@dt_lottable15 = NULL
								  ,@c_Status = '2060'
								  ,@c_Hold = '1'
								  ,@c_Remark = @c_Remark
								  ,@b_Success = @bSuccess OUTPUT
								  ,@n_Err = @nErrNo OUTPUT
								  ,@c_ErrMsg = @cErrMsg OUTPUT
								  ,@c_UserName = @cUserName
								  ,@c_UCCNo = NULL
					END
					-- VMA237 - v1.1 End
					
					SET @bSuccess = 1;
					RETURN;
				END

                SET @bSuccess = 1;
                RETURN;
            END
        END

        -- Task does not exist
        ELSE
        BEGIN
			-- If pallet exists on stock, move it to the actual drop location
            IF EXISTS (
                SELECT 1
                FROM PALLET (NOLOCK)
                WHERE PalletKey = @cPalletId
            )
            AND EXISTS (
                SELECT 1
                FROM LOTxLOCxID (NOLOCK)
                WHERE ID = @cPalletId
				AND QTY > 0
            )
            BEGIN
				-- Declare variables for stock move
				DECLARE @cSku nvarchar(20);
				DECLARE @cLot nvarchar(10);
				DECLARE @cLoc nvarchar(10);
				DECLARE @nToQty int;
				DECLARE @cToPackkey nvarchar(10);

				-- Get values for stock move variables
				SELECT
					TOP 1
					@cStorerkey = lli.StorerKey
					,@cSku = lli.Sku
					,@cLot = lli.Lot
					,@cLoc = lli.Loc
					,@nToQty = lli.Qty
					,@cToPackkey = sku.PACKKey
                FROM LOTxLOCxID lli (NOLOCK)
				INNER JOIN SKU sku (NOLOCK)
					ON sku.StorerKey = lli.StorerKey
					AND sku.Sku = lli.Sku
                WHERE lli.ID = @cPalletId

                -- Move LPN to actual drop location using standard stock move wrapper
				EXECUTE [WM].[lsp_Move_Wrapper] 
							@c_Storerkey = @cStorerkey
							,@c_Sku = @cSku
							,@c_Lot = @cLot
							,@c_Loc = @cLoc
							,@c_Id = @cPalletId
							,@c_ToLoc = @cActualDropLoc
							,@c_ToID = @cPalletId
							,@n_ToQty = @nToQty
							,@c_ToPackkey = @cToPackkey
							,@c_ToUom = NULL
							,@c_TaskManagerMove = NULL
							,@b_Success = @bSuccess OUTPUT
							,@n_Err = @nErrNo OUTPUT
							,@c_ErrMsg = @cErrMsg OUTPUT
							,@n_WarningNo = NULL
							,@c_ProceedWithWarning = NULL
							,@c_UserName = @cUserName
							,@c_MoveMethod = NULL
							,@c_Movekey  = NULL;

				RETURN;
            END

            -- If pallet does not exist, return fail with informational message
            SET @bSuccess = 0
			SET @cErrMsg = 'Pallet does not exist'

            RETURN;
        END

    END TRY
    BEGIN CATCH
		-- Return SQL error details
        SET @bSuccess = 0;
        SET @nErrNo = ERROR_NUMBER();
        SET @cErrMsg = ERROR_MESSAGE();
    END CATCH
END

GRANT EXECUTE ON dbo.isp_MCS_TaskStatusUpdate TO NSQL
GO