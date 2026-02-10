SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_1653ExtScn01                                        */
/* Copyright      :  Maersk                                                 */
/*                                                                          */
/* Purpose:       FCR-539                                                   */
/*                                                                          */
/* Date       Rev    Author   Purposes                                      */
/* 2024-07-08 1.0    CYU027   CREATE                                        */
/****************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1829ExtScn01] (
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

   DECLARE
      @cReceiptKey            NVARCHAR(10) ,
      @cUCC                   NVARCHAR( 20),
      @cLOC                   NVARCHAR( 10),
      @cParamLabel1           NVARCHAR( 20),
      @cParamLabel2           NVARCHAR( 20),
      @cParamLabel3           NVARCHAR( 20),
      @cParamLabel4           NVARCHAR( 20),
      @cParamLabel5           NVARCHAR( 20),
      @cRetainParm1Value      NVARCHAR( 1),
      @cRetainParm2Value      NVARCHAR( 1),
      @cRetainParm3Value      NVARCHAR( 1),
      @cRetainParm4Value      NVARCHAR( 1),
      @cRetainParm5Value      NVARCHAR( 1),
      @cParam1                NVARCHAR( 20),
      @cParam2                NVARCHAR( 20),
      @cParam3                NVARCHAR( 20),
      @cParam4                NVARCHAR( 20),
      @cParam5                NVARCHAR( 20)


   SELECT
      @nScn                   = Scn,
      @nStep                  = Step,
      @cReceiptKey            = V_String1,
      @cParam1                = V_String1,
      @cParam2                = V_String2,
      @cParam3                = V_String3,
      @cParam4                = V_String4,
      @cParam5                = V_String5,
      @cParamLabel1           = V_String6,
      @cParamLabel2           = V_String7,
      @cParamLabel3           = V_String8,
      @cParamLabel4           = V_String9,
      @cParamLabel5           = V_String10,
      @cRetainParm1Value      = V_String18,
      @cRetainParm2Value      = V_String19,
      @cRetainParm3Value      = V_String20,
      @cRetainParm4Value      = V_String21,
      @cRetainParm5Value      = V_String22
   FROM rdt.RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile


   IF @nFunc = 1829
   BEGIN
      IF @nStep = 1
      BEGIN
         --Scan next UCC
         SET @cInField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''

         SET @nAfterStep = 99
         SET @nAfterScn = 6623
         GOTO Quit

      END

      IF @nStep = 99
      BEGIN

         IF @nScn = 6623
         /***************************************/
         /*     Scn = 6623.Loop UCC             */
         /*             UCC:                    */
         /*       (field01, input)              */
         /*          Scanned UCC:               */
         /*       (field02, output)             */
         /*          UCC Position               */
         /*       (field03, output)             */
         /***************************************/
         BEGIN
            IF @nInputKey = 1 -- Enter
            BEGIN

               SET @cUCC = @cInField01

               SELECT TOP 1 @cLOC = UserDefine02
                  FROM ReceiptDetail WITH(NOLOCK )
               WHERE UserDefine01 = @cUCC
                  AND ReceiptKey = @cReceiptKey
                  AND StorerKey = @cStorerKey

               IF @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 241101
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 241101UCC does not exist in ASN
                  GOTO UCC_Failed
               END

               --Scan next UCC
               SET @cInField01 = ''
               SET @cOutField02 = @cUCC
               SET @cOutField03 = @cLOC

               SET @nAfterStep = 99
               SET @nAfterScn = 6623
               GOTO Quit
            END

            IF @nInputKey = 0 -- 'ESC'
            BEGIN

               -- Enable / disable field
               SET @cFieldAttr02 = CASE WHEN @cParamLabel1 = '' THEN 'O' ELSE '' END
               SET @cFieldAttr04 = CASE WHEN @cParamLabel2 = '' THEN 'O' ELSE '' END
               SET @cFieldAttr06 = CASE WHEN @cParamLabel3 = '' THEN 'O' ELSE '' END
               SET @cFieldAttr08 = CASE WHEN @cParamLabel4 = '' THEN 'O' ELSE '' END
               SET @cFieldAttr10 = CASE WHEN @cParamLabel5 = '' THEN 'O' ELSE '' END

               -- Clear optional in field
               SET @cInField02 = ''
               SET @cInField04 = ''
               SET @cInField06 = ''
               SET @cInField08 = ''
               SET @cInField10 = ''

               -- Prepare next screen var
               SET @cOutField01 = @cParamLabel1
               SET @cOutField02 = CASE WHEN @cRetainParm1Value = '1' THEN @cParam1 ELSE '' END
               SET @cOutField03 = @cParamLabel2
               SET @cOutField04 = CASE WHEN @cRetainParm1Value = '1' THEN @cParam2 ELSE '' END
               SET @cOutField05 = @cParamLabel3
               SET @cOutField06 = CASE WHEN @cRetainParm1Value = '1' THEN @cParam3 ELSE '' END
               SET @cOutField07 = @cParamLabel4
               SET @cOutField08 = CASE WHEN @cRetainParm1Value = '1' THEN @cParam4 ELSE '' END
               SET @cOutField09 = @cParamLabel5
               SET @cOutField10 = CASE WHEN @cRetainParm1Value = '1' THEN @cParam5 ELSE '' END

               SET @nAfterStep = 1
               SET @nAfterScn = 4980
               GOTO Quit
            END
            GOTO Quit

            UCC_Failed:
               SET @cInField01 = ''
               SET @cOutField02 = @cOutField02
               SET @cOutField03 = @cOutField03
               GOTO Quit


         END
      END
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1829ExtScn01 TO NSQL
GO
