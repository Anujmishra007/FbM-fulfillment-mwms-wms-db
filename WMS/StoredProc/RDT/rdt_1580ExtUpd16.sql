SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_1580ExtUpd16                                          */
/* Copyright      : LF logistics                                              */
/*                                                                            */
/* Purpose: Finalize by pallet id                                             */
/*                                                                            */
/* Date        Rev  Author      Purposes                                      */
/* 2023-03-30  1.0  James       WMS-21943. Created                            */
/* 2023-04-25  1.1  James       Addhoc fix delete temp serialno (james01)     */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1580ExtUpd16]
    @nMobile      INT
   ,@nFunc        INT
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cLangCode    NVARCHAR( 3)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cReceiptKey  NVARCHAR( 10)
   ,@cPOKey       NVARCHAR( 10)
   ,@cExtASN      NVARCHAR( 20)
   ,@cToLOC       NVARCHAR( 10)
   ,@cToID        NVARCHAR( 18)
   ,@cLottable01  NVARCHAR( 18)
   ,@cLottable02  NVARCHAR( 18)
   ,@cLottable03  NVARCHAR( 18)
   ,@dLottable04  DATETIME
   ,@cSKU         NVARCHAR( 20)
   ,@nQTY         INT
   ,@nAfterStep   INT
   ,@nErrNo       INT           OUTPUT
   ,@cErrMsg      NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount  INT
   DECLARE @cReceiptLineNumber NVARCHAR(5)
   DECLARE @bSuccess    INT
   DECLARE @nReceiveSerialNoLogKey INT
   
   SET @nTranCount = @@TRANCOUNT

   -- Handling transaction
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1580ExtUpd16 -- For rollback or commit only our own transaction

   IF @nFunc = 1580 -- Piece receiving
   BEGIN
   	IF @nStep = 9
   	BEGIN
   		IF @nInputKey = 0 -- ESC from serial no step need delete the previous scanned serial no
   		BEGIN
   			DECLARE @curDel   CURSOR
   			SET @curDel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   			SELECT ReceiveSerialNoLogKey
   			FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
   			WHERE Mobile = @nMobile
   			AND   Func = @nFunc
   			OPEN @curDel
   			FETCH NEXT FROM @curDel INTO @nReceiveSerialNoLogKey
   			WHILE @@FETCH_STATUS = 0
   			BEGIN
               DELETE rdt.rdtReceiveSerialNoLog     
               WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey 
               
               IF @@ERROR <> 0
                  GOTO RollBackTran

   				FETCH NEXT FROM @curDel INTO @nReceiveSerialNoLogKey
   			END
   		END
   	END
      IF @nStep = 10 -- Close pallet
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Loop ReceiptDetail of pallet
            DECLARE @curRD CURSOR
            SET @curRD = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT RD.ReceiptLineNumber--, RD.ToLOC, RD.SKU
            FROM dbo.ReceiptDetail RD WITH (NOLOCK)
            INNER JOIN dbo.Receipt R WITH (NOLOCK) ON ( R.ReceiptKey = RD.ReceiptKey)
            WHERE RD.ToID = @cToID
            AND   RD.FinalizeFlag <> 'Y'
            AND   RD.BeforeReceivedQty > 0
            AND   R.StorerKey = @cStorerKey
            AND   R.ReceiptKey = @cReceiptKey
            ORDER BY RD.ReceiptKey, RD.ReceiptLineNumber
            OPEN @curRD
            FETCH NEXT FROM @curRD INTO @cReceiptLineNumber
            WHILE @@FETCH_STATUS = 0
            BEGIN
               EXEC dbo.ispFinalizeReceipt
               @c_ReceiptKey        = @cReceiptKey
               ,@b_Success          = @bSuccess  OUTPUT
               ,@n_err              = @nErrNo     OUTPUT
               ,@c_ErrMsg           = @cErrMsg    OUTPUT
               ,@c_ReceiptLineNumber= @cReceiptLineNumber

               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- FinalizeRDFail
                  GOTO RollBackTran
               END

               FETCH NEXT FROM @curRD INTO  @cReceiptLineNumber
            END
         END
      END
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1580ExtUpd16 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN rdt_1580ExtUpd16

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_1580ExtUpd16] TO [NSQL]
GO
