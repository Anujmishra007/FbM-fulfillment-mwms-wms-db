SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_KIT_Update_Confirm                              */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Update KITDetail                                            */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author    Purposes                                   */
/* 2026-02-11 1.0  Jackc     FCR-9763 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_KIT_Update_Confirm] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cKitKey        NVARCHAR( 10),
   @cKITLineNo     NVARCHAR( 5),
   @cID            NVARCHAR( 18),
   @cSKU           NVARCHAR( 20),
   @nQTY           INT,
   @cLottable01    NVARCHAR( 18),
   @cLottable02    NVARCHAR( 18),
   @cLottable03    NVARCHAR( 18),
   @dLottable04    DATETIME,
   @dLottable05    DATETIME,
   @cLottable06    NVARCHAR( 30),
   @cLottable07    NVARCHAR( 30),
   @cLottable08    NVARCHAR( 30),
   @cLottable09    NVARCHAR( 30),
   @cLottable10    NVARCHAR( 30),
   @cLottable11    NVARCHAR( 30),
   @cLottable12    NVARCHAR( 30),
   @dLottable13    DATETIME,
   @dLottable14    DATETIME,
   @dLottable15    DATETIME,
   @cKITType       NVARCHAR(5),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nTranCount     INT
   DECLARE @cSQL           NVARCHAR(MAX)
   DECLARE @cSQLParam      NVARCHAR(MAX)
   DECLARE @cConfirmSP     NVARCHAR(20)

   /*
   -- Get storer config
   SET @cConfirmSP = rdt.rdtGetConfig( @nFunc, 'ConfirmSP', @cStorerKey)
   IF @cConfirmSP = '0'
      SET @cConfirmSP = ''
   */

   IF @nDebugFlag = 1
      SELECT 'rdt_KIT_Update_Confirm', @cKITKey AS KITKey, @cKITLineNo AS KITLineNumber, @cKITType AS TYPE,
         @nQty AS Qty

   IF NOT EXISTS (SELECT 1
               FROM dbo.KITDetail WITH (NOLOCK)
               WHERE KITKey = @cKitKey
                  AND Type = @cKITType
                  AND KITLineNumber = @cKITLineNo)
   BEGIN
      SET @nErrNo = 259001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update fail
      GOTO Fail
   END

   /***********************************************************************************************
                                          Standard confirm
   ***********************************************************************************************/

   BEGIN TRY
      UPDATE dbo.KITDetail WITH (ROWLOCK) 
      SET 
         Qty = ExpectedQty - @nQTY,
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE KITKey = @cKITKey
         AND Type = @cKITType
         AND KITLineNumber = @cKITLineNo
   END TRY
   BEGIN CATCH
      SET @nErrNo = 259002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update fail
      GOTO Fail
   END CATCH

Fail:

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_KIT_Update_Confirm] TO [NSQL]
GO
