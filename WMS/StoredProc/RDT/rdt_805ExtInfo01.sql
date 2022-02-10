if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_805ExtInfo01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_805ExtInfo01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_805ExtInfo01                                    */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Get next SKU to Pick                                        */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 28-06-2017 1.0 Ung         WMS-2307 Created                          */
/************************************************************************/

CREATE PROC rdt.rdt_805ExtInfo01 (
   @nMobile        INT,          
   @nFunc          INT,          
   @cLangCode      NVARCHAR( 3), 
   @nStep          INT,          
   @nAfterStep     INT,          
   @nInputKey      INT,          
   @cFacility      NVARCHAR( 5), 
   @cStorerKey     NVARCHAR( 15),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT 
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStation1 NVARCHAR(10)
   DECLARE @cStation2 NVARCHAR(10)
   DECLARE @cStation3 NVARCHAR(10)
   DECLARE @cStation4 NVARCHAR(10)
   DECLARE @cStation5 NVARCHAR(10)
   DECLARE @nBal      INT

   DECLARE @tOrders TABLE
   (
      OrderKey NVARCHAR(10) NOT NULL
   )
   
   IF @nFunc = 805 -- PTLStation
   BEGIN
      IF @nAfterStep = 3 -- ID/UCC, SKU, QTY
      BEGIN
         -- Variable mapping
         SELECT @cStation1 = Value FROM @tVar WHERE Variable = '@cStation1'
         SELECT @cStation2 = Value FROM @tVar WHERE Variable = '@cStation2'
         SELECT @cStation3 = Value FROM @tVar WHERE Variable = '@cStation3'
         SELECT @cStation4 = Value FROM @tVar WHERE Variable = '@cStation4'
         SELECT @cStation5 = Value FROM @tVar WHERE Variable = '@cStation5'
         
          -- Get orders in station
         INSERT INTO @tOrders (OrderKey) 
         SELECT OrderKey
         FROM rdt.rdtPTLStationLog WITH (NOLOCK) 
         WHERE Station IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
            AND OrderKey <> ''
         
         SELECT @nBal = ISNULL( SUM( PD.QTY), 0)
         FROM @tOrders O 
            JOIN PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = O.OrderKey)
            JOIN Orders AO WITH (NOLOCK) ON (O.OrderKey = AO.OrderKey ) 
         WHERE PD.StorerKey = @cStorerKey
            AND PD.Status <= '5'
            AND PD.CaseID = ''
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND AO.Status <> 'CANC' 
            AND AO.SOStatus <> 'CANC'
      
         SET @nErrNo = 111701
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BAL:
         
         SET @cExtendedInfo = RTRIM( @cErrMsg) + ' ' + CAST( @nBal AS NVARCHAR(10))
         
         SET @nErrNo = 0
         SET @cErrMsg = ''
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_805ExtInfo01 TO NSQL
GO


