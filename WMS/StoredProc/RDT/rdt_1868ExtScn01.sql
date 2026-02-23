SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_1868ExtScn01                                    */
/*                                                                      */
/* Purpose:       Extended Screen Logic for Serial Unpack (FCR-10102)   */
/*                                                                      */
/* Date        Rev   Author     Purposes                                */
/* 2026-02-19  1.0   NYE018     FCR-10102 Create Screen 2A Logic        */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1868ExtScn01] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nScn         INT,           
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
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @cLottable13 NVARCHAR( 30) OUTPUT, 
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @cLottable14 NVARCHAR( 30) OUTPUT, 
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @cLottable15 NVARCHAR( 30) OUTPUT, 

   @nAction      INT           OUTPUT,  
   @nAfterScn    INT           OUTPUT,  
   @nAfterStep   INT           OUTPUT,  
   @nErrNo       INT           OUTPUT,  
   @cErrMsg      NVARCHAR( 80) OUTPUT,

   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT, @cUDF04 NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT,
   @cUDF06  NVARCHAR( 250) OUTPUT, @cUDF07 NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT, @cUDF10 NVARCHAR( 250) OUTPUT,
   @cUDF11  NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT, @cUDF13 NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT, @cUDF19 NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT,
   @cUDF21  NVARCHAR( 250) OUTPUT, @cUDF22 NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT, @cUDF25 NVARCHAR( 250) OUTPUT,
   @cUDF26  NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT, @cUDF28 NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   
   DECLARE @nTranCount INT = @@TRANCOUNT
   DECLARE @cPickSlipNo NVARCHAR(20)
   DECLARE @cCurrentUnPackType NVARCHAR(60)
   DECLARE @cLastInput NVARCHAR(100)
   DECLARE @cSKU NVARCHAR(60)


   -- Initialize
   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 1868
   BEGIN
      
      -- Retrieve current state from mob rec
      SELECT 
         @cPickSlipNo = V_PickSlipNo,
         @cCurrentUnPackType = V_String1
      FROM rdt.rdtMobRec WITH (NOLOCK)
      WHERE Mobile = @nMobile 

      -- Redirect from Screen 2 (Confirm Unpack, Option 1)
      IF @nScn = 6512 
      BEGIN
         -- Update State to '1' (Unpack) for later Back logic
         UPDATE rdt.rdtMobRec SET V_String1 = '1' WHERE Mobile = @nMobile
         
         SET @nAfterScn = 6841
         SET @nAfterStep = 99
         SET @cOutField03 = 'UnPack'
         SET @cOutField01 = '' -- Clear SKU Input
         GOTO Quit
      END

      -- Redirect from Screen 3 (Location Scan)
      IF @nScn = 6513 
      BEGIN
         SELECT @cLastInput = Value FROM @tExtScnData WHERE Variable = '@cOption'
         
         -- Update State to '2' (Unpack & Unpick) and save Location
         UPDATE rdt.rdtMobRec SET V_String1 = '2', V_Loc = @cLastInput WHERE Mobile = @nMobile
         
         SET @nAfterScn = 6841
         SET @nAfterStep = 99
         SET @cOutField03 = 'UnPack And UnPick'
         SET @cOutField01 = '' 
         GOTO Quit
      END

      -- Back Logic from Step 4 (Screen 6514) -> Redirect to Screen 2A (6841)
      IF @nScn = 6514 AND @nInputKey = 0
      BEGIN
         -- When user presses ESC on Serial Scan (Step 4), return to SKU Scan (Step 99 / Scn 6841)
         
         SET @nAfterScn = 6841
         SET @nAfterStep = 99
         SET @cOutField01 = '' 
         
         IF @cCurrentUnPackType = '2'
             SET @cOutField03 = 'UnPack And UnPick'
         ELSE
             SET @cOutField03 = 'UnPack'

         GOTO Quit
      END

      -- ------------------------------------------------------------------------------------
      -- Screen 2A Logic (Scn 6841)
      -- SKU:
      -- 
      -- ------------------------------------------------------------------------------------
      IF @nScn = 6841
      BEGIN
         
         -- (Enter Key)
         IF @nInputKey = 1 
         BEGIN

            SET @cSKU = @cInField01
            -- 1. Check Empty
            IF @cSKU = ''
            BEGIN
               SET @nErrNo = 259352 
               SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- Invalid SKU
               GOTO Quit 
            END

            -- 2. Validate SKU against PickSlip
            IF NOT EXISTS (
               SELECT 1 
               FROM dbo.PackSerialNo WITH(NOLOCK) 
               WHERE PickSlipNo = @cPickSlipNo 
                 AND StorerKey = @cStorerKey
                 AND SKU = @cSKU
            )
            BEGIN
               SET @nErrNo = 259351 
               SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, 'DSP') -- SKU not in PickSlip
               GOTO Quit 
            END

            -- 3. Success -> Go to Screen 4
            SET @nAfterScn = 6514
            SET @nAfterStep = 4
            
            -- Ensure Screen 4 header is correct
            IF @cCurrentUnPackType = '1' SET @cOutField03 = 'UnPack'
            ELSE SET @cOutField03 = 'UnPack And UnPick'
            
            -- Screen 4 starts with empty serial scan
            SET @cOutField01 = '' 

            UPDATE RDT.rdtMobRec SET V_SKU = @cSKU WHERE Mobile = @nMobile

            GOTO Quit
         END
         
         -- (ESC Key)
         ELSE IF @nInputKey = 0 
         BEGIN
            IF @cCurrentUnPackType = '2'
            BEGIN
               -- Go back to Step 3 (Location Scan)
               SET @nAfterScn = 6513
               SET @nAfterStep = 3
               SET @cOutField03 = 'UnPack And UnPick'
               SET @cOutField02 = ''
            END
            ELSE
            BEGIN
               -- Default: Go back to Step 2 (Unpack Confirm)
               SET @nAfterScn = 6512
               SET @nAfterStep = 2
               SET @cOutField03 = 'UnPack'
            END
         END

         GOTO Quit
      END
   END

Quit:
   
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1868ExtScn01] TO NSQL
GO