SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1638ExtScn01                                      */
/* Copyright: Maersk                                                      */
/* Customer: HBDS                                                         */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-09-24 1.0.0  NLT013     FCR-8110. Created                         */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1638ExtScn01] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep INT,
   @nScn  INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

   @tExtScnData   VariableTable READONLY,

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction      INT,
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nCurrentStep           INT,
      @nCurrentScn            INT,
      @nTotalCases            INT,
      @nTranCount             INT,
      @cPalletKey             NVARCHAR( 30),
      @cB2CPalletKeyPrefix    NVARCHAR( 10),
      @cCartonType            NVARCHAR( 10),
      @cType                  NVARCHAR( 10),
      @cClosePallet           NVARCHAR( 1),
      @cSkipPrintPackList     NVARCHAR( 1),
      @cOrderTrackNo          NVARCHAR( 40),
      @cExternOrderKey        NVARCHAR( 50),
      @cPickSlipNo            NVARCHAR( 18),
      @cOrderKey              NVARCHAR( 10),
      @cCapturePackInfoSP     NVARCHAR( 20),
      @cCapturePackInfo       NVARCHAR( 10),
      @cLOC                   NVARCHAR( 10),
      @cCaseID                NVARCHAR( 20),
      @cWeight                NVARCHAR( 10),
      @cCube                  NVARCHAR( 10),
      @cRefNo                 NVARCHAR( 20),
      @cSKU                   NVARCHAR( 20),
      @nQTY                   INT,
      @cSQL                   NVARCHAR( MAX),
      @cSQLParam              NVARCHAR( MAX)

   SELECT 
      @nCurrentStep        = Step,
      @nCurrentScn         = Scn,
      @cSkipPrintPackList  = V_String1,
      @cClosePallet        = V_String2,
      @cCartonType         = V_String4,
      @cCapturePackInfo    = V_String5,
      @cPalletKey          = V_String41,

      @cLOC                = V_LOC
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @cB2CPalletKeyPrefix = rdt.RDTGetConfig( @nFunc, 'B2CPalletKeyPrefix', @cStorerKey)
   IF @cB2CPalletKeyPrefix = '0'
      SET @cB2CPalletKeyPrefix = ''

   SET @cCapturePackInfoSP = rdt.RDTGetConfig( @nFunc, 'CapturePackInfo', @cStorerKey)

   IF @nFunc = 1638
   BEGIN
      IF @nAfterScn = 2252 AND @nAfterStep = 3
      BEGIN
         -- PalletKey does not exist in RDTMOBREC in step 1
         IF @nCurrentStep = 1
            SELECT @cPalletKey = Value FROM @tExtScnData WHERE Variable = '@cPalletKey'

         -- B2C pallet, jump to 3A screen
         IF LEFT(@cPalletKey, LEN(@cB2CPalletKeyPrefix)) = @cB2CPalletKeyPrefix
         BEGIN
            SET @nAfterScn = 6678
            SET @nAfterStep = 99
            
            SET @cOutField01 = @cPalletKey
            SET @cOutField02 = '' -- Order Track No
            SET @cOutField03 = '' -- Extern Order Key

            GOTO Quit
         END
      END

      IF @nCurrentStep = 99
      BEGIN
         /********************************************************************************
         Step 99. Scn = 6678.
            PalletKey        (field01)
            Order Track No   (field02, input)
            OR
            Extern Order Key (field03, input)
         ********************************************************************************/
         IF @nCurrentScn = 6678
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cOrderTrackNo   = @cInField02
               SET @cExternOrderKey = @cInField03

               IF @cOrderTrackNo = '' AND @cExternOrderKey = ''
               BEGIN
                  SET @nErrNo = 247651
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need OrderTrackNo or ExternOrderKey
                  GOTO Quit
               END

               DECLARE
                  @cShipperKey       NVARCHAR(15)

               IF @cOrderTrackNo <> ''
               BEGIN
                  SELECT @cOrderKey = OrderKey,
                     @cShipperKey = ISNULL(ShipperKey, ''),
                     @cType = Type
                  FROM dbo.ORDERS WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND TrackingNo = @cOrderTrackNo

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 247652
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid OrderTrackNo
                     GOTO Quit
                  END
               END
               ELSE IF @cExternOrderKey <> ''
               BEGIN
                  SELECT @cOrderKey = OrderKey,
                     @cShipperKey = ISNULL(ShipperKey, ''),
                     @cType = Type
                  FROM dbo.ORDERS WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND ExternOrderKey = @cExternOrderKey

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 247653
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid ExternOrderKey
                     GOTO Quit
                  END
               END

               IF @cType NOT IN ('B2C','INF')
               BEGIN
                  SET @nErrNo = 247654
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Order Type is not B2C or INF
                  GOTO Quit
               END

               SELECT
                  @cPickSlipNo = PickSlipNo
               FROM dbo.PackHeader WITH (NOLOCK)
               WHERE OrderKey = @cOrderKey
                  AND StorerKey = @cStorerKey

               IF @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 247655
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No PickSliNo found
                  GOTO Quit
               END

               DECLARE
                  @cPalletOrderShipperKey       NVARCHAR(15),
                  @cPalletOrderType             NVARCHAR(10)

               SELECT TOP 1
                  @cPalletOrderShipperKey = ISNULL(ORM.ShipperKey, ''),
                  @cPalletOrderType       = ORM.Type
               FROM dbo.PalletDetail PD WITH (NOLOCK)
               INNER JOIN dbo.PackDetail PKD WITH (NOLOCK)
                  ON PD.CaseID = PKD.LabelNo
                  AND PD.StorerKey = PKD.StorerKey
               INNER JOIN dbo.PackHeader PH WITH (NOLOCK)
                  ON PKD.PickSlipNo = PH.PickSlipNo
                  AND PKD.StorerKey = PH.StorerKey
               INNER JOIN dbo.ORDERS ORM WITH (NOLOCK)
                  ON PH.OrderKey = ORM.OrderKey
                  AND PH.StorerKey = ORM.StorerKey
               WHERE PD.PalletKey = @cPalletKey
                  AND PD.StorerKey = @cStorerKey

               IF @@ROWCOUNT > 0
               BEGIN
                  IF @cShipperKey <> @cPalletOrderShipperKey OR @cType <> @cPalletOrderType
                  BEGIN
                     SET @nErrNo = 247657
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different Order Type or ShipperKey
                     GOTO Quit
                  END
               END

               SET @cCapturePackInfo = ''
               IF @cCapturePackInfoSP <> ''
               BEGIN
                  -- Custom SP to get PackInfo setup
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cCapturePackInfoSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cCapturePackInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' + 
                        ' @cPalletKey, @cCaseID, @cLOC, @cSKU, @nQTY, ' +
                        ' @cCapturePackInfo  OUTPUT, ' +
                        ' @cCartonType       OUTPUT, ' +
                        ' @cWeight           OUTPUT, ' +
                        ' @cCube             OUTPUT, ' +
                        ' @cRefNo            OUTPUT, ' +
                        ' @nErrNo            OUTPUT, ' +
                        ' @cErrMsg           OUTPUT  '
                     SET @cSQLParam =
                        '@nMobile            INT,           ' +
                        '@nFunc              INT,           ' +
                        '@cLangCode          NVARCHAR( 3),  ' +
                        '@nStep              INT,           ' +
                        '@nInputKey          INT,           ' +
                        '@cFacility          NVARCHAR( 5),  ' +
                        '@cStorerKey         NVARCHAR( 15), ' +
                        '@cPalletKey         NVARCHAR( 30), ' +
                        '@cCaseID            NVARCHAR( 20), ' +
                        '@cLOC               NVARCHAR( 10), ' +
                        '@cSKU               NVARCHAR( 20), ' +
                        '@nQTY               INT, ' +
                        '@cCapturePackInfo   NVARCHAR( 3)  OUTPUT, ' +
                        '@cCartonType        NVARCHAR( 10) OUTPUT, ' +
                        '@cWeight            NVARCHAR( 10) OUTPUT, ' +
                        '@cCube              NVARCHAR( 10) OUTPUT, ' +
                        '@cRefNo             NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo             INT           OUTPUT, ' +
                        '@cErrMsg            NVARCHAR( 20) OUTPUT  ' 

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                        @cPalletKey, @cCaseID, @cLOC, @cSKU, @nQTY,
                        @cCapturePackInfo    OUTPUT,
                        @cCartonType         OUTPUT,
                        @cWeight             OUTPUT,
                        @cCube               OUTPUT,
                        @cRefNo              OUTPUT,
                        @nErrNo              OUTPUT,
                        @cErrMsg             OUTPUT
                  END
                  ELSE
                     -- Setup is non SP
                     SET @cCapturePackInfo = @cCapturePackInfoSP
               END

               -- Capture pack info (after)
               IF CHARINDEX( '2', @cCapturePackInfo) <> 0 AND -- Capture pack info (after)
                  (CHARINDEX( 'T', @cCapturePackInfo) <> 0 OR  -- CartonType
                  CHARINDEX( 'C', @cCapturePackInfo) <> 0 OR  -- Cube
                  CHARINDEX( 'W', @cCapturePackInfo) <> 0 OR  -- Weight
                  CHARINDEX( 'R', @cCapturePackInfo) <> 0)    -- RefNo
               BEGIN
                  -- Prepare LOC screen var
                  SET @cOutField01 = '' -- @cCartonType
                  SET @cOutField02 = '' -- @cWeight
                  SET @cOutField03 = '' -- @cCube
                  SET @cOutField04 = '' -- @cRefNo
            
                  -- Enable disable field
                  SET @cFieldAttr01 = CASE WHEN CHARINDEX( 'T', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END
                  SET @cFieldAttr02 = CASE WHEN CHARINDEX( 'W', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END
                  SET @cFieldAttr03 = CASE WHEN CHARINDEX( 'C', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END
                  SET @cFieldAttr04 = CASE WHEN CHARINDEX( 'R', @cCapturePackInfo) = 0 THEN 'O' ELSE '' END
                  SET @cFieldAttr08 = '' -- QTY
            
                  -- Position cursor
                  IF @cFieldAttr01 = '' AND @cOutField01 = ''  EXEC rdt.rdtSetFocusField @nMobile, 1 ELSE
                  IF @cFieldAttr02 = '' AND @cOutField02 = '0' EXEC rdt.rdtSetFocusField @nMobile, 2 ELSE
                  IF @cFieldAttr03 = '' AND @cOutField03 = '0' EXEC rdt.rdtSetFocusField @nMobile, 3 ELSE
                  IF @cFieldAttr04 = '' AND @cOutField04 = ''  EXEC rdt.rdtSetFocusField @nMobile, 4

                  -- Go to pack info screen
                  SET @nAfterScn = 2255
                  SET @nAfterStep = 6
                  
                  GOTO Quit
               END

               -- Handling transaction
               SET @nTranCount = @@TRANCOUNT
               IF @@TRANCOUNT = 0
                  BEGIN TRAN  -- Begin our own transaction
               ELSE
                  SAVE TRAN rdt_1638ExtScn01_scn6678 -- For rollback or commit only our own transaction

               BEGIN TRY
                  -- Confirm
                  EXEC rdt.rdt_Scan_To_Pallet_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
                     ,@cPalletKey       = @cPalletKey
                     ,@cLOC             = @cLOC
                     ,@cCaseID          = ''
                     ,@cCapturePackInfo = @cCapturePackInfo
                     ,@cCartonType      = @cCartonType
                     ,@cWeight          = ''
                     ,@cCube            = ''
                     ,@cRefNo           = ''
                     ,@cPickSlipNo      = @cPickSlipNo
                     ,@nCartonNo        = 1
                     ,@cSKU             = ''
                     ,@nQTY             = 0
                     ,@nErrNo           = @nErrNo  OUTPUT
                     ,@cErrMsg          = @cErrMsg OUTPUT
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 247656
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Confirm failed
                  GOTO ROLLBACK_SCN6678
               END CATCH

               IF @nErrNo <> 0
               BEGIN
                  GOTO ROLLBACK_SCN6678
               END

               IF @@TRANCOUNT > @nTranCount
               BEGIN
                  IF XACT_STATE() = 1
                  BEGIN
                     COMMIT TRANSACTION
                  END
                  ELSE
                  BEGIN
                     -- If XACT_STATE() is 0 or -1, the transaction is not committable.
                     -- In this case, a rollback might be necessary if XACT_STATE() is -1.
                     ROLLBACK TRANSACTION -- This will only execute if there's an active transaction (XACT_STATE() = -1).
                  END
               END

               GOTO Quit

               ROLLBACK_SCN6678:
                  IF @nTranCount = 0
                  BEGIN
                     ROLLBACK TRANSACTION
                  END
                  ELSE
                  BEGIN
                     IF XACT_STATE() <> -1
                        ROLLBACK TRANSACTION rdt_1638ExtScn01_scn6678
                  END
            END
            ELSE IF @nInputKey = 0
            BEGIN
               IF @cSkipPrintPackList = '1'
               BEGIN
                  IF @cClosePallet = '1'
                  BEGIN
                     -- Prep next screen var
                     SET @cOutField01 = ''   -- Option

                     -- Go to Close Pallet screen
                     SET @nAfterScn = 2256
                     SET @nAfterStep = 7
                  END
                  ELSE
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = '' -- PalletKey
                     SET @cOutField02 = @cLOC

                     -- Go to PalletKey screen
                     SET @nAfterScn = 2250
                     SET @nAfterStep = 1
                  END
               END
               ELSE
               BEGIN
                  -- Go to next screen
                  SET @nAfterScn = 2253
                  SET @nAfterStep = 4

                  SET @cOutField01 = ''   -- Option
               END
            END
         END
      END
   END

   GOTO Quit

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1638ExtScn01 to nSQL
GO
