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
/**  FCR: UWP-59517                                                          **/
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
   @cErrMsg          NVARCHAR(20)  OUTPUT,      -- Output: error message text
   @nDebug           INT = 0                    -- Debug flag (1 = print debug info, 0 = silent)

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

   -- ============================================================
   -- DEBUG: Procedure entry - log all input parameters
   -- ============================================================
   IF @nDebug = 1
   BEGIN
      PRINT '============================================================'
      PRINT 'ENTER: ARLASTDExtValid01'
      PRINT 'Timestamp: ' + CONVERT(NVARCHAR(30), GETDATE(), 121)
      PRINT '============================================================'
      PRINT '  @nMobile    = ' + ISNULL(CAST(@nMobile AS NVARCHAR(20)), 'NULL')
      PRINT '  @nFunc      = ' + ISNULL(CAST(@nFunc AS NVARCHAR(20)), 'NULL')
      PRINT '  @cLangCode  = ' + ISNULL(@cLangCode, 'NULL')
      PRINT '  @nStep      = ' + ISNULL(CAST(@nStep AS NVARCHAR(20)), 'NULL')
      PRINT '  @nInputKey  = ' + ISNULL(CAST(@nInputKey AS NVARCHAR(20)), 'NULL')
      PRINT '  @cStorerKey = ' + ISNULL(@cStorerKey, 'NULL')
      PRINT '  @cPalletID  = ' + ISNULL(@cPalletID, 'NULL')
      PRINT '  @cMbolKey   = ' + ISNULL(@cMbolKey, 'NULL')
      PRINT '  @cDoor      = ' + ISNULL(@cDoor, 'NULL')
      PRINT '  @cOption    = ' + ISNULL(@cOption, 'NULL')
      PRINT '  @nAfterStep = ' + ISNULL(CAST(@nAfterStep AS NVARCHAR(20)), 'NULL')
      PRINT '  @nDebug     = ' + CAST(@nDebug AS NVARCHAR(5))
      PRINT '------------------------------------------------------------'
   END

   -- Initialize error output to 0 (no error / success)
   SET @nErrNo = 0

   IF @nDebug = 1
      PRINT 'DEBUG: @nErrNo initialized to 0'

   -- ============================================================
   -- Fetch Facility from RDTMOBREC
   -- The facility is determined by the mobile device being used.
   -- ============================================================
   IF @nDebug = 1
      PRINT 'DEBUG: Fetching Facility from RDT.RDTMOBREC for MOBILE = ' + ISNULL(CAST(@nMobile AS NVARCHAR(20)), 'NULL')

   SELECT @cFacility = Facility
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE MOBILE = @nMobile

   IF @nDebug = 1
   BEGIN
      PRINT 'DEBUG: @cFacility = ' + ISNULL(@cFacility, 'NULL')
      IF ISNULL(@cFacility, '') = ''
         PRINT 'DEBUG: WARNING - No Facility found for MOBILE = ' + ISNULL(CAST(@nMobile AS NVARCHAR(20)), 'NULL')
   END

   -- ============================================================
   -- Get minimum required pallet temperature count from config
   -- Uses RDTGetConfig to look up 'MinPalletTempCount' setting.
   -- Defaults to 1 if not configured or not a valid integer.
   -- ============================================================
   IF @nDebug = 1
      PRINT 'DEBUG: Fetching MinPalletTempCount config for @nFunc = ' + ISNULL(CAST(@nFunc AS NVARCHAR(20)), 'NULL') + ', @cStorerKey = ' + ISNULL(@cStorerKey, 'NULL')

   SET @nMinPalletTempReq = ISNULL(
       TRY_CAST(rdt.RDTGetConfig(@nFunc, 'MinPalletTempCount', @cStorerKey) AS INT),
       1)

   IF @nDebug = 1
   BEGIN
      PRINT 'DEBUG: @nMinPalletTempReq = ' + ISNULL(CAST(@nMinPalletTempReq AS NVARCHAR(20)), 'NULL')
      PRINT 'DEBUG: (If value is 2, it may be the default fallback - verify config table)'
   END

   -- ============================================================
   -- Check current step and execute corresponding validation
   -- ============================================================
   IF @nDebug = 1
      PRINT 'DEBUG: Evaluating @nStep. Current @nStep = ' + ISNULL(CAST(@nStep AS NVARCHAR(20)), 'NULL')

   ----------------------------------------------------------------
   -- Step 1: Validate pallet scan (duplicate check + temperature)
   ----------------------------------------------------------------
   IF @nStep = 1
   BEGIN

      IF @nDebug = 1
         PRINT 'DEBUG: Entered @nStep = 1 block (Duplicate scan + Temperature validation)'

      -- =========================================================
      -- VALIDATION 1: Duplicate pallet scan check
      -- =========================================================
      IF @nDebug = 1
      BEGIN
         PRINT 'DEBUG: --- Duplicate Pallet Scan Check ---'
         PRINT 'DEBUG: Checking RDT.rdtSTDEventLog for existing scan'
         PRINT 'DEBUG:   WHERE ToID = ' + ISNULL(@cPalletID, 'NULL')
         PRINT 'DEBUG:   AND   RefNo3 = ''SCNPL2DOOR'''
         PRINT 'DEBUG:   AND   StorerKey = ' + ISNULL(@cStorerKey, 'NULL')
      END

      IF EXISTS (
         SELECT 1
         FROM RDT.rdtSTDEventLog WITH (NOLOCK)
         WHERE ToID      = @cPalletID
         AND   RefNo3    = 'SCNPL2DOOR'
         AND   StorerKey = @cStorerKey
      )
      BEGIN
         IF @nDebug = 1
         BEGIN
            PRINT 'DEBUG: Duplicate scan check FAILED - Pallet already scanned to door'
            PRINT 'DEBUG: PalletID = ' + ISNULL(@cPalletID, 'NULL') + ' found in rdtSTDEventLog with RefNo3 = SCNPL2DOOR'
            PRINT 'DEBUG: Setting @nErrNo = 3735608 (Pallet already scanned)'
         END

         SET @nErrNo  = 3735608
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

         IF @nDebug = 1
            PRINT 'DEBUG: @cErrMsg = ' + ISNULL(@cErrMsg, 'NULL')

         GOTO Quit
      END

      IF @nDebug = 1
         PRINT 'DEBUG: Duplicate scan check PASSED - Pallet not previously scanned to door'

      -- =========================================================
      -- VALIDATION 2: Temperature capture check
      -- =========================================================
      IF @nDebug = 1
      BEGIN
         PRINT 'DEBUG: --- Temperature Capture Check ---'
         PRINT 'DEBUG: Looking up OrderKey from dbo.PickDetail WHERE StorerKey = ' + ISNULL(@cStorerKey, 'NULL') + ' AND ID = ' + ISNULL(@cPalletID, 'NULL') + ' AND Status < 9'
      END

      SELECT TOP 1 @cOrderKey = OrderKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   ID = @cPalletID
      AND   [Status] < '9'

      IF @nDebug = 1
      BEGIN
         PRINT 'DEBUG: @cOrderKey = ' + ISNULL(@cOrderKey, 'NULL')
         PRINT 'DEBUG: @@ROWCOUNT from PickDetail query = ' + CAST(@@ROWCOUNT AS NVARCHAR(10))
      END

      IF ISNULL(@cOrderKey, '') = ''
      BEGIN
         IF @nDebug = 1
         BEGIN
            PRINT 'DEBUG: ERROR - No OrderKey found for PalletID = ' + ISNULL(@cPalletID, 'NULL')
            PRINT 'DEBUG: Setting @nErrNo = 3735603 (No Order Found)'
         END

         SET @nErrNo  = 3735603
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

         IF @nDebug = 1
            PRINT 'DEBUG: @cErrMsg = ' + ISNULL(@cErrMsg, 'NULL')

         GOTO Quit
      END

      -- =========================================================
      -- Get the MBOL key for the scanned pallet's order
      -- =========================================================
      IF @nDebug = 1
         PRINT 'DEBUG: Looking up MbolKey from dbo.MBOLDetail WHERE OrderKey = ' + ISNULL(@cOrderKey, 'NULL')

      SELECT @cMBOL4Pallet = MbolKey
      FROM dbo.MBOLDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey

      IF @nDebug = 1
      BEGIN
         PRINT 'DEBUG: @cMBOL4Pallet = ' + ISNULL(@cMBOL4Pallet, 'NULL')
         PRINT 'DEBUG: @@ROWCOUNT from MBOLDetail query = ' + CAST(@@ROWCOUNT AS NVARCHAR(10))
      END

      IF ISNULL(@cMBOL4Pallet, '') = ''
      BEGIN
         IF @nDebug = 1
         BEGIN
            PRINT 'DEBUG: ERROR - No MbolKey found for OrderKey = ' + ISNULL(@cOrderKey, 'NULL')
            PRINT 'DEBUG: Setting @nErrNo = 3735604 (No MBOL created)'
         END

         SET @nErrNo  = 3735604
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

         IF @nDebug = 1
            PRINT 'DEBUG: @cErrMsg = ' + ISNULL(@cErrMsg, 'NULL')

         GOTO Quit
      END

      -- =========================================================
      -- Count distinct pallets with temperature records logged
      -- =========================================================
      IF @nDebug = 1
      BEGIN
         PRINT 'DEBUG: Counting distinct pallets in dbo.TemperatureLog'
         PRINT 'DEBUG: WHERE TL.StorerKey = ' + ISNULL(@cStorerKey, 'NULL') + ' AND MD.MbolKey = ' + ISNULL(@cMBOL4Pallet, 'NULL')
      END

      SELECT @nPalletTempCount = COUNT(DISTINCT TL.PalletId)
      FROM dbo.TemperatureLog TL WITH (NOLOCK)
      INNER JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON TL.MbolKey = MD.MbolKey
      WHERE TL.StorerKey = @cStorerKey
      AND   MD.MbolKey   = @cMBOL4Pallet

      IF @nDebug = 1
      BEGIN
         PRINT 'DEBUG: @nPalletTempCount = ' + ISNULL(CAST(@nPalletTempCount AS NVARCHAR(20)), 'NULL')
         PRINT 'DEBUG: Condition check: @nPalletTempCount (' + ISNULL(CAST(ISNULL(@nPalletTempCount, 0) AS NVARCHAR(20)), '0') + ') < @nMinPalletTempReq (' + ISNULL(CAST(@nMinPalletTempReq AS NVARCHAR(20)), 'NULL') + ') = ' + CASE WHEN ISNULL(@nPalletTempCount, 0) < @nMinPalletTempReq THEN 'TRUE (will BLOCK scan)' ELSE 'FALSE (will ALLOW scan)' END
         PRINT 'DEBUG: Condition check: @nPalletTempCount (' + ISNULL(CAST(ISNULL(@nPalletTempCount, 0) AS NVARCHAR(20)), '0') + ') < @nMinPalletTempReq (' + ISNULL(CAST(@nMinPalletTempReq AS NVARCHAR(20)), 'NULL') + ') = ' + CASE WHEN ISNULL(@nPalletTempCount, 0) <= @nMinPalletTempReq THEN 'TRUE (will BLOCK scan)' ELSE 'FALSE (will ALLOW scan)' END
      END

      IF ISNULL(@nPalletTempCount, 0) < @nMinPalletTempReq
      BEGIN
         IF @nDebug = 1
         BEGIN
            PRINT 'DEBUG: Temperature check FAILED - insufficient pallet temperatures captured'
            PRINT 'DEBUG: Inserting TRACEINFO record for SCNPT2DOOR_TEMP'
         END

         INSERT INTO TRACEINFO (TRACENAME, TIMEIN, COL1, COL2, COL3)
         VALUES ('SCNPT2DOOR_TEMP', GETDATE(), @cPalletID, @cMBOL4Pallet, 'TempNotCaptured')

         IF @nDebug = 1
            PRINT 'DEBUG: TRACEINFO insert complete. @@ROWCOUNT = ' + CAST(@@ROWCOUNT AS NVARCHAR(10))

         SET @nErrNo  = 3735605
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

         IF @nDebug = 1
         BEGIN
            PRINT 'DEBUG: Setting @nErrNo = 3735605 (Pallet Temp Not Captured)'
            PRINT 'DEBUG: @cErrMsg = ' + ISNULL(@cErrMsg, 'NULL')
         END

         GOTO Quit
      END

      IF @nDebug = 1
         PRINT 'DEBUG: Temperature check PASSED - sufficient pallet temperatures captured'

   END
   ELSE
   BEGIN
      IF @nDebug = 1
         PRINT 'DEBUG: @nStep = ' + ISNULL(CAST(@nStep AS NVARCHAR(20)), 'NULL') + ' - No validation logic for this step, skipping'
   END

