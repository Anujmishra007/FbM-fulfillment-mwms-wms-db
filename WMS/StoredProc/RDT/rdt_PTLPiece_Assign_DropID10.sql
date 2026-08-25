SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_PTLPiece_Assign_DropID10                              */
/* Copyright      : Maersk                                                    */
/* Purpose        : PTW/PTL Assignment for AEOMX with:                        */
/*                  - 3-operator limit per station                            */
/*                  - Color assignment per user (Yellow/Green/Red)            */
/*                  - Virtual carton to physical slot assignment              */
/*                  - DropID validation against station                       */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 2026-07-06 1.0  Cuize    FCR-13139 Created                                 */
/* 2026-08-17 1.1  Cuize    UWP-63852 Fix operator count and color lookup     */
/* 2026-08-20 1.2  Cuize    UWP-64610 Sync color to C_String1 in CHECK step   */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_PTLPiece_Assign_DropID10] (
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
   @cErrMsg          NVARCHAR( 1024) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Variables
   DECLARE @cDropID           NVARCHAR(20)
   DECLARE @cUserName         NVARCHAR(18)
   DECLARE @nOperatorCount    INT
   DECLARE @cUserColor        NVARCHAR(20)
   DECLARE @cAvailableColor   NVARCHAR(20)
   DECLARE @cWaveKey          NVARCHAR(10)
   DECLARE @cWaveStation      NVARCHAR(10)
   DECLARE @cVirtualCartonID  NVARCHAR(20)
   DECLARE @cPosition         NVARCHAR(10)
   DECLARE @cIPAddress        NVARCHAR(40)
   DECLARE @nTotalDropID      INT
   DECLARE @bSuccess          INT

   -- Get username from MobRec
   SELECT @cUserName = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   /***********************************************************************************************
                                          POPULATE-IN (Step 1 -> Step 2)
   ***********************************************************************************************/
   IF @cType = 'POPULATE-IN'
   BEGIN
      -- ========================================================================
      -- CHECK 1: 3-operator limit per station
      -- FCR-13139: Count by UserDefine01 (color), not AddWho
      -- When user exits station, UserDefine02 stays INPROGRESS but color is cleared
      -- So active operators = distinct non-empty colors
      -- ========================================================================
      SELECT @nOperatorCount = COUNT(DISTINCT UserDefine01)
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND UserDefine02 = 'INPROGRESS'
        AND ISNULL(UserDefine01, '') <> ''
        AND AddWho <> @cUserName

      IF @nOperatorCount >= 3
      BEGIN
         SET @nErrNo = 272751
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Station Busy
         GOTO Quit
      END

      -- ========================================================================
      -- CHECK 2: Assign color to user
      -- ========================================================================
      -- Check if user already has a color assigned
      -- FCR-13139 FIX: Only select records WITH a color assigned
      -- Avoids returning empty string when user has mixed records
      SELECT TOP 1 @cUserColor = UserDefine01
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND AddWho = @cUserName
        AND UserDefine02 = 'INPROGRESS'
        AND ISNULL(UserDefine01, '') <> ''
      ORDER BY EditDate DESC

      IF @cUserColor IS NULL OR @cUserColor = ''
      BEGIN
         -- Find first available color not assigned to other users
         SELECT TOP 1 @cAvailableColor = UDF01
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'PTLLIGHTS'
           AND Code = @cStation
           AND StorerKey = @cStorerKey
           AND UDF03 = 'SORT'
           AND UDF01 NOT IN (
               SELECT DISTINCT UserDefine01
               FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
               WHERE Station = @cStation
                 AND UserDefine02 = 'INPROGRESS'
                 AND UserDefine01 IS NOT NULL
                 AND UserDefine01 <> ''
           )
         ORDER BY Code2

         IF @cAvailableColor IS NULL
         BEGIN
            SET @nErrNo = 272754
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No Color Avail
            GOTO Quit
         END

         SET @cUserColor = @cAvailableColor
      END

      -- FCR-13139: Store color in MobRec.C_String1 for screen attribute lookup
      -- This persists color even after rdtPTLPieceLog becomes COMPLETE
      UPDATE rdt.rdtMobRec WITH (ROWLOCK)
      SET C_String1 = @cUserColor,
          EditDate = GETDATE()
      WHERE Mobile = @nMobile

      -- Get stats
      SELECT @nTotalDropID = COUNT(DISTINCT SourceKey)
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND Method = @cMethod
        AND SourceKey <> ''

      -- Prepare next screen vars
      SET @cOutField01 = ''  -- DropID input
      SET @cOutField02 = CAST(@nTotalDropID AS NVARCHAR(5))

      -- Go to DropID scan screen
      SET @nScn = 4602
   END


   /***********************************************************************************************
                                          POPULATE-OUT (Step 4 - Unassign)
   ***********************************************************************************************/
   IF @cType = 'POPULATE-OUT'
   BEGIN
      -- Step 4: Unassign station (Option 1 = YES)
      IF @nStep = 4 AND @nInputKey = 1 AND @cInField01 = '1'
      BEGIN
         -- ========================================================================
         -- UNASSIGN: Clear user from all active slots
         -- ========================================================================
         DECLARE @tUserSlots TABLE (
            Position NVARCHAR(10),
            SourceKey NVARCHAR(20),
            CartonID NVARCHAR(20),
            SlotLOC NVARCHAR(10)
         )

         -- Get user's active slots with their info
         INSERT INTO @tUserSlots (Position, SourceKey, CartonID, SlotLOC)
         SELECT L.Position, L.SourceKey, L.CartonID, DP.LOC
         FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
         JOIN dbo.DeviceProfile DP WITH (NOLOCK)
            ON DP.DeviceID = L.Station
            AND DP.DevicePosition = L.Position
            AND DP.StorerKey = @cStorerKey
         WHERE L.Station = @cStation
           AND L.AddWho = @cUserName
           AND L.UserDefine02 = 'INPROGRESS'

         -- FCR-13139: Do NOT move inventory on unassign
         -- Partially sorted inventory is already in SortTote (LOC/ID updated by Confirm_Order23)
         -- Moving it again would cause QtyAllocated constraint violation
         -- The inventory stays in SortTote and will be packed from there

         -- FCR-13139: On unassign, only clear UserDefine01 (user color) to make slot available
         -- Do NOT update UserDefine02 to COMPLETE - keep INPROGRESS so another user can continue
         UPDATE rdt.rdtPTLPieceLog WITH (ROWLOCK)
         SET UserDefine01 = '',
             EditDate = GETDATE(),
             EditWho = SUSER_SNAME()
         WHERE Station = @cStation
           AND AddWho = @cUserName
           AND UserDefine02 = 'INPROGRESS'

         -- FCR-13139: DO NOT release slots to IDLE on Sorter unassign
         -- Slot may still have sorted inventory waiting for Packer
         -- Only Packer should set slot to IDLE after packing is complete



         SET @cStation = ''
         SET @nErrNo = 0
         GOTO Quit
      END
   END


   /***********************************************************************************************
                                          CHECK (Step 2 - DropID Scan)
   ***********************************************************************************************/
   IF @cType = 'CHECK'
   BEGIN
      SET @cDropID = @cInField01

      -- Get total assigned
      SELECT @nTotalDropID = COUNT(DISTINCT SourceKey)
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND SourceKey <> ''

      -- Finish assign if blank and already have some
      IF @cDropID = '' AND @nTotalDropID > 0
      BEGIN
         GOTO Quit
      END

      -- Check blank
      IF @cDropID = ''
      BEGIN
         SET @nErrNo = 187951
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Need DropID
         GOTO Quit
      END

      -- ========================================================================
      -- CHECK 3: Validate DropID exists
      -- ========================================================================
      IF NOT EXISTS(
         SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND DropID = @cDropID
      )
      BEGIN
         SET @nErrNo = 187952
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Bad DropID
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- ========================================================================
      -- CHECK 4: Validate DropID belongs to this station (Canal incorrecto)
      -- ========================================================================
      SELECT TOP 1 @cWaveKey = PD.WaveKey,
                   @cWaveStation = W.UserDefine03
      FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN dbo.Wave W WITH (NOLOCK) ON PD.WaveKey = W.WaveKey
      WHERE PD.StorerKey = @cStorerKey
        AND PD.DropID = @cDropID

      IF @cWaveStation <> @cStation
      BEGIN
         SET @nErrNo = 272752
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Canal incorrecto
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- ========================================================================
      -- CHECK 5: Assign virtual cartons to physical slots
      -- ========================================================================
      -- Get user's color (should already be assigned from POPULATE-IN)
      -- FCR-13139 FIX: Only select records WITH a color assigned
      SELECT TOP 1 @cUserColor = UserDefine01
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND AddWho = @cUserName
        AND UserDefine02 = 'INPROGRESS'
        AND ISNULL(UserDefine01, '') <> ''
      ORDER BY EditDate DESC

      IF @cUserColor IS NULL OR @cUserColor = ''
      BEGIN
         -- Assign color if not yet
         SELECT TOP 1 @cUserColor = UDF01
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'PTLLIGHTS'
           AND Code = @cStation
           AND StorerKey = @cStorerKey
           AND UDF03 = 'SORT'
           AND UDF01 NOT IN (
               SELECT DISTINCT UserDefine01
               FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
               WHERE Station = @cStation
                 AND UserDefine02 = 'INPROGRESS'
                 AND UserDefine01 IS NOT NULL
           )
         ORDER BY Code2
      END

      -- FCR-13139 FIX: Update C_String1 with the final color for screen display
      -- This ensures color stays in sync between Step 1 and Step 2
      UPDATE rdt.rdtMobRec WITH (ROWLOCK)
      SET C_String1 = @cUserColor,
          EditDate = GETDATE()
      WHERE Mobile = @nMobile

      -- Process each virtual carton (CaseID)
      -- SourceKey = CaseID for BOTH Full UCC and Unit-Level
      DECLARE @tVirtualCartons TABLE (CaseID NVARCHAR(20), Processed BIT DEFAULT 0)

      -- Always use CaseID from PickDetail as SourceKey
      INSERT INTO @tVirtualCartons (CaseID)
      SELECT DISTINCT ISNULL(NULLIF(CaseID, ''), @cDropID)
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND DropID = @cDropID
        AND Qty > 0

      DECLARE @nNoSlotCount INT = 0
      DECLARE @cExistingCartonID NVARCHAR(20)

      WHILE EXISTS (SELECT 1 FROM @tVirtualCartons WHERE Processed = 0)
      BEGIN
         SELECT TOP 1 @cVirtualCartonID = CaseID
         FROM @tVirtualCartons WHERE Processed = 0

         -- Reset for each iteration
         SET @cPosition = NULL
         SET @cExistingCartonID = NULL

         -- ========================================================================
         -- FCR-13139: Multi-user slot sharing logic
         -- Check if this user already has a record for this VirtualCarton
         -- ========================================================================
         -- FCR-13139: Check if this user already has an INPROGRESS record for this CaseID
         -- If yes, UPDATE DropID to current UCC (multiple UCCs can share same CaseID/slot)
         -- DropID represents "currently processing UCC", not historical relationship
         -- ========================================================================
         IF EXISTS (
            SELECT 1 FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE SourceKey = @cVirtualCartonID
              AND Station = @cStation
              AND AddWho = @cUserName
              AND UserDefine02 = 'INPROGRESS'
         )
         BEGIN
            -- User already has an INPROGRESS record for this CaseID
            -- Update DropID to current UCC for ConfirmSP to process
            -- FCR-13139: Also restore UserDefine01 (color) if it was cleared by unassign
            UPDATE rdt.rdtPTLPieceLog WITH (ROWLOCK)
            SET DropID = @cDropID,
                UserDefine01 = @cUserColor,
                EditDate = GETDATE(),
                EditWho = SUSER_SNAME()
            WHERE SourceKey = @cVirtualCartonID
              AND Station = @cStation
              AND AddWho = @cUserName
              AND UserDefine02 = 'INPROGRESS'

            UPDATE @tVirtualCartons SET Processed = 1 WHERE CaseID = @cVirtualCartonID
            CONTINUE
         END

         -- ========================================================================
         -- Check if slot already assigned by ANOTHER user (INPROGRESS or COMPLETE)
         -- If yes, create a new entry copying Position, CartonID from existing
         -- ========================================================================
         SELECT TOP 1
            @cPosition = Position,
            @cIPAddress = IPAddress,
            @cExistingCartonID = CartonID
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
         WHERE SourceKey = @cVirtualCartonID
           AND Station = @cStation
           AND UserDefine02 IN ('INPROGRESS', 'COMPLETE')

         IF @cPosition IS NOT NULL
         BEGIN
            -- Slot exists, create new entry for this user copying slot info
            BEGIN TRY
               INSERT INTO rdt.rdtPTLPieceLog (
                  Station, IPAddress, Position, Method, SourceKey, CartonID,
                  UserDefine01, UserDefine02, StorerKey, WaveKey, AddWho, DropID
               )
               VALUES (
                  @cStation, @cIPAddress, @cPosition, @cMethod, @cVirtualCartonID, @cExistingCartonID,
                  @cUserColor, 'INPROGRESS', @cStorerKey, @cWaveKey, @cUserName, @cDropID
               )
            END TRY
            BEGIN CATCH
               SET @nErrNo = 187957
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INS Log fail
               GOTO Quit
            END CATCH
         END
         ELSE
         BEGIN
            -- ========================================================================
            -- No existing slot, find available IDLE slot
            -- FCR: Status = 'IDLE' AND NOT EXISTS rdtPTLPieceLog with INPROGRESS
            -- ========================================================================
            SELECT TOP 1
               @cPosition = DevicePosition,
               @cIPAddress = IPAddress
            FROM dbo.DeviceProfile DP WITH (NOLOCK)
            WHERE DP.DeviceID = @cStation
              AND DP.DeviceType = 'STATION'
              AND DP.Status = 'IDLE'
              AND DP.StorerKey = @cStorerKey
              AND NOT EXISTS (
                  SELECT 1 FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
                  WHERE L.Station = @cStation
                    AND L.Position = DP.DevicePosition
                    AND L.UserDefine02 = 'INPROGRESS'
              )
            ORDER BY DP.LogicalPOS

            IF @cPosition IS NULL
            BEGIN
               SET @nNoSlotCount = @nNoSlotCount + 1
            END
            ELSE
            BEGIN
               -- Assign new slot
               BEGIN TRY
                  UPDATE dbo.DeviceProfile WITH (ROWLOCK)
                  SET Status = 'BUSY',
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
                  WHERE DeviceID = @cStation
                    AND DevicePosition = @cPosition
                    AND StorerKey = @cStorerKey

                  INSERT INTO rdt.rdtPTLPieceLog (
                     Station, IPAddress, Position, Method, SourceKey,
                     UserDefine01, UserDefine02, StorerKey, WaveKey, AddWho, DropID
                  )
                  VALUES (
                     @cStation, @cIPAddress, @cPosition, @cMethod, @cVirtualCartonID,
                     @cUserColor, 'INPROGRESS', @cStorerKey, @cWaveKey, @cUserName, @cDropID
                  )
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 272755
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INS Log fail2
                  GOTO Quit
               END CATCH
            END
         END

         UPDATE @tVirtualCartons SET Processed = 1 WHERE CaseID = @cVirtualCartonID
      END

      -- Check if ALL virtual cartons have no slot
      IF @nNoSlotCount > 0 AND NOT EXISTS (
         SELECT 1 FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
         WHERE Station = @cStation
           AND AddWho = @cUserName
           AND UserDefine02 = 'INPROGRESS'
      )
      BEGIN
         SET @nErrNo = 272753
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PTW sin espacio
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- Get updated total
      SELECT @nTotalDropID = COUNT(DISTINCT SourceKey)
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND Method = @cMethod
        AND SourceKey <> ''

      -- Prepare current screen var
      SET @cOutField01 = ''
      SET @cOutField02 = CAST(@nTotalDropID AS NVARCHAR(5))
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_PTLPiece_Assign_DropID10 TO NSQL
GO
