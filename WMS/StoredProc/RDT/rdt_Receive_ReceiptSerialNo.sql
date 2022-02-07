IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_Receive_ReceiptSerialNo]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_Receive_ReceiptSerialNo]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_Receive_ReceiptSerialNo                               */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Date       Rev  Author      Purposes                                       */
/* 2018-08-01 1.0  Ung         WMS-5722 Receive Serial No by batch            */
/* 2019-08-08 1.1  Ung         INC0807312 Renumber error no                   */
/******************************************************************************/

CREATE PROCEDURE [RDT].[rdt_Receive_ReceiptSerialNo] (
   @nFunc               INT,
   @nMobile             INT,
   @cLangCode           NVARCHAR( 3),
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cReceiptKey         NVARCHAR( 10),
   @cReceiptLineNumber  NVARCHAR( 5),
   @cSKU                NVARCHAR( 20),
   @cSerialNo           NVARCHAR( 30), 
   @nSerialQTY          INT, 
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount            INT
   DECLARE @nTranCount           INT
   DECLARE @nReceiptSerialNoKey  INT
   DECLARE @cChkSerialSKU        NVARCHAR( 20)
   DECLARE @nChkSerialQTY        INT
   DECLARE @nChkSerialQTYExp     INT
   
   -- Get serial no info
   SELECT 
      @nReceiptSerialNoKey = ReceiptSerialNoKey, 
      @nChkSerialQTYExp = QTYExpected, 
      @cChkSerialSKU = SKU, 
      @nChkSerialQTY = QTY
   FROM ReceiptSerialNo WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
      AND StorerKey = @cStorerKey
      AND SerialNo = @cSerialNo
   
   SET @nRowCount = @@ROWCOUNT
   SET @nTranCount = @@TRANCOUNT
   
   -- New serial no
   IF @nRowCount = 0
   BEGIN
      -- Handling transaction
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_Receive_ReceiptSerialNo -- For rollback or commit only our own transaction
      
      -- Insert ReceiptSerialNo 
      INSERT INTO ReceiptSerialNo (ReceiptKey, ReceiptLineNumber, StorerKey, SKU, SerialNo, QTYExpected, QTY)
      VALUES (@cReceiptKey, @cReceiptLineNumber, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY, @nSerialQTY)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 142751
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RDSNo Fail
         GOTO RollBackTran
      END
      
      COMMIT TRAN rdt_Receive_ReceiptSerialNo
      GOTO Quit
   END
   
   -- Verify serial no
   ELSE IF @nRowCount = 1
   BEGIN
      -- Check SKU matches
      IF @cChkSerialSKU <> @cSKU
      BEGIN
         SET @nErrNo = 142752
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO Diff SKU
         GOTO Quit
      END
      
      -- Check QTY matches
      IF @nChkSerialQTYExp <> @nSerialQTY
      BEGIN
         SET @nErrNo = 142753
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO Diff QTY
         GOTO Quit
      END
      
      -- Check serial no received
      IF @nChkSerialQTY <> 0
      BEGIN
         SET @nErrNo = 142754
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady rcv
         GOTO Quit
      END

      -- Update serial no 
      UPDATE ReceiptSerialNo WITH (ROWLOCK) SET
         QTY = @nSerialQTY
      WHERE ReceiptSerialNoKey = @nReceiptSerialNoKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 142755
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD RSNO Fail
         GOTO Quit
      END      
   END
   ELSE
   BEGIN
      SET @nErrNo = 142756
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNOMultiRecord 
      GOTO Quit
   END  
   GOTO Quit

RollBackTran:  
   ROLLBACK TRAN rdt_Receive_ReceiptSerialNo  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_Receive_ReceiptSerialNo TO NSQL
GO