QUIT:
   -- ============================================================
   -- DEBUG: Procedure exit - log final output values
   -- ============================================================
   IF @nDebug = 1
   BEGIN
      PRINT '------------------------------------------------------------'
      PRINT 'EXIT: ARLASTDExtValid01'
      PRINT 'Timestamp: ' + CONVERT(NVARCHAR(30), GETDATE(), 121)
      PRINT '  Final @nErrNo  = ' + ISNULL(CAST(@nErrNo AS NVARCHAR(20)), 'NULL')
      PRINT '  Final @cErrMsg = ' + ISNULL(@cErrMsg, 'NULL')
      PRINT '  @cFacility     = ' + ISNULL(@cFacility, 'NULL')
      PRINT '  @cOrderKey     = ' + ISNULL(@cOrderKey, 'NULL')
      PRINT '  @cMBOL4Pallet  = ' + ISNULL(@cMBOL4Pallet, 'NULL')
      PRINT '  @nPalletTempCount  = ' + ISNULL(CAST(@nPalletTempCount AS NVARCHAR(20)), 'NULL')
      PRINT '  @nMinPalletTempReq = ' + ISNULL(CAST(@nMinPalletTempReq AS NVARCHAR(20)), 'NULL')
      PRINT '  Result: ' + CASE WHEN @nErrNo = 0 THEN 'SUCCESS - Scan allowed' ELSE 'BLOCKED - Error ' + CAST(@nErrNo AS NVARCHAR(10)) END
      PRINT '============================================================'
   END
GO
