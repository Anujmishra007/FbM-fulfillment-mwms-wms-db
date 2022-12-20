SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
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
/* 2022-08-03   1.1  James      WMS-20213 Add custom lookup field (james01)   */
/* 2022-10-05   1.2  YeeKung    WMS-20491 Add eventlog (yeekung01)            */
/* 2022-12-15   1.3  James      WMS-21350 Create mbol with header (james02)   */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_MbolCreation](
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cOrderKey    NVARCHAR( 10)
   ,@cLoadKey     NVARCHAR( 10)
   ,@cRefNo1      NVARCHAR( 20)
   ,@cRefNo2      NVARCHAR( 20)
   ,@cRefNo3      NVARCHAR( 20)
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
         ' @cLoadKey, @cRefNo1, @cRefNo2, @cRefNo3, @tMbolCreate, ' + 
         ' @cMBOLKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
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
         ' @cRefNo1      NVARCHAR( 20), ' +
         ' @cRefNo2      NVARCHAR( 20), ' +
         ' @cRefNo3      NVARCHAR( 20), ' +
         ' @tMbolCreate  VariableTable READONLY, ' +
         ' @cMBOLKey     NVARCHAR( 10)  OUTPUT, ' +
         ' @nErrNo       INT            OUTPUT, ' +
         ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cOrderKey, 
         @cLoadKey, @cRefNo1, @cRefNo2, @cRefNo3, @tMbolCreate, 
         @cMBOLKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

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
   DECLARE @cMbolCriteria  NVARCHAR( 20)
   DECLARE @cRefnoLabel1   NVARCHAR( 20)
   DECLARE @cRefnoLabel2   NVARCHAR( 20)
   DECLARE @cRefnoLabel3   NVARCHAR( 20)
   DECLARE @cDATA_TYPE     NVARCHAR( 20)
   DECLARE @cSQLSelect     NVARCHAR( MAX)
   DECLARE @cSQLWhere      NVARCHAR( MAX)
   DECLARE @cSQLExists     NVARCHAR( MAX)
   DECLARE @CColumnName    NVARCHAR( 20)
   DECLARE @nCnt           INT = 1
   DECLARE @cOperator      NVARCHAR( 10)
   DECLARE @curCondition   CURSOR
   DECLARE @cValue         NVARCHAR( 30)
   DECLARE @cSQLCondition  NVARCHAR( MAX)
   DECLARE @nOrderAdded    INT = 0
   DECLARE @ndebug         INT = 0
   
   SELECT @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   SET @cMbolCriteria = rdt.rdtGetConfig( @nFunc, 'MbolCriteria', @cStorerKey)
   IF @cMbolCriteria = '0'
      SET @cMbolCriteria = ''
      
   IF @cMbolCriteria <> ''
   BEGIN
   	DECLARE @curMBOLRule CURSOR
   	SET @curMBOLRule = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
   	SELECT UDF01
      FROM dbo.CodeLKUP WITH (NOLOCK)
      WHERE ListName = @cMbolCriteria
      AND   StorerKey = @cStorerKey
      AND   code2 = @cFacility
   	ORDER BY Code
      OPEN @curMBOLRule
      FETCH NEXT FROM @curMBOLRule INTO @CColumnName
      WHILE @@FETCH_STATUS = 0
      BEGIN
      	IF @nCnt = 1
      	   SET @cRefnoLabel1 = @CColumnName

      	IF @nCnt = 2
      	   SET @cRefnoLabel2 = @CColumnName

      	IF @nCnt = 3
      	   SET @cRefnoLabel3 = @CColumnName
      	   
         SET @nCnt = @nCnt + 1      	   
      	FETCH NEXT FROM @curMBOLRule INTO @CColumnName
      END
   END
   
   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN MbolCreation -- For rollback or commit only our own transaction
   
   IF @cOrderKey <> '' OR @cLoadKey <> ''
   BEGIN
      SET @nExists = 0
      SET @cSQLSelect = 
         ' SELECT @nExists = COUNT( 1) FROM dbo.ORDERS O WITH (NOLOCK) '  
      IF @cOrderKey <> ''
         SET @cSQLWhere = ' WHERE O.OrderKey = @cOrderKey ' 
      IF @cLoadKey <> ''
         SET @cSQLWhere = ' WHERE O.LoadKey = @cLoadKey ' 

      IF @cMBOLKey = ''
         SET @cSQLExists = +  ' AND EXISTS ( SELECT 1 
                                FROM dbo.MBOLDetail MD WITH (NOLOCK) 
                                WHERE O.OrderKey = MD.OrderKey)'
      ELSE
         SET @cSQLExists = +  ' AND O.MBOLKey = @cMBOLKey ' 

      SET @cSQL = @cSQLSelect + @cSQLWhere + @cSQLExists
   
      SET @cSQLParam = 
         '@cOrderKey    NVARCHAR( 10), ' +  
         '@cLoadKey     NVARCHAR( 10), ' +  
         '@cMBOLKey     NVARCHAR( 20), ' + 
         '@cRefNo1      NVARCHAR( 20), ' +
         '@cRefNo2      NVARCHAR( 20), ' +
         '@cRefNo3      NVARCHAR( 20), ' +
         '@nExists      INT   OUTPUT '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
         @cOrderKey, @cLoadKey, @cMBOLKey, @cRefNo1, @cRefNo2, @cRefNo3, @nExists OUTPUT

      IF @nExists > 0
      BEGIN
         SET @nErrNo = 172151
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Orders in mbol
         GOTO RollBackTran
      END
   END

   -- Create MBOL header only (james02)
   -- Sometime user wanna create header only and use Excel loader to upload details
   IF @cMBOLKey = 'NOORDER'
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
         SET @nErrNo = 172157
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
         GOTO RollBackTran
      END

      INSERT INTO MBOL (MBOLKey, ExternMBOLKey, Facility, STATUS, Remarks) VALUES 
      (@cMBOLKey, '', @cFacility, '0', 'rdt_MbolCreation')    

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 172158
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins MBOL Err
         GOTO RollBackTran
      END

      COMMIT TRAN MbolCreation -- Only commit change made here
      GOTO Quit
   END

   SET @cSQL = ''
   SET @cSQLSelect = ''
   SET @cSQLWhere = ''
   SET @cSQLExists = ''
   
   SET @cSQLSelect = 
      ' SELECT OrderKey, LoadKey, ExternOrderKey FROM dbo.ORDERS O WITH (NOLOCK) '  

   SET @cSQLWhere = ' WHERE O.StorerKey = @cStorerKey '
   
   IF @cOrderKey <> ''
      SET @cSQLWhere = @cSQLWhere + ' AND O.OrderKey = @cOrderKey ' 
   IF @cLoadKey <> ''
      SET @cSQLWhere = @cSQLWhere + ' AND O.LoadKey = @cLoadKey ' 
      
   IF @cMbolCriteria <> '' 
   BEGIN
      IF @cRefno1 <> ''
      BEGIN
         SELECT @cDATA_TYPE = DATA_TYPE
         FROM INFORMATION_SCHEMA.COLUMNS 
         WHERE TABLE_NAME = 'ORDERS' 
         AND COLUMN_NAME = @cRefnoLabel1

         IF @cDATA_TYPE = 'NVARCHAR'
            SET @cSQLWhere = @cSQLWhere + ' AND O.' + @cRefnoLabel1 + ' = ' +  '@cRefNo1 '
         ELSE IF @cDATA_TYPE = 'INT'
            SET @cSQLWhere = @cSQLWhere + ' AND O.' + @cRefnoLabel1 + ' = ' +  'CAST( @cRefNo1 AS INT) '
         ELSE 
         	SET @cSQLWhere = @cSQLWhere + ' AND CONVERT( NVARCHAR( 8), CAST( O.' + @cRefnoLabel1 + ' AS DATE), 112)' + ' = ' +  '@cRefNo1 '
      END
         	
      IF @cRefno2 <> ''
      BEGIN
         SELECT @cDATA_TYPE = DATA_TYPE
         FROM INFORMATION_SCHEMA.COLUMNS 
         WHERE TABLE_NAME = 'ORDERS' 
         AND COLUMN_NAME = @cRefnoLabel2

         IF @cDATA_TYPE = 'NVARCHAR'
            SET @cSQLWhere = @cSQLWhere + ' AND O.' + @cRefnoLabel2 + ' = ' +  '@cRefNo2 '
         ELSE IF @cDATA_TYPE = 'INT'
            SET @cSQLWhere = @cSQLWhere + ' AND O.' + @cRefnoLabel2 + ' = ' +  'CAST( @cRefNo2 AS INT) '
         ELSE 
         	SET @cSQLWhere = @cSQLWhere + ' AND CONVERT( NVARCHAR( 8), CAST( O.' + @cRefnoLabel2 + ' AS DATE), 112)' + ' = ' +  '@cRefNo2 '
      END

      IF @cRefno3 <> ''
      BEGIN
         SELECT @cDATA_TYPE = DATA_TYPE
         FROM INFORMATION_SCHEMA.COLUMNS 
         WHERE TABLE_NAME = 'ORDERS' 
         AND COLUMN_NAME = @cRefnoLabel3

         IF @cDATA_TYPE = 'NVARCHAR'
            SET @cSQLWhere = @cSQLWhere + ' AND O.' + @cRefnoLabel3 + ' = ' +  '@cRefNo3 '
         ELSE IF @cDATA_TYPE = 'INT'
            SET @cSQLWhere = @cSQLWhere + ' AND O.' + @cRefnoLabel3 + ' = ' +  'CAST( @cRefNo3 AS INT) '
         ELSE 
         	SET @cSQLWhere = @cSQLWhere + ' AND CONVERT( NVARCHAR( 8), CAST( O.' + @cRefnoLabel3 + ' AS DATE), 112)' + ' = ' +  '@cRefNo3 '
      END
   END

   SET @cSQLCondition = ''
   SET @cColumnName = ''
   SET @cOperator = ''
   SET @cValue = ''
   
   SET @curCondition = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   SELECT UDF01, UDF02, UDF03
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME = 'BuildMBCon' 
   AND   Storerkey = @cStorerKey
   AND   code2 = @cFacility
   OPEN @curCondition
   FETCH NEXT FROM @curCondition INTO @cColumnName, @cOperator, @cValue
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @cDATA_TYPE = DATA_TYPE
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'ORDERS' 
      AND COLUMN_NAME = @cColumnName

      IF @@ROWCOUNT = 0
         BREAK

      IF @cDATA_TYPE = 'NVARCHAR'
         SET @cSQLCondition = @cSQLCondition + ' AND O.' + @cColumnName + @cOperator + '''' + @cValue + ''''
      ELSE IF @cDATA_TYPE = 'INT'
         SET @cSQLCondition = @cSQLCondition + ' AND O.' + @cColumnName + @cOperator + CAST( @cValue AS INT)
      ELSE 
         SET @cSQLCondition = @cSQLCondition + ' AND CONVERT( NVARCHAR( 8), CAST( O.' + @cColumnName + ' AS DATE), 112)' + @cOperator + '''' + @cValue + ''''

   	FETCH NEXT FROM @curCondition INTO @cColumnName, @cOperator, @cValue
   END 

   SET @cSQLExists = +  ' AND NOT EXISTS ( SELECT 1 
                          FROM dbo.MBOLDetail MD WITH (NOLOCK) 
                          WHERE O.OrderKey = MD.OrderKey)'

   SET @cSQL = @cSQLSelect + @cSQLWhere + @cSQLCondition + @cSQLExists
   SET @cSQL = @cSQL +  ' GROUP BY OrderKey, LoadKey, ExternOrderKey'
   SET @cSQL = @cSQL +  ' ORDER BY OrderKey'

   IF @ndebug > 0
   BEGIN
      PRINT @cSQL
   END
   
   -- Open cursor  
   SET @cSQL =   
      ' SET @curMBOLDTL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +   
       @cSQL +   
      ' OPEN @curMBOLDTL '   

   SET @cSQLParam = 
      '@curMBOLDTL   CURSOR OUTPUT, ' + 
      '@cStorerKey   NVARCHAR( 15), ' +
      '@cOrderKey    NVARCHAR( 10), ' +  
      '@cLoadKey     NVARCHAR( 10), ' +  
      '@cRefNo1      NVARCHAR( 20), ' +
      '@cRefNo2      NVARCHAR( 20), ' +
      '@cRefNo3      NVARCHAR( 20)  '
         --      SET @nErrNo = -1 
         --GOTO RollBackTran
   EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
      @curMBOLDTL OUTPUT, @cStorerKey, @cOrderKey, @cLoadKey, @cRefNo1, @cRefNo2, @cRefNo3

   FETCH NEXT FROM @curMBOLDTL INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
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

      SET @nOrderAdded = @nOrderAdded + 1

      FETCH NEXT FROM @curMBOLDTL INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
   END

   IF @nOrderAdded = 0
   BEGIN
      SET @nErrNo = 172155
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NO ORDERS ADD
      SET @cMBOLKey = ''
      GOTO RollBackTran
   END

   EXEC RDT.rdt_STD_EventLog    --(yeekung01)
      @cActionType   = '4', 
      @cUserID       = @cUserName,    
      @nMobileNo     = @nMobile,    
      @nFunctionID   = @nFunc,    
      @cFacility     = @cFacility,    
      @cStorerKey    = @cStorerKey,    
      @cTrackingno   = @cRefNo1,    
      @cOrderKey     = @cOUTOrderKey,    
      @cLoadkey      = @cOUTLoadKey,    
      @cMbolkey      = @cMBOLKey   

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

GRANT EXECUTE ON RDT.rdt_MbolCreation TO NSQL
GO