SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_605RcvCfm05                                     */
/*                                                                      */
/* Purpose:       For SCHNEIDER ELECTRIC Belgium                        */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-02-26 1.0.0  Jackc    FCR-9673                                  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605RcvCfm05] (
   @nFunc        INT,
   @nMobile      INT,
   @cLangCode    NVARCHAR( 3),
   @cStorerKey   NVARCHAR( 15),
   @cFacility    NVARCHAR( 5),
   @cReceiptKey  NVARCHAR( 10),
   @cToID        NVARCHAR( 18),
   @cToLOC       NVARCHAR( 10),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 1024) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag   INT = 0

   DECLARE @cSKU                    NVARCHAR( 20)
   DECLARE @cUOM                    NVARCHAR( 10)
   DECLARE @nQTY                    INT           -- In mast
   DECLARE @cLottable01             NVARCHAR( 18)
   DECLARE @cLottable02             NVARCHAR( 18)
   DECLARE @cLottable03             NVARCHAR( 18)
   DECLARE @dLottable04             DATETIME
   DECLARE @dLottable05             DATETIME
   DECLARE @cLottable06             NVARCHAR( 30)
   DECLARE @cLottable07             NVARCHAR( 30)
   DECLARE @cLottable08             NVARCHAR( 30)
   DECLARE @cLottable09             NVARCHAR( 30)
   DECLARE @cLottable10             NVARCHAR( 30)
   DECLARE @cLottable11             NVARCHAR( 30)
   DECLARE @cLottable12             NVARCHAR( 30)
   DECLARE @dLottable13             DATETIME
   DECLARE @dLottable14             DATETIME
   DECLARE @dLottable15             DATETIME
   DECLARE @cReceiptLineNumber      NVARCHAR( 5)
   DECLARE @cReceiptLineNumberOutput NVARCHAR( 5)
   DECLARE @cDefaultToLoc           NVARCHAR( 10)
   DECLARE @cConditionCode          NVARCHAR( 10)
   DECLARE @cOption                 NVARCHAR( 1)
   DECLARE @cTransmitLog2Config     NVARCHAR( 1)
   DECLARE @cTransmitLog3Config     NVARCHAR( 1)
   DECLARE @cUserDefine05           NVARCHAR(30)
   DECLARE @cAddress1               NVARCHAR(18)
   DECLARE @cUserName               NVARCHAR(18)
   DECLARE @cTaskDetailKey          NVARCHAR(10)
   DECLARE @cSuggPAToLoc            NVARCHAR(10)
   DECLARE @cSuggAreaKey            NVARCHAR(10)
   DECLARE @nRowCount               INT
   DECLARE @bSuccess                INT
   DECLARE @nBulkSNO                INT = 0  
   DECLARE @nBulkSNOQTY             INT = 0

   DECLARE @cMsg1                   NVARCHAR(60)
   DECLARE @cMsg2                   NVARCHAR(60)
   DECLARE @cMsg3                   NVARCHAR(60)

   SET @cDefaultToLoc = rdt.RDTGetConfig( @nFunc, 'DefaultToLoc', @cStorerKey)
   IF @cDefaultToLoc = '0'
      SET @cDefaultToLoc = ''

   SET @cTransmitLog2Config = rdt.RDTGetConfig( @nFunc, 'TransmitLog2', @cStorerKey)
   SET @cTransmitLog3Config = rdt.RDTGetConfig( @nFunc, 'TransmitLog3', @cStorerKey)

   SELECT
      @cUserName = UserName,
      @cOption = I_Field14
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing 605RcvCfm04', @cReceiptKey AS ASN, @cToID AS ID, @cOption AS Opt

   IF ISNULL(@cOption, '') NOT IN ('1','3')
   BEGIN
      SET @nErrNo = 259901
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF @cOption = '3'
      SET @cConditionCode = 'DAMAGE'
   ELSE
      SET @cConditionCode = 'OK'

   IF NOT EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                  WHERE ReceiptKey = @cReceiptKey
                        AND ToID = @cToID
                        AND BeforeReceivedQTY = 0)
   BEGIN
      SET @nErrNo = 259902
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                  WHERE ReceiptKey = @cReceiptKey
                        AND ToID = @cToID
                        AND FinalizeFlag = 'Y')
   BEGIN
      SET @nErrNo = 259903
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   DECLARE @curReceipt CURSOR
   SET @curReceipt = CURSOR FOR
      SELECT
         ReceiptLineNumber, ToLOC, SKU, QTYExpected,
         Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
         Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
         Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
      FROM dbo.ReceiptDetail WITH (NOLOCK)
      WHERE ReceiptKey = @cReceiptKey
         AND ToID = @cToID
         AND BeforeReceivedQTY = 0
      ORDER BY ReceiptLineNumber
   OPEN @curReceipt
   FETCH NEXT FROM @curReceipt INTO @cReceiptLineNumber, @cToLOC, @cSKU, @nQTY,
      @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
      @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
      @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_605RcvCfm05 -- For rollback or commit only our own transaction

   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Handling RcptDetail', @cToLOC AS ToLoc, @cSKU AS SKU, @nQTY AS Qty, @cLottable02 AS Lot02

      IF @cDefaultToLoc <> '' 
         SET @cToLOC = @cDefaultToLoc

      IF ISNULL(@cToLOC,'') = ''
      BEGIN
         SET @nErrNo = 259904
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END
   	
      -- Get SKU info
      SELECT @cUOM = Pack.PackUOM3
      FROM SKU WITH (NOLOCK)
         JOIN Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE StorerKey = @cStorerKey
         AND SKU = @cSKU

      EXEC rdt.rdt_Receive_V7
         @nFunc         = @nFunc,
         @nMobile       = @nMobile,
         @cLangCode     = @cLangCode,
         @nErrNo        = @nErrNo OUTPUT,
         @cErrMsg       = @cErrMsg OUTPUT,
         @cStorerKey    = @cStorerKey,
         @cFacility     = @cFacility,
         @cReceiptKey   = @cReceiptKey,
         @cPOKey        = 'NOPO',
         @cToLOC        = @cToLOC,
         @cToID         = @cToID,
         @cSKUCode      = @cSKU,
         @cSKUUOM       = @cUOM,
         @nSKUQTY       = @nQTY,
         @cUCC          = '',
         @cUCCSKU       = '',
         @nUCCQTY       = '',
         @cCreateUCC    = '',
         @cLottable01   = @cLottable01,
         @cLottable02   = @cLottable02,
         @cLottable03   = @cLottable03,
         @dLottable04   = @dLottable04,
         @dLottable05   = @dLottable05,
         @cLottable06   = @cLottable06,
         @cLottable07   = @cLottable07,
         @cLottable08   = @cLottable08,
         @cLottable09   = @cLottable09,
         @cLottable10   = @cLottable10,
         @cLottable11   = @cLottable11,
         @cLottable12   = @cLottable12,
         @dLottable13   = @dLottable13,
         @dLottable14   = @dLottable14,
         @dLottable15   = @dLottable15,
         @nNOPOFlag     = 1,
         @cConditionCode = @cConditionCode,
         @cSubreasonCode = '',
         @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT

      IF @nErrNo <> 0
         GOTO RollBackTran

      IF @nDebugFlag = 1
         SELECT 'After confirm receiving', @cReceiptLineNumberOutput AS RctpLineNoOutput

      FETCH NEXT FROM @curReceipt INTO @cReceiptLineNumber, @cToLOC, @cSKU, @nQTY,
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
   END

   IF NOT EXISTS (SELECT 1 FROM dbo.Pallet WHERE PalletKey = @cToID AND StorerKey = @cStorerKey)
   BEGIN
      BEGIN TRY
         INSERT INTO dbo.Pallet ( 
            PalletKey, StorerKey, Status,EffectiveDate,AddDate,AddWho,EditDate,EditWho,
            TimeStamp,Length,Width,Height,GrossWgt,PalletType)
         VALUES ( 
            @cToID, @cStorerKey, '0', GETDATE(), GETDATE(), USER_NAME(), GETDATE(), USER_NAME(),
            NULL, 1, 1 , 1, 1, 'NO');
      END TRY
      BEGIN CATCH
         SET @nErrNo = 259905
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END

   COMMIT TRAN rdt_605RcvCfm05

   --Finalize ASN if all line finalized
   IF NOT EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND FinalizeFlag <> 'Y')
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'All ASN line finalized'

      SELECT TOP 1 @cAddress1 = Lottable01
      FROM dbo.ReceiptDetail (NOLOCK)
      WHERE Receiptkey = @cReceiptKey
      ORDER BY ReceiptLineNumber

      SELECT @cUserDefine05 = Address1 + '-' + Address2
      FROM dbo.STORER WITH (NOLOCK)
      WHERE Type = '2'
         AND ConsigneeFor = @cStorerKey
         AND Address1 = @cAddress1

      BEGIN TRY
         UPDATE dbo.Receipt WITH (ROWLOCK)
         SET 
            ASNStatus = '9',
            UserDefine05 = @cUserDefine05
         WHERE Receiptkey = @cReceiptKey
      END TRY
      BEGIN CATCH
         SET @cMsg1 = ''
         SET @cMsg2 = ''
         SET @cMsg3 = ''

         SET @cMsg1 = '259906:'
         SET @cMsg2 = rdt.rdtgetmessage( 259906, @cLangCode, 'DSP')
         SET @cMsg3 = 'Retry via web'

         EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2,@cMsg3
      END CATCH

      --Generate transmitlog2/transmitlog3 for each receipt line when config = 2
      IF @cTransmitLog2Config = '2' OR @cTransmitLog3Config = '2'
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Gen Transmitlog2/3 by ASN'

         DECLARE @cLoopReceiptLineNumber NVARCHAR(5)
         DECLARE @nLoopASNErrFlag INT = 0
         DECLARE @curReceiptLine CURSOR

         SET @curReceiptLine = CURSOR FOR
            SELECT ReceiptLineNumber
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
            ORDER BY ReceiptLineNumber
         OPEN @curReceiptLine
         FETCH NEXT FROM @curReceiptLine INTO @cLoopReceiptLineNumber

         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- TransmitLog2
            IF @cTransmitLog2Config = '2'
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Gen TransmigLo2 per line', @cReceiptKey AS ReceiptKey, @cLoopReceiptLineNumber AS ASNLine

               EXEC dbo.ispGenTransmitLog2
                  @c_TableName = N'WSNSCPRECCFM ',
                  @c_Key1 = @cReceiptKey,
                  @c_Key2 = @cLoopReceiptLineNumber,
                  @c_Key3 = @cStorerKey,
                  @c_TransmitBatch = '',
                  @b_Success = @bSuccess OUTPUT,
                  @n_err = @nErrNo OUTPUT,
                  @c_errmsg = @cErrMsg OUTPUT

               IF @bSuccess <> 1 OR @nErrNo <> 0
               BEGIN
                  SET @nLoopASNErrFlag = 1

                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                             Col1, Col2, Col3, Col4, Col5)  
                  VALUES ('605RcvCfm05', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                           TRY_CAST(@nErrNo AS NVARCHAR(10)), @cReceiptKey, @cReceiptLineNumber, '', 'GenTranLogByASN')
               END
            END -- TransmitLog2

            -- TransmitLog3
            IF @cTransmitLog3Config = '2'
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Gen TransmitLog3 per line', @cReceiptKey AS ReceiptKey, @cLoopReceiptLineNumber AS ASNLine

               EXEC dbo.ispGenTransmitLog3
                  @c_TableName = N'RCPTLOG ',
                  @c_Key1 = @cReceiptKey,
                  @c_Key2 = @cLoopReceiptLineNumber,
                  @c_Key3 = @cStorerKey,
                  @c_TransmitBatch = '',
                  @b_Success = @bSuccess OUTPUT,
                  @n_err = @nErrNo OUTPUT,
                  @c_errmsg = @cErrMsg OUTPUT

               IF @bSuccess <> 1 OR @nErrNo <> 0
               BEGIN
                  SET @nLoopASNErrFlag = 1

                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                                             Col1, Col2, Col3, Col4, Col5)  
                  VALUES ('605RcvCfm05', GETDATE(), @cUserName, CAST(@nMobile AS NVARCHAR(10)),
                           TRY_CAST(@nErrNo AS NVARCHAR(10)), @cReceiptKey, @cReceiptLineNumber, '', 'GenTranLogByASN')
               END
            END -- TransmitLog3

            SET @nErrNo = 0 -- not block process, continue
            FETCH NEXT FROM @curReceiptLine INTO @cLoopReceiptLineNumber
         END
         CLOSE @curReceiptLine
         DEALLOCATE @curReceiptLine

         IF @nLoopASNErrFlag = 1
         BEGIN
            SET @cMsg1 = '259909:'
            SET @cMsg2 = rdt.rdtgetmessage(259909, @cLangCode, 'DSP')
            SET @cMsg3 = 'ASN:' + @cReceiptKey

            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2, @cMsg3
         END
      END --gen transmitlog2/3 by each line when config = 2
   END --All asnline are finalized

   --Generate transmit by finalized line
   IF @cTransmitLog2Config = '1' OR @cTransmitLog3Config = '1'
   BEGIN
      IF @nDebugFlag = 1
            SELECT 'Gen Transmitlog2/3 by ASN Line'

      DECLARE @curReceiptLine2 CURSOR
      DECLARE @cCurrentReceiptLine2 NVARCHAR(10)

      SET @curReceiptLine2 = CURSOR FOR
         SELECT ReceiptLineNumber
         FROM dbo.ReceiptDetail WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey
            AND ToID = @cToID
            AND FinalizeFlag = 'Y'
         ORDER BY ReceiptLineNumber

      OPEN @curReceiptLine2
      FETCH NEXT FROM @curReceiptLine2 INTO @cCurrentReceiptLine2

      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF @cTransmitLog2Config = '1'
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Gen TransmitLog2 by ASN line: ' + @cCurrentReceiptLine2

            EXEC dbo.ispGenTransmitLog2
               @c_TableName = N'WSNSCPRECCFM ',
               @c_Key1 = @cReceiptKey,
               @c_Key2 = @cCurrentReceiptLine2,
               @c_Key3 = @cStorerKey,
               @c_TransmitBatch = '',
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT

            IF @bSuccess <> 1 OR @nErrNo <> 0
            BEGIN
               SET @cMsg1 = ''
               SET @cMsg2 = ''
               SET @cMsg3 = ''

               SET @cMsg1 = '259907:'
               SET @cMsg2 = rdt.rdtgetmessage( 259907, @cLangCode, 'DSP')
               SET @cMsg3 = 'ASN-' + @cReceiptKey + ' Line-' + @cCurrentReceiptLine2
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2,@cMsg3

               SET @nErrNo = 0 -- not block process
            END
         END

         IF @cTransmitLog3Config = '1'
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Gen TransmitLog3 by ASN line: ' + @cCurrentReceiptLine2

            EXEC dbo.ispGenTransmitLog3
               @c_TableName = N'RCPTLOG ',
               @c_Key1 = @cReceiptKey,
               @c_Key2 = @cCurrentReceiptLine2,
               @c_Key3 = @cStorerKey,
               @c_TransmitBatch = '',
               @b_Success = @bSuccess OUTPUT,
               @n_err = @nErrNo OUTPUT,
               @c_errmsg = @cErrMsg OUTPUT

            IF @bSuccess <> 1 OR @nErrNo <> 0
            BEGIN
               SET @cMsg1 = ''
               SET @cMsg2 = ''
               SET @cMsg3 = ''

               SET @cMsg1 = '259908:'
               SET @cMsg2 = rdt.rdtgetmessage( 259908, @cLangCode, 'DSP')
               SET @cMsg3 = 'ASN-' + @cReceiptKey + ' Line-' + @cCurrentReceiptLine2
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cMsg1, @cMsg2,@cMsg3

               SET @nErrNo = 0 -- not block process
            END
         END

         FETCH NEXT FROM @curReceiptLine2 INTO @cCurrentReceiptLine2
      END

      CLOSE @curReceiptLine2
      DEALLOCATE @curReceiptLine2
   END -- send iml by asn line

   IF EXISTS (SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND ToID = @cToID AND FinalizeFlag = 'Y')
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                     WHERE StorerKey = @cStorerKey
                        AND TaskType = 'ASTPA'
                        AND Status IN ('0','3')
                        AND FromID = @cToID)
      BEGIN
         SET @bSuccess = 1
         SET @cSuggPAToLOC = ''
         SET @cSuggAreaKey = ''

         -- Get suggested putaway location
         EXEC RDT.rdt_605RcvCfm05_GetSuggestLoc
            @nMobile = @nMobile,
            @nFunc = @nFunc,
            @cLangCode = @cLangCode,
            @cStorerKey = @cStorerKey,
            @cFacility = @cFacility,
            @cReceiptKey = @cReceiptKey,
            @cToID = @cToID,
            @cSuggestLoc = @cSuggPAToLOC OUTPUT,
            @nErrNo = @nErrNo OUTPUT,
            @cErrMsg = @cErrMsg OUTPUT

         IF @cSuggPAToLOC = ''
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'No Location Found'

            --alert is created in suggested loc SP

            GOTO Quit
         END
         ELSE
         BEGIN
            SELECT @cSuggAreaKey = AreaKey
            FROM dbo.LOC LOC WITH (NOLOCK)
            JOIN dbo.AreaDetail AD WITH (NOLOCK)
            ON LOC.PutawayZone = AD.PutawayZone
            WHERE Facility = @cFacility
               AND LOC = @cSuggPAToLOC
            
            SET @cSuggAreaKey = ISNULL(@cSuggAreaKey, '')
         END

         IF @nDebugFlag = 1
            SELECT 'Start to generate ASTPA task'

         EXECUTE dbo.nspg_getkey
            'TaskDetailKey'
            , 10
            , @cTaskDetailKey OUTPUT
            , @bsuccess OUTPUT
            , @nErrNo    OUTPUT
            , @cErrMsg   OUTPUT
         
         IF @bSuccess <> 1 OR @nErrNo <> 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT '259910-Fail to generate TaskKey'
            ELSE
               -- Generate alert
               EXEC nspLogAlert
                  @c_modulename       = '605-PALRCPT'
                  , @c_AlertMessage     = 'PAtask creation failed: 259910-Fail to generate TaskKey'
                  , @n_Severity         = '5'
                  , @b_Success          = @bSuccess      OUTPUT
                  , @n_err              = @nErrNo        OUTPUT
                  , @c_errmsg           = @cErrMsg       OUTPUT
                  , @c_Activity         = 'PALRCPT'
                  , @c_Storerkey        = @cStorerKey
                  , @c_SKU              = ''
                  , @c_UOM              = ''
                  , @c_UOMQty           = ''
                  , @c_Qty              = ''
                  , @c_Lot              = ''
                  , @c_Loc              = @cToLOC
                  , @c_ID               = @cToID
                  , @c_TaskDetailKey    = ''

            GOTO Quit
         END

         BEGIN TRY
            INSERT INTO TaskDetail (
               TaskDetailKey, Status, TaskType, Storerkey, FromLOC, LogicalFromLOC, FromID, ToLoc,
               LogicalToLOC, ToID, PickMethod, Priority, SourcePriority, SourceType, SourceKey, AreaKey)
            VALUES (
               @cTaskDetailKey, '0', 'ASTPA', @cStorerKey, @cToLOC, '', @cToID, @cSuggPAToLOC,
               '', '', 'FP', '9', '9', 'rdt_605RcvCfm05', @cReceiptKey, @cSuggAreaKey)
         END TRY
         BEGIN CATCH
            IF @nDebugFlag = 1
               SELECT '259911-Insert TaskDetail Fail'
            ELSE
               -- Generate alert
               EXEC nspLogAlert
                  @c_modulename       = '605-PALRCPT'
                  , @c_AlertMessage     = 'PA task creation failed: 259911-Insert TaskDetail Fail'
                  , @n_Severity         = '5'
                  , @b_Success          = @bSuccess      OUTPUT
                  , @n_err              = @nErrNo        OUTPUT
                  , @c_errmsg           = @cErrMsg       OUTPUT
                  , @c_Activity         = 'PALRCPT'
                  , @c_Storerkey        = @cStorerKey
                  , @c_SKU              = ''
                  , @c_UOM              = ''
                  , @c_UOMQty           = ''
                  , @c_Qty              = ''
                  , @c_Lot              = ''
                  , @c_Loc              = @cToLOC
                  , @c_ID               = @cToID
                  , @c_TaskDetailKey    = ''

            GOTO Quit
         END CATCH

         -- Lock the suggested location by updating PendingMoveIn
         DECLARE @nPABookingKey INT = 0

         EXEC rdt.rdt_Putaway_PendingMoveIn
            @cUserName        = @cUserName,
            @cType            = 'LOCK',
            @cFromLOC         = @cToLOC,
            @cFromID          = @cToID,
            @cSuggestedLOC    = @cSuggPAToLOC,
            @cStorerKey       = @cStorerKey,
            @nErrNo           = @nErrNo OUTPUT,
            @cErrMsg          = @cErrMsg OUTPUT,
            @cSKU             = '',
            @nPutawayQTY      = NULL,
            @cUCCNo           = '',
            @cFromLOT         = '',
            @cToID            = '',
            @cTaskDetailKey   = @cTaskDetailKey,
            @nFunc            = @nFunc,
            @nPABookingKey    = @nPABookingKey OUTPUT

         IF @nErrNo <> 0 OR @cErrMsg <> ''
         BEGIN
            IF @nDebugFlag = 1
               SELECT '259913-Fail to lock suggested location'
            ELSE
               EXEC nspLogAlert
                  @c_modulename       = '605-PALRCPT'
                  , @c_AlertMessage     = 'PA task creation failed: 259913-Fail to lock suggested location'
                  , @n_Severity         = '5'
                  , @b_Success          = @bSuccess      OUTPUT
                  , @n_err              = @nErrNo        OUTPUT
                  , @c_errmsg           = @cErrMsg       OUTPUT
                  , @c_Activity         = 'PALRCPT'
                  , @c_Storerkey        = @cStorerKey
                  , @c_SKU              = ''
                  , @c_UOM              = ''
                  , @c_UOMQty           = ''
                  , @c_Qty              = ''
                  , @c_Lot              = ''
                  , @c_Loc              = @cSuggPAToLOC
                  , @c_ID               = @cToID
                  , @c_TaskDetailKey    = @cTaskDetailKey

            SET @nErrNo = 0 -- not block process
            GOTO Quit
         END
      END-- open ASTPA not exsits
      ELSE
      BEGIN
         IF @nDebugFlag = 1
            SELECT '259912-Open ASTPA task exists'
         ELSE
            -- Generate alert
            EXEC nspLogAlert
               @c_modulename        = '605-PALRCPT'
               , @c_AlertMessage     = 'PA task creation failed: 259912-Open ASTPA task exists'
               , @n_Severity         = '5'
               , @b_Success          = @bSuccess      OUTPUT
               , @n_err              = @nErrNo        OUTPUT
               , @c_errmsg           = @cErrMsg       OUTPUT
               , @c_Activity         = 'PALRCPT'
               , @c_Storerkey        = @cStorerKey
               , @c_SKU              = ''
               , @c_UOM              = ''
               , @c_UOMQty           = ''
               , @c_Qty              = ''
               , @c_Lot              = ''
               , @c_Loc              = @cToLOC
               , @c_ID               = @cToID
               , @c_TaskDetailKey    = ''

         GOTO Quit
      END--open ASTPA with same id exists
   END -- ID is finalized

   GOTO Quit
END

RollBackTran:
   ROLLBACK TRAN rdt_605RcvCfm05
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
GO
GRANT EXECUTE ON  [RDT].[rdt_605RcvCfm05] TO [NSQL]
GO
