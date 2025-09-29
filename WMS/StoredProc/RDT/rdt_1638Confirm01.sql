SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1638Confirm01                                     */
/* Copyright: Maersk                                                      */
/* Customer: HUDA                                                         */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-09-25 1.0.0  Nick       FCR-8110 Created                          */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1638Confirm01] (
    @nMobile            INT
   ,@nFunc              INT
   ,@cLangCode          NVARCHAR( 3)
   ,@nStep              INT
   ,@nInputKey          INT
   ,@cFacility          NVARCHAR( 5)
   ,@cStorerKey         NVARCHAR( 15)
   ,@cPalletKey         NVARCHAR( 30)
   ,@cLOC               NVARCHAR( 10)
   ,@cCaseID            NVARCHAR( 20)
   ,@cCapturePackInfo   NVARCHAR( 10)
   ,@cCartonType        NVARCHAR( 10)
   ,@cCube              NVARCHAR( 10)
   ,@cWeight            NVARCHAR( 10)
   ,@cRefNo             NVARCHAR( 20)
   ,@cPickSlipNo        NVARCHAR( 10) 
   ,@nCartonNo          INT
   ,@cSKU               NVARCHAR( 20)
   ,@nQTY               INT
   ,@nErrNo             INT           OUTPUT
   ,@cErrMsg            NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cPalletLineNumber      NVARCHAR( 5),
      @nLoopIndex             INT,
      @cRefNo1                NVARCHAR(20),
      @cRefNo2                NVARCHAR(20)

   DECLARE @tPackDetail TABLE
   (
      RowIndex          INT IDENTITY( 1, 1),
      CaseID            NVARCHAR( 20),
      SKU               NVARCHAR( 20),
      LOC               NVARCHAR( 10),
      Qty               INT
   )

   INSERT INTO @tPackDetail (CaseID, SKU, LOC, Qty)
   SELECT DISTINCT
      LabelNo,
      SKU,
      @cLOC,
      Qty
   FROM dbo.PackDetail WITH (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
      AND StorerKey = @cStorerKey
      AND Qty > 0

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 247803
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --No PackDetail found
      RETURN
   END

   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0
      BEGIN TRAN  -- Begin our own transaction
   ELSE
      SAVE TRAN rdt_1638Confirm01 -- For rollback or commit only our own transaction

   SET @nLoopIndex = -1
   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @nLoopIndex = RowIndex,
         @cCaseID = CaseID,
         @cSKU = SKU,
         @cLOC = LOC,
         @nQty = Qty
      FROM @tPackDetail
      WHERE RowIndex > @nLoopIndex
      ORDER BY RowIndex

      IF @@ROWCOUNT = 0
         BREAK -- Exit loop

      -- Insert PalletDetail
      IF EXISTS (SELECT 1 
                     FROM dbo.PalletDetail WITH (NOLOCK) 
                     WHERE PalletKey = @cPalletKey 
                        AND CaseID = @cCaseID
                        AND StorerKey = @cStorerKey
                        AND Sku = @cSKU
                        AND Loc = @cLOC)
      BEGIN
         SET @nErrNo = 247804
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Order already scanned
         GOTO ROLLBACK_TRAN
      END
      ELSE
      BEGIN
         SELECT @cPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
         FROM dbo.PalletDetail WITH (NOLOCK)
         WHERE PalletKey = @cPalletKey
            AND StorerKey = @cStorerKey
         
         BEGIN TRY
            INSERT INTO dbo.PalletDetail
               (PalletKey, PalletLineNumber, CaseId, StorerKey, Sku, Loc, Qty, Status, 
               AddDate, AddWho, EditDate, EditWho)
            VALUES
               (@cPalletKey, @cPalletLineNumber, @cCaseID, @cStorerKey, @cSKU, @cLOC, @nQty, '0', 
               GETDATE(), SUSER_SNAME(), GETDATE(), SUSER_SNAME())
         END TRY
         BEGIN CATCH
            SET @nErrNo = 247801
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Insert Pallet Detail Failed
            GOTO ROLLBACK_TRAN
         END CATCH

         SET @cRefNo1 = SUBSTRING( @cPalletKey, 1, 15)
         SET @cRefNo2 = SUBSTRING( @cPalletKey, 16, 15)

         BEGIN TRY
            -- EventLog
            EXEC RDT.rdt_STD_EventLog
               @cActionType   = '14',
               @nMobileNo     = @nMobile,
               @nFunctionID   = @nFunc,
               @cFacility     = @cFacility,
               @cStorerKey    = @cStorerkey,
               @cLocation     = @cLOC,
               @cID           = @cCaseID,
               @cSKU          = @cSKU,
               @nQTY          = @nQTY,
               @cRefNo1       = @cRefNo1,
               @cRefNo2       = @cRefNo2
         END TRY
         BEGIN CATCH
            SET @nErrNo = 247802
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Insert Event Log Failed
            GOTO ROLLBACK_TRAN
         END CATCH
      END
   END

   GOTO Quit

ROLLBACK_TRAN:
   IF @nTranCount = 0
   BEGIN
      ROLLBACK TRANSACTION
   END
   ELSE
   BEGIN
      IF XACT_STATE() <> -1
         ROLLBACK TRANSACTION rdt_1638Confirm01
   END
Quit:
   IF @@TRANCOUNT > @nTranCount
   BEGIN
      IF XACT_STATE() = 1
      BEGIN
         COMMIT TRANSACTION
      END
      ELSE
      BEGIN
         -- If XACT_STATE() is 0 or -1, the transaction is not committable.
         -- In this case, a rollback might be necessary if XACT_STATE() is -1.
         ROLLBACK TRANSACTION -- This will only execute if there's an active transaction (XACT_STATE() = -1).
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1638Confirm01 TO NSQL
GO