/************************************************************************/
/* Store procedure: rdt_1878ConfirmSP01                                 */
/* Copyright      : MAersk                                              */
/*                                                                      */
/* Purpose: Confirm logic for Pallet Consolidate BESE                   */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-03-13 1.0.0  Jackc    FCR-9676 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1878ConfirmSP01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR(5),
   @cStorerKey     NVARCHAR(15),
   @cToID          NVARCHAR(18),
   @cToLoc         NVARCHAR(10),
   @cLot           NVARCHAR(10),
   @cSKU           NVARCHAR(20),
   @nQty           INT,
   @cFromLoc       NVARCHAR(10),
   @cFromID        NVARCHAR(18),
   @cLottable01    NVARCHAR(18),
   @cLottable02    NVARCHAR(18),
   @cLottable03    NVARCHAR(18),
   @dLottable04    DATETIME,
   @dLottable05    DATETIME,
   @cLottable06    NVARCHAR(30),
   @cLottable07    NVARCHAR(30),
   @cLottable08    NVARCHAR(30),
   @cLottable09    NVARCHAR(30),
   @cLottable10    NVARCHAR(30),
   @cLottable11    NVARCHAR(30),
   @cLottable12    NVARCHAR(30),
   @dLottable13    DATETIME,
   @dLottable14    DATETIME,
   @dLottable15    DATETIME,
   @nErrNo         INT OUTPUT,
   @cErrMsg        NVARCHAR(1024) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE 
      @cTransferkey     NVARCHAR(10),
      @bSuccess         INT,
      @cSuggestLoc      NVARCHAR(10),
      @cSuggAreaKey     NVARCHAR(10),
      @cPutawayZone     NVARCHAR(10),
      @cTaskDetailKey   NVARCHAR(10),
      @cUserName        NVARCHAR(18)

   DECLARE
      @cFromLottable01    NVARCHAR( 18),
      @cFromLottable02    NVARCHAR( 18),
      @cFromLottable03    NVARCHAR( 18),
      @dFromLottable04    DATETIME,
      @dFromLottable05    DATETIME,
      @cFromLottable06    NVARCHAR( 30),
      @cFromLottable07    NVARCHAR( 30),
      @cFromLottable08    NVARCHAR( 30),
      @cFromLottable09    NVARCHAR( 30),
      @cFromLottable10    NVARCHAR( 30),
      @cFromLottable11    NVARCHAR( 30),
      @cFromLottable12    NVARCHAR( 30),
      @dFromLottable13    DATETIME,
      @dFromLottable14    DATETIME,
      @dFromLottable15    DATETIME

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nDebugFlag = 1
      SELECT 'Executing 1878Cfm01', @cToID AS ToID, @cFromID AS FromID

   SELECT @cUserName = ISNULL(UserName,'') FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   SET @cUserName = ISNULL (@cUserName, '')

   SELECT TOP 1
      @cFromLottable01  = Lottable01,
      @cFromLottable02  = Lottable02
   FROM dbo.LotXLocXID LLI WITH (NOLOCK)
   JOIN dbo.LotAttribute LA WITH (NOLOCK)
   ON LLI.Lot = LA.Lot
   WHERE LLI.StorerKey = @cStorerKey
   AND ID = @cFromID
   AND Qty > 0

   IF ISNULL(@cFromLottable02,'') = 'MIX'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Tansfer lot'

      -- Handling transaction
      DECLARE @nTranCount  INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN rdt_1878CfmSP01_Transfer

      EXEC dbo.nspg_GetKey @KeyName = 'Transfer'
         , @fieldlength = 10
         , @keystring = @cTransferkey OUTPUT
         , @b_Success = @bSuccess OUTPUT
         , @n_err = @nErrNo OUTPUT
         , @c_errmsg = @cErrMsg OUTPUT

      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 261201
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Gen transfer key failed
         GOTO RollBackTran 
      END

      BEGIN TRY
         INSERT INTO dbo.TRANSFER 
            (TransferKey, FromStorerKey, ToStorerKey, Type, Status, GenerateHOCharges, GenerateIS_HICharges
            , ReLot, EffectiveDate, ReasonCode, Remarks, Facility, ToFacility)
            VALUES
            (@cTransferkey, @cStorerKey, @cStorerkey, 'RDT', '0', '0', '0'
            , '1', GETDATE(), 'PltCons', 'Lot change in Pallet Consolidate', @cFacility, @cFacility)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261202
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins Transfer fail
         GOTO RollBackTran 
      END CATCH

      BEGIN TRY
         INSERT INTO dbo.TRANSFERDETAIL
            (TransferKey, TransferLineNumber, 
               FromStorerKey, FromSku, FromLoc, FromLot, FromId, FromQty, FromPackKey, FromUOM,
               ToStorerKey, ToSku, ToLoc, ToId, ToQty, ToPackKey, ToUOM, Status, EffectiveDate,
               tolottable01, tolottable02, tolottable03, tolottable04, tolottable05, 
               tolottable06, tolottable07, tolottable08, tolottable09, tolottable10, 
               tolottable11, tolottable12, tolottable13, tolottable14, tolottable15 )
            SELECT
               @cTransferKey, RIGHT('00000' + CONVERT(VARCHAR(5), ROW_NUMBER() OVER (ORDER BY LLI.Lot)), 5) AS LineNumber,
               LLI.StorerKey, LLI.SKU, LLI.Loc, LLI.Lot, LLI.ID, LLI.Qty,SKU.PackKey, 'EA',
               @cStorerKey, LLI.SKU, LLI.Loc, LLI.ID, LLI.Qty, SKU.PackKey, 'EA', '0', GETDATE(),
               LA.Lottable01, 'MONO', LA.Lottable03, LA.Lottable04, LA.Lottable05, 
               LA.Lottable06, LA.Lottable07, LA.Lottable08, LA.Lottable09, LA.Lottable10,
               LA.Lottable11, LA.Lottable12, LA.Lottable13, LA.Lottable14, LA.Lottable15
            FROM dbo.LotXLocXID LLI WITH (NOLOCK)
            JOIN dbo.LotAttribute LA WITH (NOLOCK) ON LLI.Lot = LA.Lot
            JOIN dbo.SKU WITH (NOLOCK) ON LLI.StorerKey = SKU.StorerKey AND LLI.SKU = SKU.SKU
            WHERE LLI.StorerKey = @cStorerKey
              AND LLI.ID = @cFromID
              AND LLI.Qty > 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 261203
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins TransferDetail fail
         GOTO RollBackTran 
      END CATCH

      EXEC ispFinalizeTransfer  
            @c_Transferkey = @cTransferkey  
         ,  @b_Success     = @bSuccess   OUTPUT   
         ,  @n_err         = @nErrNo     OUTPUT   
         ,  @c_errmsg      = @cErrMsg    OUTPUT

      IF @bSuccess <> 1 OR @nErrNo <> 0
      BEGIN
         SET @nErrNo = 261204
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Finalize transfer failed
         GOTO RollBackTran 
      END

      COMMIT TRAN rdt_1878CfmSP01_Transfer
   END -- transfer lot

   IF ISNULL(@cToLoc, '') = ''
      SET @cToLOC = @cFromLOC

   IF @nDebugFlag = 1
      SELECT 'Move ID'

   BEGIN TRAN rdt_1878CfmSP01_Move

   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode,
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT, 
      @cSourceType = 'rdt_1878ConfirmSP01',
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility,
      @cFromLOC    = @cFromLOC,
      @cToLOC      = @cToLOC,
      @cFromID     = @cFromID,     
      @cToID       = @cToID,      
      @nFunc       = @nFunc 

   IF @nErrNo <> 0
      GOTO RollBackTran

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
         SET @nErrNo = 261205
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END

   COMMIT TRAN rdt_1878CfmSP01_Move

   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '4', -- Move
      @cUserID       = @cUserName,
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerkey,
      @cLocation     = @cFromLOC,
      @cToLocation   = @cToLOC,
      @cID           = @cFromID,
      @cToID         = @cToID, 
      @nQTY          = 0, 
      @cRefNo1       = 'FULL PALLET MOVE'

   GOTO Quit

   RollBackTran:
      IF @nDebugFlag = 1
         SELECT 'Rollback transaction'
      Rollback Tran

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1878ConfirmSP01 TO NSQL
GO