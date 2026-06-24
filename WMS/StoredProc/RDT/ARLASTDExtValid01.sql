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
   @cPalletID        NVARCHAR(20),              -- Scanned pallet identifier
   @cMbolKey         NVARCHAR(10),              -- MBOL key - required by caller
   @cDoor            NVARCHAR(20),              -- Door assignment - required by caller
   @cOption          NVARCHAR(1),               -- Option (close truck) - required by caller
   @nAfterStep       INT,                       -- After step - required by caller
   @nErrNo           INT           OUTPUT,      -- Output: error number (0 = success)
   @cErrMsg          NVARCHAR(20)  OUTPUT       -- Output: error message text
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Local variable declarations
   DECLARE @cOrderKey          NVARCHAR(10),     -- Order key linked to the scanned pallet
           @cMBOL4Pallet       NVARCHAR(10),     -- MBOL key associated with the pallet's order
           @nPalletTempCount   INT,              -- Count of distinct pallets with temperatures logged
           @nMinPalletTempReq  INT               -- Minimum required pallet temperature count from config

   -- Initialize error output to 0 (no error / success)
   SET @nErrNo = 0
   SET @nMinPalletTempReq = ISNULL(
      TRY_CAST(rdt.RDTGetConfig(@nFunc, 'MinPalletTempCount', @cStorerKey) AS INT),
      1)

   -- Step 1: Validate pallet scan (duplicate check + temperature)
   IF @nStep = 1
   BEGIN
      -- VALIDATION 1: Duplicate pallet scan check
      IF EXISTS (
         SELECT 1
         FROM RDT.rdtSTDEventLog WITH (NOLOCK)
         WHERE ToID      = @cPalletID
         AND   RefNo3    = 'SCNPL2DOOR'
         AND   StorerKey = @cStorerKey
      )
      BEGIN
         SET @nErrNo  = 271401
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- Pallet already scanned to door
         GOTO Quit
      END

      -- VALIDATION 2: Temperature capture check
      SELECT TOP 1 @cOrderKey = OrderKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   ID = @cPalletID
      AND   [Status] < '9'

      IF ISNULL(@cOrderKey, '') = ''
      BEGIN
         SET @nErrNo  = 271402
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- PalletTempNotCapture
         GOTO Quit
      END

      -- Use MBOL key provided by caller (rdtfnc_Scan_Pallet_To_Door) to avoid inconsistencies
      SET @cMBOL4Pallet = @cMbolKey
      ORDER BY MbolKey

      IF ISNULL(@cMBOL4Pallet, '') = ''
      BEGIN
         SET @nErrNo  = 271403
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- MBOL key not found
         GOTO Quit
      END

      -- Count distinct pallets with temperature records logged
      FROM dbo.TemperatureLog TL WITH (NOLOCK)
      AND   TL.MbolKey   = @cMBOL4Pallet
      AND   MD.MbolKey   = @cMBOL4Pallet

      IF ISNULL(@nPalletTempCount, 0) < @nMinPalletTempReq
      BEGIN
         SET @nErrNo  = 271404
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- PalletTempNotCapture
         GOTO Quit
      END
   END

QUIT:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.ARLASTDExtValid01 TO NSQL
GO

