
/****** Object:  StoredProcedure [RDT].[rdt_605ExtScn04]    Script Date: 10/30/2024 9:12:06 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_605ExtScn04                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:       For AMZDGL                                            */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-06-18 1.0  CYU027   Created                                     */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605ExtScn04] (
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
   @cErrMsg          NVARCHAR( 1024)  OUTPUT,
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


   DECLARE  @cToLoc              NVARCHAR(10),
            @cChkFacility        NVARCHAR( 5),
            @cReceiptKey         NVARCHAR( 10),
            @cRefNo              NVARCHAR( 20),
            @nCurrentScanned     INT


   SET @nAfterScn = @nScn
   SET @nAfterStep = @nStep

   SELECT
      --@cLott10 = C_String1,
      --@cPalletTypeSave = C_String2,
      --@cSKUReceived = C_String3
      @nCurrentScanned = V_Integer4,

      @nCurrentScanned  = V_Integer4,
      @cReceiptKey      = V_ReceiptKey,
      @cRefNo           = V_String21,
      @cToLoc           = V_String27,
      @nStep            = Step,
      @nScn             = Scn
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nFunc = 605
   BEGIN
      IF @nStep = 1 --ASN Scn
      BEGIN
         IF @nInputKey = 1 --'ENTER'
         BEGIN

            DECLARE @cDefaultToLoc  NVARCHAR( 10) = ''

            SET @cDefaultToLoc = rdt.RDTGetConfig( @nFunc, 'DefaultToLoc', @cStorerKey)
            IF @cDefaultToLoc = '0'
               SET @cDefaultToLoc = ''

            -- Prepare next screen var
            SET @cOutField01 = @cReceiptKey
            SET @cOutField02 = @cRefNo
            SET @cOutField03 = @cDefaultToLoc -- TOLoc
            SET @nCurrentScanned=0


            -- Go to next screen
            SET @nAfterScn = 6621
            SET @nAfterStep = 99

         END
      END

      IF @nStep = 99
      BEGIN
         IF @nInputKey = 1 --'ENTER'
         BEGIN
            SET @cToLoc = @cInField03

            IF @cToLoc = ''
            BEGIN
               SET @nErrNo = 240501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC Required
               GOTO Quit
            END

            -- Get LOC info
            SELECT @cChkFacility = Facility FROM LOC WITH (NOLOCK) WHERE LOC = @cToLoc

            -- Check LOC valid
            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 240502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid LOC
               GOTO Quit
            END

            -- Check different facility
            IF @cChkFacility <> @cFacility
            BEGIN
               SET @nErrNo = 240503
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff facility
               GOTO Quit
            END

            -- Prepare next screen var
            SET @cOutField01 = @cReceiptKey
            SET @cOutField02 = @cRefNo
            SET @cOutField03 = '' -- ID
            SET @nCurrentScanned=0

            -- Go to next screen
            SET @nScn = @nScn + 1
            SET @nStep = @nStep + 1

            SET @nAfterStep = 2
            SET @nAfterScn = 4251

            --OUTPUT
            SET @cUDF01 = @cToLoc
            SET @cUDF02 = @nCurrentScanned

         END

         IF @nInputKey = 0 --'ESC'
         BEGIN
            SET @cOutField01 = ''
            SET @cOutField02 = ''

            IF @cReceiptKey <> ''
               EXEC rdt.rdtSetFocusField @nMobile, 1 -- ASN
            ELSE
               EXEC rdt.rdtSetFocusField @nMobile, 2 -- RefNo

            SET @nAfterStep = 1
            SET @nAfterScn = 4250
         END
      END

   END


Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


GRANT EXECUTE ON rdt.rdt_605ExtScn04 TO NSQL
GO
