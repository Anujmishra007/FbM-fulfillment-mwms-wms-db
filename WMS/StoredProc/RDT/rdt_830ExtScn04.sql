
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_830ExtScn04                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:       FCR-330                                               */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-01-13 1.0  Cuize   CREATE                                      */
/*                                                                      */
/************************************************************************/

ALTER   PROC [RDT].[rdt_830ExtScn04] (
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

   DECLARE @cSKU NVARCHAR(20)
   DECLARE    @cLottableCode NVARCHAR( 20)

   SELECT    @cSKU         = V_SKU,
             @cLottableCode    = V_String3
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @nMorePage    INT


   IF @nFunc = 830
      BEGIN
         IF @nStep = 8 -- Verify Lottable
            BEGIN
               IF @nInputKey = 1 -- ENTER
                  BEGIN

                     -- Dynamic lottable
                     EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, 1, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'PRECAPTURE', 'POPULATE', 5, 1,
                          @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                          @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                          @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                          @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                          @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                          @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                          @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                          @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                          @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                          @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                          @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                          @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                          @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                          @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                          @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                          @nMorePage   OUTPUT,
                          @nErrNo      OUTPUT,
                          @cErrMsg     OUTPUT,
                          '',      -- SourceKey
                          @nFunc   -- SourceType

                  END
            END
      END
   Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_830ExtScn04 TO NSQL
GO
 
 
