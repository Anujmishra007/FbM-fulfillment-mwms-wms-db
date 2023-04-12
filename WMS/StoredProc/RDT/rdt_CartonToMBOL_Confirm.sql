SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_CartonToMBOL_Confirm                                  */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author   Purposes                                        */
/* 2023-03-30   1.0  Ung      WMS-22181 Created                               */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_CartonToMBOL_Confirm](
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cMBOLKey     NVARCHAR( 10)
   ,@cRefNo       NVARCHAR( 20)
   ,@cOrderKey    NVARCHAR( 10)
   ,@cPalletLOC   NVARCHAR( 10) 
   ,@cCartonID    NVARCHAR( 20)
   ,@cSKU         NVARCHAR( 20) 
   ,@cData1       NVARCHAR( 20)
   ,@cData2       NVARCHAR( 20)
   ,@cData3       NVARCHAR( 20)
   ,@cData4       NVARCHAR( 20)
   ,@cData5       NVARCHAR( 20)
   ,@tConfirmVar  VariableTable  READONLY
   ,@nTotalCarton INT            OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 20)  OUTPUT
) 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL        NVARCHAR( MAX)
   DECLARE @cSQLParam   NVARCHAR( MAX)
   DECLARE @cConfirmSP   NVARCHAR( 20)

   -- Get storer config
   SET @cConfirmSP = rdt.RDTGetConfig( @nFunc, 'ConfirmSP', @cStorerKey)
   IF @cConfirmSP = '0'
      SET @cConfirmSP = ''
 
   /***********************************************************************************************
                                              Custom confirm
   ***********************************************************************************************/
   IF @cConfirmSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cConfirmSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cConfirmSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
            ' @cMBOLKey, @cRefNo, @cOrderKey, @cPalletLOC, @cCartonID, @cSKU, @cData1, @cData2, @cData3, @cData4, @cData5, @tConfirmVar, ' +
            ' @nTotalCarton OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            ' @nMobile      INT,           ' +
            ' @nFunc        INT,           ' +
            ' @cLangCode    NVARCHAR( 3),  ' +
            ' @nStep        INT,           ' +
            ' @nInputKey    INT,           ' +
            ' @cFacility    NVARCHAR( 5),  ' +
            ' @cStorerKey   NVARCHAR( 15), ' +
            ' @cMBOLKey     NVARCHAR( 10), ' +
            ' @cRefNo       NVARCHAR( 20), ' +
            ' @cOrderKey    NVARCHAR( 10), ' +
            ' @cPalletLOC   NVARCHAR( 10), ' + 
            ' @cCartonID    NVARCHAR( 20), ' +
            ' @cSKU         NVARCHAR( 20), ' + 
            ' @cData1       NVARCHAR( 20), ' +
            ' @cData2       NVARCHAR( 20), ' +
            ' @cData3       NVARCHAR( 20), ' +
            ' @cData4       NVARCHAR( 20), ' +
            ' @cData5       NVARCHAR( 20), ' +
            ' @tConfirmVar  VariableTable  READONLY, ' +
            ' @nTotalCarton INT            OUTPUT,   ' +
            ' @nErrNo       INT            OUTPUT,   ' +
            ' @cErrMsg      NVARCHAR( 20)  OUTPUT    '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cOrderKey,
            @cMBOLKey, @cRefNo, @cOrderKey, @cPalletLOC, @cCartonID, @cSKU, @cData1, @cData2, @cData3, @cData4, @cData5, @tConfirmVar,
            @nTotalCarton OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

         GOTO Quit
      END
   END

   /***********************************************************************************************
                                             Standard create
   ***********************************************************************************************/
   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_CartonToMBOL_Confirm -- For rollback or commit only our own transaction

   -- MBOL detail
   IF NOT EXISTS( SELECT 1 FROM dbo.MBOLDetail WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND OrderKey = @cOrderKey)
   BEGIN
      INSERT INTO dbo.MBOLDetail
         (MBOLKey, MBOLLineNumber, OrderKey)
      VALUES
         (@cMBOLKey, '00000', @cOrderKey)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 198901
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBDtl Fail
         GOTO RollBackTran
      END
   END

/*
   -- PalletDetail
   IF NOT EXISTS( SELECT 1 FROM PalletDetail WITH (NOLOCK) WHERE PalletKey = @cMBOLKey AND CaseID = @cCartonID)
   BEGIN
      INSERT INTO dbo.PalletDetail
         (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, QTY, Status, UserDefine01)
      VALUES
         (@cMBOLKey, '0', @cCartonID, @cStorerKey, @cSKU, @cPalletLOC, 0, '0', @cOrderKey)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 198902
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PLDtl Fail
         GOTO RollbackTran
      END
   END
*/

-- Update stat
UPDATE dbo.MBOL SET
   NoofIDSCarton = ISNULL( NoofIDSCarton, 0) + 1, 
   EditWho = SUSER_SNAME(), 
   EditDate = GETDATE()
WHERE MBOLKey = @cMBOLKey
IF @@ERROR <> 0
BEGIN
   SET @nErrNo = 198903
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD MBOL Fail
   GOTO RollBackTran
END

-- Get stat
SELECT @nTotalCarton = NoofIDSCarton
FROM dbo.MBOL WITH (NOLOCK)
WHERE MbolKey = @cMBOLKey

/*
   SELECT @nTotalCarton = COUNT(1)
   FROM dbo.PalletDetail WITH (NOLOCK)
   WHERE PalletKey = @cMBOLKey
*/

   -- Check max carton
   DECLARE @cMaxCarton NVARCHAR(20)
   DECLARE @nMaxCarton INT
   SET @cMaxCarton = rdt.rdtGetConfig( @nFunc, 'MaxCarton', @cStorerKey)
   SET @nMaxCarton = ISNULL( TRY_CAST( @cMaxCarton AS INT), 0)
   IF @nMaxCarton > 0 AND @nTotalCarton > @nMaxCarton
   BEGIN
      SET @nErrNo = 198904
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over MAXCarton
      GOTO RollBackTran
   END
   
   -- EventLog
   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '4',
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerKey,
      @cMbolkey      = @cMBOLKey, 
      @cRefNo1       = @cData1,
      @cRefNo2       = @cData2,
      @cRefNo3       = @cData3,
      @cRefNo4       = @cData4,
      @cRefNo5       = @cData5,
      @cOrderKey     = @cOrderKey,
      @cLocation     = @cPalletLOC, 
      @cCartonID     = @cCartonID, 
      @cSKU          = @cSKU

   COMMIT TRAN rdt_CartonToMBOL_Confirm -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_CartonToMBOL_Confirm -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_CartonToMBOL_Confirm TO NSQL
GO