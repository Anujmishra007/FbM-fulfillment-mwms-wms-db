SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1768ExtOpt01                                    */
/* Copyright      : MAERSK                                              */    
/* Purpose: Decide whether need to send Alert and Supervisor count      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev   Author     Purposes                                 */
/* 2025-07-07 1.0.0 James      FCR-6059. Created                        */
/* 2025-07-19 1.0.1 NickT      FCR-6059. No adjustment on allocated INV */
/* 2025-08-13 1.1.0 NickT      UWP-39425 RDT screen go to blank screen  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1768ExtOpt01] (
   @nMobile         INT,   
   @nFunc           INT         OUTPUT,   
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT         OUTPUT,
   @nScn            INT         OUTPUT,
   @nInputKey       INT, 
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15), 
   @cTaskDetailKey  NVARCHAR( 10), 
   @cCCKey          NVARCHAR( 10), 
   @cCCDetailKey    NVARCHAR( 10), 
   @cLoc            NVARCHAR( 10), 
   @cID             NVARCHAR( 18), 
   @cSKU            NVARCHAR( 20), 
   @nActQTY          INT, 
   @cOptions        NVARCHAR( 1), 
   @cLottable01     NVARCHAR( 18), 
   @cLottable02     NVARCHAR( 18), 
   @cLottable03     NVARCHAR( 18), 
   @dLottable04     DATETIME, 
   @dLottable05     DATETIME, 
   @cLottable06     NVARCHAR( 30), 
   @cLottable07     NVARCHAR( 30), 
   @cLottable08     NVARCHAR( 30), 
   @cLottable09     NVARCHAR( 30), 
   @cLottable10     NVARCHAR( 30), 
   @cLottable11     NVARCHAR( 30), 
   @cLottable12     NVARCHAR( 30), 
   @dLottable13     DATETIME, 
   @dLottable14     DATETIME, 
   @dLottable15     DATETIME, 
   @tExtOption      VariableTable READONLY,
   @nErrNo          INT           OUTPUT, 
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess       INT
   DECLARE @nTranCount     INT
   DECLARE @nTolQty        INT = 0
   DECLARE @nCCDQty        INT
   DECLARE @cTolQty        NVARCHAR( 10)
   DECLARE @curCCD         CURSOR
   DECLARE @curADJ         CURSOR
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cCCDLOT        NVARCHAR( 10)
   DECLARE @cCCDLOC        NVARCHAR( 10)
   DECLARE @cCCDID         NVARCHAR( 18)
   DECLARE @cCCDSKU        NVARCHAR( 20)
   DECLARE @cPostADJ       NVARCHAR( 1)
   DECLARE @cADJFinalize   NVARCHAR( 1)
   DECLARE @cADJType       NVARCHAR( 10)
   DECLARE @cADJReason     NVARCHAR( 10)
   DECLARE @cAdjustmentKey NVARCHAR( 10) = ''
   DECLARE @cAdjDetailLine NVARCHAR( 5)
   DECLARE @cPackkey       NVARCHAR( 10)
   DECLARE @cAlertMessage  NVARCHAR( 255)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @nIsAlert       INT = 0
   DECLARE @cSKUGroup      NVARCHAR( 10)
   DECLARE @nQtyAlloc      INT = 0
   DECLARE @nOriCCQty      INT
   DECLARE @nInvQty        INT
   DECLARE @nLoopIndex     INT = -1

   DECLARE @tPosting TABLE (
      RowRef            BIGINT IDENTITY(1,1)  Primary Key,
      AdjustmentKey     NVARCHAR( 10)
   )

   SELECT @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @cOptions = '2'
         BEGIN
            SELECT 
               @cSKUGroup = Code,
               @cTolQty = Short
            FROM dbo.CODELKUP WITH (NOLOCK)
            WHERE LISTNAME = 'CCTOLRANCE'
            AND   Storerkey = @cStorerKey

            IF @cSKUGroup = 'DEFAULT'
               SET @nTolQty = ISNULL( CAST( @cTolQty AS INT), 0)

            SELECT @cTaskType = TaskType
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            SET @nTranCount = @@TRANCOUNT
            BEGIN TRAN
            SAVE TRAN rdt_1768ExtOpt01

            IF @cTaskType = 'CC'
            BEGIN
               SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT Loc, Sku, 
               SUM( CASE
                     WHEN SystemQty > Qty THEN -(SystemQty - Qty)    -- Negative difference
                     WHEN SystemQty < Qty THEN (Qty - SystemQty)   -- Positive difference
                     ELSE 0
                  END)--SUM( SystemQty - Qty)
               FROM dbo.CCDetail WITH (NOLOCK)
               WHERE CCSheetNo = @cTaskDetailKey
               GROUP BY LOC, SKU
               HAVING 
                  ABS( SUM( CASE
                                 WHEN SystemQty > Qty THEN -(SystemQty - Qty)
                                 WHEN SystemQty < Qty THEN (Qty - SystemQty)
                                 ELSE 0
                              END)) > 0
               OPEN @curCCD
               FETCH NEXT FROM @curCCD INTO @cCCDLOC, @cCCDSKU, @nCCDQty
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  IF @cSKUGroup <> 'DEFAULT'
                  BEGIN
                     SELECT @cSKUGroup = SKUGroup
                     FROM dbo.SKU WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND   SKU = @cCCDSKU

                     SELECT @cTolQty = Short
                     FROM dbo.CODELKUP WITH (NOLOCK)
                     WHERE LISTNAME = 'CCTOLRANCE'
                     AND   Storerkey = @cStorerKey
                     AND   Code = @cSKUGroup

                     SET @nTolQty = ISNULL( CAST( @cTolQty AS INT), 0)
                  END

                  IF ABS( @nCCDQty) >= @nTolQty
                  BEGIN
                     SET @nErrNo = 0
                     SET @cAlertMessage =
                        'VARIANCE QTY (' + CAST( @nCCDQty AS NVARCHAR( 5)) + ') > TOLERANCE (' + CAST( @nTolQty AS NVARCHAR( 5)) + ')'
                     EXEC nspLogAlert
                           @c_modulename       = 'TMCCSKU'
                        , @c_AlertMessage     = @cAlertMessage
                        , @n_Severity         = '5'
                        , @b_success          = @bSuccess
                        , @n_err              = @nErrNo
                        , @c_errmsg           = @cErrMsg
                        , @c_Activity         = 'CC'
                        , @c_Storerkey        = @cStorerkey
                        , @c_SKU              = @cSKU
                        , @c_UOM              = ''
                        , @c_UOMQty           = ''
                        , @c_Qty              = @nCCDQty
                        , @c_Lot              = ''
                        , @c_Loc              = @cLoc
                        , @c_ID               = @cID
                        , @c_TaskDetailKey    = @cTaskDetailKey
                        , @c_UCCNo            = ''

                     IF @nErrNo <> 0
                        GOTO RollBackTran

                     SET @nIsAlert = 1
                  END

                  FETCH NEXT FROM @curCCD INTO @cCCDLOC, @cCCDSKU, @nCCDQty
               END
               CLOSE @curCCD
               DEALLOCATE @curCCD
            END

            IF @cTaskType = 'CCSUP'
            BEGIN
               SET @cPostADJ = rdt.RDTGetConfig( @nFunc, 'PostADJ', @cStorerKey)
               SET @cADJFinalize = rdt.RDTGetConfig( @nFunc, 'ADJFinalize', @cStorerKey)
               SET @cADJType = rdt.RDTGetConfig( @nFunc, 'ADJType', @cStorerKey)
               SET @cADJReason = rdt.RDTGetConfig( @nFunc, 'ADJReason', @cStorerKey)

               DELETE FROM @tPosting

               IF @cPostADJ = '1'
               BEGIN 
                  SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT 
                     CCDetailKey, 
                     SUM( CASE
                              WHEN SystemQty > Qty THEN -(SystemQty - Qty)    -- Negative difference
                              WHEN SystemQty < Qty THEN (Qty - SystemQty)   -- Positive difference
                              ELSE 0
                           END),
                     SUM(Qty)
                     FROM dbo.CCDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND   CCSheetNo = @cTaskDetailKey
                     GROUP BY CCDetailKey
                     HAVING 
                        ABS( SUM( CASE
                                       WHEN SystemQty > Qty THEN -(SystemQty - Qty)
                                       WHEN SystemQty < Qty THEN (Qty - SystemQty)
                                       ELSE 0
                                    END)) > 0
                  OPEN @curCCD
                  FETCH NEXT FROM @curCCD INTO @cCCDetailKey, @nCCDQty, @nOriCCQty
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     SELECT @nQtyAlloc = SUM( LLI.QtyAllocated),
                        @nInvQty = SUM( LLI.Qty)
                     FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                     JOIN dbo.CCDetail CCD WITH (NOLOCK) ON ( CCD.Lot = LLI.Lot AND CCD.Loc = LLI.Loc AND CCD.Id = LLI.ID)
                     WHERE CCD.CCDetailKey = @cCCDetailKey

                     -- If Qty Allocated > 0 and CCDQty > 0, then skip this CCDetailKey
                     --Qty 20 @nQtyAlloc 2
                        --@nOriCCQty 0 -> Qty 2 @nQtyAlloc 2
                        --@nOriCCQty 2 -> Qty 2 @nQtyAlloc 2
                        --@nOriCCQty 3 -> Qty 3 @nQtyAlloc 2
                        --@nOriCCQty 20 -> Qty 20 @nQtyAlloc 2
                        --@nOriCCQty 21 -> Qty 21 @nQtyAlloc 2
                     IF @nQtyAlloc > 0 
                     BEGIN 
                        IF @nOriCCQty <= @nQtyAlloc
                        BEGIN
                           SELECT @nCCDQty = @nQtyAlloc - @nInvQty
                        END
                        ELSE
                        BEGIN
                           IF @nOriCCQty = @nInvQty
                              GOTO CONTINUE_curCCD
                           ELSE
                              SET @nCCDQty = @nOriCCQty - @nInvQty
                        END
                     END

                     IF NOT EXISTS( SELECT 1 FROM dbo.ADJUSTMENT WITH (NOLOCK) WHERE AdjustmentKey = @cAdjustmentKey)
                     BEGIN
                        EXECUTE nspg_getkey
                           @KeyName       = 'Adjustment',
                           @fieldlength   = 10,
                           @keystring     = @cAdjustmentKey OUTPUT,
                           @b_success     = @bSuccess       OUTPUT,
                           @n_err         = @nErrNo         OUTPUT,
                           @c_errmsg      = @cErrMsg        OUTPUT

                        IF NOT @bSuccess = 1
                        BEGIN
                           SET @nErrNo = 241501
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   --nspg_GetKey
                           GOTO RollBackTran   
                        END

                        INSERT INTO dbo.ADJUSTMENT ( AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks)
                        VALUES ( @cAdjustmentKey, @cADJType, @cStorerKey, @cFacility, @cAdjustmentKey, @cTaskDetailKey)

                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 241502
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Ins AdjHdr Err
                           GOTO RollBackTran   
                        END
                     END

                     SELECT 
                        @cCCDLOT = Lot,
                        @cCCDLOC = Loc,
                        @cCCDID = Id,
                        @cCCDSKU = SKU,
                        @cLottable01 = Lottable01,
                        @cLottable02 = Lottable02,
                        @cLottable03 = Lottable03,
                        @dLottable04 = Lottable04,
                        @cLottable06 = Lottable06,
                        @cLottable07 = Lottable07,
                        @cLottable08 = Lottable08,
                        @cLottable09 = Lottable09,
                        @cLottable10 = Lottable10,
                        @cLottable11 = Lottable11,
                        @cLottable12 = Lottable12,
                        @dLottable13 = Lottable13,
                        @dLottable14 = Lottable14,
                        @dLottable15 = Lottable15
                     FROM dbo.CCDetail WITH (NOLOCK)
                     WHERE CCDetailKey = @cCCDetailKey

                     SELECT @cPackkey = Pack.Packkey
                     FROM dbo.SKU WITH (NOLOCK)
                     JOIN dbo.PACK PACK WITH (NOLOCK) ON ( SKU.PackKey = PACK.PackKey)
                     WHERE SKU.StorerKey = @cStorerKey
                     AND   SKU.SKU = @cCCDSKU

                     SELECT @cAdjDetailLine = RIGHT('0000' + RTRIM(Cast( (ISNULL(MAX(AdjustmentLineNumber),0) + 1) as NVARCHAR(5))),5)
                     FROM  dbo.ADJUSTMENTDETAIL (NOLOCK)
                     WHERE AdjustmentKey = @cAdjustmentKey

                     INSERT INTO dbo.ADJUSTMENTDETAIL
                     (AdjustmentKey,AdjustmentLineNumber,StorerKey, Sku, 
                     Lot, Loc, Id, ReasonCode, UOM, PackKey, Qty, 
                     Lottable01, Lottable02, Lottable03,Lottable04, Lottable05,
                     Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                     Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
                     VALUES
                     (@cAdjustmentKey, @cAdjDetailLine, @cStorerKey, @cCCDSKU, 
                     @cCCDLOT, @cCCDLOC, @cID, @cADJReason, 'EA', @cPackkey, @nCCDQty, 
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, NULL, 
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15)

                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 241503
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Ins AdjDtl Err
                        GOTO RollBackTran   
                     END

                     INSERT INTO @tPosting (AdjustmentKey) VALUES (@cAdjustmentKey)

                     CONTINUE_curCCD:
                     FETCH NEXT FROM @curCCD INTO @cCCDetailKey, @nCCDQty, @nOriCCQty
                  END
                  CLOSE @curCCD
                  DEALLOCATE @curCCD
                     /*
                     IF @cADJFinalize = '1' 
                        AND @cUserName <> 'jameswong' -- testing
                     BEGIN
                        SET @curADJ = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                        SELECT AdjustmentKey
                        FROM @tPosting
                        ORDER BY 1
                        OPEN @curADJ
                        FETCH NEXT FROM @curADJ INTO @cAdjustmentKey
                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                           EXEC dbo.isp_FinalizeADJ
                              @c_ADJKey   = @cAdjustmentKey,
                              @b_Success  = @bSuccess    OUTPUT,
                              @n_err      = @nErrNo      OUTPUT,
                              @c_errmsg   = @cErrMsg     OUTPUT

                           IF NOT @bSuccess = 1
                           BEGIN
                              SET @nErrNo = 241504
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Finalize failed
                              GOTO RollBackTran   
                           END

                           FETCH NEXT FROM @curADJ INTO @cAdjustmentKey
                        END
                     END
                     */
               END
            END

            UPDATE dbo.TaskDetail SET
               [Status] = '9',
               EditWho = @cUserName,
               EditDate = GetDate(),
               EndTime = GetDate()
            WHERE TaskDetailKey = @cTaskDetailKey

            IF @@ERROR <> ''
            BEGIN
               SET @nErrNo = 241504
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdTaskDetFailed'
               GOTO RollBackTran
            END

            IF EXISTS ( SELECT 1 
                        FROM dbo.TaskDetail WITH (NOLOCK)
                        WHERE TaskDetailKey = @cTaskDetailKey
                        AND   TaskType = 'CCSUP')
            BEGIN
               UPDATE dbo.ALERT WITH (ROWLOCK) SET
                  [Status] = '9'
               WHERE TaskDetailKey = @cTaskDetailKey
               AND   [Status] = '0'

               IF @@ERROR <> ''
               BEGIN
                  SET @nErrNo = 241505
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'CloseAlertErr'
                  GOTO RollBackTran
               END
            END

            IF @nIsAlert = 1
            BEGIN
               -- GOTO Alert Screen
               SET @nScn = @nScn + 1
               SET @nStep = @nStep + 1
            END
            ELSE
            BEGIN
               -- GOTO Main Module Get Next Task Screen Screen
               SET @nFunc = 1766
               SET @nScn = 2875
               SET @nStep = 6

               UPDATE dbo.Loc WITH (ROWLOCK) SET
                  LastCycleCount = GETDATE(),
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE Loc = @cLoc
               AND   Facility = @cFacility

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 241506
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Upd LastCC Err
                  GOTO RollBackTran
               END
            END

            GOTO QUIT

            RollBackTran:
               ROLLBACK TRAN rdt_1768ExtOpt01

            Quit:
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN rdt_1768ExtOpt01

            IF @cADJFinalize = '1' 
            BEGIN
               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 
                     @cAdjustmentKey = AdjustmentKey,
                     @nLoopIndex = RowRef
                  FROM @tPosting
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  IF ISNULL( @cAdjustmentKey, '') <> ''
                  BEGIN
                     EXEC dbo.isp_FinalizeADJ
                        @c_ADJKey   = @cAdjustmentKey,
                        @b_Success  = @bSuccess    OUTPUT,
                        @n_err      = @nErrNo      OUTPUT,
                        @c_errmsg   = @cErrMsg     OUTPUT

                     IF NOT @bSuccess = 1
                     BEGIN
                        SET @nErrNo = 241507
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Finalize failed
                        GOTO Quit_SP   
                     END
                  END
               END
            END
         END
      END
   END

   Quit_SP:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_1768ExtOpt01] TO [NSQL]
GO