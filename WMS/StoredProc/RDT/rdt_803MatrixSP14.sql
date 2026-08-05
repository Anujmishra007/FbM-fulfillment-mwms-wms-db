SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_803MatrixSP14                                   */
/* Copyright      : Maersk                                              */
/* Purpose        : Matrix display for AEOMX PTW/PTL showing:           */
/*                  - Slot status (IDLE/BUSY/COMPLETE)                  */
/*                  - Assigned user color                               */
/*                  - Virtual carton assignment                         */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-07-06 1.0  Cuize    FCR-13139 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_803MatrixSP14] (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT
   ,@nInputKey  INT
   ,@cFacility  NVARCHAR( 5)
   ,@cStorerKey NVARCHAR( 15)
   ,@cLight     NVARCHAR( 1)
   ,@cStation   NVARCHAR( 10)
   ,@cMethod    NVARCHAR( 1)
   ,@cSKU       NVARCHAR( 20)
   ,@cIPAddress NVARCHAR( 40)
   ,@cPosition  NVARCHAR( 10)
   ,@cDisplay   NVARCHAR( 5)
   ,@nErrNo     INT            OUTPUT
   ,@cErrMsg    NVARCHAR( 20)  OUTPUT
   ,@cResult01  NVARCHAR( 20)  OUTPUT
   ,@cResult02  NVARCHAR( 20)  OUTPUT
   ,@cResult03  NVARCHAR( 20)  OUTPUT
   ,@cResult04  NVARCHAR( 20)  OUTPUT
   ,@cResult05  NVARCHAR( 20)  OUTPUT
   ,@cResult06  NVARCHAR( 20)  OUTPUT
   ,@cResult07  NVARCHAR( 20)  OUTPUT
   ,@cResult08  NVARCHAR( 20)  OUTPUT
   ,@cResult09  NVARCHAR( 20)  OUTPUT
   ,@cResult10  NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUserName     NVARCHAR(18)
   DECLARE @cUserColor    NVARCHAR(20)
   DECLARE @cColorHex     NVARCHAR(20)
   DECLARE @cLogicalName  NVARCHAR(10)
   DECLARE @cSlotStatus   NVARCHAR(20)
   DECLARE @cSlotLOC      NVARCHAR(10)
   DECLARE @cLightMode    NVARCHAR(4)
   DECLARE @bSuccess      INT

   -- Initialize results
   SET @cResult01 = ''
   SET @cResult02 = ''
   SET @cResult03 = ''
   SET @cResult04 = ''
   SET @cResult05 = ''
   SET @cResult06 = ''
   SET @cResult07 = ''
   SET @cResult08 = ''
   SET @cResult09 = ''
   -- FCR-13139: Do NOT overwrite @cResult10, it may contain NODROPID flag
   -- SET @cResult10 = ''

   -- Get username
   SELECT @cUserName = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get user's assigned color and HEX code
   SELECT TOP 1 @cUserColor = L.UserDefine01
   FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
   WHERE L.Station = @cStation
     AND L.AddWho = @cUserName
     AND L.UserDefine02 = 'INPROGRESS'

   -- Get HEX color code for PTL light
   SELECT TOP 1 @cColorHex = UDF02
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE ListName = 'PTLLIGHTS'
     AND Code = @cStation
     AND StorerKey = @cStorerKey
     AND UDF01 = @cUserColor
     AND UDF03 = 'SORT'

   -- Get logical name for current position
   SET @cLogicalName = @cPosition
   SELECT @cLogicalName = LogicalName,
          @cSlotLOC = LOC
   FROM dbo.DeviceProfile WITH (NOLOCK)
   WHERE DeviceType = 'STATION'
     AND DeviceID = @cStation
     AND DevicePosition = @cPosition
     AND StorerKey = @cStorerKey

   -- Get assignment info for this slot (current user's record)
   DECLARE @cSourceKey NVARCHAR(20)
   DECLARE @cCartonID NVARCHAR(20)

   SELECT TOP 1
      @cSourceKey = SourceKey,
      @cCartonID = CartonID
   FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
   WHERE Station = @cStation
     AND Position = @cPosition
     AND AddWho = @cUserName
     AND UserDefine02 IN ('INPROGRESS', 'COMPLETE')
   ORDER BY EditDate DESC

   -- FCR-13139: Slot status logic - based on actual PickDetail inventory
   -- Slot is COMPLETE only when ALL inventory for this VirtualCarton is in the SortTote
   IF @cSourceKey IS NOT NULL AND @cCartonID IS NOT NULL
   BEGIN
      IF NOT EXISTS (
         SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND CaseID = @cSourceKey      -- VirtualCarton
           AND DropID <> @cCartonID      -- Not yet in SortTote
           AND Qty > 0
      )
      BEGIN
         SET @cSlotStatus = 'COMPLETE'
      END
      ELSE
      BEGIN
         SET @cSlotStatus = 'INPROGRESS'
      END
   END

   -- Line 8: LOC (Physical SLOT) for Screen 3a
   SET @cResult01 = 'LOC:' + ISNULL(@cSlotLOC, '')

   -- Line 9: TOTE (TOTE IN SLOT) for Screen 3a
   SET @cResult02 = 'TOTE:' + ISNULL(@cCartonID, '')

   -- Line 10: Status message for Screen 3a
   -- Check if current slot complete
   IF @cSlotStatus = 'COMPLETE'
   BEGIN
      SET @cResult03 = '** SLOT COMPLETE **'

      -- Check if user's DropID complete (no entries in PickDetail for this DropID)
      DECLARE @cUserDropID NVARCHAR(20)
      SELECT TOP 1 @cUserDropID = DropID
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND AddWho = @cUserName
        AND UserDefine02 = 'COMPLETE'
      ORDER BY EditDate DESC

      IF @cUserDropID IS NOT NULL AND @cUserDropID <> ''
      BEGIN
         IF NOT EXISTS (
            SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
              AND DropID = @cUserDropID
              AND Qty > 0
         )
         BEGIN
            SET @cResult03 = 'DropID/UCC Sorted:'
            SET @cResult04 =  @cUserDropID
         END
      END
   END

   -- ========================================================================
   -- FCR-13139: PTL Light Control
   -- Config: LightControl = '1' to enable
   --
   -- SORTING Side (AMX_Sorter):
   --   Scenario 1: Show qty with user's color (YELLOW->UDF01, GREEN->UDF02, RED->UDF03)
   --   Scenario 2: Slot complete -> GREEN light with 'FF'
   --
   -- PACKING Side (BATCH):
   --   Scenario 3: GREEN light - back location was empty (inventory moved to back)
   --   Scenario 4: BLUE light - back location occupied (inventory stayed in front)
   -- ========================================================================
   DECLARE @cLightControl NVARCHAR(10)
   SET @cLightControl = rdt.RDTGetConfig(@nFunc, 'LightControl', @cStorerKey)

   IF @cLightControl = '1' AND @cSourceKey IS NOT NULL AND @cSourceKey <> ''
   BEGIN
      DECLARE @nTotalQty INT = 0
      DECLARE @nSortedQty INT = 0
      DECLARE @nRemainingQty INT
      DECLARE @cDisplayValue NVARCHAR(5)
      DECLARE @cSortToteID NVARCHAR(20)
      DECLARE @cSorterDevicePos NVARCHAR(20)
      DECLARE @cGreenDevicePos NVARCHAR(20)
      DECLARE @cPackerDevicePos NVARCHAR(20)
      DECLARE @cBackLOC NVARCHAR(10)
      DECLARE @bInventoryInBack BIT = 0

      -- Get SortTote ID from rdtPTLPieceLog
      SELECT TOP 1 @cSortToteID = CartonID
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND Position = @cPosition
        AND SourceKey = @cSourceKey

      -- Get DevicePos from CODELKUP.AEO_PTWSTG
      -- Field mapping:
      --   Code  = DEVICEPROFILE.LOC (Front location)
      --   Short = STG PTW location (Back LOC)
      --   UDF01 = Yellow DevicePos
      --   UDF02 = Green DevicePos
      --   UDF03 = Red DevicePos
      --   UDF04 = Packer DevicePos
      SELECT TOP 1
         @cSorterDevicePos = CASE @cUserColor
            WHEN 'YELLOW' THEN UDF01
            WHEN 'GREEN' THEN UDF02
            WHEN 'RED' THEN UDF03
            ELSE ''
         END,
         @cGreenDevicePos = UDF02,
         @cPackerDevicePos = UDF04,
         @cBackLOC = Short
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'AEO_PTWSTG'
        AND Code = @cSlotLOC
        AND StorerKey = @cStorerKey

      -- Get total qty for this virtual carton
      -- FCR-13139: Calculate remaining qty for THIS SKU only (not all SKUs in carton)
      SELECT @nTotalQty = ISNULL(SUM(Qty), 0)
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND CaseID = @cSourceKey
        AND SKU = @cSKU

      -- Get sorted qty for THIS SKU (already in SortTote)
      IF @cSortToteID IS NOT NULL AND @cSortToteID <> ''
      BEGIN
         SELECT @nSortedQty = ISNULL(SUM(Qty), 0)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND CaseID = @cSourceKey
           AND DropID = @cSortToteID
           AND SKU = @cSKU
      END

      SET @nRemainingQty = @nTotalQty - @nSortedQty

      -- Check if inventory is in back location (for Packer side light decision)
      IF @cBackLOC IS NOT NULL AND @cBackLOC <> '' AND @cSortToteID IS NOT NULL
      BEGIN
         IF EXISTS (
            SELECT 1 FROM dbo.LotxLocxID WITH (NOLOCK)
            WHERE LOC = @cBackLOC
              AND ID = @cSortToteID
              AND Qty > 0
         )
         BEGIN
            SET @bInventoryInBack = 1
         END
      END

      -- ========================================================================
      -- SORTING SIDE (AMX_Sorter)
      -- RAW message: PP1050000XXXX YY
      -- Pass real LOC (@cSlotLOC) and Color (@cUserColor via @c_ForceColor)
      -- isp_PTL_LightUpLoc will convert to actual light position from CODELKUP
      -- ========================================================================
      IF @cSlotStatus = 'COMPLETE'
      BEGIN
         -- Scenario 2: FLASHY GREEN LIGHT ON SORT COMPLETION
         -- Always use GREEN color with 'FF'
         EXEC PTL.isp_PTL_LightUpLoc
            @n_Func = @nFunc,
            @n_PTLKey = 0,
            @c_DisplayValue = 'FF',
            @b_Success = @bSuccess OUTPUT,
            @n_Err = @nErrNo OUTPUT,
            @c_ErrMsg = @cErrMsg OUTPUT,
            @c_ForceColor = 'GREEN',
            @c_DeviceID = @cStation,
            @c_DevicePos = @cSlotLOC,
            @c_DeviceIP = @cIPAddress,
            @c_LModMode = '1',
            @c_DeviceModel = 'AMX_Sorter'
      END
      ELSE
      BEGIN
         -- Scenario 1: TURN ON LIGHT WITH QTY FOR SORTING
         -- Pass user's color for position lookup
         SET @cDisplayValue = RIGHT('00' + CAST(@nRemainingQty AS NVARCHAR(4)), 2)

         EXEC PTL.isp_PTL_LightUpLoc
            @n_Func = @nFunc,
            @n_PTLKey = 0,
            @c_DisplayValue = @cDisplayValue,
            @b_Success = @bSuccess OUTPUT,
            @n_Err = @nErrNo OUTPUT,
            @c_ErrMsg = @cErrMsg OUTPUT,
            @c_ForceColor = @cUserColor,
            @c_DeviceID = @cStation,
            @c_DevicePos = @cSlotLOC,
            @c_DeviceIP = @cIPAddress,
            @c_LModMode = '1',
            @c_DeviceModel = 'AMX_Sorter'
      END

      -- ========================================================================
      -- PACKING SIDE (AMX_Packer) - only when slot complete
      -- RAW message: PP1050000m1$XX$XX$XXm2$11$11$11m4$50ma$40{UDF04}$20$20101
      -- Green: m1$21$21$21, Blue: m1$21$12$21
      -- ========================================================================
      IF @cSlotStatus = 'COMPLETE' AND @cPackerDevicePos IS NOT NULL AND @cPackerDevicePos <> ''
      BEGIN
         DECLARE @cPackerColor NVARCHAR(10)

         IF @cStation LIKE '%ECOM%'
         BEGIN
            -- ECOM Station (Single deep): Always GREEN light
            SET @cPackerColor = 'GREEN'
         END
         ELSE
         BEGIN
            -- WHSLE/RTL Station (Double deep)
            IF @bInventoryInBack = 1
            BEGIN
               -- Scenario 3: Inventory moved to back -> GREEN light
               SET @cPackerColor = 'GREEN'
            END
            ELSE
            BEGIN
               -- Scenario 4: Inventory stayed in front (back occupied) -> BLUE light
               SET @cPackerColor = 'BLUE'
            END
         END

         EXEC PTL.isp_PTL_LightUpLoc
            @n_Func = @nFunc,
            @n_PTLKey = 0,
            @c_DisplayValue = '',
            @b_Success = @bSuccess OUTPUT,
            @n_Err = @nErrNo OUTPUT,
            @c_ErrMsg = @cErrMsg OUTPUT,
            @c_ForceColor = @cPackerColor,
            @c_DeviceID = @cStation,
            @c_DevicePos = @cPackerDevicePos,
            @c_DeviceIP = @cIPAddress,
            @c_LModMode = '',
            @c_DeviceModel = 'AMX_Packer'
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_803MatrixSP14 TO NSQL
GO
