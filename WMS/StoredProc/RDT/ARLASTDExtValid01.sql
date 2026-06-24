SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/** Store procedure: ARLASTDExtValid01                                       **/
/** Purpose: Validates the following when a pallet is scanned to door:       **/
/**          1. Duplicate scan check - Ensures the pallet has not            **/
/**             already been scanned to door by checking                     **/
/**             RDT.rdtSTDEventLog for a matching record where               **/
/**             ToID = scanned pallet and RefNo3 = 'SCNPL2DOOR'.            **/
/**          2. Temperature capture check - Validates that pallet            **/
/**             temperatures are captured for at least the configured        **/
/**             minimum number of distinct pallets per MBOL key in           **/
/**             TemperatureLog before allowing the scan/load to door.        **/
/**          If either condition fails, the scan to door operation is        **/
/**          blocked with an appropriate error message.                      **/
/**                                                                          **/
/** Called from: rdtfnc_Scan_Pallet_To_Door                                  **/
/**                                                                          **/
/** Modifications log:                                                       **/
/** Version: 1.4                                                             **/
/** Date       Rev  Author     Purposes                                      **/
/** 2026-03-21 1.0  SYO054     Created - Temperature capture validation      **/
/**                            for ARLA storer                               **/
/** 2026-03-22 1.1  SYO054     Added @nDebug parameter and PRINT             **/
/**                            statements for troubleshooting                **/
/** 2026-04-04 1.2  SYO054     Added duplicate pallet scan validation        **/
/**                            against RDT.rdtSTDEventLog before             **/
/**                            temperature check (merged from                **/
/**                            ARLASTDExtValid01)                            **/
/** 2026-04-08 1.3  SYO054     Removed unused parameters: @nInputKey,        **/
/**                            @cMbolKey, @cDoor, @cOption, @nAfterStep      **/
/** 2026-04-09 1.4  SYO054     Restored parameters removed in 1.3 to        **/
/**                            match caller rdtfnc_Scan_Pallet_To_Door       **/
/**                            signature. Fixes "too many arguments" error   **/
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[ARLASTDExtValid01] (
   @nMobile          INT,                       -- Mobile device identifier
   @nFunc            INT,                       -- Function identifier (used for config lookup)
   @cLangCode        NVARCHAR(3),               -- Language code for error messages
   @nStep            INT,                       -- Current step in the scan workflow
   @nInputKey        INT,                       -- Input key (ENTER=1, ESC=0) - required by caller
   @cStorerKey       NVARCHAR(15),              -- Storer key to identify the customer/storer
   @cPalletID        NVARCHAR(18),              -- Scanned pallet identifier
   @cMbolKey         NVARCHAR(10),              -- MBOL key - required by caller
   @cDoor            NVARCHAR(20),              -- Door assignment - required by caller
   @cOption          NVARCHAR(1),               -- Option (close truck) - required by caller
   @nAfterStep       INT,                       -- After step - required by caller
   @nErrNo           INT           OUTPUT,      -- Output: error number (0 = success)
   @cErrMsg          NVARCHAR(20)  OUTPUT       -- Output: error message text
)
AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
   -- Local variable declarations
   DECLARE @cFacility          NVARCHAR(5),     -- Facility code from mobile device record
           @cOrderKey          NVARCHAR(10),     -- Order key linked to the scanned pallet
           @cMBOL4Pallet       NVARCHAR(10),     -- MBOL key associated with the pallet's order
           @nPalletTempCount   INT,              -- Count of distinct pallets with temperatures logged
           @nMinPalletTempReq  INT               -- Minimum required pallet temperature count from config
   -- Initialize error output to 0 (no error / success)
   SET @nErrNo = 0
   -- ============================================================
   -- Fetch Facility from RDTMOBREC
   -- The facility is determined by the mobile device being used.
   -- ============================================================
   SELECT @cFacility = Facility
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE MOBILE = @nMobile
   -- ============================================================
   -- Get minimum required pallet temperature count from config
   -- Uses RDTGetConfig to look up 'MinPalletTempCount' setting.
   -- Defaults to 1 if not configured or not a valid integer.
   -- ============================================================
   SET @nMinPalletTempReq = ISNULL(
       TRY_CAST(rdt.RDTGetConfig(@nFunc, 'MinPalletTempCount', @cStorerKey) AS INT),
       1)
   -- ============================================================
   -- Check current step and execute corresponding validation
   -- ============================================================
   ----------------------------------------------------------------
   -- Step 1: Validate pallet scan (duplicate check + temperature)
   ----------------------------------------------------------------
   IF @nStep = 1
   BEGIN
      -- =========================================================
      -- VALIDATION 1: Duplicate pallet scan check
      -- Ensures the pallet has not already been scanned to door
      -- by checking RDT.rdtSTDEventLog for a matching record.
      -- =========================================================
      IF EXISTS (
         SELECT 1
         FROM RDT.rdtSTDEventLog WITH (NOLOCK)
         WHERE ToID      = @cPalletID
         AND   RefNo3    = 'SCNPL2DOOR'
         AND   StorerKey = @cStorerKey
      )
      BEGIN
         -- Pallet already scanned to door - block with error
         SET @nErrNo  = 271402
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END
      -- =========================================================
      -- VALIDATION 2: Temperature capture check
      -- Step 2a: Look up the OrderKey from PickDetail for the
      --          scanned pallet (only active pick lines, Status < 9)
      -- =========================================================
      SELECT TOP 1 @cOrderKey = OrderKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   ID = @cPalletID
      AND   [Status] < '9'
      IF ISNULL(@cOrderKey, '') = ''
      BEGIN
         -- No order found for the scanned pallet - block with error
         SET @nErrNo  = 202001
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END
      -- =========================================================
      -- Step 2b: Get the MBOL key for the scanned pallet's order
      -- =========================================================
      SELECT @cMBOL4Pallet = MbolKey
      FROM dbo.MBOLDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey
      IF ISNULL(@cMBOL4Pallet, '') = ''
      BEGIN
         -- No MBOL created for the order - block with error
         SET @nErrNo  = 202002
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END
      -- =========================================================
      -- Step 2c: Count distinct pallets with temperature records
      --          logged for the MBOL key and storer
      -- =========================================================
      SELECT @nPalletTempCount = COUNT(DISTINCT TL.PalletId)
      FROM dbo.TemperatureLog TL WITH (NOLOCK)
      INNER JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON TL.MbolKey = MD.MbolKey
      WHERE TL.StorerKey = @cStorerKey
      AND   MD.MbolKey   = @cMBOL4Pallet
      -- =========================================================
      -- Step 2d: Compare count against minimum required.
      --          If insufficient, log a TRACEINFO record and block.
      -- =========================================================
      IF ISNULL(@nPalletTempCount, 0) < @nMinPalletTempReq
      BEGIN
         -- Insert trace record for temperature capture failure
         BEGIN TRY
            INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Col1, Col2, Col3)
            VALUES ('SCNPT2DOOR_TEMP', GETDATE(), @cPalletID, @cMBOL4Pallet, 'TempNotCaptured')
         END TRY
         BEGIN CATCH
            -- Silently handle TRACEINFO insert failure;
            -- the validation error below will still be raised
         END CATCH
         -- Insufficient pallet temperatures captured - block with error
         SET @nErrNo  = 271401
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END
   END
   -- For all other steps: no validation logic, allow scan to proceed
QUIT:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.ARLASTDExtValid01 TO NSQL
GO

