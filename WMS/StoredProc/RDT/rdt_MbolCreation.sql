IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_MbolCreation]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_MbolCreation]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_MbolCreation                                          */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Purpose: Populate orders into MBOL, MBOLDetail                             */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2021-07-27   1.0  James      WMS-17484 Created                             */
/******************************************************************************/
CREATE  PROC rdt.rdt_MbolCreation(
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cOrderKey    NVARCHAR( 10)
   ,@cLoadKey     NVARCHAR( 10)
   ,@cRefNo       NVARCHAR( 20)
   ,@tMbolCreate  VariableTable READONLY
   ,@cMBOLKey     NVARCHAR( 10)  OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cMbolCreateSP  NVARCHAR( 20)

   -- Get storer config
   SET @cMbolCreateSP = rdt.RDTGetConfig( @nFunc, 'MbolCreateSP', @cStorerKey)

   /***********************************************************************************************
                                              Custom create 
   ***********************************************************************************************/
   -- Lookup by SP
   IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cMbolCreateSP AND type = 'P')
   BEGIN
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cMbolCreateSP) +
         ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cOrderKey, ' +
         ' @cLoadKey, @cRefNo, @tMbolCreate, @cMBOLKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
      SET @cSQLParam =
         ' @nMobile      INT,           ' +
         ' @nFunc        INT,           ' +
         ' @cLangCode    NVARCHAR( 3),  ' +
         ' @nStep        INT,           ' +
         ' @nInputKey    INT,           ' +
         ' @cFacility    NVARCHAR( 5),  ' +
         ' @cStorerKey   NVARCHAR( 15), ' +
         ' @cOrderKey    NVARCHAR( 10), ' +
         ' @cLoadKey     NVARCHAR( 10), ' +
         ' @cRefNo       NVARCHAR( 20), ' +
         ' @tMbolCreate  VariableTable READONLY, ' +
         ' @cMBOLKey     NVARCHAR( 10)  OUTPUT, ' +
         ' @nErrNo       INT            OUTPUT, ' +
         ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cOrderKey, 
         @cLoadKey, @cRefNo, @tMbolCreate, @cMBOLKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

      GOTO Quit
   END
   
   /***********************************************************************************************
                                             Standard create
   ***********************************************************************************************/
   DECLARE @nTranCount  INT
   DECLARE @nSuccess    INT
   DECLARE @nExists     INT
   DECLARE @curMBOLDTL  CURSOR
   DECLARE @cOUTOrderKey   NVARCHAR( 10)
   DECLARE @cOUTLoadKey    NVARCHAR( 10)
   DECLARE @cOUTExternOrderKey    NVARCHAR( 50)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cRefNoLookupColumn   NVARCHAR( 20)
   
   SELECT @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @cRefNo <> ''
      SET @cRefNoLookupColumn = rdt.rdtGetConfig( @nFunc, 'RefNoLookupColumn', @cStorerKey)

   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN MbolCreation -- For rollback or commit only our own transaction
   

   SET @nExists = 0
   SET @cSQL = 
      ' SELECT @nExists = COUNT( 1) FROM dbo.ORDERS O WITH (NOLOCK) '  
   IF @cOrderKey <> ''
      SET @cSQL = @cSQL +  ' WHERE OrderKey = @cOrderKey ' 
   IF @cLoadKey <> ''
      SET @cSQL = @cSQL +  ' WHERE LoadKey = @cLoadKey ' 
   IF @cRefNo <> ''
      SET @cSQL = @cSQL +  ' WHERE ' + @cRefNoLookupColumn + ' = ' +  '@cRefNo '
   SET @cSQL = @cSQL +  ' AND EXISTS ( SELECT 1 
                           FROM dbo.MBOLDetail MD WITH (NOLOCK) 
                           WHERE O.OrderKey = MD.OrderKey)'

   SET @cSQLParam = 
      '@cOrderKey    NVARCHAR( 10), ' +  
      '@cLoadKey     NVARCHAR( 10), ' +  
      '@cRefNo       NVARCHAR( 20), ' + 
      '@nExists      INT   OUTPUT ' 

   EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
      @cOrderKey, @cLoadKey, @cRefNo, @nExists OUTPUT

   IF @nExists > 0
   BEGIN
      SET @nErrNo = 172151
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Orders in mbol
      GOTO RollBackTran
   END

   IF @cMBOLKey = ''
   BEGIN
      SET @nSuccess = 1
      EXECUTE dbo.nspg_getkey
         'MBOL'
         , 10
         , @cMBOLKey    OUTPUT
         , @nSuccess    OUTPUT
         , @nErrNo      OUTPUT
         , @cErrMsg     OUTPUT

      IF @nSuccess <> 1
      BEGIN
         SET @nErrNo = 172152
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
         GOTO RollBackTran
      END

      INSERT INTO MBOL (MBOLKey, ExternMBOLKey, Facility, STATUS, Remarks) VALUES 
      (@cMBOLKey, '', @cFacility, '0', 'rdt_MbolCreation')    

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 172153
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins MBOL Err
         GOTO RollBackTran
      END
   END

   SET @cSQL = 
      ' SELECT OrderKey, LoadKey, ExternOrderKey FROM dbo.ORDERS WITH (NOLOCK) '  
   IF @cOrderKey <> ''
      SET @cSQL = @cSQL +  ' WHERE OrderKey = @cOrderKey ' 
   IF @cLoadKey <> ''
      SET @cSQL = @cSQL +  ' WHERE LoadKey = @cLoadKey ' 
   IF @cRefNo <> ''
      SET @cSQL = @cSQL +  ' WHERE ' + @cRefNoLookupColumn + ' = ' +  '@cRefNo '
   SET @cSQL = @cSQL +  ' GROUP BY OrderKey, LoadKey, ExternOrderKey'
   SET @cSQL = @cSQL +  ' ORDER BY OrderKey'

   -- Open cursor  
   SET @cSQL =   
      ' SET @curMBOLDTL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +   
       @cSQL +   
      ' OPEN @curMBOLDTL '   

   SET @cSQLParam = 
      '@curMBOLDTL   CURSOR OUTPUT, ' + 
      '@cOrderKey    NVARCHAR( 10), ' +  
      '@cLoadKey     NVARCHAR( 10), ' +  
      '@cRefNo       NVARCHAR( 20)  ' 

   EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
      @curMBOLDTL OUTPUT, @cOrderKey, @cLoadKey, @cRefNo

   FETCH NEXT FROM @curMBOLDTL INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      INSERT INTO dbo.MBOLDetail 
      (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, ExternOrderKey, AddWho, AddDate, EditWho, EditDate) 
      VALUES
      (@cMBOLKey, '00000', @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey, @cUserName, GETDATE(), @cUserName, GETDATE())
         
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 172154
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins MBOLDtl Err
         GOTO RollBackTran
      END

      FETCH NEXT FROM @curMBOLDTL INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
   END

   COMMIT TRAN MbolCreation -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN MbolCreation -- Only rollback change made here
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

GRANT EXECUTE ON [rdt].[rdt_MbolCreation] TO NSQL
GO