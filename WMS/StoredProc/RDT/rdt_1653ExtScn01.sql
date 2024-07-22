SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1653ExtScn01                                    */
/* Copyright      :  Maersk                                             */
/*                                                                      */
/* Purpose:       FCR-539                                               */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2024-07-08 1.0  CYU027   CREATE                                      */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1653ExtScn01] (
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
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
   @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
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
      @nTranCount             INT,
      @cSuggPalletKey         NVARCHAR( 20),
      @cPalletKey             NVARCHAR( 20),
      @cTrackNo               NVARCHAR( 40),
      @cOrderKey              NVARCHAR( 10),
      @cMBOLKey               NVARCHAR( 10),
      @cLane                  NVARCHAR( 30),
      @cLabelNo               NVARCHAR( 20),
      @cSuggestLoc            NVARCHAR( 1),
      @cOverrideLoc           NVARCHAR( 1),
      @cOption                NVARCHAR( 1),
      @tCreateMBOLVar         VARIABLETABLE

   SELECT
      @cLabelNo               = V_String1,
      @cMBOLKey               = V_String3,
      @cSuggestLoc            = V_String29,
      @cOverrideLoc           = V_String30,
      @cTrackNo               = V_String41,
      @cOrderKey              = V_OrderKey,
      @cLane                  = V_String42

   FROM rdt.RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cOption = @cInField02

   IF @nFunc = 1653
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @cOption <> '1' AND @nInputKey = 1
         BEGIN

            SET @cFieldAttr05 = ''
            --FCR-539 Pallet Found, loc uneditable
            IF @cPalletKey <> 'NEW PALLET' AND @cPalletKey <> ''
               BEGIN
                  SET @cFieldAttr05 = 'O'
               END
            ELSE
               --FCR-539 Pallet not Found, loc found, uneditable
               BEGIN
                  --Do not suggest LOC
                  IF @cSuggestLoc <> '1'
                     SET @cLane = ''
                  --Do not override LOC
                  IF @cOverrideLoc = '0' AND @cLane <> ''
                     SET @cFieldAttr05 = 'O'
               END

            SET @cInField05 = @cLane
            SET @cOutField05 = @cLane
            SET @nStep = 99
            SET @nScn = 5807
            GOTO Quit
         END
      END


      IF @nStep = 99
      BEGIN
         IF @nInputKey = 1 -- Yes or Send
         BEGIN
            /********************************************************************************
               Scn = 5807. SCAN TO LOC/LANE
                  TRACK NO          (field01)
                  ORDERKEY          (field02)
                  SCAN TO PALLET:   (field04, input)
                  SCAN PALLET:      (field03)
                  LOC/LANE:         (field05, input)
            ********************************************************************************/
            -- Initialize value
            SET @cSuggPalletKey = @cOutField03
            SET @cPalletKey = @cInField04

            IF ISNULL(@cOverrideLoc,'0') <> '1' AND @cLane <> @cInField05 AND ISNULL(@cLane,'') <> ''
            BEGIN
               SET @nErrNo = 219151
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --cannot override location
               GOTO Step_ShowPalletID_Fail
            END

            IF ISNULL( @cPalletKey, '') = ''
            BEGIN
               SET @nErrNo = 219152
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Pallet ID
               GOTO Step_ShowPalletID_Fail
            END

            -- Check barcode format
            IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'PalletKey', @cPalletKey) = 0
            BEGIN
               SET @nErrNo = 219153
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
               GOTO Step_ShowPalletID_Fail
            END


            IF @cSuggPalletKey <> @cPalletKey AND @cSuggPalletKey <> 'NEW PALLET'
            BEGIN
               SET @nErrNo = 219154
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Not Match
               GOTO Step_ShowPalletID_Fail
            END

            IF ISNULL(@cInField05,'') = ''
            BEGIN
               SET @nErrNo = 219156
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location is required
               GOTO Step_ShowPalletID_Fail
            END

            IF NOT EXISTS ( SELECT 1
                            FROM dbo.LOC WITH (NOLOCK)
                            WHERE LOC = @cInField05
                            AND Facility = @cFacility)
            BEGIN
               SET @nErrNo = 219155
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC NOT FOUND
               GOTO Step_ShowPalletID_Fail
            END

            SET @nTranCount = @@TRANCOUNT
            BEGIN TRAN  -- Begin our own transaction
            SAVE TRAN rdt_CreateMbol -- For rollback or commit only our own transaction

            SET @nErrNo = 0
            EXEC [RDT].[rdt_TrackNo_SortToPallet_CreateMbol]
                 @nMobile       = @nMobile,
                 @nFunc         = @nFunc,
                 @cLangCode     = @cLangCode,
                 @nStep         = @nStep,
                 @nInputKey     = @nInputKey,
                 @cFacility     = @cFacility,
                 @cStorerKey    = @cStorerKey,
                 @cTrackNo      = @cTrackNo,
                 @cOrderKey     = @cOrderKey,
                 @cPalletKey    = @cPalletKey,
                 @cMBOLKey      = @cMBOLKey,
                 @cLane         = @cInField05,
                 @cLabelNo      = @cLabelNo,
                 @tCreateMBOLVar= @tCreateMBOLVar,
                 @nErrNo        = @nErrNo      OUTPUT,
                 @cErrMsg       = @cErrMsg     OUTPUT

            IF @nErrNo <> 0
               ROLLBACK TRAN rdt_CreateMbol
            ElSE
               COMMIT TRAN rdt_CreateMbol
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN

            IF @nErrNo <> 0
               GOTO Quit

            -- Prep next screen var
            SET @cOutField01 = '' -- Track No
            SET @cOutField02 = '' -- Option

            EXEC rdt.rdtSetFocusField @nMobile, 1

            SET @nAfterScn = 5800
            SET @nAfterStep = 1


            GOTO Quit

         END

         IF @nInputKey = 0 -- Esc or No
         BEGIN
            -- Initialize value
            SET @cTrackNo = ''
            SET @cOrderKey = ''

            -- Prep next screen var
            SET @cOutField01 = '' -- Track No
            SET @cOutField02 = ''

            SET @nAfterScn = 5800
            SET @nAfterStep = 1
         END
      END

      Step_ShowPalletID_Fail:
      BEGIN
         SET @cPalletKey = ''
         SET @cOutField04 = ''
      END
   END
Quit:
END;

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1653ExtScn01 TO NSQL
GO
