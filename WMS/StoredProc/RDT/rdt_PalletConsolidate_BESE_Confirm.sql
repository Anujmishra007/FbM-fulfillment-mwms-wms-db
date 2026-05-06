/************************************************************************/
/* Store procedure: rdt_PalletConsolidate_BESE_Confirm                  */
/* Copyright      : MAersk                                              */
/*                                                                      */
/* Purpose: Confirm logic for Pallet Consolidate BESE                   */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-03-11 1.0.0  Jackc    FCR-9676 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_PalletConsolidate_BESE_Confirm] (
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

   DECLARE @cSQL         NVARCHAR(MAX)
   DECLARE @cSQLParam    NVARCHAR(MAX)
   DECLARE @cConfirmSP   NVARCHAR(20)

   DECLARE @cUserName    NVARCHAR(18)

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Get storer config for custom ConfirmSP
   SET @cConfirmSP = rdt.rdtGetConfig(@nFunc, 'ConfirmSP', @cStorerKey)
   IF @cConfirmSP = '0'
      SET @cConfirmSP = ''

   -- Execute custom ConfirmSP if configured
   IF @cConfirmSP <> ''
   BEGIN
      IF EXISTS(SELECT 1 FROM sys.objects WHERE name = @cConfirmSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM(@cConfirmSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
            '@cToID, @cToLoc, @cLot, @cSKU, @nQty, @cFromLoc, @cFromID, ' +
            '@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
            '@cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
            '@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
            '@nErrNo OUTPUT, @cErrMsg OUTPUT'

         SET @cSQLParam =
            '@nMobile        INT,            ' +
            '@nFunc          INT,            ' +
            '@cLangCode      NVARCHAR(3),    ' +
            '@nStep          INT,            ' +
            '@nInputKey      INT,            ' +
            '@cFacility      NVARCHAR(5),    ' +
            '@cStorerKey     NVARCHAR(15),   ' +
            '@cToID          NVARCHAR(18),   ' +
            '@cToLoc         NVARCHAR(10),   ' +
            '@cLot           NVARCHAR(10),   ' +
            '@cSKU           NVARCHAR(20),   ' +
            '@nQty           INT,            ' +
            '@cFromLoc       NVARCHAR(10),   ' +
            '@cFromID        NVARCHAR(18),   ' +
            '@cLottable01    NVARCHAR(18),   ' +
            '@cLottable02    NVARCHAR(18),   ' +
            '@cLottable03    NVARCHAR(18),   ' +
            '@dLottable04    DATETIME,       ' +
            '@dLottable05    DATETIME,       ' +
            '@cLottable06    NVARCHAR(30),   ' +
            '@cLottable07    NVARCHAR(30),   ' +
            '@cLottable08    NVARCHAR(30),   ' +
            '@cLottable09    NVARCHAR(30),   ' +
            '@cLottable10    NVARCHAR(30),   ' +
            '@cLottable11    NVARCHAR(30),   ' +
            '@cLottable12    NVARCHAR(30),   ' +
            '@dLottable13    DATETIME,       ' +
            '@dLottable14    DATETIME,       ' +
            '@dLottable15    DATETIME,       ' +
            '@nErrNo         INT OUTPUT,     ' +
            '@cErrMsg        NVARCHAR(1024) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
            @cToID, @cToLoc, @cLot, @cSKU, @nQty, @cFromLoc, @cFromID,
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
            @nErrNo OUTPUT, @cErrMsg OUTPUT

         GOTO Quit
      END
   END

   SELECT @cUserName = ISNULL(UserName,'') FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   SET @cUserName = ISNULL (@cUserName, '')

   IF ISNULL(@cToLoc, '') = ''
      SET @cToLOC = @cFromLOC

   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode,
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT, 
      @cSourceType = 'rdt_PltCon_BESE_Confirm',
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility,
      @cFromLOC    = @cFromLOC,
      @cToLOC      = @cToLOC,
      @cFromID     = @cFromID,     
      @cToID       = @cToID,      
      @nFunc       = @nFunc 

   IF @nErrNo <> 0
      GOTO Fail

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

   Fail:
      IF @nDebugFlag = 1
         SELECT 'Move failure', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_PalletConsolidate_BESE_Confirm TO NSQL
GO