
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_803ExtScn03                                       */
/* Copyright      : Maersk                                                */
/* Customer       : ONBR                                                  */
/*                                                                        */
/* Date       Rev    Author   Purposes                                    */
/* 2025-11-27 1.0.0  Cuize    FCR-9003 Created                            */
/**************************************************************************/
  
CREATE OR ALTER PROC [RDT].[rdt_803ExtScn03] (
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
   @nAction          INT, 
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
      @nCurrentScn      INT,
      @nCurrentStep     INT,
      @cOption          NVARCHAR( 10),
      @cStation         NVARCHAR( 10),
      @cCartID          NVARCHAR( 10),
      @cMethod          NVARCHAR( 1),
      @cDeviceID        NVARCHAR( 20),
      @nMenu            INT


   SELECT
   @nCurrentScn = Scn,
   @nCurrentStep = Step,
   @cDeviceID  = DeviceID,
   @cStation = V_String1,
   @cMethod  = V_String2,
   @cCartID = V_String42,
   @nMenu      = Menu

   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile


   IF @nFunc = 803
   BEGIN
      IF @nCurrentStep = 1 -- If Next Step is Confirm Unassign
      BEGIN

         SET @cStation = @cInField01

         SET @nAfterScn = 6706
         SET @nAfterStep = 99
         GOTO Quit
      END
   
      IF @nCurrentStep = 99 -- Customize Step Screen
      BEGIN
         IF @nCurrentScn = 6706 -- scn 1A
         BEGIN

            IF @nInputKey = 0
            BEGIN

               SET @cOutfield01 = @cStation
               SET @cOutfield02 = @cMethod

               SET @nAfterStep = 1
               SET @nAfterScn = 4590

            END


            IF @nInputKey = 1
            BEGIN
               SET @cCartID = @cInField01

               -- Check station valid
               IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'CART' AND DeviceID <> '' AND DeviceID = @cCartID)
               BEGIN
                  SET @nErrNo = 252851
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidCartID
                  SET @cOutField01 = ''
                  GOTO Quit
               END

   --             -- Check station valid
   --             IF EXISTS(
   --                SELECT 1 FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
   --                WHERE  UserDefine01  = @cCartID
   --                  AND   Storerkey = @cStorerKey
   --                  AND   station <> @cStation
   --             )
   --             BEGIN
   --                SET @nErrNo = 252852
   --                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cart is not empty
   --                SET @cOutField01 = ''
   --                GOTO Quit
   --             END

               IF EXISTS(
                  SELECT 1 FROM rdt.RDTPTLPIECELOG WITH (NOLOCK)
                           WHERE station = @cStation
                             AND UserDefine01 <> @cCartID
               )
               BEGIN
                  SET @nErrNo = 252853
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Station assigned with different cart
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               IF NOT EXISTS(
                  SELECT 1 FROM rdt.RDTPTLPIECELOG WITH (NOLOCK)
                  WHERE station = @cStation
                    AND UserDefine01 <> @cCartID
               ) -- cart already Unassinged
               AND EXISTS(
                  SELECT 1 FROM LOTxLOCxID
                     WHERE ID LIKE @cCartID + '%'
                     AND QTY > 0
               ) --CART has inventory
               BEGIN
                  SET @nErrNo = 252860
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cart is not empty
                  SET @cOutField01 = ''
                  GOTO Quit
               END


               IF EXISTS(
                  SELECT 1
                  FROM rdt.RDTPTLPIECELOG WITH (NOLOCK)
                  WHERE  UserDefine01 = @cCartID
                  AND Station <> @cStation)
               BEGIN
                  SET @nErrNo = 252854
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cart assigned to another station
                  SET @cOutField01 = ''
                  GOTO Quit
               END

               -- Dynamic assign
               EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
                    @cStation, @cMethod, 'POPULATE-IN',
                    @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                    @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                    @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                    @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                    @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                    @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                    @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                    @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                    @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                    @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                    @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                    @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                    @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                    @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                    @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                    @nAfterScn        OUTPUT,
                    @nErrNo      OUTPUT,
                    @cErrMsg     OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit


               SET @nAfterStep = 2
            END

         END

      END
   END

   IF @nFunc = @nMenu
   BEGIN
      SET @cStation = ''
   END

   
   GOTO Quit

Quit:

   SET @cUDF07 = @cCartID
   SET @cUDF08 = @cStation

END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_803ExtScn03 TO NSQL
GO
