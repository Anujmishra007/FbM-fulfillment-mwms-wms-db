if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_PTLStation_GetTask_OrderSKU]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_PTLStation_GetTask_OrderSKU
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_PTLStation_GetTask_OrderSKU                     */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Get next SKU to Pick                                        */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 29-02-2016 1.0  Ung        SOS363160 Created                         */
/************************************************************************/

CREATE PROC rdt.rdt_PTLStation_GetTask_OrderSKU (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT 
   ,@nInputKey  INT 
   ,@cFacility  NVARCHAR(5)
   ,@cStorerKey NVARCHAR(15)
   ,@cType      NVARCHAR(20)
   ,@cLight     NVARCHAR(1)
   ,@cStation1  NVARCHAR(10)  
   ,@cStation2  NVARCHAR(10)  
   ,@cStation3  NVARCHAR(10)  
   ,@cStation4  NVARCHAR(10)  
   ,@cStation5  NVARCHAR(10)  
   ,@cMethod    NVARCHAR(10)
   ,@cScanID    NVARCHAR(20)
   ,@cSKU       NVARCHAR(20)
   ,@cCartonID  NVARCHAR(20)
   ,@nErrNo     INT          OUTPUT
   ,@cErrMsg    NVARCHAR(20) OUTPUT
   ,@nCartonQTY INT = 0      OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cIPAddress  NVARCHAR(40)
   DECLARE @cPosition   NVARCHAR(10)
   DECLARE @nGroupKey   INT
   
   -- Get position
   SELECT 
      @cIPAddress = IPAddress, 
      @cPosition = Position, 
      @nGroupKey = RowRef
   FROM rdt.rdtPTLStationLog WITH (NOLOCK) 
   WHERE Station IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
      AND CartonID = @cCartonID
   
   -- For tote
   IF @cType = 'CURRENTCARTON'
   BEGIN
      -- Get current task QTY
      SELECT @nCartonQTY = ISNULL( SUM( ExpectedQTY), 0)
      FROM PTL.PTLTran WITH (NOLOCK)
      WHERE IPAddress = @cIPAddress 
         AND DevicePosition = @cPosition
         AND GroupKey = @nGroupKey
         AND DropID = @cScanID
         AND SKU = @cSKU
         AND Status <> '9'
   END
   
   -- For tote
   IF @cType = 'NEXTCARTON'
   BEGIN
      -- Get next task exist
      IF NOT EXISTS( SELECT 1 
         FROM PTL.PTLTran WITH (NOLOCK)
         WHERE IPAddress = @cIPAddress 
            AND DevicePosition = @cPosition
            AND GroupKey = @nGroupKey
            AND Status <> '9')
         SET @nErrNo = -1 -- No task
   END
   
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_PTLStation_GetTask_OrderSKU TO NSQL
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