SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_PTLPiece_Assign_BatchCart                             */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 27-10-2023 1.2  Ung      WMS-23803 base on rdt_PTLPiece_Assign_Batch       */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_PTLPiece_Assign_BatchCart] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cStation         NVARCHAR( 10),
   @cMethod          NVARCHAR( 1),
   @cType            NVARCHAR( 15), --POPULATE-IN/POPULATE-OUT/CHECK
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,
   @nScn             INT           OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount  INT
   DECLARE @cSQL        NVARCHAR(MAX)
   DECLARE @cSQLParam   NVARCHAR(MAX)

   DECLARE @cBatchKey   NVARCHAR(20)
   DECLARE @cCartID     NVARCHAR(10)
   DECLARE @cIPAddress  NVARCHAR(40)
   DECLARE @cPosition   NVARCHAR(10)

   SET @nTranCount = @@TRANCOUNT


   /***********************************************************************************************
                                                POPULATE
   ***********************************************************************************************/
   IF @cType = 'POPULATE-IN'
   BEGIN
      -- Get batch
      SET @cBatchKey = ''
      SET @cCartID = ''
      SELECT 
         @cBatchKey = BatchKey, 
         @cCartID = LEFT( UserDefine01, 10)
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation

		-- Prepare next screen var
		SET @cOutField01 = @cBatchKey
		SET @cOutField02 = @cCartID

      -- Assigned
      IF @cBatchKey <> ''
      BEGIN
         SET @cFieldAttr01 = 'O' -- BatchKey
         SET @cFieldAttr02 = 'O' -- CartID
      END

		-- Go to batch screen
		SET @nScn = 6165
   END

   IF @cType = 'POPULATE-OUT'
   BEGIN
      SET @cFieldAttr01 = '' -- BatchKey
      SET @cFieldAttr02 = '' -- CartID
   END

   /***********************************************************************************************
                                                 CHECK
   ***********************************************************************************************/
   IF @cType = 'CHECK'
   BEGIN
      -- Screen mapping
      SET @cBatchKey = CASE WHEN @cFieldAttr01 = '' THEN @cInField01 ELSE @cOutField01 END
      SET @cCartID = CASE WHEN @cFieldAttr02 = '' THEN @cInField02 ELSE @cOutField02 END

      -- BatchKey enable
      IF @cFieldAttr01 = ''
      BEGIN
         -- Check blank
         IF @cBatchKey = ''
         BEGIN
            SET @nErrNo = 208001
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need batch
            EXEC rdt.rdtSetFocusField @nMobile, 1 -- BatchKey
            SET @cOutField01 = ''
            GOTO Quit
         END
            
         -- Check batch valid
         IF NOT EXISTS( SELECT 1 FROM PackTask WITH (NOLOCK) WHERE TaskBatchNo = @cBatchKey)
         BEGIN
            SET @nErrNo = 208002
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid batch
            EXEC rdt.rdtSetFocusField @nMobile, 1 -- BatchKey
            SET @cOutField01 = ''
            GOTO Quit
         END

         -- Check batch assigned
         IF EXISTS( SELECT 1
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE Station <> @cStation
               AND BatchKey = @cBatchKey)
         BEGIN
            SET @nErrNo = 208003
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Batch assigned
            EXEC rdt.rdtSetFocusField @nMobile, 1 -- BatchKey
            SET @cOutField01 = ''
            GOTO Quit
         END

         -- Check batch belong to login storer
         IF EXISTS( SELECT 1
            FROM PackTask T WITH (NOLOCK)
               JOIN Orders O WITH (NOLOCK) ON (O.OrderKey = T.OrderKey)
            WHERE T.TaskBatchNo = @cBatchKey
               AND O.StorerKey <> @cStorerKey)
         BEGIN
            SET @nErrNo = 208004
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff Storerf
            EXEC rdt.rdtSetFocusField @nMobile, 1 -- BatchKey
            SET @cOutField01 = ''
            GOTO Quit
         END

         -- Check pick not completed
         IF rdt.RDTGetConfig( @nFunc, 'CheckPickCompleted', @cStorerKey) = '1'
         BEGIN
            IF EXISTS( SELECT 1
               FROM PackTask T WITH (NOLOCK)
                  JOIN Orders O WITH (NOLOCK) ON (O.OrderKey = T.OrderKey)
                  JOIN PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)
               WHERE T.TaskBatchNo = @cBatchKey
                  AND PD.Status IN ('0', '4')
                  AND PD.QTY > 0)
            BEGIN
               SET @nErrNo = 208005
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pick NotFinish
               EXEC rdt.rdtSetFocusField @nMobile, 1 -- BatchKey
               SET @cOutField01 = ''
               GOTO Quit
            END
         END
         
         SET @cOutField01 = @cBatchKey
      END

      -- CartID enable
      IF @cFieldAttr02 = ''
      BEGIN
         -- Check blank
         IF @cCartID = ''
         BEGIN
            SET @nErrNo = 208006
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need cart
            EXEC rdt.rdtSetFocusField @nMobile, 2 -- CartID
            SET @cOutField02 = ''
            GOTO Quit
         END
            
         -- Check cart format
         IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'CartID', @cCartID) = 0
         BEGIN
            SET @nErrNo = 208007
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid cart
            EXEC rdt.rdtSetFocusField @nMobile, 2 -- CartID
            SET @cOutField02 = ''
            GOTO Quit
         END

         -- Check batch assigned
         IF EXISTS( SELECT 1
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE Station <> @cStation
               AND StorerKey = @cStorerKey
               AND UserDefine01 = @cCartID)
         BEGIN
            SET @nErrNo = 208008
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cart assigned
            EXEC rdt.rdtSetFocusField @nMobile, 2 -- CartID
            SET @cOutField02 = ''
            GOTO Quit
         END
         
         -- Get station info
         DECLARE @nTotalPos INT
         SELECT @nTotalPos = COUNT(1)
         FROM DeviceProfile WITH (NOLOCK)
         WHERE DeviceType = 'STATION'
            AND DeviceID = @cStation

         -- Get total orders
         DECLARE @nTotalOrder INT
         SELECT @nTotalOrder = COUNT(1) FROM PackTask WITH (NOLOCK) WHERE TaskBatchNo = @cBatchKey

         -- Check order fit in station
         IF @nTotalOrder > @nTotalPos
         BEGIN
            SET @nErrNo = 208009
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not enuf Pos
            EXEC rdt.rdtSetFocusField @nMobile, 2 -- CartID
            SET @cOutField02 = ''
            GOTO Quit
         END

         -- Handling transaction
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdt_PTLPiece_Assign -- For rollback or commit only our own transaction

         SET @cIPAddress = '' -- (james01)

         -- Loop orders
         DECLARE @cPreassignPos NVARCHAR(10)
         DECLARE @cOrderKey NVARCHAR(10)
         DECLARE @curOrder CURSOR
         SET @curOrder = CURSOR FOR
            SELECT OrderKey, DevicePosition
            FROM PackTask PT WITH (NOLOCK)
            WHERE TaskBatchNo = @cBatchKey
            ORDER BY OrderKey
         OPEN @curOrder
         FETCH NEXT FROM @curOrder INTO @cOrderKey, @cPreassignPos
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Not pre-assign position
            IF @cPreassignPos = ''
            BEGIN
               -- Get position not yet assign
               SET @cPosition = ''
               SELECT TOP 1
                  @cIPAddress = DP.IPAddress,
                  @cPosition = DP.DevicePosition
               FROM dbo.DeviceProfile DP WITH (NOLOCK)
               WHERE DP.DeviceType = 'STATION'
                  AND DP.DeviceID = @cStation
                  AND NOT EXISTS( SELECT 1
                     FROM rdt.rdtPTLPieceLog Log WITH (NOLOCK)
                     WHERE Log.Station = @cStation
                        AND Log.Position = DP.DevicePosition)
               ORDER BY DP.LogicalPos, DP.DevicePosition
            END
            ELSE
            BEGIN
               -- Use preassign position
               SET @cPosition = @cPreassignPos

               SELECT TOP 1
                  @cIPAddress = DP.IPAddress
               FROM dbo.DeviceProfile DP WITH (NOLOCK)
               WHERE DP.DeviceType = 'STATION'
                  AND DP.DeviceID = @cStation
                  AND DevicePosition = @cPosition
            END

            -- Save assign
            INSERT rdt.rdtPTLPieceLog (Station, IPAddress, Position, BatchKey, OrderKey, StorerKey, UserDefine01)
            SELECT @cStation, @cIPAddress, @cPosition, @cBatchKey, @cOrderKey, @cStorerKey, @cCartID
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 208010
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS Log fail
               GOTO RollBackTran
            END

            FETCH NEXT FROM @curOrder INTO @cOrderKey, @cPreassignPos
         END

         COMMIT TRAN rdt_PTLStation_Assign
      END
      
      -- Enable field
      SET @cFieldAttr01 = '' -- BatchKey
      SET @cFieldAttr02 = '' -- CartID
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_PTLStation_Assign

Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON  [RDT].[rdt_PTLPiece_Assign_BatchCart] TO [NSQL]
GO
