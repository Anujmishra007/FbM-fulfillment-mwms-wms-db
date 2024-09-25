
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_805UnassignSP01                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Close station                                               */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 13-Sep-2024 1.0  yeekung     FCR-609 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_805UnassignSP01] (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT
   ,@nInputKey  INT
   ,@cFacility  NVARCHAR(5)
   ,@cStorerKey NVARCHAR( 15)
   ,@cStation1  NVARCHAR( 10)
   ,@cStation2  NVARCHAR( 10)
   ,@cStation3  NVARCHAR( 10)
   ,@cStation4  NVARCHAR( 10)
   ,@cStation5  NVARCHAR( 10)
   ,@cMethod    NVARCHAR( 10)
   ,@cCartonID  NVARCHAR( 20) -- Optional
   ,@nErrNo     INT           OUTPUT
   ,@cErrMsg    NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE  @cLight         NVARCHAR( 1),
            @bSuccess       INT

   DECLARE @nRowRef INT
   DECLARE @nPTLKey INT
   DECLARE @cIPAddress NVARCHAR(40)
   DECLARE @cPosition  NVARCHAR(10)
   DECLARE @cPTLStationLogQueue  NVARCHAR( 1)

   DECLARE @tOrders TABLE  
   (  
      OrderKey NVARCHAR(10) NOT NULL  
   )  


   SELECT @cLight  = V_String27
   FROM RDT.RDTMobrec (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cPTLStationLogQueue = rdt.RDTGetConfig( @nFunc, 'PTLStationLogQueue', @cStorerKey)
   
   IF @cCartonID <> ''
      SELECT 
         @cIPAddress = IPAddress, 
         @cPosition = Position
      FROM rdt.rdtPTLStationLog WITH (NOLOCK)
      WHERE Station IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
         AND CartonID = @cCartonID

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_805UnassignSP01 -- For rollback or commit only our own transaction


   -- Get orders in station  
   INSERT INTO @tOrders (OrderKey)  
   SELECT OrderKey  
   FROM rdt.rdtPTLStationLog WITH (NOLOCK)  
   WHERE Station IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)  
      AND OrderKey <> ''  

   IF EXISTS ( SELECT 1  
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
                  AND PD.UOM <> '2'  
            )  
   BEGIN  
      SET @nErrNo = 223504
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --WaveNotSorted
      GOTO RollBackTran
   END  

   -- rdtPTLStationLog
   DECLARE @curDPL CURSOR
   IF @cCartonID <> ''
      SET @curDPL = CURSOR FOR
         SELECT RowRef
         FROM rdt.rdtPTLStationLog WITH (NOLOCK)
         WHERE Station IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
            AND IPAddress = @cIPAddress
            AND Position = @cPosition
   ELSE
      SET @curDPL = CURSOR FOR
         SELECT RowRef
         FROM rdt.rdtPTLStationLog WITH (NOLOCK)
         WHERE Station IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)

   OPEN @curDPL
   FETCH NEXT FROM @curDPL INTO @nRowRef
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Update rdtPTLStationLog
      DELETE rdt.rdtPTLStationLog WHERE RowRef = @nRowRef
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 223501
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL LOG Fail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curDPL INTO @nRowRef
   END

   -- PTLTran
   DECLARE @curPTL CURSOR
   IF @cCartonID <> ''
      SET @curPTL = CURSOR FOR
         SELECT PTLKey
         FROM PTL.PTLTran WITH (NOLOCK)
         WHERE DeviceID IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
            AND IPAddress = @cIPAddress
            AND DevicePosition = @cPosition
            AND Status <> '9'
   ELSE
      SET @curPTL = CURSOR FOR
         SELECT PTLKey
         FROM PTL.PTLTran WITH (NOLOCK)
         WHERE DeviceID IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
            AND Status <> '9'
   OPEN @curPTL
   FETCH NEXT FROM @curPTL INTO @nPTLKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Update DeviceProfileLog
      UPDATE PTL.PTLTran SET
         Status = '9',
         EditWho = SUSER_SNAME(), 
         EditDate = GETDATE(), 
         TrafficCop = NULL
      WHERE PTLKey = @nPTLKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 223502
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DEL PTL Fail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curPTL INTO @nPTLKey
   END

   -- (james02)
   -- rdtPTLStationLog
   DECLARE @curPTLQueue CURSOR
   IF @cCartonID <> ''
      SET @curPTLQueue = CURSOR FOR
         SELECT RowRef
         FROM rdt.rdtPTLStationLogQueue WITH (NOLOCK)
         WHERE Station IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
            AND IPAddress = @cIPAddress
            AND Position = @cPosition
   ELSE
      SET @curPTLQueue = CURSOR FOR
         SELECT RowRef
         FROM rdt.rdtPTLStationLogQueue WITH (NOLOCK)
         WHERE Station IN( @cStation1, @cStation2, @cStation3, @cStation4, @cStation5)

   OPEN @curPTLQueue
   FETCH NEXT FROM @curPTLQueue INTO @nRowRef
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Update rdtPTLStationLog
      UPDATE rdt.rdtPTLStationLogQueue SET 
         DataPopulated = '0',
         EditWho = SUSER_SNAME(),
         EditDate = GETDATE()  
      WHERE RowRef = @nRowRef
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 223503
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD QLOG Fail
         GOTO RollBackTran
      END
      FETCH NEXT FROM @curPTLQueue INTO @nRowRef
   END

   IF @cLight = '1' 
   BEGIN
      -- Off all lights
      EXEC PTL.isp_PTL_TerminateModule
            @cStorerKey
         ,@nFunc
         ,@cStation1
         ,'STATION'
         ,@bSuccess    OUTPUT
         ,@nErrNo       OUTPUT
         ,@cErrMsg      OUTPUT
      IF @nErrNo <> 0
         GOTO Quit
   END  
   
   COMMIT TRAN rdt_805UnassignSP01
   GOTO Quit
   
RollBackTran:
   ROLLBACK TRAN rdt_805UnassignSP01 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_805UnassignSP01 TO NSQL
GO