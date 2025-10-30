SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1767ExtOpt01                                    */
/* Copyright      : MAERSK                                              */
/* Purpose: Decide whether need to send Alert and Supervisor count      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-07-07 1.0  James      FCR-6060. Created                         */
/* 2025-07-23 1.1.0 NickT     FCR-6060 fixed some issues                */
/* 2025-08-13 1.2.0 NickT     UWP-39425 RDT screen go to blank screen   */
/* 2025-08-29 1.3.0 NickT     UWP-40373 Correct Qty of Alert Msg, no need*/
/*                            to generate Adjustment if UCC is Picked   */
/* 2025-09-02 1.3.1 Jackc     UWP-40373 Correct Qty of Alert.Qty        */
/* 2025-10-30 1.4.0 NickT     UWP-43212 Skip allocated UCC              */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1767ExtOpt01] (
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
   @cUCC            NVARCHAR( 20),
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
   @tExtOption      VARIABLETABLE READONLY,
   @nErrNo          INT           OUTPUT, 
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess    INT
   DECLARE @nTranCount  INT
   DECLARE @nTolQty     INT
   DECLARE @nCCDQty     INT
   DECLARE @nAlterQty   INT --v1.3.1
   DECLARE @cTolQty     NVARCHAR( 10)
   DECLARE @curCCD      CURSOR
   DECLARE @curADJ      CURSOR
   DECLARE @cTaskType   NVARCHAR( 10)
   DECLARE @cCCDLOT     NVARCHAR( 10)
   DECLARE @cCCDLOC     NVARCHAR( 10)
   DECLARE @cCCDID      NVARCHAR( 18)
   DECLARE @cCCDSKU     NVARCHAR( 20)
   DECLARE @cPostADJ       NVARCHAR( 1)
   DECLARE @cADJFinalize   NVARCHAR( 1)
   DECLARE @cADJType       NVARCHAR( 10)
   DECLARE @cADJReason     NVARCHAR( 10)
   DECLARE @cAdjustmentKey NVARCHAR( 10) = ''
   DECLARE @cAdjDetailLine NVARCHAR( 5)
   DECLARE @cPackkey       NVARCHAR( 10)
   DECLARE @cAlertMessage  NVARCHAR( 255)
   DECLARE @nVariance      INT = 0
   DECLARE @cSkipAlertScreen  NVARCHAR( 1)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cUCCStatus     NVARCHAR(1) = '1'
   DECLARE @nIsAlert       INT = 0
   DECLARE @curADJDtl      CURSOR
   DECLARE @nLoopIndex     INT
   DECLARE @nRowCount      INT
   DECLARE @nAdjustmentQty INT
   DECLARE @cUCCFromLOC    NVARCHAR( 10)
   DECLARE @cUCCFromID     NVARCHAR( 18)
   DECLARE @cUCCToLOC      NVARCHAR( 10)
   DECLARE @cUCCToID       NVARCHAR( 18)
   DECLARE @tUCCToMove     TABLE
   (
      RowIndex          INT IDENTITY(1,1),
      UCCNo             NVARCHAR( 20),
      FromLoc           NVARCHAR( 10),
      FromID            NVARCHAR( 18),
      ToLoc             NVARCHAR( 10),
      ToID              NVARCHAR( 18)
   )

   DECLARE @tAdjustmentKeys     TABLE
   (
      RowIndex          INT IDENTITY(1,1),
      AdjustmentKey     NVARCHAR( 10)
   )

   DECLARE @tPosting TABLE
   (
      RowRef            BIGINT IDENTITY(1,1) PRIMARY KEY,
      AdjustmentKey     NVARCHAR( 10)
   )

   SELECT 
      @cUserName = UserName,
      @cSkipAlertScreen = V_String7
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nStep = 2
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @cOptions = '2'
         BEGIN
            SELECT @cTaskType = TaskType
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            IF @cTaskType = 'CC'
            BEGIN
               SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT RefNo, SUM( SystemQty - Qty)
               FROM dbo.CCDetail WITH (NOLOCK)
               WHERE CCSheetNo = @cTaskDetailKey
                  AND ISNULL( RefNo, '') <> ''
               GROUP BY RefNo
               HAVING ABS( SUM( SystemQty - Qty)) > 0
               OPEN @curCCD
               FETCH NEXT FROM @curCCD INTO @cUCC, @nCCDQty
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  SET @nErrNo = 0
                  SET @cAlertMessage =
                     'UCC: ' + @cUCC + ' WITH VARIANCE QTY (' + CAST( @nCCDQty * -1 AS NVARCHAR( 5)) + ').'

                  SELECT @cUCCStatus = Status,
                     @cUCCFromLOC = LOC
                  FROM dbo.UCC WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND UCCNo = @cUCC

                  IF @cUCCStatus = '3'
                     SET @cAlertMessage = @cAlertMessage + ' It is allocated to ' + ISNULL(@cUCCFromLOC, '') + '.'
                  ELSE
                     SET @cAlertMessage = @cAlertMessage + ' No allocation.'

                  --V1.3.1
                  SET @nAlterQty = ISNULL(@nCCDQty,0) * -1

                  EXEC nspLogAlert
                        @c_modulename       = 'TMCCUCC'
                     , @c_AlertMessage     = @cAlertMessage
                     , @n_Severity         = '5'
                     , @b_success          = @bSuccess
                     , @n_err              = @nErrNo
                     , @c_errmsg           = @cErrMsg
                     , @c_Activity         = 'CC'
                     , @c_Storerkey        = @cStorerkey
                     , @c_SKU              = ''
                     , @c_UOM              = ''
                     , @c_UOMQty           = ''
                     , @c_Qty              = @nAlterQty
                     , @c_Lot              = ''
                     , @c_Loc              = @cLoc
                     , @c_ID               = @cID
                     , @c_TaskDetailKey    = @cTaskDetailKey
                     , @c_UCCNo            = @cUCC

                  IF @nErrNo <> 0
                     GOTO RollBackTran

                  IF @nVariance = 0
                     SET @nVariance = 1

                  SET @nIsAlert = 1

                  FETCH NEXT FROM @curCCD INTO @cUCC, @nCCDQty
               END
               CLOSE @curCCD
               DEALLOCATE @curCCD
            END
            ELSE
            IF @cTaskType = 'CCSUP'
            BEGIN
               SET @cPostADJ = rdt.RDTGetConfig( @nFunc, 'PostADJ', @cStorerKey)
               SET @cADJFinalize = rdt.RDTGetConfig( @nFunc, 'ADJFinalize', @cStorerKey)
               SET @cADJType = rdt.RDTGetConfig( @nFunc, 'ADJType', @cStorerKey)
               SET @cADJReason = rdt.RDTGetConfig( @nFunc, 'ADJReason', @cStorerKey)

               IF @cPostADJ = '1'
               BEGIN
                  DELETE FROM @tUCCToMove
                  DELETE FROM @tAdjustmentKeys
                  DELETE FROM @tPosting

                  SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT RefNo, Lot, Loc, Id, Sku, 
                  SUM(
                     CASE
                        WHEN SystemQty > Qty THEN -SystemQty     -- Rule 1
                        WHEN SystemQty < Qty THEN Qty            -- Rule 2
                        ELSE 0                                   -- Equal: ignore in sum
                    END
                    )
                  FROM dbo.CCDetail WITH (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                     AND CCSheetNo = @cTaskDetailKey
                     AND ISNULL( RefNo, '') <> ''
                  GROUP BY RefNo, Lot, Loc, Id, Sku
                  HAVING 
                  SUM(
                     CASE
                        WHEN SystemQty <> Qty THEN 1
                        ELSE 0
                     END
                     ) > 0  -- Rule 3: include only if mismatch exists
                  OPEN @curCCD
                  FETCH NEXT FROM @curCCD INTO @cUCC, @cCCDLOT, @cCCDLOC, @cCCDID, @cCCDSKU, @nCCDQty
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     SELECT @cUCCStatus = Status
                     FROM dbo.UCC WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND UCCNo = @cUCC

                     IF @cUCCStatus IN ('3', '5','6') -- replenished to/picking done
                     BEGIN
                        GOTO NEXT_LOOP
                     END

                     IF @cAdjustmentKey = ''
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
                           SET @nErrNo = 241751
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   --nspg_GetKey
                           GOTO RollBackTran   
                        END
                     END

                     IF NOT EXISTS( SELECT 1 FROM dbo.ADJUSTMENT WITH (NOLOCK) WHERE AdjustmentKey = @cAdjustmentKey)
                     BEGIN
                        INSERT INTO dbo.ADJUSTMENT ( AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks, DocType)
                        VALUES ( @cAdjustmentKey, @cADJType, @cStorerKey, @cFacility, @cAdjustmentKey, @cTaskDetailKey, 'U')

                        IF @@ERROR <> 0
                        BEGIN
                           SET @nErrNo = 241752
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Ins AdjHdr Err
                           GOTO RollBackTran   
                        END

                        INSERT INTO @tAdjustmentKeys (AdjustmentKey)
                        VALUES (@cAdjustmentKey)
                     END

                     SELECT TOP 1
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
                     WHERE CCSheetNo = @cTaskDetailKey
                     AND   Loc = @cCCDLOC
                     AND   Sku = @cCCDSKU
                     ORDER BY 1

                     SELECT @cPackkey = Pack.Packkey
                     FROM dbo.SKU WITH (NOLOCK)
                     JOIN dbo.PACK PACK WITH (NOLOCK) ON ( SKU.PackKey = PACK.PackKey)
                     WHERE SKU.StorerKey = @cStorerKey
                     AND   SKU.SKU = @cCCDSKU

                     IF EXISTS(SELECT 1 
                              FROM dbo.UCC WITH (NOLOCK) 
                              INNER JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK)
                              ON UCC.StorerKey = LLI.StorerKey AND UCC.Lot = LLI.Lot AND UCC.Loc = LLI.Loc AND UCC.Id = LLI.Id
                              WHERE UCC.StorerKey = @cStorerKey
                                 AND UCC.UCCNo = @cUCC
                                 AND UCC.Status = '1'
                                 AND (UCC.Loc <> @cLoc OR UCC.ID <> @cID) )
                     BEGIN
                        INSERT INTO @tUCCToMove (UCCNo, FromLoc, FromID, ToLoc, ToID)
                        SELECT @cUCC, Loc, ID, @cLoc, @cID
                        FROM dbo.UCC WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                              AND UCCNo = @cUCC

                        GOTO VARIANCE
                     END

                     SELECT @cAdjDetailLine = RIGHT('0000' + RTRIM(Cast( (ISNULL(MAX(AdjustmentLineNumber),0) + 1) as NVARCHAR(5))),5)
                     FROM  dbo.ADJUSTMENTDETAIL (NOLOCK)
                     WHERE AdjustmentKey = @cAdjustmentKey

                     INSERT INTO dbo.ADJUSTMENTDETAIL
                        (AdjustmentKey,AdjustmentLineNumber,StorerKey, Sku, 
                        Lot, Loc, Id, ReasonCode, UOM, PackKey, Qty, 
                        Lottable01, Lottable02, Lottable03,Lottable04, Lottable05,
                        Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                        Lottable11, Lottable12, Lottable13, Lottable14, Lottable15, UCCNo)
                     VALUES
                        (@cAdjustmentKey, @cAdjDetailLine, @cStorerKey, @cCCDSKU, 
                        @cCCDLOT, @cCCDLOC, @cID, @cADJReason, 'EA', @cPackkey, @nCCDQty,
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04, NULL, 
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, @cUCC)

                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 241753
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Ins AdjDtl Err
                        GOTO RollBackTran   
                     END
                     
                     VARIANCE:
                     IF @nVariance = 0
                        SET @nVariance = 1

                     NEXT_LOOP:
                     FETCH NEXT FROM @curCCD INTO @cUCC, @cCCDLOT, @cCCDLOC, @cCCDID, @cCCDSKU, @nCCDQty
                  END
                  CLOSE @curCCD
                  DEALLOCATE @curCCD

                  IF @cADJFinalize = '1'
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
                           SET @nErrNo = 241754
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Finalize failed
                           GOTO RollBackTran
                        END

                        NEXT_ADJUSTMENT:
                        FETCH NEXT FROM @curADJ INTO @cAdjustmentKey
                     END

                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1 
                           @cUCC = UCCNo,
                           @cUCCFromLOC = FromLoc,
                           @cUCCFromID = FromID,
                           @cUCCToLOC = ToLoc,
                           @cUCCToID = ToID,
                           @nLoopIndex = RowIndex
                        FROM @tUCCToMove
                        WHERE RowIndex > @nLoopIndex
                        ORDER BY RowIndex

                        SET @nRowCount = @@ROWCOUNT

                        IF @nRowCount = 0
                           BREAK

                        BEGIN TRY
                           EXEC RDT.rdt_Move 
                              @nMobile     = @nMobile,
                              @cLangCode   = @cLangCode,
                              @nErrNo      = @nErrNo  OUTPUT,
                              @cErrMsg     = @cErrMsg OUTPUT,
                              @cSourceType = 'rdt_1767ExtOpt01',
                              @cStorerKey  = @cStorerKey,
                              @cFacility   = @cFacility,
                              @cFromLOC    = @cUCCFromLOC,
                              @cToLOC      = @cUCCToLOC,
                              @cFromID     = @cUCCFromID,
                              @cToID       = @cUCCToID,
                              @cSKU        = NULL, 
                              @cUCC        = @cUCC,
                              @nFunc       = @nFunc,
                              @cDropID     = @cUCC
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 241758
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- MoveUCCFail
                           GOTO RollBackTran
                        END CATCH

                        IF @nErrNo <> 0
                        BEGIN
                           SET @nErrNo = 241759
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- MoveUCCFail
                           GOTO RollBackTran
                        END
                     END
                  END
               END
            END

            UPDATE dbo.TaskDetail SET
               [Status] = '9',
               TrafficCop = NULL,
               EditDate = GetDate()
            WHERE TaskDetailKey = @cTaskDetailKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 241755
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdTaskDetFailed'
               GOTO RollBackTran
            END

            UPDATE AL WITH (ROWLOCK) SET 
               AL.STATUS = '9'
            FROM dbo.TaskDetail TD 
            JOIN dbo.Alert AL ON TD.Message03 = AL.AlertKey 
            WHERE TD.TaskDetailKey = @cTaskDetailKey
            AND   TD.TaskType = 'CCSUP'
            AND   TD.Status = '9'

            IF @@ERROR <> ''
            BEGIN
               SET @nErrNo = 241756
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD ALERT FAIL'
               GOTO RollBackTran
            END    

            SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT CCDetailKey
            FROM dbo.CCDetail WITH (NOLOCK)
            WHERE CCSheetNo = @cTaskDetailKey
            OPEN @curCCD
            FETCH NEXT FROM @curCCD INTO @cCCDetailKey
            WHILE @@FETCH_STATUS = 0
            BEGIN
               UPDATE dbo.CCDetail SET
                  FinalizeFlag = 'Y',
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE CCDetailKey = @cCCDetailKey
            
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 241757
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPDCCDetFail'
                  GOTO RollBackTran
               END 

               FETCH NEXT FROM @curCCD INTO @cCCDetailKey
            END
            CLOSE @curCCD
            DEALLOCATE @curCCD

            DELETE ADJ
            FROM dbo.ADJUSTMENT ADJ
            INNER JOIN @tAdjustmentKeys TADJ ON ADJ.AdjustmentKey = TADJ.AdjustmentKey
            LEFT JOIN dbo.ADJUSTMENTDETAIL ADJD ON ADJ.AdjustmentKey = ADJD.AdjustmentKey
            WHERE ADJ.StorerKey = @cStorerkey
               AND ADJD.AdjustmentKey IS NULL

            IF @nVariance = 0
            BEGIN
               -- GOTO Main Module Get Next Task Screen Screen
               SET @nFunc = 1766
               SET @nScn = 2875
               SET @nStep = 6 
            END
            ELSE
            BEGIN
               IF @cTaskType = 'CCSUP'
               BEGIN
                  -- GOTO Main Module Get Next Task Screen Screen
                  SET @nFunc = 1766
                  SET @nScn = 2875
                  SET @nStep = 6 
               END
               ELSE
               BEGIN
                  IF @cSkipAlertScreen = '1' OR @nIsAlert = 0
                  BEGIN
                     -- GOTO Main Module Get Next Task Screen Screen
                     SET @nFunc = 1766
                     SET @nScn = 2875
                     SET @nStep = 6 
                  END
                  ELSE
                  BEGIN
                     -- GOTO Alert Screen
                     SET @nScn = @nScn + 1
                     SET @nStep = @nStep + 1
                  END
               END
            END

            GOTO QUIT

            RollBackTran:

            Quit:
         END
      END
   END

   Quit_SP:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_1767ExtOpt01] TO [NSQL]
GO