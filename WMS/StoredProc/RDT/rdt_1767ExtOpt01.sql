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
   DECLARE @cTolQty     NVARCHAR( 10)
   DECLARE @curCCD      CURSOR
   DECLARE @curADJ      CURSOR
   DECLARE @cTaskType   NVARCHAR( 10)
   DECLARE @cCCDLOC     NVARCHAR( 10)
   DECLARE @cCCDSKU     NVARCHAR( 20)
   DECLARE @cPostADJ       NVARCHAR( 1)
   DECLARE @cADJFinalize   NVARCHAR( 1)
   DECLARE @cADJType       NVARCHAR( 10)
   DECLARE @cADJReason     NVARCHAR( 10)
   DECLARE @cAdjustmentKey NVARCHAR( 10)
   DECLARE @cAdjDetailLine NVARCHAR( 5)
   DECLARE @cPackkey       NVARCHAR( 10)
   DECLARE @cAlertMessage  NVARCHAR( 255)
   DECLARE @nVariance      INT = 0
   DECLARE @cSkipAlertScreen  NVARCHAR( 1)
   DECLARE @cUserName      NVARCHAR( 18)

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

            SET @nTranCount = @@TRANCOUNT
            BEGIN TRAN
            SAVE TRAN rdt_1767ExtOpt01

            IF @cTaskType = 'CC'
            BEGIN
               SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT RefNo, SUM( SystemQty - Qty)
               FROM dbo.CCDetail WITH (NOLOCK)
               WHERE CCSheetNo = @cTaskDetailKey
               GROUP BY RefNo
               HAVING SUM( SystemQty - Qty) > 0
               OPEN @curCCD
               FETCH NEXT FROM @curCCD INTO @cUCC, @nCCDQty
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  SET @nErrNo = 0
                  SET @cAlertMessage =
                     'UCC: ' + @cUCC + ' WITH VARIANCE QTY (' + @nCCDQty + ')'
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
                     , @c_Qty              = @nCCDQty
                     , @c_Lot              = ''
                     , @c_Loc              = @cLoc
                     , @c_ID               = @cID
                     , @c_TaskDetailKey    = @cTaskDetailKey
                     , @c_UCCNo            = @cUCC

                  IF @nErrNo <> 0
                     GOTO RollBackTran

                  IF @nVariance = 0
                     SET @nVariance = 1

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
                  IF OBJECT_ID('tempdb..#Posting') IS NOT NULL      
                     DROP TABLE #Posting    
    
                  CREATE TABLE #Posting  (      
                     RowRef            BIGINT IDENTITY(1,1)  Primary Key,      
                     AdjustmentKey     NVARCHAR( 10))      

                  SET @curCCD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT RefNo, Loc, Sku, SUM( SystemQty - Qty)
                  FROM dbo.CCDetail WITH (NOLOCK)
                  WHERE CCSheetNo = @cTaskDetailKey
                  GROUP BY RefNo, Loc, Sku
                  HAVING SUM( SystemQty - Qty) > 0
                  OPEN @curCCD
                  FETCH NEXT FROM @curCCD INTO @cUCC, @cCCDLOC, @cCCDSKU, @nCCDQty
                  WHILE @@FETCH_STATUS = 0
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

                     INSERT INTO dbo.ADJUSTMENT ( AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks)
                     VALUES ( @cAdjustmentKey, @cADJType, @cStorerKey, @cFacility, @cAdjustmentKey, '')

                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 241752
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Ins AdjHdr Err
                        GOTO RollBackTran   
                     END

                     SELECT TOP 1
                        @cID = Id,
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

                     SELECT @cAdjDetailLine = RIGHT('0000' + RTRIM(Cast( (ISNULL(MAX(AdjustmentLineNumber),0) + 1) as NVARCHAR(5))),5)
                     FROM  dbo.ADJUSTMENTDETAIL (NOLOCK)
                     WHERE AdjustmentKey = @cAdjustmentKey

                     INSERT INTO dbo.ADJUSTMENTDETAIL
                     (AdjustmentKey,AdjustmentLineNumber,StorerKey, Sku, 
                     Loc, Id, ReasonCode, UOM, PackKey, Qty, 
                     Lottable01, Lottable02, Lottable03,Lottable04, Lottable05,
                     Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                     Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
                     VALUES
                     (@cAdjustmentKey, @cAdjDetailLine, @cStorerKey, @cCCDSKU, 
                     @cCCDLOC, @cID, @cADJReason, 'EA', @cPackkey, @nCCDQty, 
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, NULL, 
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15)

                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 241753
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   -- Ins AdjDtl Err
                        GOTO RollBackTran   
                     END

                     -- Skip posting if UCC has Qty allocated, ops need do it manually
                     IF EXISTS( SELECT 1
                                FROM dbo.CCDetail CCD WITH (NOLOCK)
                                JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK) ON 
                                 ( CCD.Lot = LLI.Lot AND CCD.Loc = LLI.Loc AND CCD.Id = LLI.Id)
                                WHERE CCD.CCSheetNo = @cTaskDetailKey
                                AND   CCD.RefNo = @cUCC
                                AND   LLI.QtyAllocated > 0)
                     BEGIN
                        INSERT INTO #Posting (AdjustmentKey) VALUES (@cAdjustmentKey)
                     END
                     
                     IF @nVariance = 0
                        SET @nVariance = 1

                     FETCH NEXT FROM @curCCD INTO @cUCC, @cCCDLOC, @cCCDSKU, @nCCDQty
                  END
                  CLOSE @curCCD
                  DEALLOCATE @curCCD

                  IF @cADJFinalize = '1'
                  BEGIN
                     SET @curADJ = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                     SELECT AdjustmentKey
                     FROM #Posting
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

                        FETCH NEXT FROM @curADJ INTO @cAdjustmentKey
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
                  SET @nErrNo = 241756
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPDCCDetFail'
                  GOTO RollBackTran
               END 

               FETCH NEXT FROM @curCCD INTO @cCCDetailKey
            END
            CLOSE @curCCD
            DEALLOCATE @curCCD

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
                  -- GOTO Alert Screen
                  SET @nScn = @nScn + 1
                  SET @nStep = @nStep + 1
               END
               ELSE
               BEGIN
                  IF @cSkipAlertScreen = '1'
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
               ROLLBACK TRAN rdt_1767ExtOpt01

            Quit:
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN rdt_1767ExtOpt01
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