/*
   -- For ID
   IF @cType = 'ID' 
   BEGIN
      -- Use light
      IF @cLight = '1' 
      BEGIN
         DECLARE @cStation NVARCHAR(10)
         DECLARE @i INT
         
         -- Loop stations
         SET @i = 1
         WHILE @i < 6
         BEGIN
            SET @cStation = ''
            IF @i = 1 SET @cStation = @cStation1 ELSE 
            IF @i = 2 SET @cStation = @cStation2 ELSE 
            IF @i = 3 SET @cStation = @cStation3 ELSE 
            IF @i = 4 SET @cStation = @cStation4 ELSE 
            IF @i = 5 SET @cStation = @cStation5 ELSE 
         
            -- Off all lights in station
            IF @cStation <> ''
               EXEC PTL.isp_PTL_TerminateModule
                   @cStorerKey
                  ,@nFunc
                  ,@cStation
                  ,''
                  ,@bSuccess    OUTPUT
                  ,@nErrNo      OUTPUT
                  ,@cErrMsg     OUTPUT
            
            SET @i = @i + 1
         END
      END
      
      -- Get task of ID
      SELECT 
         @cSKU = PTL.SKU, 
         @nQTY = PTL.ExpectedQTY
      FROM PTL.PTLTran WITH (NOLOCK)
      WHERE PTL.DeviceID IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
         AND DropID = @cScanID
         AND Status = '0'
      ORDER BY PTL.SKU
   
      -- Check tasks
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 54751
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --NoTask!
         GOTO Quit
      END
   
      -- Get SKU description
      DECLARE @cDispStyleColorSize  NVARCHAR( 20)
      SET @cDispStyleColorSize = rdt.RDTGetConfig( @nFunc, 'DispStyleColorSize', @cStorerKey)
      
      IF @cDispStyleColorSize = '0'
         SELECT @cSKUDescr = Descr FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
      
      ELSE IF @cDispStyleColorSize = '1'
         SELECT @cSKUDescr = 
            CAST( Style AS NCHAR(20)) + 
            CAST( Color AS NCHAR(10)) + 
            CAST( Size  AS NCHAR(10)) 
         FROM SKU WITH (NOLOCK) 
         WHERE StorerKey = @cStorerKey 
            AND SKU = @cSKU
         
      ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDispStyleColorSize AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cDispStyleColorSize) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
            ' @cType, @cLight, @cStation1, @cStation2, @cStation3, @cStation4, @cStation5, @cMethod, @cScanID, @cCartonID, @cSKU, ' +
            ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cSKUDescr OUTPUT '
         SET @cSQLParam =
            ' @nMobile    INT,          ' +
            ' @nFunc      INT,          ' +
            ' @cLangCode  NVARCHAR( 3), ' +
            ' @nStep      INT,          ' +
            ' @nInputKey  INT,          ' +
            ' @cFacility  NVARCHAR(5),  ' +
            ' @cStorerKey NVARCHAR(15), ' +
            ' @cType      NVARCHAR(20), ' +
            ' @cLight     NVARCHAR(1),  ' +
            ' @cStation1  NVARCHAR(10), ' +  
            ' @cStation2  NVARCHAR(10), ' +  
            ' @cStation3  NVARCHAR(10), ' +  
            ' @cStation4  NVARCHAR(10), ' +  
            ' @cStation5  NVARCHAR(10), ' +  
            ' @cMethod    NVARCHAR(10), ' +
            ' @cScanID    NVARCHAR(20), ' +
            ' @cSKU       NVARCHAR(20), ' +
            ' @nErrNo     INT          OUTPUT, ' +
            ' @cErrMsg    NVARCHAR(20) OUTPUT, ' +
            ' @cSKUDescr  NVARCHAR(60) OUTPUT  '
      
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
            @cType, @cLight, @cStation1, @cStation2, @cStation3, @cStation4, @cStation5, @cMethod, @cScanID, @cCartonID, @cSKU, 
            @nErrNo OUTPUT, @cErrMsg OUTPUT, @cSKUDescr OUTPUT
      END
     
      GOTO Quit
   END
   
   -- Get IP, position
   DECLARE @cIPAddress NVARCHAR(40)
   DECLARE @cPosition NVARCHAR(10)
   SELECT 
      @cIPAddress = IPAddress, 
      @cPosition = Position 
   FROM rdt.rdtPTLStationLog WITH (NOLOCK) 
   WHERE Station IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
      AND CartonID = @cCartonID
   

   -- For carton
   IF @cType = 'CURRENTCARTON'
   BEGIN
      -- Get current task QTY
      SELECT @nToteQTY = ISNULL( SUM( PTL.ExpectedQTY), 0)
      FROM PTLTran PTL WITH (NOLOCK)
      WHERE IPAddress = @cIPAddress
         AND DevicePosition = @cPosition
         AND DropID = @cScanID
         AND SKU = @cSKU
         AND Status = '0'
   END
   
   -- For carton
   IF @cType = 'NEXTCARTON'
   BEGIN
      -- Get next task exist
      IF NOT EXISTS( SELECT 1 
         FROM PTLTran PTL WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PTL.LOC)
         WHERE IPAddress = @cIPAddress
            AND DevicePosition = @cPosition
            AND Status = '0')
         SET @nErrNo = -1 -- No task
   END
*/